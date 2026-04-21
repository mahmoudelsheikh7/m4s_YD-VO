# م4س YD&VO | m4s YD&VO

<div align="center">

```
  ███╗   ███╗██╗  ██╗███████╗    ██╗   ██╗██████╗ ██╗   ██╗ ██████╗
  ████╗ ████║██║  ██║██╔════╝    ╚██╗ ██╔╝██╔══██╗██║   ██║██╔═══██╗
  ██╔████╔██║███████║███████╗     ╚████╔╝ ██║  ██║██║   ██║██║   ██║
  ██║╚██╔╝██║╚════██║╚════██║      ╚██╔╝  ██║  ██║╚██╗ ██╔╝██║   ██║
  ██║ ╚═╝ ██║     ██║███████║       ██║   ██████╔╝ ╚████╔╝ ╚██████╔╝
  ╚═╝     ╚═╝     ╚═╝╚══════╝       ╚═╝   ╚═════╝   ╚═══╝   ╚═════╝
```

**YouTube Downloader & Vocal Output**

[![Platform](https://img.shields.io/badge/Platform-Linux%20%7C%20Windows-blue?style=flat-square)](https://github.com)
[![Language](https://img.shields.io/badge/Language-C++17%20Qt6-green?style=flat-square)](https://www.qt.io/)
[![License](https://img.shields.io/badge/License-MIT-yellow?style=flat-square)](LICENSE)
[![AI](https://img.shields.io/badge/AI-Demucs%20%7C%20100%25%20Local-purple?style=flat-square)](https://github.com/facebookresearch/demucs)

</div>

---

## 🌐 Bilingual Description | وصف ثنائي اللغة

### العربية 🇸🇦

**م4س YD&VO** هو تطبيق سطح مكتب مبني بـ **C++ / Qt6** يعمل كواجهة رسومية متكاملة لأداتين قويتين:

- **yt-dlp** — لتنزيل الفيديو والصوت من يوتيوب وأكثر من 1000 موقع آخر بأفضل جودة.
- **demucs** — للذكاء الاصطناعي المحلي لفصل الصوت البشري عن الموسيقى بدون أي خادم سحابي.

يدعم التطبيق **الوضع الداكن والفاتح**، **تبديل اللغة عربي/إنجليزي**، **الفحص الذاتي للأدوات** عند بدء التشغيل، وإدارة ذكية لأجهزة المعالجة (CPU/CUDA) لتجنب أخطاء بطاقات الرسوميات القديمة.

### English 🇬🇧

**m4s YD&VO** is a **C++ Qt6** desktop application acting as a clean graphical front-end for two powerful tools:

- **yt-dlp** — downloads audio/video from YouTube and 1,000+ other sites at any quality.
- **demucs** — Meta's AI vocal separator that runs **100% locally**, splitting vocals from instrumentals with no cloud dependency.

The app features **Light/Dark mode**, **Arabic/English UI**, **startup self-diagnostics**, and smart **CPU/GPU CUDA device selection** with a built-in fix for older GPU CUDA compatibility errors.

---

## ✨ Features

| Feature | Details |
|---|---|
| 🎵 **Audio Download** | MP3 (best quality) · WAV (lossless) |
| 🎬 **Video Download** | Best · 1080p · 720p · 480p (auto-merge via ffmpeg) |
| 🤖 **AI Vocal Separation** | Demucs HTDemucs model — 100% local, no internet required for AI |
| 🔍 **Self-Diagnostic** | Startup check for yt-dlp & demucs with colour-coded results |
| 🌙 **Dark / Light Mode** | One-click Fusion palette toggle |
| 🌐 **Arabic / English UI** | Full bidirectional layout switch (RTL ↔ LTR) |
| ⚡ **CPU / GPU Device Select** | Force CPU or enable CUDA — universal CUDA error fix included |
| 📋 **Clipboard Paste** | Instant URL paste from clipboard |
| 📺 **Real-time Logs** | Colour-coded live output from both yt-dlp and demucs |
| 🔇 **Non-blocking UI** | All processing via `QProcess` — UI stays responsive |
| 🔒 **Privacy-First** | Everything runs locally. No telemetry, no accounts, no cloud |

---

## 🖥️ Screenshots (UI Overview)

```
┌─────────────────────────────────────────────────────────────────────┐
│  m4s YD&VO — YouTube Downloader & Vocal Output    [العربية] [🌙 Dark] │
├─────────────────────────────────────────────────────────────────────┤
│ ╔══ Download Settings ════════════════════════════════════════════╗ │
│ ║ Media URL:  [https://www.youtube.com/watch?v=...    ] [📋 Paste] ║ │
│ ║ Quality:    [Audio  MP3        ▼]  Device: [CPU (Always Safe) ▼] ║ │
│ ║ ☐  Run Demucs — Extract Vocals                                  ║ │
│ ╚═════════════════════════════════════════════════════════════════╝ │
│                                                                     │
│  [▶  Start]  [■  Stop]                             [Clear Log]     │
│ ─────────────────────────────────────────────────────────────────  │
│ ╔══ Process Log ══════════════════════════════════════════════════╗ │
│ ║ ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━            ║ │
│ ║   m4s YD&VO  |  Self-Diagnostic                               ║ │
│ ║   [OK]  yt-dlp   ->  /usr/bin/yt-dlp                         ║ │
│ ║   [OK]  demucs   ->  /home/user/.local/bin/demucs             ║ │
│ ║   Ready — paste a URL and press Start.                        ║ │
│ ╚═════════════════════════════════════════════════════════════════╝ │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 🚀 Installation

### Linux — Universal Installer (Recommended)

The single `install_app.sh` script handles everything: dependency installation, compilation, and desktop integration.

```bash
# 1. Clone or download the repository
git clone https://github.com/your-username/m4s-ydvo.git
cd m4s-ydvo

# 2. Make the installer executable
chmod +x install_app.sh

# 3. Run the installer (do NOT run as root; it uses sudo internally)
./install_app.sh
```

The installer will:
1. Detect your package manager (pacman / apt / dnf / zypper)
2. Install Qt6, CMake, ffmpeg, yt-dlp, and pipx
3. Install demucs via `pipx` (creates an isolated virtual environment automatically)
4. Compile the Qt6 application from source
5. Install the binary to `/usr/local/bin/m4s-ydvo`
6. Create a `.desktop` entry so the app appears in your application menu

After installation:
```bash
m4s-ydvo        # run from terminal
# or find "m4s YD&VO" in your application launcher
```

---

### Supported Linux Distributions

| Distribution | Package Manager | Status |
|---|---|---|
| Arch Linux / Manjaro | `pacman` | ✅ Fully supported |
| Ubuntu / Debian / Mint | `apt` | ✅ Fully supported |
| Fedora / RHEL / CentOS | `dnf` | ✅ Fully supported |
| openSUSE Tumbleweed / Leap | `zypper` | ✅ Fully supported |
| Other (Gentoo, Void, etc.) | Manual | ⚠️ Manual build required |

---

### Windows — Manual Build

Windows is supported via manual build using **MSVC** or **MinGW** with Qt6.

#### Prerequisites (Windows)

Install the following tools:

| Tool | Download / Command |
|---|---|
| Qt 6.x (MSVC or MinGW) | [qt.io/download](https://www.qt.io/download-open-source) |
| CMake 3.16+ | [cmake.org](https://cmake.org/download/) or `winget install cmake` |
| Git | `winget install git` |
| yt-dlp | `winget install yt-dlp` or [GitHub releases](https://github.com/yt-dlp/yt-dlp/releases) |
| ffmpeg | `winget install ffmpeg` |
| Python 3.10+ | `winget install python` |
| pipx | `pip install pipx` then `python -m pipx ensurepath` |
| demucs | `pipx install demucs --pip-args="--no-cache-dir"` |

#### Build Steps (Windows — PowerShell)

```powershell
# Clone the project
git clone https://github.com/your-username/m4s-ydvo.git
cd m4s-ydvo

# Create build directory
mkdir build; cd build

# Configure with CMake (adjust CMAKE_PREFIX_PATH to your Qt installation)
cmake .. `
  -DCMAKE_PREFIX_PATH="C:/Qt/6.x.x/msvc2022_64" `
  -DCMAKE_BUILD_TYPE=Release

# Build
cmake --build . --config Release --parallel

# Run
.\Release\m4s-ydvo.exe
```

> **Note:** On Windows, ensure `yt-dlp.exe`, `ffmpeg.exe`, and `demucs` (via pipx) are all in your `%PATH%`. The app's self-diagnostic will verify this on startup.

#### Windows Deployment (Optional)

To deploy the app with all Qt DLLs included:
```powershell
windeployqt6.exe .\Release\m4s-ydvo.exe
```

---

## ⚙️ Universal CUDA Fix

### The Problem

Older NVIDIA GPUs (e.g., **Quadro M1200**, **GTX 9xx series**, and other Maxwell/Pascal-era cards) often fail with demucs when CUDA is selected:

```
RuntimeError: CUDA error: no kernel image is available for execution on the device
(cudaErrorNoKernelImageForDevice)
```

This happens because modern PyTorch versions drop CUDA kernel images for compute capabilities below 7.0 (sm_70), meaning they no longer ship pre-compiled kernels for older GPUs.

### The m4s YD&VO Solution

The app exposes a **"Processing Device"** dropdown with two options:

```
┌──────────────────────────────────┐
│ Device: [CPU  (Always Safe)    ▼]│
│         [GPU / CUDA  (Accel.)  ▼]│
└──────────────────────────────────┘
```

- **CPU (Always Safe)** — passes `--device cpu` to demucs. Works on every machine without exception. Processing takes 2–10× longer but always completes successfully.
- **GPU / CUDA (Accelerated)** — passes `--device cuda` to demucs. Dramatically faster on compatible GPUs (RTX, newer Quadro, A-series, etc.). Will fail gracefully on incompatible hardware.

When a CUDA failure is detected (non-zero exit code), the app automatically shows:

```
[!!]  Demucs failed  (exit 1)
[!!]  CUDA error — switch Device to CPU and retry.
      This avoids cudaErrorNoKernelImageForDevice on older GPUs.
```

**No editing of config files, no reinstalling PyTorch, no command-line flags** — just switch the dropdown to CPU and click Start again.

---

## 📁 Output Structure

All files are saved to `~/Downloads/m4s-ydvo/` (created automatically):

```
~/Downloads/m4s-ydvo/
├── Song Title.mp3              # yt-dlp audio download
├── Song Title.wav              # yt-dlp WAV download
├── Video Title.mp4             # yt-dlp video download
└── separated/
    └── htdemucs/
        └── Song Title/
            ├── vocals.wav      # isolated vocal track
            ├── drums.wav       # isolated drum track
            ├── bass.wav        # isolated bass track
            └── other.wav       # remaining instruments
```

---

## 🔒 Privacy-First Design

- **No accounts required.** The app never asks you to log in anywhere.
- **No telemetry.** Zero data is sent to any server by this application.
- **No cloud AI.** Demucs runs entirely on your local CPU or GPU. Your audio never leaves your machine.
- **No hidden network calls.** The only outbound connections are the yt-dlp download you explicitly request.
- **Open source.** The full source code is provided — inspect every line.

---

## 📦 Dependencies

| Tool | Role | How it's installed |
|---|---|---|
| **Qt6** (Core, Gui, Widgets) | UI framework | System package manager |
| **CMake 3.16+** | Build system | System package manager |
| **yt-dlp** | Media downloader | System package manager or upstream binary |
| **ffmpeg** | Audio/video muxing for yt-dlp | System package manager |
| **Python 3** | Runtime for demucs | System package manager |
| **pipx** | Isolated Python app installer | System package manager |
| **demucs** | AI vocal separation | `pipx install demucs` |

---

## 🛠️ Manual Build (Advanced)

If you prefer to build without the installer:

```bash
# Install dependencies manually (Arch example)
sudo pacman -S qt6-base qt6-tools cmake base-devel ffmpeg yt-dlp python-pipx

# Install demucs
pipx install demucs --pip-args="--no-cache-dir"

# Build the app
mkdir build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
make -j$(nproc)

# Run directly
./m4s-ydvo
```

---

## 🧩 Architecture

```
main.cpp
│
├── struct LangStrings          — All UI text in Arabic & English
│
└── class MainWindow : QMainWindow
    ├── buildUi()               — Constructs all widgets and layouts
    ├── retranslate()           — Updates all text labels + RTL/LTR direction
    ├── applyPalette()          — Applies dark/light Fusion QPalette
    │
    ├── runDiagnostic()         — Startup: check yt-dlp and demucs via QProcess
    │   └── onDiagFinished()    — 3-step state machine (which → python fallback → finalize)
    │
    ├── onStart()               — Snapshot output dir, build yt-dlp args, launch process
    │   ├── onDlData()          — Real-time stdout → colour log
    │   └── onDlFinished()      — On success: chain to demucs if checkbox active
    │
    └── startDemucs()           — Launch demucs with CPU or CUDA device flag
        ├── onDemucsData()      — Real-time stdout → colour log
        └── onDemucsFinished()  — Show result + CUDA tip if failed on GPU
```

---

## ❓ Troubleshooting

**The Start button stays greyed out after launch.**
→ yt-dlp is not installed or not in `$PATH`. See the diagnostic log for the exact error and fix command.

**Demucs checkbox is always greyed out.**
→ Either demucs is not installed, or a non-audio quality (Video) is selected. The checkbox only activates for Audio MP3 / Audio WAV with demucs installed.

**Download fails with "HTTP Error 403".**
→ Update yt-dlp: `yt-dlp -U` or `sudo pacman -Syu yt-dlp`.

**Demucs fails immediately on GPU.**
→ Switch the Device dropdown to "CPU (Always Safe)" and try again. See the [Universal CUDA Fix](#-universal-cuda-fix) section above.

**`pipx: command not found` after install.**
→ Add `~/.local/bin` to your PATH:
```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

**App not appearing in the application menu.**
→ Re-run: `sudo update-desktop-database /usr/share/applications/`

---

## 📄 License

This project is released under the **MIT License**. See [LICENSE](LICENSE) for details.

The underlying tools have their own licenses:
- **yt-dlp** — Unlicense
- **demucs** — MIT License (Facebook Research)
- **Qt6** — LGPL v3 / GPL v3 / Commercial

---

## 🙌 Credits

- [yt-dlp](https://github.com/yt-dlp/yt-dlp) — the backbone media downloader
- [demucs](https://github.com/facebookresearch/demucs) — Meta AI's open-source source separation
- [Qt Framework](https://www.qt.io/) — the GUI toolkit that makes cross-platform C++ beautiful

---

<div align="center">
<sub>Built with ❤️ using C++17 · Qt6 · yt-dlp · demucs</sub>
</div>
