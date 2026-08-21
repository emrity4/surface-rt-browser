# Apotheosis Browser for ARM

Packages the [Project Apotheosis](https://github.com/MoonlightLabCN/Project-Apotheosis) WebKit browser for Windows 10 Mobile ARM32 devices (Surface RT, Lumia 950, etc.).

Apotheosis ports WebKitGTK 2.52.4 to ARM32 UWP with JSC JIT + GPU compositing — a real modern browser engine, not an EdgeHTML wrapper.

## Build

**Actions → Package Apotheosis Browser → Run workflow**. Artifact `apotheosis-arm` contains:

- `Apotheosis_<tag>_ARM.appx` — the WebKit browser
- `Apotheosis_<tag>_ARM.cer` — sideloading certificate

## Install

1. Trust the `.cer` (Trusted Root + Trusted People)
2. `Add-AppxPackage .\Apotheosis_<tag>_ARM.appx`

## Notes

- Source builds of the WebKit engine are not reproducible from the Apotheosis repo alone (engine source untracked, GB-scale, custom toolchain). This workflow mirrors their official prebuilt releases.
- Crashes and lag are expected — the project is WIP.