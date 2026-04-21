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

[![Platform](https://img.shields.io/badge/Platform-Linux-blue?style=flat-square&logo=linux)](https://github.com)
[![Language](https://img.shields.io/badge/Language-C++17%20%7C%20Qt6-green?style=flat-square&logo=qt)](https://www.qt.io/)
[![License](https://img.shields.io/badge/License-MIT-yellow?style=flat-square)](LICENSE)
[![AI Model](https://img.shields.io/badge/AI-htdemucs__ft%20%7C%20Zero%20Bleed-purple?style=flat-square)](https://github.com/facebookresearch/demucs)
[![Installer](https://img.shields.io/badge/Installer-Universal%20%7C%204%20Distros-orange?style=flat-square)](install_m4s.sh)
[![Offline](https://img.shields.io/badge/AI-100%25%20Local%20%7C%20No%20Cloud-red?style=flat-square)](https://github.com)

</div>

---

## 🌐 وصف ثنائي اللغة | Bilingual Description

### العربية 🇸🇦

**م4س YD&VO** هو تطبيق سطح مكتب مبني بـ **C++ / Qt6** يعمل كواجهة رسومية متكاملة لأداتين قويتين:

- **yt-dlp** — لتنزيل الفيديو والصوت من يوتيوب وأكثر من 1000 موقع آخر بأفضل جودة.
- **demucs** — للذكاء الاصطناعي المحلي لفصل الصوت البشري عن الموسيقى بدون أي خادم سحابي.

يستخدم التطبيق نموذج **htdemucs_ft** مع خيار **`--shifts=2`** لضمان **صفر نزيف موسيقي** في المخرجات. يدعم التطبيق:
- **الوضع الداكن والفاتح** مع تبديل بنقرة واحدة.
- **تبديل اللغة عربي/إنجليزي** مع دعم الاتجاه من اليمين لليسار.
- **الفحص الذاتي للأدوات** عند بدء التشغيل.
- **تشغيل الملفات المحلية** عبر ffmpeg بالإضافة للروابط الإلكترونية.
- **إدارة ذكية لأجهزة المعالجة** (CPU/CUDA) مع رجوع تلقائي للـ CPU عند فشل CUDA.

### English 🇬🇧

**m4s YD&VO** is a **C++ Qt6** desktop application acting as a clean graphical front-end for two powerful command-line tools:

- **yt-dlp** — downloads audio/video from YouTube and 1,000+ other sites at any quality.
- **demucs** — Meta's AI vocal separator that runs **100% locally**, splitting vocals from instrumentals with no cloud dependency.

The app uses the **htdemucs_ft** model with **`--shifts=2`** and **`--two-stems=vocals`** flags for **zero music bleed** in every output. It features a **bilingual Arabic/English UI**, **Dark/Light mode**, startup **self-diagnostics** for all three tools, a **Browse Local File** panel with automatic ffmpeg audio extraction, and smart **CPU/GPU CUDA fallback** that retries automatically on older cards.

---

## ✨ Features | المميزات

| Feature | Details |
|---|---|
| 🎵 **Audio Download** | MP3 (best quality) · WAV (lossless) via yt-dlp |
| 🎬 **Video Download** | Best · 1080p · 720p · 480p (auto-merge via ffmpeg) |
| 📂 **Local File Support** | Browse any video/audio file; auto-extract audio with ffmpeg |
| 🤖 **AI Vocal Isolation** | htdemucs_ft · `--shifts=2` · `--two-stems=vocals` · 100% local |
| 🔇 **Zero Music Bleed** | `htdemucs_ft` + `--shifts=2` eliminates instrument leakage |
| 🔍 **3-Tool Self-Diagnostic** | Startup check for yt-dlp, ffmpeg, and demucs |
| 🌙 **Dark / Light Mode** | One-click Fusion palette toggle |
| 🌐 **Arabic / English UI** | Full RTL ↔ LTR bidirectional layout switch |
| ⚡ **CPU / GPU Radio Buttons** | Force CPU or enable CUDA with visual radio selection |
| 🔄 **Auto CUDA Fallback** | CUDA failure auto-retried on CPU — no user action needed |
| 🔧 **torchcodec Fix** | `pipx inject demucs torchcodec` prevents audio saving errors |
| 📋 **Clipboard Paste** | Instant URL paste from clipboard |
| 📺 **Real-time Colour Log** | Live output from yt-dlp, ffmpeg, and demucs in distinct colours |
| 🔇 **Non-blocking UI** | All processing via `QProcess` — UI always stays responsive |
| 🔒 **Privacy-First** | No telemetry, no accounts, no cloud. Everything runs locally |

---

## 🖥️ UI Overview

```
┌──────────────────────────────────────────────────────────────────────┐
│  m4s YD&VO v2.0 — YouTube Downloader & Vocal Output  [العربية] [🌙] │
├──────────────────────────────────────────────────────────────────────┤
│ ╔══ Download Settings ═══════════════════════════════════════════╗  │
│ ║ ┌─ 📡 Online URL ──────┐  ┌─ 📂 Local File ────────────────┐ ║  │
│ ║ │ URL: [youtube.com...] [📋 Paste]                          │ ║  │
│ ║ │                        [📂 Browse] [path/to/file.mp4    ] │ ║  │
│ ║ └────────────────────────┘  └──────────────────────────────┘ ║  │
│ ║ Quality: [Audio MP3 ▼]  Device: ● CPU (Safe)  ○ GPU (CUDA)  ║  │
│ ║ ✨  Ultimate Vocal Isolation — htdemucs_ft                    ║  │
│ ╚══════════════════════════════════════════════════════════════╝  │
│                                                                    │
│  [▶  Start]  [■  Stop]                          [Clear Log]       │
│ ──────────────────────────────────────────────────────────────── │
│ ╔══ Process Log ══════════════════════════════════════════════════╗ │
│ ║  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━               ║ │
│ ║    m4s YD&VO v2.0  |  Self-Diagnostic                         ║ │
│ ║    [OK]  yt-dlp   ->  /usr/bin/yt-dlp                         ║ │
│ ║    [OK]  ffmpeg   ->  /usr/bin/ffmpeg                          ║ │
│ ║    [OK]  demucs  ->  /home/user/.local/bin/demucs              ║ │
│ ║    [OK]  Model: htdemucs_ft  |  shifts=2  |  two-stems=vocals  ║ │
│ ║    [OK]  torchcodec: injected (audio save fix active)          ║ │
│ ║    Ready — paste a URL, or browse a local file, then Start.    ║ │
│ ╚═════════════════════════════════════════════════════════════════╝ │
└──────────────────────────────────────────────────────────────────────┘
```

---

## 🚀 Installation | التثبيت

### Linux — Universal Installer (Recommended)

```bash
# 1. Clone the repository
git clone https://github.com/mahmoudelsheikh7/m4s_YD-VO.git
cd m4s-ydvo

# 2. Make the installer executable
chmod +x install_m4s.sh

# 3. Run (do NOT use sudo — it uses sudo internally when needed)
./install_m4s.sh
```

The installer performs these steps automatically:

1. **Detects** your package manager (pacman / apt / dnf / zypper)
2. **Installs** Qt6, CMake, build tools, ffmpeg, yt-dlp, and pipx
3. **Installs** demucs via `pipx install demucs`
4. **Injects** torchcodec via `pipx inject demucs torchcodec` *(critical audio save fix)*
5. **Generates** `CMakeLists.txt` and `main.cpp` from embedded source
6. **Compiles** the Qt6 application with CMake and make
7. **Installs** the binary to `/usr/local/bin/m4s-ydvo`
8. **Creates** a `.desktop` file for your application menu

After installation:
```bash
m4s-ydvo
# or launch "m4s YD&VO" from your application menu
```

---

### Supported Linux Distributions

| Distribution | Package Manager | Status |
|---|---|---|
| Arch Linux / Manjaro / EndeavourOS | `pacman` | ✅ Fully supported |
| Ubuntu / Debian / Linux Mint / Pop!_OS | `apt` | ✅ Fully supported |
| Fedora / RHEL / Rocky / AlmaLinux | `dnf` | ✅ Fully supported |
| openSUSE Tumbleweed / Leap | `zypper` | ✅ Fully supported |
| Gentoo / Void / NixOS / Other | Manual | ⚠️ Manual build required |

---

## ⚙️ Universal CUDA Fix | إصلاح أخطاء CUDA الشامل

### 🔴 The Problem | المشكلة

Older NVIDIA GPUs — including **Quadro M-series**, **GTX 9xx/10xx (Maxwell/Pascal)**, and any card with compute capability below **sm_70** — often fail when demucs runs with CUDA:

```
RuntimeError: CUDA error: no kernel image is available for execution on the device
(cudaErrorNoKernelImageForDevice)
```

Modern PyTorch versions drop pre-compiled CUDA kernels for older compute capabilities. This is a PyTorch build limitation, not a demucs bug.

Additionally, some systems encounter an audio-saving crash after demucs finishes processing:

```
AttributeError: module 'torchaudio.backend.sox_io_backend' has no attribute 'save'
```

This is caused by `torchaudio` breaking its backend API in newer versions.

---

### 🟢 The m4s YD&VO Solution | الحل

The installer and the app together implement a **three-layer fix**:

#### Layer 1 — torchcodec Injection (Install-time Fix)

The installer runs this critical command automatically:

```bash
pipx inject demucs torchcodec
```

`torchcodec` is Meta's modern audio I/O library that replaces the broken `torchaudio.backend.sox_io_backend.save()` call. This silently prevents audio-saving crashes before they can occur, with no user intervention needed.

#### Layer 2 — CPU/GPU Radio Button Control (User Control)

The app exposes a clear **Device** radio button group:

```
Device:  ● CPU  (Always Safe)     ○ GPU / CUDA  (Accelerated)
```

- **CPU (Always Safe)** — passes `-d cpu` to demucs. Works on every machine without exception. Takes 2–10× longer but always completes.
- **GPU / CUDA (Accelerated)** — passes `-d cuda` to demucs. Dramatically faster on RTX, A-series, and newer Quadro cards.

#### Layer 3 — Automatic CUDA Fallback (Runtime Retry)

When GPU is selected and demucs exits with a non-zero code, the app **automatically**:

1. Detects the CUDA failure
2. Logs an explanation
3. Switches the radio button to CPU
4. **Retries the exact same file on CPU without any user action**

```
[!!]  CUDA error detected — automatically retrying with CPU...
      (cudaErrorNoKernelImageForDevice: older GPU not supported by this PyTorch build)
```

This means users with older GPUs experience **zero friction**: click Start, the app handles the rest.

---

## 🎯 AI Model Details | تفاصيل نموذج الذكاء الاصطناعي

The app uses the **`htdemucs_ft`** model with carefully chosen flags:

| Flag | Value | Purpose |
|---|---|---|
| `-n` | `htdemucs_ft` | Fine-tuned Hybrid Transformer Demucs — best separation quality |
| `--two-stems` | `vocals` | Outputs only `vocals.wav` + `no_vocals.wav` (faster, cleaner) |
| `--shifts` | `2` | Runs 2 shifted predictions and averages — eliminates music bleed |
| `-d` | `cpu` or `cuda` | Device selection with auto-fallback |
| `-o` | `~/Downloads/m4s-ydvo/` | All output in one organized folder |

The combination of `htdemucs_ft` + `--shifts=2` + `--two-stems=vocals` is the recommended configuration for professional-quality vocal isolation with zero instrument leakage into the vocal stem.

---

## 📁 Output Structure | هيكل المخرجات

```
~/Downloads/m4s-ydvo/
├── Song Title.mp3                  ← yt-dlp audio download
├── Song Title.wav                  ← yt-dlp WAV download
├── Video Title.mp4                 ← yt-dlp video download
├── temp_audio_<timestamp>.mp3      ← ffmpeg local extraction (auto-cleaned)
└── htdemucs_ft/
    └── Song Title/
        ├── vocals.wav              ← isolated vocal track ✨
        └── no_vocals.wav           ← instrumental / backing track
```

---

## 🔄 Pipeline Logic | منطق المعالجة

```
User Input
    │
    ├─── [Online URL Tab]
    │        │
    │        └── Step A: yt-dlp download
    │                 └── [if Demucs checked] ──► Step C: demucs
    │
    └─── [Local File Tab]
             │
             ├── [Audio file: .mp3/.wav/.flac/etc.]
             │        └── [if Demucs checked] ──► Step C: demucs
             │            [else] copy to output folder
             │
             └── [Video file: .mp4/.mkv/.avi/etc.]
                      └── Step B: ffmpeg extract audio
                               └── [if Demucs checked] ──► Step C: demucs


Step C — Demucs Pipeline:
    demucs -n htdemucs_ft --two-stems=vocals --shifts=2 -d <device> <file>
        │
        ├── SUCCESS ──► vocals.wav + no_vocals.wav saved
        │
        └── FAILURE (CUDA) ──► Auto-retry with CPU
                 └── SUCCESS ──► vocals.wav + no_vocals.wav saved
```

---

## 🧩 Architecture | البنية المعمارية

```
main.cpp
│
├── struct LangStrings          — All UI text in Arabic & English
│
└── class MainWindow : QMainWindow
    ├── buildUi()               — Constructs all widgets, tabs, and layouts
    ├── retranslate()           — Updates all text + RTL/LTR direction
    ├── applyPalette()          — Applies dark/light Fusion QPalette
    │
    ├── runDiagnostic()         — Startup: check yt-dlp, ffmpeg, demucs
    │   └── onDiagFinished()    — 4-step state machine
    │
    ├── onStart()               — Route: URL tab vs. Local File tab
    │   ├── [URL]   buildYtdlpArgs() → yt-dlp QProcess
    │   └── [File]  isAudioFile()?
    │               ├── yes → startDemucs() or copy
    │               └── no  → startExtract() [ffmpeg]
    │
    ├── startExtract()          — ffmpeg -i input -q:a 0 -map a output.mp3
    │   └── onExtractFinished() — chain to startDemucs() if checked
    │
    └── startDemucs()           — htdemucs_ft --two-stems=vocals --shifts=2
        └── onDemucsFinished()  — auto-retry on CUDA fail (cudaFailed flag)
```

---

## ❓ Troubleshooting | استكشاف الأخطاء

**The Start button stays greyed out.**
→ Check the diagnostic log. Either `yt-dlp` (for URLs) or `ffmpeg` (for local files) is missing.

**Demucs checkbox is greyed out.**
→ demucs is not installed, or a Video quality is selected in URL mode.

**Demucs fails with an audio saving error.**
→ Run: `pipx inject demucs torchcodec` — this is the critical fix for torchaudio backend changes.

**Demucs fails on GPU.**
→ The app automatically retries on CPU. No action needed. If you want to permanently use CPU, select the CPU radio button before clicking Start.

**Download fails with "HTTP Error 403".**
→ Update yt-dlp: `yt-dlp -U` or reinstall via `pipx install yt-dlp`.

**`demucs: command not found` after install.**
→ Add `~/.local/bin` to your PATH:
```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc && source ~/.bashrc
```

**App not appearing in the application menu.**
→ Run: `sudo update-desktop-database /usr/share/applications/`

**FFmpeg extraction produces no audio.**
→ The video file may have no audio track. Check with: `ffprobe -show_streams your_file.mp4`

---

## 📦 Dependencies | التبعيات

| Tool | Role | Installed By |
|---|---|---|
| **Qt6** (Core, Gui, Widgets) | GUI framework | System package manager |
| **CMake 3.16+** | Build system | System package manager |
| **yt-dlp** | Online media downloader | System package manager / upstream binary |
| **ffmpeg** | Audio extraction from local videos | System package manager |
| **Python 3** | Runtime for demucs | System package manager |
| **pipx** | Isolated Python app environment | System package manager |
| **demucs** | AI vocal separation | `pipx install demucs` |
| **torchcodec** | Audio I/O fix for newer PyTorch | `pipx inject demucs torchcodec` |

---

## 🛠️ Manual Build | البناء اليدوي

```bash
# Arch Linux
sudo pacman -S qt6-base qt6-tools cmake base-devel ffmpeg yt-dlp python-pipx

# Ubuntu / Debian
sudo apt install qt6-base-dev qt6-tools-dev cmake build-essential ffmpeg pipx python3

# Install demucs with torchcodec fix
pipx install demucs
pipx inject demucs torchcodec

# Build
mkdir build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
make -j$(nproc)

# Run
./m4s-ydvo
```

---

## 🔒 Privacy-First Design | التصميم المراعي للخصوصية

- **No accounts required.** The app never asks you to sign in anywhere.
- **No telemetry.** Zero data is sent to any server by this application.
- **No cloud AI.** Demucs runs entirely on your local CPU or GPU. Your audio never leaves your machine.
- **No hidden network calls.** The only outbound connection is the yt-dlp download you explicitly request.
- **Open source.** Full C++ source code is generated and compiled on your own machine.

---

## 📄 License | الرخصة

This project is released under the **MIT License**. See [LICENSE](LICENSE) for details.

Underlying tools have their own licenses:
- **yt-dlp** — The Unlicense
- **demucs** — MIT License (Meta AI Research)
- **Qt6** — LGPL v3 / GPL v3 / Commercial

---

## 🙌 Credits | الشكر والتقدير

- [yt-dlp](https://github.com/yt-dlp/yt-dlp) — the backbone media downloader
- [demucs](https://github.com/facebookresearch/demucs) — Meta AI's open-source source separation
- [Qt Framework](https://www.qt.io/) — the GUI toolkit powering the interface
- [torchcodec](https://github.com/pytorch/torchcodec) — Meta's modern audio I/O that fixes the torchaudio save errors

---

<div align="center">
<sub>Built with ❤️ using C++17 · Qt6 · yt-dlp · ffmpeg · demucs htdemucs_ft</sub>
</div>
