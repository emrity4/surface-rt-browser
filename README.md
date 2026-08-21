# Apotheosis Browser for ARM

Packages the [Project Apotheosis](https://github.com/MoonlightLabCN/Project-Apotheosis) WebKit browser for Windows 10 Mobile ARM32 devices (Surface RT, Lumia 950, etc.).

Apotheosis ports WebKitGTK 2.52.4 to ARM32 UWP with JSC JIT + GPU compositing — a real modern browser engine, not an EdgeHTML wrapper.

## Optimizations over upstream

- **Updated SSL certificates** — latest `cacert.pem` from curl.se (biggest compatibility win: old certs = TLS errors on modern sites)
- **Stripped debug symbols** — removes `.pdb` files for smaller package
- **Auto-sync** — weekly workflow monitors upstream releases and auto-publishes here
- **Installer script** — one-command setup on a connected PC

## Install

### Option A: Installer script (PC connected via USB)

```powershell
.\scripts\Install-Apotheosis.ps1 -AppxPath .\optimized.appx -CerPath .\build.cer
```

### Option B: Manual

1. Trust `build.cer` (Trusted Root + Trusted People)
2. `Add-AppxPackage .\optimized.appx`

## Workflows

- `build-appx.yml` — download upstream, update certs, repackage (manual trigger)
- `sync-release.yml` — auto-sync upstream releases (weekly)
