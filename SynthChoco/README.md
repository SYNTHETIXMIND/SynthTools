<!--
  @file        README.md
  @description Public product page and release notes for SynthChoco
  @author      Thomas Dobler - SYNTHETIXMIND LTD
  @email       tom@synthetixmind.com
  @uid         0c6f3e8a-5b2d-4f71-9a43-7e1d2c8b9f05
  @version     0.3.1.1
  @created     2026-11-08
  @updated     2026-11-08
  @copyright   (c) 2026 by SYNTHETIXMIND LTD
-->

# SynthChoco

**A Windows app for Chocolatey.** Install, update, remove and scan your software packages from one window, and watch every choco command and its output as it runs.

More information: [synthetixmind.com](https://synthetixmind.com/pages/tools.php?utm_source=SynthChoco&utm_medium=github&utm_campaign=SynthChoco)

## Features

- Welcome screen with Chocolatey status and version, one-click Chocolatey install, and a count of installed and outdated packages
- Installed and outdated lists, search across all repositories, install one or many, Upgrade all (always with `-y`)
- SYNTHETIXMIND view: every package from the SYNTHETIXMIND repository with Install and Update
- Repositories: list, add, enable, disable, remove; the SYNTHETIXMIND repository in one click
- Export and import of package lists; import installs only what's missing and keeps only id and version from the file
- Windows Defender scan of a package and its install folder
- Live console (queued, coloured, cancellable), hidden by default; light and dark theme

## Download

**[Download SynthChoco 0.3.1 for Windows](https://synthetixmind.com/downloads/SynthChoco/SynthChoco_x64-setup.exe)** (1.4 MB) · [SHA-256](https://synthetixmind.com/downloads/SynthChoco/SynthChoco_x64-setup.exe.sha256): `4addbe50ec36eb409f2b8886c7abd2081ea07ebf750b5c5bc8b05001c78bf5c2`

The installer sets SynthChoco up for your Windows user and needs no administrator rights. Installing, upgrading and removing packages does: SynthChoco offers "Restart as administrator" for that. You can also install it from SynthLauncher, or with Chocolatey (elevated PowerShell):

```powershell
choco source add --name=synthetixmind --source="https://repo.synthetixmind.com/repository/synthetixmind/"
choco install synthchoco -y --source=synthetixmind
```

> The installer is not code-signed yet. Windows SmartScreen may ask you to confirm ("More info" → "Run anyway").

## Release notes

### 0.3.1
- First release: installed, outdated and search views, Upgrade all, live console
- Welcome screen with Chocolatey status and one-click Chocolatey install
- SYNTHETIXMIND view with every package from the SYNTHETIXMIND repository
- Export and import of package lists, Windows Defender scan per package, light and dark theme

---

© 2026 by SYNTHETIXMIND LTD · All rights reserved.
