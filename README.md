# m4s d — Universal Downloader & AI Vocal Extractor

```
  ███╗   ███╗██╗  ██╗███████╗    ██████╗
  ████╗ ████║██║  ██║██╔════╝    ██╔══██╗
  ██╔████╔██║███████║███████╗    ██║  ██║
  ██║╚██╔╝██║╚════██║╚════██║    ██║  ██║
  ██║ ╚═╝ ██║     ██║███████║    ██████╔╝
  ╚═╝     ╚═╝     ╚═╝╚══════╝    ╚═════╝
  v2.0.0  —  Universal Downloader + AI Vocal Extractor
```

[![C++17](https://img.shields.io/badge/C%2B%2B-17-blue?logo=cplusplus)](https://isocpp.org/)
[![Qt6](https://img.shields.io/badge/Qt-6-green?logo=qt)](https://www.qt.io/)
[![Platform](https://img.shields.io/badge/Platform-Linux%20%7C%20Windows-lightgrey?logo=linux)](https://github.com/mahmoudelsheikh7/M4S_D)
[![AI](https://img.shields.io/badge/AI-Meta%20Demucs%20htdemucs__ft-purple?logo=pytorch)](https://github.com/facebookresearch/demucs)
[![License](https://img.shields.io/badge/License-MIT-yellow)](LICENSE)
[![Donate](https://img.shields.io/badge/Donate-USDT%20TRC20-green?logo=tether)](https://tronscan.org/#/address/TLTRj89qEp1oPcEQjAsqiDWutd1ezd4W4y)

> Download audio & video from **1,000+ websites** and extract clean vocals with **Meta's Demucs AI** — all from one sleek Qt6 desktop app with bilingual Arabic/English support.

---

## ✨ Features

| Feature | Details |
|---|---|
| 🌐 **1,000+ Sites** | Powered by yt-dlp — YouTube, SoundCloud, Spotify, TikTok, Twitter/X, and more |
| 🎤 **AI Vocal Extraction** | Meta Demucs `htdemucs_ft` model, `--two-stems=vocals` |
| ⚡ **Extreme Isolation** | shifts=4, overlap=0.25 — maximum quality, slower processing |
| 📁 **Local File Support** | Drag & drop or browse any audio/video file |
| 🎬 **Video Audio Extraction** | ffmpeg extracts audio from video files before processing |
| 🌙 **Dark / Light Theme** | Fusion-style Qt6 themes, saved between sessions |
| 🌐 **Arabic / English** | Full RTL/LTR bilingual UI toggle |
| ⚙ **Offline-First Tools** | yt-dlp & ffmpeg cached locally — no re-downloads |
| 🧹 **Auto Cleanup** | Deletes temp files, extracted audio, demucs output after saving |
| 🖥 **GPU / CPU Mode** | CUDA acceleration with automatic CPU fallback |

---

## 🎵 Supported Formats

| Type | Formats |
|---|---|
| **Audio Output** | MP3 (VBR q2), M4A (AAC 256k), WAV (PCM), FLAC (lossless) |
| **Video Output** | Best, 4K (2160p), 1080p, 720p, 480p — merged to MP4 |
| **Local Input** | MP3, M4A, WAV, FLAC, OGG, OPUS, MP4, MKV, WEBM, AVI, MOV, FLV |

---

## 🔄 Processing Pipeline

```
┌──────────────────────────────────────────────────────────────────────┐
│                        m4s d  PIPELINE                               │
├──────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  INPUT                                                               │
│  ┌──────────────┐     ┌──────────────────────────────────────────┐  │
│  │  URL (yt-dlp)│────▶│ Download audio as WAV  ──or──            │  │
│  │  Local File  │────▶│ Extract audio from video (ffmpeg -vn)    │  │
│  └──────────────┘     └──────────────────┬───────────────────────┘  │
│                                          │                           │
│  ┌───────────────────────────────────────▼───────────────────────┐  │
│  │  "No Music" checked?                                           │  │
│  │                                                                │  │
│  │  YES ──▶ demucs -n htdemucs_ft --two-stems=vocals             │  │
│  │          (shifts=2 normal  /  shifts=4 extreme)               │  │
│  │          ──▶ vocals.wav                                        │  │
│  │                                                                │  │
│  │  NO  ──▶ Skip demucs                                          │  │
│  └───────────────────────────────────────┬────────────────────────┘  │
│                                          │                           │
│  ┌───────────────────────────────────────▼───────────────────────┐  │
│  │  ffmpeg convert  ──▶  MP3 / M4A / WAV / FLAC                  │  │
│  │  Output name:  "Title (no music).ext"  or  "Title.ext"        │  │
│  └───────────────────────────────────────┬────────────────────────┘  │
│                                          │                           │
│  ┌───────────────────────────────────────▼───────────────────────┐  │
│  │  🧹 AUTO CLEANUP                                               │  │
│  │  Delete: original download · temp WAV · demucs output folder  │  │
│  └───────────────────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────────────────┘
```

---

## 🐧 Linux Installation

### Requirements
- GCC / Clang, CMake ≥ 3.16
- Qt6 (Base, Widgets, Network, Tools)
- Python 3.9+ with pipx

### One-command install

```bash
git clone https://github.com/mahmoudelsheikh7/M4S_D
cd M4S_D
chmod +x install_linux.sh
./install_linux.sh
```

The script auto-detects your distro and handles everything:

**Arch / Manjaro / EndeavourOS** — `pacman`
**Ubuntu / Debian / Mint** — `apt`
**Fedora / RHEL / Rocky** — `dnf` + RPM Fusion
**openSUSE** — `zypper`

After installation:
```bash
m4s_d         # launch from terminal
# or open "m4s d" from your application menu
```

> **Note:** If demucs is not found after install:
> ```bash
> echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
> source ~/.bashrc
> ```

---

## 🪟 Windows Installation

### Requirements
- Windows 10/11 (64-bit)
- Python 3.9+ from [python.org](https://www.python.org/downloads/)
- For building the GUI: [Qt Creator](https://www.qt.io/download) or MSYS2

### Step 1 — Download tools automatically

```powershell
# Allow script execution (run once)
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned

# Run installer
.\install_windows.ps1
```

This downloads yt-dlp.exe, ffmpeg.exe, and installs demucs into a Python venv at `%LOCALAPPDATA%\m4s\m4s_d\`.

### Step 2 — Build the GUI (Qt Creator — recommended)

1. Install [Qt 6.x](https://www.qt.io/download-open-source) (select Qt 6.x → MSVC or MinGW)
2. Open **Qt Creator** → Open Project → select `CMakeLists.txt`
3. Configure build kit → click **Build** → click **Run**

### Step 2 (alternate) — Build with MSYS2

```bash
# In MSYS2 MinGW64 terminal:
pacman -S mingw-w64-x86_64-qt6-base mingw-w64-x86_64-cmake mingw-w64-x86_64-gcc make
mkdir build && cd build
cmake .. -G "MinGW Makefiles" -DCMAKE_BUILD_TYPE=Release
mingw32-make -j4
```

---

## 🔧 Manual Build (any platform)

```bash
mkdir build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
make -j$(nproc)         # Linux / macOS
# or: cmake --build . --config Release   # Windows
```

---

## 📁 Project Structure

```
M4S_D/
├── main.cpp              ← Qt6 C++17 application source (single file)
├── CMakeLists.txt        ← CMake build configuration
├── m4s_d_desktop.in      ← Linux .desktop entry template
├── install_linux.sh      ← Linux installer (pacman/apt/dnf/zypper)
├── install_windows.ps1   ← Windows tool downloader + venv setup
├── README.md             ← This file
└── index.html            ← Project landing page
```

---

## 🙏 Credits & Dependencies

| Tool | License | Purpose |
|---|---|---|
| [yt-dlp](https://github.com/yt-dlp/yt-dlp) | Unlicense | Download from 1,000+ sites |
| [ffmpeg](https://ffmpeg.org/) | LGPL/GPL | Audio/video conversion |
| [Meta Demucs](https://github.com/facebookresearch/demucs) | MIT | AI vocal separation |
| [Qt6](https://www.qt.io/) | LGPL | GUI framework |
| [torchcodec](https://github.com/pytorch/torchcodec) | BSD | Audio codec fix for demucs |

---

## 💛 Support the Project

If m4s d saves you time and you'd like to say thanks, a crypto donation is greatly appreciated. It keeps the project alive and motivates future improvements.

```
┌─────────────────────────────────────────────────────────────────┐
│                    💛  DONATE — USDT TRC20                      │
│                                                                 │
│   Address:  TLTRJ89qEp1oPcEQjAsqiDWutd1ezd4W4y                 │
│                                                                 │
│   Network:  TRON (TRC20)  ·  Token: USDT (Tether)              │
│                                                                 │
│   ⚠  Always verify the address before sending.                  │
│      Only send USDT on the TRC20 network.                       │
└─────────────────────────────────────────────────────────────────┘
```

**USDT TRC20:** `TLTRj89qEp1oPcEQjAsqiDWutd1ezd4W4y`

---

## 📜 License

MIT License — see [LICENSE](LICENSE) for details.

---

*Made with ❤ by [mahmoudelsheikh7](https://github.com/mahmoudelsheikh7)*
