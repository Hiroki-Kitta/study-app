$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$OutDir = Join-Path $Root "public_site"
$ZipPath = Join-Path $Root "public_site.zip"

if (-not (Test-Path $OutDir)) {
  New-Item -ItemType Directory -Path $OutDir | Out-Null
}

$files = @(
  "index.html",
  "styles.css",
  "app.js",
  "data.js"
)

foreach ($file in $files) {
  Copy-Item -LiteralPath (Join-Path $Root $file) -Destination (Join-Path $OutDir $file) -Force
}

if (Test-Path $ZipPath) {
  Remove-Item -LiteralPath $ZipPath -Force
}

Compress-Archive -LiteralPath (Join-Path $OutDir "index.html"), (Join-Path $OutDir "styles.css"), (Join-Path $OutDir "app.js"), (Join-Path $OutDir "data.js") -DestinationPath $ZipPath

Write-Host "Public site files were created:"
Write-Host $OutDir
Write-Host ""
Write-Host "Zip file was created:"
Write-Host $ZipPath
Write-Host ""
Write-Host "Upload public_site.zip or every file in public_site to a static hosting service."
