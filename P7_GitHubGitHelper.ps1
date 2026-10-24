<#PSScriptInfo
.VERSION 0.0.0.11
.GUID 7b8e3f4a-5c6d-789e-bc01-345678901abc
.AUTHOR Thomas Dobler - tom@synthetixmind.com - SYNTHETIXMIND LTD
.COMPANYNAME SYNTHETIXMIND LTD
.COPYRIGHT (C) 2026 by SYNTHETIXMIND LTD - All rights reserved
.TAGS GitHub, Git, Repository, Automation
.LICENSEURI
.PROJECTURI
.ICONURI
.EXTERNALMODULEDEPENDENCIES
.REQUIREDSCRIPTS
.EXTERNALSCRIPTDEPENDENCIES
.RELEASENOTES

Change History of this Script by Schema Major.Minor.Build.Revision,only Major Versions should be used in production
Version     |Type      |Date (Y/M/D)   |User                |Note
0.0.0.1     |Build     |2024/12/30     |Thomas Dobler       |Initial script creation for GitHub Git automation converted from Azure DevOps version
0.0.0.2     |Build     |2024/12/30     |Thomas Dobler       |Modified to use current directory as RepoPath, removed RepoUrl and cloning functionality
0.0.0.3     |Build     |2024/12/30     |Thomas Dobler       |Fixed remote URL parsing, added better error handling, improved credential setup, added .git suffix to remote URLs
0.0.0.4     |Build     |2024/12/30     |Thomas Dobler       |Fixed GitHub PAT token formatting issue by cleaning special characters and using remote remove/add approach
0.0.0.5     |Build     |2026/01/11     |Thomas Dobler       |Added $Message and $ForceResolve parameters to allow direct commit message and skip conflict resolution prompts
0.0.0.6     |Build     |2026/06/11     |Thomas Dobler       |Removed broken 'credential.helper manager-core' global config; pull/push now run with '-c credential.helper=' (auth via PAT-in-URL), silencing the 'credential-manager-core is not a git command' warning
0.0.0.7     |Build     |2026/06/23     |Thomas Dobler       |Removed hardcoded PAT; PAT now read from $env:PS_Repo_Automation (set as Windows env var locally or GitHub Actions secret in CI)
0.0.0.8     |Build     |2026/06/24     |Thomas Dobler       |Suppress credential-manager-core noise: pipe pull/push stderr through noise filter; git config calls silenced with 2>$null; git stash uses --quiet
0.0.0.9     |Build     |2026/06/24     |Thomas Dobler       |Restructured flow: pull now happens at the beginning (stash -> pull -> pop -> stage -> commit -> push); removed redundant double-staging
0.0.0.10    |Build     |2026/07/07     |Thomas Dobler       |Security: PAT no longer persisted in .git/config. Remote is normalised to a token-free URL; pull/push authenticate transiently via in-memory http.extraHeader (base64 x-access-token:PAT). Self-heals poisoned remotes; auth vars cleared in finally.
0.0.0.11    |Build     |2026/09/01     |Thomas Dobler       |After a successful push, verify the structure-sync workflow actually fired for the pushed SHA and dispatch it manually if the commit matched no path in the workflow's paths: filter. Guarded to TemplateClaudeStructure so the check is a no-op in every synced target repo.
#>

# .FILENAME P7_GitHubGitHelper.ps1

# Requires -Module $null
<# 
.DESCRIPTION 
 This script helps automate the process of adding, committing, and pushing changes to a GitHub repository.
 It assumes the script is run from within an already initialized Git repository directory,
 sets up git global configuration, configures credentials, stashes local changes, pulls remote updates, 
 applies stashed changes, and guides through the commit process.
#> 

param(
    [Parameter(Mandatory = $false)]
    [string]$Message,
    
    [Parameter(Mandatory = $false)]
    [bool]$ForceResolve = $true
)

# Variable declarations
$UserName = "synthetixmind"  # GitHub username - will be prompted if empty
$GITHUB_PAT = $env:PS_Repo_Automation          # Read from env var (set locally) or GitHub Actions secret in CI — prompted if empty
$UserFullName = "Thomas Dobler"  # Full Name like 'John Doe' - will be prompted if empty
$UserEmail = "github@synthetixmind.com"  # Email address like 'john.doe@company.com' - will be prompted if empty
$RepoPath = Get-Location  # Current directory as repository path
$BranchName = "main"  # Default branch name (main or master)

# Repo that owns the structure-sync workflow. The post-push sync check below runs
# ONLY there: this script is itself copied into every sync target, so an unguarded
# check would fire `gh workflow run` against 22 repos that have no such workflow.
$SyncSourceRepo = "SYNTHETIXMIND/TemplateClaudeStructure"
$SyncWorkflow   = "sync-to-targets.yml"

# Tracks whether we overwrote GH_TOKEN, so `finally` restores it only if we did
# (blindly clearing it would clobber a token the caller set for their own use).
$GhTokenWasSet = $false
$PrevGhToken   = $null

# Main script execution
try {
    Write-Host "GitHub Git Helper Script" -ForegroundColor Green
    Write-Host "========================" -ForegroundColor Green
    
    # Verify we are in a Git repository
    if (-not (Test-Path -Path ".git")) {
        throw "This directory is not a Git repository. Please run this script from within an initialized Git repository directory."
    }
    
    Write-Host "Current repository directory: $RepoPath" -ForegroundColor Green
    
    # Prompt for credentials if not set
    if ([string]::IsNullOrEmpty($UserName)) {
        $UserName = Read-Host "Enter your GitHub username"
    }
    
    if ([string]::IsNullOrEmpty($GITHUB_PAT)) {
        $SecurePAT = Read-Host "Enter your GitHub Personal Access Token" -AsSecureString
        $GITHUB_PAT = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecurePAT))
    }
    
    if ([string]::IsNullOrEmpty($UserFullName)) {
        $UserFullName = Read-Host "Enter your full name (e.g. 'John Doe')"
    }
    
    if ([string]::IsNullOrEmpty($UserEmail)) {
        $UserEmail = Read-Host "Enter your email address (e.g. 'john.doe@company.com')"
    }
    
    # Set your identity
    Write-Host "Setting up Git global configuration..." -ForegroundColor Yellow
    git config --global user.name "$UserFullName" 2>$null
    git config --global user.email "$UserEmail" 2>$null

    # NOTE: deliberately NO credential.helper here. Auth is supplied transiently via an
    #       in-memory `-c http.extraHeader` on each pull/push (built below); network ops also
    #       run with `-c credential.helper=` so git never invokes a (possibly absent)
    #       credential-manager-core binary. The PAT is never written to .git/config.
    Write-Host "Setting additional Git configuration for GitHub..." -ForegroundColor Yellow
    git config --global push.default simple 2>$null
    git config --global pull.rebase false 2>$null
    Write-Host "Git configuration completed." -ForegroundColor Green
    
    # Normalise the remote to a CLEAN, token-free URL.
    # WHY: the PAT must NEVER be persisted to .git/config. Earlier versions embedded the
    #      token in the remote URL (https://user:token@github.com/...), writing it to disk
    #      and re-poisoning the remote on every run. We now keep the stored remote token-free
    #      and authenticate transiently via an in-memory Authorization header (see
    #      $ExtraHeaderArg) passed with `git -c` at pull/push time. Rewriting the remote to a
    #      clean URL here also SELF-HEALS any remote that was previously poisoned with a token.
    Write-Host "Normalising remote URL (removing any embedded credentials)..." -ForegroundColor Yellow
    $CurrentRemote = git remote get-url origin
    # Strip any embedded `user:token@` segment so a leaked token is never printed to the console.
    $BareRemote    = $CurrentRemote -replace "://[^@/]+@", "://"
    Write-Host "Current remote URL: $BareRemote" -ForegroundColor Cyan

    # Parse owner/repo from the credential-free remote (covers https and git@ SSH forms).
    $RepoOwner = $null
    $RepoName  = $null
    if ($BareRemote -match "github\.com[:/]([^/]+)/([^/]+?)(?:\.git)?/?$") {
        $RepoOwner = $matches[1] -replace "[^a-zA-Z0-9\-_\.]", ""
        $RepoName  = ($matches[2] -replace "\.git$", "") -replace "[^a-zA-Z0-9\-_\.]", ""
    }

    if (-not ($RepoOwner -and $RepoName)) {
        Write-Warning "Could not parse remote URL: $BareRemote"
        $ManualSetup = Read-Host "Enter the repository owner and name manually? (y/n)"
        if ($ManualSetup -eq 'y' -or $ManualSetup -eq 'Y') {
            $RepoOwner = Read-Host "Enter repository owner (username/organization)"
            $RepoName  = Read-Host "Enter repository name"
        }
    }

    if (-not ($RepoOwner -and $RepoName)) {
        throw "Could not determine repository owner/name; cannot configure the remote."
    }

    # Token-free canonical URL — auth is supplied transiently, never written to disk.
    $CleanRemoteUrl = "https://github.com/$RepoOwner/$RepoName.git"
    git remote set-url origin $CleanRemoteUrl 2>$null
    if ($LASTEXITCODE -ne 0) {
        git remote remove origin 2>$null
        git remote add origin $CleanRemoteUrl
    }
    Write-Host "Remote set (token-free): $CleanRemoteUrl" -ForegroundColor Green

    # Build a transient Authorization header for git network operations.
    # WHY: base64("x-access-token:<PAT>") passed via `git -c http.extraHeader=...` authenticates
    #      pull/push WITHOUT ever writing the token to .git/config. It exists only as an in-memory
    #      argument for the duration of each git call and is cleared in the `finally` block.
    #      `x-access-token` is GitHub's canonical username for token auth (works for any owner).
    $TokenClean     = $GITHUB_PAT.Trim()
    $AuthB64        = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes("x-access-token:$TokenClean"))
    $ExtraHeaderArg = "http.extraHeader=Authorization: Basic $AuthB64"

    # Step 6: Stash any uncommitted local changes so pull can run cleanly
    Write-Host "Stashing local changes before pull..." -ForegroundColor Yellow
    git stash --quiet

    # Step 7: Pull remote changes FIRST — before staging or committing.
    # Auth is supplied transiently via `-c http.extraHeader` (in-memory, never on disk).
    # `-c credential.helper=` disables the credential manager so git relies solely on the header.
    # Stderr is filtered to suppress 'credential-manager-core is not a git command' noise.
    Write-Host "Pulling remote changes..." -ForegroundColor Yellow
    git -c $ExtraHeaderArg -c credential.helper= pull origin $BranchName 2>&1 |
        Where-Object { $_ -notmatch 'credential-manager-core' }
    $pullExitCode = $LASTEXITCODE

    if ($pullExitCode -ne 0) {
        Write-Warning "Failed to pull remote changes. Attempting to continue..."
    }

    # Step 8: Restore stashed changes on top of the pulled baseline
    Write-Host "Restoring stashed changes..." -ForegroundColor Yellow
    git stash pop

    if ($LASTEXITCODE -ne 0) {
        Write-Warning "Conflicts may have occurred while restoring stashed changes."

        if ($ForceResolve) {
            Write-Host "ForceResolve is enabled - assuming conflicts are already resolved." -ForegroundColor Yellow
        }
        else {
            Write-Host "Please resolve any conflicts manually before proceeding." -ForegroundColor Red
            Write-Host "Use 'git status' to check for conflicts and 'git add .' after resolving them." -ForegroundColor Yellow

            $ContinueChoice = Read-Host "Have you resolved all conflicts? (y/n)"
            if ($ContinueChoice -ne 'y' -and $ContinueChoice -ne 'Y') {
                throw "Operation cancelled due to unresolved conflicts."
            }
        }
    }

    # Step 9: Stage all changes (once, after pull + stash pop)
    Write-Host "Staging all changes..." -ForegroundColor Yellow
    git add .
    git add -u
    Write-Host "All changes staged." -ForegroundColor Green

    Write-Host ""
    Write-Information "Info: Empty folders will not be committed or pushed." -InformationAction Continue
    Write-Host ""

    # Step 10: Get commit message
    if ([string]::IsNullOrEmpty($Message)) {
        $CommitMessage = Read-Host "Give me the commit message"
    }
    else {
        $CommitMessage = $Message
        Write-Host "Using provided commit message: $CommitMessage" -ForegroundColor Cyan
    }

    if ([string]::IsNullOrEmpty($CommitMessage)) {
        throw "Commit message cannot be empty."
    }

    # Step 11: Commit
    git commit -m $CommitMessage

    if ($LASTEXITCODE -eq 0) {
        Write-Host "Changes committed successfully." -ForegroundColor Green

        # Step 12: Push to origin (transient header auth; token never stored on disk).
        # WHY: pushing via PAT (not GITHUB_TOKEN) is what causes GitHub Actions
        #      push-triggered workflows to fire on the target repo.
        git -c $ExtraHeaderArg -c credential.helper= push origin $BranchName 2>&1 |
            Where-Object { $_ -notmatch 'credential-manager-core' }
        $pushExitCode = $LASTEXITCODE

        if ($pushExitCode -eq 0) {
            Write-Host "Changes pushed to GitHub successfully!" -ForegroundColor Green

            # Step 13: Confirm the structure-sync workflow actually fired for THIS commit.
            #
            # WHY: a green push is not a green sync. `sync-to-targets.yml` triggers on
            #      `push` with a `paths:` filter, so a commit that touches only unfiltered
            #      paths (.github/workflows/**, README.md, docs/**) pushes successfully and
            #      syncs nothing -- the failure mode is silence, which is exactly why it goes
            #      unnoticed. Poll for a run attached to the pushed SHA and dispatch manually
            #      only when none appeared, so an ordinary sync is never run twice (each run
            #      clones and pushes to every target and takes ~1.5 min).
            if (($RepoOwner + "/" + $RepoName) -ieq $SyncSourceRepo) {
                if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
                    Write-Warning "GitHub CLI (gh) not found - cannot verify that '$SyncWorkflow' fired."
                    Write-Warning "Check it manually: https://github.com/$RepoOwner/$RepoName/actions"
                }
                else {
                    $PushedSha = (git rev-parse HEAD).Trim()
                    Write-Host "Verifying '$SyncWorkflow' fired for commit $($PushedSha.Substring(0, 7))..." -ForegroundColor Yellow

                    # gh reads GH_TOKEN from the environment. Set it transiently (never via
                    # `gh auth login`, which writes the PAT to gh's config store) and restore
                    # the caller's previous value in the `finally` block.
                    $PrevGhToken   = $env:GH_TOKEN
                    $env:GH_TOKEN  = $TokenClean
                    $GhTokenWasSet = $true

                    # GitHub registers the run a few seconds after the push lands, so poll.
                    # A single immediate query would report "no run" for a perfectly healthy
                    # push and trigger a redundant dispatch.
                    $SyncRunId = $null
                    foreach ($Attempt in 1..10) {
                        $SyncRunId = (gh run list --workflow $SyncWorkflow --commit $PushedSha --limit 1 --json databaseId --jq '.[0].databaseId' 2>$null | Out-String).Trim()
                        if (-not [string]::IsNullOrWhiteSpace($SyncRunId)) { break }
                        Start-Sleep -Seconds 3
                    }

                    if ([string]::IsNullOrWhiteSpace($SyncRunId)) {
                        Write-Host "No sync run for this commit - the changed paths do not match the workflow's paths: filter." -ForegroundColor Yellow
                        Write-Host "Dispatching '$SyncWorkflow' manually so the targets are still synced..." -ForegroundColor Yellow
                        gh workflow run $SyncWorkflow --ref $BranchName 2>&1 | Out-Null

                        if ($LASTEXITCODE -eq 0) {
                            Write-Host "Sync workflow dispatched: https://github.com/$RepoOwner/$RepoName/actions/workflows/$SyncWorkflow" -ForegroundColor Green
                        }
                        else {
                            Write-Warning "Could not dispatch '$SyncWorkflow'. Run it manually: gh workflow run $SyncWorkflow"
                        }
                    }
                    else {
                        Write-Host "Sync workflow running: https://github.com/$RepoOwner/$RepoName/actions/runs/$SyncRunId" -ForegroundColor Green
                    }
                }
            }
        }
        else {
            throw "Failed to push changes to remote repository."
        }
    }
    else {
        Write-Warning "Nothing to commit or commit failed."
    }
}
catch {
    Write-Error "An error occurred: $($_.Exception.Message)"
    exit 1
}
finally {
    # Clear sensitive variables — the PAT and derived auth material must not linger in memory.
    $GITHUB_PAT     = $null
    $SecurePAT      = $null
    $TokenClean     = $null
    $AuthB64        = $null
    $ExtraHeaderArg = $null
    $UserFullName   = $null
    $UserEmail      = $null

    # Restore GH_TOKEN only if this script overwrote it; assigning $null removes
    # the variable, which is the correct restore when the caller had none set.
    if ($GhTokenWasSet) { $env:GH_TOKEN = $PrevGhToken }
    $PrevGhToken = $null
}

Write-Host ""
Write-Host "GitHub Git Helper Script completed." -ForegroundColor Green

<# End of Script #>
