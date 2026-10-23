<!--
  @file        README.md
  @description Public product page and release notes for SynthKeys
  @author      Thomas Dobler - SYNTHETIXMIND LTD
  @email       tom@synthetixmind.com
  @uid         a7695d50-224f-4889-8b6a-90d367089fb2
  @version     0.1.1.2
  @created     2026-10-23
  @updated     2026-10-23
  @copyright   (c) 2026 by SYNTHETIXMIND LTD
-->

# SynthKeys

**A text expander for Windows.** Type a short trigger such as `#sig` followed by a space, Enter or punctuation mark in any app, and SynthKeys replaces it with your signature, phrase or template.

More information: [synthetixmind.com](https://synthetixmind.com/tools.php?utm_source=SynthKeys&utm_medium=github&utm_campaign=SynthKeys)

## Features

- Works in every Windows app, typed or pasted (instant for long signatures)
- Placeholders: date, time, clipboard, input prompts, auto-incrementing counter, Enter / Shift+Enter / Tab
- **Snippet chains**: one trigger inserts several snippets
- Groups, search, live preview; sample snippets to start with
- Import from AutoHotkey scripts, export as backup (`.json`) or AutoHotkey v2 (`.ahk`)
- Tray icon, pause switch, start with Windows, optional Start menu entry

## Download

**[Download SynthKeys 1.0.1 for Windows](https://synthetixmind.com/downloads/SynthKeys/SynthKeys_1.0.1_x64-setup.exe)** (1.3 MB) · [SHA-256](https://synthetixmind.com/downloads/SynthKeys/SynthKeys_1.0.1_x64-setup.exe.sha256): `09bf6196efef40daacc515f27c2fa818ce6602d6eb977eb0600cba35b0e83c8e`

Older versions and release assets: [Releases](https://github.com/SYNTHETIXMIND/SynthTools/releases). It installs per user and needs no administrator rights.

> The installer is not code-signed yet. Windows SmartScreen may ask you to confirm ("More info" → "Run anyway").

## Update files

[`update/`](update/) holds the update manifest that installed copies of SynthKeys check on start. It stays empty until the built-in updater ships.

## Release notes

### 1.0.1
- Start menu entry (Synthetixmind › SynthKeys) can be switched on or off in Settings
- Snippet chains with `{snippet:#trigger}`
- Export (SynthKeys JSON, AutoHotkey v2) and JSON import
- Sample snippets, with options to remove only samples or all snippets (a backup is written first)
- Copyright footer and "More Informations" tray item

---

© 2026 by SYNTHETIXMIND LTD · All rights reserved.
