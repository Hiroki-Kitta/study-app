$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$OutDir = Join-Path $Root "private_site"
$ZipPath = Join-Path $Root "private_site.zip"
$BundledNode = Join-Path $env:USERPROFILE ".cache\codex-runtimes\codex-primary-runtime\dependencies\node\bin\node.exe"

function Get-NodePath {
  if (Test-Path $BundledNode) { return $BundledNode }
  $node = Get-Command node -ErrorAction SilentlyContinue
  if ($node) { return $node.Source }
  throw "Node.js was not found."
}

$secure = Read-Host "Password for private site" -AsSecureString
$bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure)
try {
  $password = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr)
} finally {
  [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
}

if (-not $password) {
  throw "Password is required."
}

Copy-Item -LiteralPath (Join-Path $Root "private_index.html") -Destination (Join-Path $OutDir "index.html") -Force
Copy-Item -LiteralPath (Join-Path $Root "styles.css") -Destination (Join-Path $OutDir "styles.css") -Force
Copy-Item -LiteralPath (Join-Path $Root "app.js") -Destination (Join-Path $OutDir "app.js") -Force
Copy-Item -LiteralPath (Join-Path $Root "private-loader.js") -Destination (Join-Path $OutDir "private-loader.js") -Force

$env:STUDY_WIKI_PASSWORD = $password
try {
  & (Get-NodePath) (Join-Path $Root "build-private-site.mjs") $OutDir
} finally {
  Remove-Item Env:\STUDY_WIKI_PASSWORD -ErrorAction SilentlyContinue
}

if (Test-Path $ZipPath) {
  Remove-Item -LiteralPath $ZipPath -Force
}

Compress-Archive -LiteralPath (Join-Path $OutDir "index.html"), (Join-Path $OutDir "styles.css"), (Join-Path $OutDir "app.js"), (Join-Path $OutDir "private-loader.js"), (Join-Path $OutDir "encrypted-data.js") -DestinationPath $ZipPath

Write-Host "Private encrypted site files were created:"
Write-Host $OutDir
Write-Host ""
Write-Host "Zip file was created:"
Write-Host $ZipPath
Write-Host ""
Write-Host "Upload private_site.zip or every file in private_site."
