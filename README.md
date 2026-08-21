# Apotheosis Browser for ARM

Packages the [Project Apotheosis](https://github.com/MoonlightLabCN/Project-Apotheosis) WebKit browser for Windows 10 Mobile ARM32 devices (Surface RT, Lumia 950, etc.).

Apotheosis ports WebKitGTK 2.52.4 to ARM32 UWP with JSC JIT + GPU compositing — a real modern browser engine, not an EdgeHTML wrapper.

## What's different from upstream

- **Auto-sync** — weekly workflow monitors upstream releases and auto-publishes here
- **Installer script** — one-command setup on a connected PC (`scripts/Install-Apotheosis.ps1`)
- **Release packaging** — clean releases with appx + cer ready to sideload

## Build

**Actions → Package Apotheosis Browser → Run workflow** (or wait for auto-sync).

## Install (device)

### Option A: Installer script (PC connected via USB)

```powershell
.\scripts\Install-Apotheosis.ps1 -AppxPath .\Apotheosis_v0.1.8.6_ARM.appx -CerPath .\Apotheosis_v0.1.8.6_ARM.cer
```

For remote install via Device Portal:
```powershell
.\scripts\Install-Apotheosis.ps1 -AppxPath .\Apotheosis_v0.1.8.6_ARM.appx -CerPath .\Apotheosis_v0.1.8.6_ARM.cer -DeviceIP 192.168.1.100
```

### Option B: Manual

1. Trust the `.cer` (Trusted Root + Trusted People)
2. `Add-AppxPackage .\Apotheosis_v0.1.8.6_ARM.appx`

## Files

- `.github/workflows/sync-release.yml` — auto-sync upstream releases
- `.github/workflows/build-appx.yml` — manual build workflow
- `scripts/Install-Apotheosis.ps1` — installation helper
