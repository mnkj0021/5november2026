# DifSync Windows bootstrap for a clean PC.
# Downloads the official DifSync Windows installer after preparing Node.js LTS.
# Pairing code is requested locally and is never embedded in this public file.
param(
    [Parameter(Mandatory = $false)]
    [string]$PairCode
)

$ErrorActionPreference = 'Stop'

Write-Host ''
Write-Host 'DifSync | Windows first-run setup' -ForegroundColor Cyan

function Refresh-SessionPath {
    $machinePath = [Environment]::GetEnvironmentVariable('Path', 'Machine')
    $userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
    $env:Path = "$machinePath;$userPath"
}

if (-not (Get-Command node.exe -ErrorAction SilentlyContinue)) {
    Write-Host '[1/3] Node.js not detected. Installing Node.js LTS...' -ForegroundColor Yellow

    if (-not (Get-Command winget.exe -ErrorAction SilentlyContinue)) {
        throw 'Windows Package Manager (winget) is unavailable. Install Microsoft App Installer (https://aka.ms/getwinget), or install Node.js LTS from https://nodejs.org/en/download, then rerun this command.'
    }

    & winget.exe install --id OpenJS.NodeJS.LTS --exact --source winget --accept-source-agreements --accept-package-agreements
    if ($LASTEXITCODE -ne 0) {
        throw "Node.js installation failed (winget exit code $LASTEXITCODE). Complete installation of Node.js LTS and rerun the setup."
    }

    # Winget installs update the registry PATH, but not this open PowerShell session.
    Refresh-SessionPath
    if (-not (Get-Command node.exe -ErrorAction SilentlyContinue)) {
        $standardNodeDir = Join-Path $env:ProgramFiles 'nodejs'
        if (Test-Path (Join-Path $standardNodeDir 'node.exe')) {
            $env:Path = "$standardNodeDir;$env:Path"
        }
    }
}

if (-not (Get-Command node.exe -ErrorAction SilentlyContinue)) {
    throw 'Node.js is still not on PATH. Close PowerShell, reopen it, and run the same setup command again.'
}

Write-Host ('[1/3] Node.js ready: ' + (& node.exe --version)) -ForegroundColor Green

Write-Host '[2/3] Downloading DifSync installer...' -ForegroundColor Cyan
$installer = Join-Path $env:TEMP 'difsync-install.ps1'
Invoke-WebRequest 'https://difsync.com/install/windows.ps1' -UseBasicParsing -OutFile $installer -ErrorAction Stop
if (-not (Test-Path $installer)) {
    throw 'DifSync installer download did not create a file.'
}

if ([string]::IsNullOrWhiteSpace($PairCode)) {
    $PairCode = Read-Host 'Enter your current DifSync pairing code'
}
if ([string]::IsNullOrWhiteSpace($PairCode)) {
    throw 'A DifSync pairing code is required.'
}

Write-Host '[3/3] Starting DifSync installer...' -ForegroundColor Cyan
& $installer -PairCode $PairCode
if (-not $?) {
    throw 'DifSync installer returned a PowerShell error.'
}
