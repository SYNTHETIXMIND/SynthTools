<!--
  @file        README.md
  @description Public download and update repository for SYNTHETIXMIND tools
  @author      Thomas Dobler - SYNTHETIXMIND LTD
  @email       tom@synthetixmind.com
  @uid         5462a4ec-4431-49b7-bef4-611bc6c7a3cc
  @version     0.3.1.4
  @created     2026-10-23
  @updated     2026-10-24
  @copyright   (c) 2026 by SYNTHETIXMIND LTD
-->

# SynthTools

Downloads and update files for the desktop tools by **SYNTHETIXMIND LTD**: [synthetixmind.com](https://synthetixmind.com/pages/tools.php?utm_source=SynthTools&utm_medium=github&utm_campaign=SynthTools).

This repository holds **no source code**, only release notes, update manifests and installers.

| Tool | Platform | Folder |
|------|----------|--------|
| **SynthLauncher**: installs, updates and opens all SynthTools | Windows | [`SynthLauncher/`](SynthLauncher/README.md) |
| **SynthKeys**: text expander for signatures and phrases | Windows | [`SynthKeys/`](SynthKeys/README.md) |

## Layout

```
catalog.json       List of all tools + latest versions, read by SynthLauncher
catalog.json.sig   Ed25519 signature of catalog.json (the launcher rejects unsigned catalogs)
<Tool>/
├── README.md      What the tool does, download, release notes
└── update/        Update manifest(s) read by the installed app
```

Installers are attached to [GitHub Releases](https://github.com/SYNTHETIXMIND/SynthTools/releases), tagged `<tool>-v<version>` (for example `synthkeys-v1.0.1`).
Every update is signed; the apps only install files whose signature matches the key built into them.

---

© 2026 by SYNTHETIXMIND LTD · All rights reserved. The tools are proprietary software.
