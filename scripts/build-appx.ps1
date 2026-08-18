param(
    [ValidateSet("32", "64")][string]$Arch = "64",
    [string]$Version = "",
    [string]$Work = "$PWD\work"
)
$ErrorActionPreference = "Stop"
$OutDir = "$PWD\out"
New-Item -ItemType Directory $OutDir -Force | Out-Null
New-Item -ItemType Directory $Work -Force | Out-Null

# 1. Resolve release tag and asset name
if (-not $Version) {
    $rel = Invoke-RestMethod -Headers @{ "User-Agent" = "supermium-appx" } "https://api.github.com/repos/win32ss/supermium/releases/latest"
    $Version = $rel.tag_name
}
$verCore = ($Version -replace '^v', '') -replace '-r\d+$', ''
$zipName = "supermium_${verCore}_${Arch}_nonsetup.zip"
Write-Host "Building $Version ($zipName)"

$url = "https://github.com/win32ss/supermium/releases/download/$Version/$zipName"
Invoke-WebRequest $url -OutFile "$Work\supermium.zip"
Expand-Archive "$Work\supermium.zip" "$Work\unpacked" -Force

# 2. Locate the executable; its directory becomes the package layout
$exe = Get-ChildItem "$Work\unpacked" -Recurse -Filter chrome.exe | Select-Object -First 1
if (-not $exe) { throw "chrome.exe not found in archive" }
$layout = $exe.DirectoryName
Write-Host "Layout: $layout"

# 3. Generate tile logos from the executable icon
Add-Type -AssemblyName System.Drawing
New-Item -ItemType Directory "$layout\Assets" -Force | Out-Null
$icon = [System.Drawing.Icon]::ExtractAssociatedIcon($exe.FullName)
foreach ($size in @(44, 150, 300)) {
    $bmp = New-Object System.Drawing.Bitmap($icon.ToBitmap(), $size, $size)
    $bmp.Save("$layout\Assets\Square${size}x${size}Logo.png", [System.Drawing.Imaging.ImageFormat]::Png)
    $bmp.Dispose()
}

# 4. Manifest with a 4-part version from the release tag (e.g. v144-r5 -> 1.0.144.5)
$tag = $Version -replace '^v', ''
if ($tag -match '^(\d+)(?:-r(\d+))?$') {
    $vMajor = [int]$Matches[1]
    $vRev = if ($Matches[2]) { [int]$Matches[2] } else { 0 }
} else { $vMajor = 0; $vRev = 0 }
$manifest = [System.IO.File]::ReadAllText("$PSScriptRoot\AppxManifest.xml")
$manifest = $manifest -creplace 'Version="[0-9.]+"', "Version=`"1.0.$vMajor.$vRev`""
[System.IO.File]::WriteAllText("$layout\AppxManifest.xml", $manifest, (New-Object System.Text.UTF8Encoding($false)))

# ponytail: self-check before packing
$null = [xml](Get-Content "$layout\AppxManifest.xml" -Raw)
$head = [System.IO.File]::ReadAllBytes("$layout\AppxManifest.xml")[0..3]
Write-Host ("Manifest head bytes: " + (($head | ForEach-Object { $_.ToString('X2') }) -join ' '))

# 5. Self-signed code-signing cert (fresh each run; publisher matches the manifest)
$cert = New-SelfSignedCertificate -Type Custom -Subject "CN=Supermium Publisher" `
    -KeyUsage DigitalSignature -KeyExportPolicy Exportable `
    -CertStoreLocation Cert:\CurrentUser\My `
    -TextExtension @("2.5.29.37={text}1.3.6.1.5.5.7.3.3")
# ponytail: dev cert for sideloading, not a real secret
$pfxPass = "SupermiumSideload"
Export-PfxCertificate -Cert $cert -FilePath "$OutDir\Supermium.pfx" `
    -Password (ConvertTo-SecureString $pfxPass -AsPlainText -Force) | Out-Null
Export-Certificate -Cert $cert -FilePath "$OutDir\Supermium.cer" | Out-Null

# 6. Locate MakeAppx / SignTool (Windows SDK), else pull the SDK BuildTools package
function Find-Tool([string]$name) {
    foreach ($root in @("${env:ProgramFiles(x86)}\Windows Kits\10\bin", "${env:ProgramFiles}\Windows Kits\10\bin")) {
        if (Test-Path $root) {
            $hit = Get-ChildItem $root -Recurse -Filter $name -ErrorAction SilentlyContinue |
                Sort-Object FullName -Descending | Select-Object -First 1
            if ($hit) { return $hit.FullName }
        }
    }
    return $null
}
$makeappx = Find-Tool "makeappx.exe"
$signtool = Find-Tool "signtool.exe"
if (-not $makeappx -or -not $signtool) {
    Invoke-WebRequest "https://www.nuget.org/api/v2/package/Microsoft.Windows.SDK.BuildTools" -OutFile "$Work\sdk.zip"
    Expand-Archive "$Work\sdk.zip" "$Work\sdk" -Force
    $makeappx = (Get-ChildItem "$Work\sdk" -Recurse -Filter makeappx.exe | Select-Object -First 1).FullName
    $signtool = (Get-ChildItem "$Work\sdk" -Recurse -Filter signtool.exe | Select-Object -First 1).FullName
}
if (-not $makeappx -or -not $signtool) { throw "Could not locate makeappx.exe / signtool.exe" }

# 7. Pack and sign
& $makeappx pack /d $layout /p "$OutDir\Supermium.appx" /o
if ($LASTEXITCODE -ne 0) { throw "makeappx pack failed" }

& $signtool sign /fd SHA256 /f "$OutDir\Supermium.pfx" /p $pfxPass `
    /tr http://timestamp.digicert.com /td SHA256 "$OutDir\Supermium.appx"
if ($LASTEXITCODE -ne 0) { throw "signtool sign failed" }

Remove-Item "$OutDir\Supermium.pfx" -Force
Write-Host "Done: $OutDir\Supermium.appx"