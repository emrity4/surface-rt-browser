# Supermium APPX

Builds [Supermium](https://github.com/win32ss/supermium) (Chromium for Windows XP+) into a
sideloadable `.appx` package using GitHub Actions. No source build, no Chromium toolchain —
the workflow downloads the official Supermium release zip, packages it, and signs it with a
self-signed certificate.

Runs on any Windows 10/11 device. On Windows on ARM64, Supermium runs via the built-in x64
emulation.

## Build

1. Go to **Actions → Build Supermium APPX → Run workflow** (optionally pick `32` vs `64` and a release tag).
2. Download the `supermium-appx` artifact: `Supermium.appx` + `Supermium.cer`.

## Install (sideload)

1. Right-click `Supermium.cer` → **Install Certificate** → **Local Machine** → **Trusted Root Certification Authorities** (and **Trusted People**). The cert is a fresh self-signed dev cert generated each build.
2. `Add-AppxPackage .\Supermium.appx` (or double-click it).
3. Launch **Supermium Browser** from the Start menu.

## Files

- `.github/workflows/build-appx.yml` — CI workflow
- `scripts/build-appx.ps1` — download, package, sign
- `scripts/AppxManifest.xml` — MSIX manifest template (version patched at build time)