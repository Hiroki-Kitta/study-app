$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$PidFile = Join-Path $Root ".phone-server.pid"

if (-not (Test-Path $PidFile)) {
  Write-Host "Phone server is not running."
  exit 0
}

$serverPid = Get-Content $PidFile -ErrorAction SilentlyContinue
$process = if ($serverPid) { Get-Process -Id $serverPid -ErrorAction SilentlyContinue } else { $null }

if ($process) {
  Stop-Process -Id $serverPid
  Write-Host "Phone server stopped."
} else {
  Write-Host "Server process was not found."
}

Remove-Item -LiteralPath $PidFile -ErrorAction SilentlyContinue
