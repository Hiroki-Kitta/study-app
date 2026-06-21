param(
  [int]$Port = 8080
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$PidFile = Join-Path $Root ".phone-server.pid"
$LogFile = Join-Path $Root "phone-server.log"
$ErrFile = Join-Path $Root "phone-server.err.log"
$BundledPython = Join-Path $env:USERPROFILE ".cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe"
$BundledPythonw = Join-Path $env:USERPROFILE ".cache\codex-runtimes\codex-primary-runtime\dependencies\python\pythonw.exe"

function Get-LocalIPv4 {
  $ip = $null
  try {
    $ip = Get-NetIPAddress -AddressFamily IPv4 |
      Where-Object {
        $_.IPAddress -notlike "127.*" -and
        $_.IPAddress -notlike "169.254.*" -and
        $_.PrefixOrigin -ne "WellKnown"
      } |
      Sort-Object InterfaceMetric |
      Select-Object -First 1 -ExpandProperty IPAddress
  } catch {
    $ip = $null
  }

  if (-not $ip) {
    $addresses = [regex]::Matches((ipconfig | Out-String), "\b(?:\d{1,3}\.){3}\d{1,3}\b") |
      ForEach-Object { $_.Value } |
      Where-Object {
        $_ -notlike "127.*" -and
        $_ -notlike "169.254.*" -and
        $_ -ne "0.0.0.0" -and
        $_ -ne "255.255.255.0" -and
        $_ -ne "255.255.0.0" -and
        $_ -ne "255.255.255.255"
      } |
      Select-Object -Unique

    $ip = $addresses |
      Where-Object { $_ -like "192.168.*" -or $_ -like "10.*" -or $_ -match "^172\.(1[6-9]|2[0-9]|3[0-1])\." } |
      Select-Object -First 1

    if (-not $ip) {
      $ip = $addresses | Select-Object -First 1
    }
  }

  if (-not $ip) {
    throw "No LAN IPv4 address was found. Make sure this PC is connected to the same Wi-Fi as your phone."
  }
  return $ip
}

function Get-PythonPath {
  if (Test-Path $BundledPythonw) { return $BundledPythonw }
  if (Test-Path $BundledPython) { return $BundledPython }
  $python = Get-Command python -ErrorAction SilentlyContinue
  if ($python) { return $python.Source }
  throw "Python was not found. Install Python or run this from Codex with the bundled Python available."
}

if (Test-Path $PidFile) {
  $oldPid = Get-Content $PidFile -ErrorAction SilentlyContinue
  if ($oldPid) {
    $oldProcess = Get-Process -Id $oldPid -ErrorAction SilentlyContinue
    if ($oldProcess) {
      $ip = Get-LocalIPv4
      Write-Host "Already running: http://${ip}:$Port/index.html"
      exit 0
    }
  }
}

$pythonPath = Get-PythonPath
$psi = New-Object System.Diagnostics.ProcessStartInfo
$psi.FileName = $pythonPath
$psi.Arguments = '"' + (Join-Path $Root "phone_server.py") + '" ' + $Port
$psi.WorkingDirectory = $Root
$psi.UseShellExecute = $true
$psi.WindowStyle = [System.Diagnostics.ProcessWindowStyle]::Hidden

$process = New-Object System.Diagnostics.Process
$process.StartInfo = $psi
[void]$process.Start()

$process.Id | Set-Content -Path $PidFile -Encoding ascii
Start-Sleep -Milliseconds 800
if (-not (Get-Process -Id $process.Id -ErrorAction SilentlyContinue)) {
  throw "Server process exited immediately. Try running python -m http.server manually from this folder."
}
$ipAddress = Get-LocalIPv4

Write-Host "Phone server started."
Write-Host "Open this URL on your phone while connected to the same Wi-Fi:"
Write-Host "http://${ipAddress}:$Port/index.html"
Write-Host ""
Write-Host "To stop it, run stop-phone-server.ps1."
