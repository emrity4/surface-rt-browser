# SurfaceRT Browser

A tiny UWP browser for **ARM32 (ARMv7) Windows 10 Mobile** — the kind of build you can run on a
Surface RT (Tegra 3) via the golden-keys method. It wraps the on-device EdgeHTML `WebView`
control: an address bar, back/forward, and a full-screen page view.

Why a WebView shell and not Chromium/Supermium? Windows 10 Mobile is ARMv7 and AppContainer-only.
It cannot run x86/x64 binaries (no emulation layer) and will not install Win32 `runFullTrust`
packages. Chromium has no ARM32 UWP build, so the EdgeHTML engine shipped in the OS is the only
real browser engine this device can run. That caps "modern browsing" at the EdgeHTML version in
your flashed build (roughly 2016-17 era) — that's a hardware/platform limit, not a config choice.

## Build

**Actions → Build SurfaceRT Browser APPX → Run workflow** (also runs monthly). Artifact
`surface-rt-browser` contains:

- `SurfaceRtBrowser_1.0.0.0_ARM_Release.appx` — the browser, compiled for ARM32
- `Dependencies/` — required .NET runtime packages (ARM)
- `build.cer` — the self-signed signing cert (fresh each build)

## Install (sideload)

On the device, with **developer mode** enabled:

1. Trust the cert: install `build.cer` into **Trusted Root Certification Authorities** and **Trusted People**.
2. Install dependencies first (if not already present), then the app:
   - `Add-AppxPackage .\Dependencies\Microsoft.NET.CoreRuntime_*.appx`
   - `Add-AppxPackage .\SurfaceRtBrowser_1.0.0.0_ARM_Release.appx`

Launch **SurfaceRT Browser** from the Start menu.

## Files

- `src/SurfaceRtBrowser/` — the UWP C# app (XAML + code-behind, classic UWP csproj)
- `.github/workflows/build-appx.yml` — CI: creates a code-signing cert, builds with MSBuild, uploads the package

## Limitations

- Renders with the device's EdgeHTML — some 2020s sites won't work. That is unavoidable on ARM32 UWP.
- WebView is single-window; tabs aren't supported.
- The signing cert is recreated on every build, so each new build must be re-trusted.