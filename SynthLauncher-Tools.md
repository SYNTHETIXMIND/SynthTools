<!--
  @file        SynthLauncher-Tools.md
  @description All tools listed in SynthLauncher: description, version, download link, icon, SHA-256 checksums and Defender exception commands (keep in sync with catalog.json)
  @author      Thomas Dobler - SYNTHETIXMIND LTD
  @email       tom@synthetixmind.com
  @uid         5a5b7392-da1c-4849-965a-efd10dd9b0bd
  @version     0.2.1.5
  @created     2026-11-07
  @updated     2026-11-07
  @copyright   (c) 2026 by SYNTHETIXMIND LTD
-->

# SynthLauncher — Tools

Every tool that SynthLauncher installs, updates and opens, with its download link, icon and checksums.

**Source of truth:** the signed catalog `https://synthetixmind.com/downloads/catalog.json` (copy: `C:\GitHub\SynthTools\catalog.json`, generated 2026-11-07T17:15:44Z).
**Last checked:** 2026-11-07. Every installer, `.sha256` file and icon below answered HTTP 200. Every downloaded installer and icon matched the size and SHA-256 in the catalog exactly, and the live catalog is byte-identical to the SynthTools copy.

## Overview

| Tool | Version | Released | Category | Installer size | Purpose |
|------|---------|----------|----------|----------------|---------|
| [SynthLauncher](#synthlauncher) | 0.1.2 | 2026-11-07 | Utilities | 1,943,689 bytes | Installs, updates and opens all SynthTools |
| [SynthKeys](#synthkeys) | 1.0.1 | 2026-10-23 | Productivity | 1,389,348 bytes | Text expander for signatures, phrases and templates |
| [SynthSize](#synthsize) | 0.2.0 | 2026-10-26 | Utilities | 1,288,268 bytes | Shows what fills your drives |
| [SynthDiff](#synthdiff) | 0.1.0 | 2026-10-26 | Utilities | 1,255,923 bytes | Compares two folders and shows what differs |
| [SynthWorks](#synthworks) | 0.2.1 | 2026-11-07 | Developer Tools | 2,164,058 bytes | Slim workspace for project folders with terminals and editor |

All tools: Windows 10/11 64-bit, per-user NSIS installer (no admin rights), publisher SYNTHETIXMIND LTD, proprietary free download.

## Download names

Download files keep a **fixed name without a version**: `https://synthetixmind.com/downloads/<Tool>/<Tool>_x64-setup.exe`, plus `<Tool>_x64-setup.exe.sha256` and `icon.png`. A new release overwrites the file, so links never change. The version lives only in the catalog, the Overviews and the release notes. The older versioned files (e.g. `SynthKeys_1.0.1_x64-setup.exe`) were removed from the server on 2026-11-07.

## About the checksums

- **SHA-256** is the checksum of each installer and icon. SynthLauncher checks the installer's SHA-256 and size before it runs it, and the icon's SHA-256 before it shows it. A `.sha256` file with the installer's value sits next to every installer on the server.
- The checksums are not RSA. The **catalog** itself is signed with **Ed25519** (`catalog.json.sig`), and SynthLauncher checks that signature against the public key built into the app. A changed or unsigned catalog is rejected, so a checksum can't be swapped without the private key.
- Verify a download yourself:

  ```powershell
  Get-FileHash .\<Tool>_x64-setup.exe -Algorithm SHA256
  ```

  The hash must equal the SHA-256 listed below (PowerShell prints it in upper case; the comparison ignores case).

## Security settings to use (Windows Defender exception)

If Windows Defender blocks or slows down a tool, exclude its install folder. Every tool installs per user into `%LOCALAPPDATA%\<Tool>`; SynthLauncher's folder also holds its downloaded installers (`%LOCALAPPDATA%\SynthLauncher\downloads`).

1. Open **PowerShell as administrator** (right-click Start → Terminal (Admin)).
2. Paste the line for the tool and press Enter.

| Tool | Add exception |
|------|---------------|
| SynthLauncher | `Add-MpPreference -ExclusionPath (Join-Path $env:LOCALAPPDATA 'SynthLauncher')` |
| SynthKeys | `Add-MpPreference -ExclusionPath (Join-Path $env:LOCALAPPDATA 'SynthKeys')` |
| SynthSize | `Add-MpPreference -ExclusionPath (Join-Path $env:LOCALAPPDATA 'SynthSize')` |
| SynthDiff | `Add-MpPreference -ExclusionPath (Join-Path $env:LOCALAPPDATA 'SynthDiff')` |
| SynthWorks | `Add-MpPreference -ExclusionPath (Join-Path $env:LOCALAPPDATA 'SynthWorks')` |

- Show all exceptions: `(Get-MpPreference).ExclusionPath`
- Remove one again: the same line with `Remove-MpPreference` instead of `Add-MpPreference`.
- An exception means Defender no longer scans files in that folder. Add it only for tools installed from synthetixmind.com.
- Since SynthLauncher 0.1.2, every card has a collapsed **Security settings to use** section with these commands and a Copy button (for an installed tool it uses the actual install folder from the registry).

---

## SynthLauncher

**Installs, updates and opens all SynthTools**

| | |
|---|---|
| Version | 0.1.2 (2026-11-07) |
| Installer | https://synthetixmind.com/downloads/SynthLauncher/SynthLauncher_x64-setup.exe |
| SHA-256 file | https://synthetixmind.com/downloads/SynthLauncher/SynthLauncher_x64-setup.exe.sha256 |
| SHA-256 | `73bddffca19b3e9a6730058907cc4130a3c00449d88cf8460506f283b4d8a9d0` |
| Size | 1.9 MB (1,943,689 bytes) |
| Icon | https://synthetixmind.com/downloads/SynthLauncher/icon.png |
| Icon SHA-256 | `bb818e3ed51ab21f290329475d1eaef83297b8136757bd527f6d5f93e1f9639c` |
| Product page | https://synthetixmind.com/pages/tools.php?utm_source=SynthLauncher&utm_medium=app&utm_campaign=SynthLauncher |

SynthLauncher is one window for every SYNTHETIXMIND SynthTool on Windows. It lists every tool, shows which ones are installed and in which version, and offers the right action for each: Install, Update, Open or Uninstall.

- **Signed catalog:** the tool list comes from `catalog.json` on synthetixmind.com. Its Ed25519 signature is checked against the key built into the app.
- **Verified downloads:** only synthetixmind.com download URLs are allowed, and size and SHA-256 are checked before an installer runs.
- **Smooth updates:** installers run in passive mode. An update closes a running copy of the tool and starts it again afterwards.
- **Clean uninstall:** runs the tool's own uninstaller and waits until Windows no longer lists the tool.
- **Offline mode:** uses the last verified catalog, checked again before use.
- **Self-update:** a banner offers "Update and restart" when a new SynthLauncher is available.

Release notes 0.1.2:
- New on every tool card: "Security settings to use" with copy-ready PowerShell commands for a Windows Defender exception (add, show, remove).
- All downloads now use fixed file names.

Release notes 0.1.1:
- Fix: the list no longer falls back to "Offline" when the server answers slowly (longer timeout + one retry).
- Error messages now name the cause of a failed download.

---

## SynthKeys

**Text expander for signatures, phrases and templates**

| | |
|---|---|
| Version | 1.0.1 (2026-10-23) |
| Installer | https://synthetixmind.com/downloads/SynthKeys/SynthKeys_x64-setup.exe |
| SHA-256 file | https://synthetixmind.com/downloads/SynthKeys/SynthKeys_x64-setup.exe.sha256 |
| SHA-256 | `09bf6196efef40daacc515f27c2fa818ce6602d6eb977eb0600cba35b0e83c8e` |
| Size | 1.3 MB (1,389,348 bytes) |
| Icon | https://synthetixmind.com/downloads/SynthKeys/icon.png |
| Icon SHA-256 | `d1b5c80364afbfd5ee09b7b9fc52b293cd71626ff7c658d2fbeeb2a4b2d617c4` |
| Product page | https://synthetixmind.com/pages/tools.php?utm_source=SynthLauncher&utm_medium=app&utm_campaign=SynthKeys |

Type a short trigger such as `#sig` in any app, and SynthKeys replaces it with your signature, phrase or template. It runs as a tray app with an editor (groups, search, live preview) and works in mail, chat, browser and office apps alike.

- **Triggers in any app:** a trigger followed by a space, Enter or a punctuation mark is replaced by the snippet.
- **Two insert methods:** Unicode keystrokes, or a clipboard paste for long text that restores the previous clipboard text afterwards.
- **Tokens:** date and time (strftime formats), clipboard, input prompts, counters, Enter/Tab keys.
- **Snippet chains:** `{snippet:#trigger}` nests other snippets, up to 8 levels deep.
- **Per-snippet options:** fire immediately, keep or drop the ending key, case-sensitive matching, Enter or Shift+Enter line breaks.
- **AutoHotkey import and export:** imports `::abbr::text` hotstrings; exports SynthKeys JSON or AutoHotkey v2 scripts.
- **Local data:** snippets stay in `%APPDATA%\SynthKeys\snippets.json`.

Release notes 1.0.1:
- Start menu entry can be switched on or off in Settings.
- Snippet chains with `{snippet:#trigger}`.
- Export (SynthKeys JSON, AutoHotkey v2) and JSON import.
- Sample snippets with safe removal (backup first).

---

## SynthSize

**Shows what fills your drives**

| | |
|---|---|
| Version | 0.2.0 (2026-10-26) |
| Installer | https://synthetixmind.com/downloads/SynthSize/SynthSize_x64-setup.exe |
| SHA-256 file | https://synthetixmind.com/downloads/SynthSize/SynthSize_x64-setup.exe.sha256 |
| SHA-256 | `eac9c5a54eced5dadfb7968e39cae118816baabcfc8ddfde96011919d4308f2a` |
| Size | 1.2 MB (1,288,268 bytes) |
| Icon | https://synthetixmind.com/downloads/SynthSize/icon.png |
| Icon SHA-256 | `fd23e115d91da81809156841f024cc8594308e0f76a998a9f8b7f3b1fc290bd9` |
| Product page | https://synthetixmind.com/pages/tools.php?utm_source=SynthLauncher&utm_medium=app&utm_campaign=SynthSize |

SynthSize lists every drive with its free and total space. Pick one, or type any folder or UNC path, and it scans the tree in parallel. It shows each folder's size, file and folder counts, share of its parent and newest change, largest first, and lets you act on the biggest items right from the result.

- **Item menu:** open in Explorer, cut or copy to the Windows clipboard, rename (never overwrites), Properties, Rescan.
- **Safe delete:** Recycle Bin by default, Shift+Del for a confirmed permanent delete. Totals update without a new scan. Scan root and drive roots are protected.
- **No double counting:** symlinks and junctions are skipped, so scans can't loop.
- **Explorer context menu:** optional "Analyze with SynthSize" for folders and drives, without admin rights.
- **Full keyboard control:** arrows, Enter, Del, F2, F5, Ctrl+C/X, Alt+Enter, Menu key.

Release notes 0.2.0:
- Item menu: open in Explorer, cut/copy to the clipboard, rename, delete, properties.
- Explorer context menu "Analyze with SynthSize".

---

## SynthDiff

**Compares two folders and shows what differs**

| | |
|---|---|
| Version | 0.1.0 (2026-10-26) |
| Installer | https://synthetixmind.com/downloads/SynthDiff/SynthDiff_x64-setup.exe |
| SHA-256 file | https://synthetixmind.com/downloads/SynthDiff/SynthDiff_x64-setup.exe.sha256 |
| SHA-256 | `c2fc78407689dbf5e7d374985b553044ab0c715ec38250abef19fd5d800389e7` |
| Size | 1.2 MB (1,255,923 bytes) |
| Icon | https://synthetixmind.com/downloads/SynthDiff/icon.png |
| Icon SHA-256 | `e2b4880223727a3f407be39e5daab54b5636f2658661d186cba341f7e020a69c` |
| Product page | https://synthetixmind.com/pages/tools.php?utm_source=SynthLauncher&utm_medium=app&utm_campaign=SynthDiff |

Pick two folders and SynthDiff marks every file and folder as Same, Different, Only left, Only right or File vs folder. You can copy, move or delete items straight from the list, one or many at a time.

- **Two compare modes:** size + date (fast, 2 s timestamp tolerance) or byte-by-byte content.
- **Filter chips with counts:** identical items are hidden by default. An ignore list (`.git`, `node_modules`, `*.tmp`) skips noise on both sides.
- **Actions:** copy to the other side (F6), cut, copy, delete, delete permanently, open in Explorer, properties. Copy and delete use the Windows shell: native progress dialog, Recycle Bin, Ctrl+Z undo in Explorer.
- **Multi-select** with Ctrl, Shift, Ctrl+A and Space, as in Explorer.
- **Safe:** refuses to compare a folder with itself or its own subfolder, never follows symlinks or junctions, and confirms every action with a list of what will be replaced.
- **Extras:** drag & drop, folder picker, swap, command line `SynthDiff.exe "<left>" "<right>"`, and a copyable difference report for Excel or a ticket.

Release notes 0.1.0:
- First release: compare by size + date or byte by byte.
- Filters, multi-select, copy to the other side, cut/copy/delete, report.

---

## SynthWorks

**Slim workspace for project folders with terminals and editor**

| | |
|---|---|
| Version | 0.2.1 (2026-11-07) |
| Installer | https://synthetixmind.com/downloads/SynthWorks/SynthWorks_x64-setup.exe |
| SHA-256 file | https://synthetixmind.com/downloads/SynthWorks/SynthWorks_x64-setup.exe.sha256 |
| SHA-256 | `e0f5121fddc5433d26ae3afaa93d8b8541e412dbd0cde7ae9905c36d5fab4e48` |
| Size | 2.1 MB (2,164,058 bytes) |
| Icon | https://synthetixmind.com/downloads/SynthWorks/icon.png |
| Icon SHA-256 | `8813e0c12e3abba8fb942a4b1b7c57f314a9383c6c700480cd80304deb4830f5` |
| Product page | https://synthetixmind.com/pages/tools.php?utm_source=SynthLauncher&utm_medium=app&utm_campaign=SynthWorks |

SynthWorks keeps your project folders (Workfolders) in a sidebar and opens each one in its own tab with PowerShell terminals, Claude Code buttons, a file panel and a basic editor. Requires PowerShell 7 (pwsh) for the terminals.

- **Workfolders:** add, rename, reorder, color, missing-path check, session restore.
- **Terminals:** PowerShell 7 through ConPTY, sub-tabs, Claude / Claude (continue) buttons, activity dot for background output, Windows Terminal-style copy and paste.
- **File panel:** fast virtual tree with live refresh, filter, create, rename, Recycle Bin, copy/cut/paste, drag and drop, open in Explorer or a terminal.
- **Editor:** tabs, conflict-safe saving, encoding and line endings preserved, external change warning, unsaved backup every 7 s.
- **Details panel:** description, todo, links and exclude list per Workfolder.
- **No orphaned processes:** closing SynthWorks, even a hard kill, ends every program it started.

Release notes 0.2.1:
- Fix: Ctrl+V and right-click paste insert the text once in the terminal (Ctrl+V pasted twice).
- The version is shown in the window title and next to "SynthWorks" in the sidebar.

---

## Keeping this document current

Update this file in the same change as every catalog change (new tool, new version, new checksum, new icon, removed tool):
1. Take version, date, URL, size, SHA-256, icon URL and icon SHA-256 from the new `catalog.json`. Never type a checksum by hand.
2. Check every link (HTTP 200), download each installer and icon and compare `Get-FileHash` with the catalog.
3. Update the overview table, the tool section, "Last checked", and bump `@version` / `@updated`.
4. Copy the file to `C:\GitHub\SynthTools` together with the catalog.
