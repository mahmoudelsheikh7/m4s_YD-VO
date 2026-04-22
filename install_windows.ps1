# ==============================================================================
#  m4s d — Windows Installer v2.0.0
#  GitHub : https://github.com/mahmoudelsheikh7/M4S_D
#
#  Downloads: yt-dlp.exe, ffmpeg.exe, demucs (via Python venv)
#  Requires:  PowerShell 5.1+ or PowerShell 7+, Python 3.10+
#
#  Usage (in PowerShell as Administrator or regular user):
#    Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
#    .\install_windows.ps1
# ==============================================================================

$ErrorActionPreference = "Stop"

$AppName   = "m4s_d"
$AppDir    = Join-Path $env:LOCALAPPDATA "m4s\m4s_d"
$BinDir    = Join-Path $AppDir "bin"
$VenvDir   = Join-Path $AppDir "venv"
$LogFile   = Join-Path $AppDir "install.log"

function Write-Banner {
    Write-Host ""
    Write-Host "  ███╗   ███╗██╗  ██╗███████╗    ██████╗ " -ForegroundColor Cyan
    Write-Host "  ████╗ ████║██║  ██║██╔════╝    ██╔══██╗" -ForegroundColor Cyan
    Write-Host "  ██╔████╔██║███████║███████╗    ██║  ██║" -ForegroundColor Cyan
    Write-Host "  ██║╚██╔╝██║╚════██║╚════██║    ██║  ██║" -ForegroundColor Cyan
    Write-Host "  ██║ ╚═╝ ██║     ██║███████║    ██████╔╝" -ForegroundColor Cyan
    Write-Host "  ╚═╝     ╚═╝     ╚═╝╚══════╝    ╚═════╝ " -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  m4s d v2.0 — Universal Downloader + AI Vocal Extractor" -ForegroundColor White
    Write-Host "  Windows Installer v2.0.0" -ForegroundColor Gray
    Write-Host "  https://github.com/mahmoudelsheikh7/M4S_D" -ForegroundColor DarkGray
    Write-Host ""
}

function Write-Step   { param($msg) Write-Host "`n━━━  $msg  ━━━" -ForegroundColor Blue }
function Write-Info   { param($msg) Write-Host "  [INFO]  $msg" -ForegroundColor Cyan }
function Write-Ok     { param($msg) Write-Host "  [OK]    $msg" -ForegroundColor Green }
function Write-Warn   { param($msg) Write-Host "  [WARN]  $msg" -ForegroundColor Yellow }
function Write-Fail   { param($msg) Write-Host "  [ERR]   $msg" -ForegroundColor Red; exit 1 }

function Ensure-Dir { param($path) if (-not (Test-Path $path)) { New-Item -ItemType Directory -Path $path -Force | Out-Null } }

function Download-File {
    param([string]$Url, [string]$Dest)
    Write-Info "Downloading: $([System.IO.Path]::GetFileName($Dest))"
    try {
        $wc = New-Object System.Net.WebClient
        $wc.DownloadFile($Url, $Dest)
        Write-Ok "Downloaded: $Dest"
    } catch {
        Write-Warn "WebClient failed, trying Invoke-WebRequest…"
        Invoke-WebRequest -Uri $Url -OutFile $Dest -UseBasicParsing
        Write-Ok "Downloaded: $Dest"
    }
}

function Extract-Zip {
    param([string]$ZipPath, [string]$Dest)
    Write-Info "Extracting: $([System.IO.Path]::GetFileName($ZipPath))"
    Expand-Archive -Path $ZipPath -DestinationPath $Dest -Force
    Write-Ok "Extracted to: $Dest"
}

function Find-Python {
    $candidates = @("python", "python3", "py")
    foreach ($c in $candidates) {
        try {
            $v = & $c --version 2>&1
            if ($v -match "Python 3\.(\d+)") {
                $minor = [int]$Matches[1]
                if ($minor -ge 9) { return $c }
            }
        } catch {}
    }
    return $null
}

# ─── Step 1: Create directories ───────────────────────────────────────────────

Write-Banner
Write-Step "Creating application directories"
Ensure-Dir $AppDir
Ensure-Dir $BinDir
Ensure-Dir $VenvDir
Write-Ok "Directories ready: $AppDir"

# ─── Step 2: Download yt-dlp.exe ──────────────────────────────────────────────

Write-Step "Downloading yt-dlp"
$ytdlpDest = Join-Path $BinDir "yt-dlp.exe"
if (Test-Path $ytdlpDest) {
    Write-Info "yt-dlp.exe already exists. Updating…"
}
Download-File `
    "https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe" `
    $ytdlpDest
Write-Ok "yt-dlp ready: $ytdlpDest"

# ─── Step 3: Download & extract ffmpeg ────────────────────────────────────────

Write-Step "Downloading ffmpeg"
$ffmpegZip  = Join-Path $AppDir "ffmpeg.zip"
$ffmpegDest = Join-Path $BinDir "ffmpeg.exe"

if (-not (Test-Path $ffmpegDest)) {
    Download-File `
        "https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-win64-gpl.zip" `
        $ffmpegZip

    $extractDir = Join-Path $AppDir "ffmpeg_extract"
    Ensure-Dir $extractDir
    Extract-Zip $ffmpegZip $extractDir

    $ffmpegExe = Get-ChildItem -Path $extractDir -Recurse -Filter "ffmpeg.exe" |
                 Where-Object { $_.FullName -notmatch "ffprobe|ffplay" } |
                 Select-Object -First 1
    if ($ffmpegExe) {
        Copy-Item $ffmpegExe.FullName $ffmpegDest -Force
        Write-Ok "ffmpeg.exe extracted: $ffmpegDest"
    } else {
        Write-Warn "Could not locate ffmpeg.exe inside zip. Check $extractDir manually."
    }
    Remove-Item $ffmpegZip -Force -ErrorAction SilentlyContinue
    Remove-Item $extractDir -Recurse -Force -ErrorAction SilentlyContinue
} else {
    Write-Info "ffmpeg.exe already exists, skipping download."
}

# ─── Step 4: Python venv + demucs ─────────────────────────────────────────────

Write-Step "Setting up Python virtual environment for demucs"

$python = Find-Python
if (-not $python) {
    Write-Warn "Python 3.9+ not found in PATH."
    Write-Warn "Install Python from https://www.python.org/downloads/ and rerun this script."
    Write-Warn "Skipping demucs installation."
} else {
    $pyVer = & $python --version 2>&1
    Write-Info "Using: $pyVer"

    $venvPython = Join-Path $VenvDir "Scripts\python.exe"
    $venvPip    = Join-Path $VenvDir "Scripts\pip.exe"

    if (-not (Test-Path $venvPython)) {
        Write-Info "Creating venv at: $VenvDir"
        & $python -m venv $VenvDir
        Write-Ok "venv created."
    } else {
        Write-Info "venv already exists."
    }

    Write-Info "Upgrading pip…"
    & $venvPython -m pip install --upgrade pip --quiet

    Write-Info "Installing demucs (htdemucs_ft AI model) — may take 5–20 min, ~1–3 GB…"
    try {
        & $venvPip install demucs --no-cache-dir
        Write-Ok "demucs installed."
    } catch {
        Write-Warn "demucs install failed: $_"
    }

    Write-Info "Installing torchcodec (critical audio-save fix)…"
    try {
        & $venvPip install torchcodec --no-cache-dir
        Write-Ok "torchcodec installed."
    } catch {
        Write-Warn "torchcodec install failed: $_"
        Write-Warn "Manual fix: activate the venv and run: pip install torchcodec"
    }

    $demucsExe = Join-Path $VenvDir "Scripts\demucs.exe"
    if (Test-Path $demucsExe) {
        Write-Ok "demucs executable: $demucsExe"
    } else {
        Write-Warn "demucs.exe not found in venv\Scripts — check venv installation."
    }
}

# ─── Step 5: Add BinDir to user PATH ──────────────────────────────────────────

Write-Step "Updating user PATH"
$currentPath = [System.Environment]::GetEnvironmentVariable("PATH", "User")
if ($currentPath -notlike "*$BinDir*") {
    [System.Environment]::SetEnvironmentVariable(
        "PATH",
        "$BinDir;$currentPath",
        "User"
    )
    Write-Ok "Added to PATH: $BinDir"
} else {
    Write-Info "BinDir already in PATH."
}

$venvScripts = Join-Path $VenvDir "Scripts"
if ($currentPath -notlike "*$venvScripts*") {
    $updatedPath = [System.Environment]::GetEnvironmentVariable("PATH", "User")
    [System.Environment]::SetEnvironmentVariable(
        "PATH",
        "$venvScripts;$updatedPath",
        "User"
    )
    Write-Ok "Added venv Scripts to PATH: $venvScripts"
}

# ─── Step 6: Build instructions ───────────────────────────────────────────────

Write-Step "Build Instructions (GUI)"

Write-Host ""
Write-Host "  ╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "  ║           m4s d v2.0 — Tools Ready!                         ║" -ForegroundColor Green
Write-Host "  ╠══════════════════════════════════════════════════════════════╣" -ForegroundColor Green
Write-Host "  ║                                                              ║"
Write-Host "  ║  Tools installed to:  $BinDir" -ForegroundColor White
Write-Host "  ║                                                              ║"
Write-Host "  ║  BUILD the GUI app (requires MSYS2 + Qt6 or Qt Creator):    ║"
Write-Host "  ║                                                              ║"
Write-Host "  ║  Option A — MSYS2 / MinGW:                                  ║"
Write-Host "  ║    pacman -S mingw-w64-x86_64-qt6-base cmake make gcc        ║"
Write-Host "  ║    mkdir build && cd build                                   ║"
Write-Host "  ║    cmake .. -G 'MinGW Makefiles' -DCMAKE_BUILD_TYPE=Release  ║"
Write-Host "  ║    mingw32-make -j4                                          ║"
Write-Host "  ║                                                              ║"
Write-Host "  ║  Option B — Qt Creator (recommended for Windows):            ║"
Write-Host "  ║    Install Qt 6.x from https://www.qt.io/download            ║"
Write-Host "  ║    Open CMakeLists.txt in Qt Creator, build & run            ║"
Write-Host "  ║                                                              ║"
Write-Host "  ║  NOTE: Restart your terminal for PATH changes to take effect ║"
Write-Host "  ║                                                              ║"
Write-Host "  ╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""

$logContent = @"
m4s d Windows Install Log
Date: $(Get-Date)
AppDir:    $AppDir
BinDir:    $BinDir
VenvDir:   $VenvDir
yt-dlp:    $ytdlpDest
ffmpeg:    $ffmpegDest
"@
$logContent | Out-File $LogFile -Encoding UTF8
Write-Info "Install log saved: $LogFile"
