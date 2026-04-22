#!/usr/bin/env bash
# ==============================================================================
#  m4s d — Linux Installer v2.0.0
#  GitHub : https://github.com/mahmoudelsheikh7/M4S_D
#
#  Supports:
#    Arch Linux / Manjaro / EndeavourOS  (pacman)
#    Ubuntu / Debian / Linux Mint        (apt)
#    Fedora / RHEL / Rocky               (dnf)
#    openSUSE Tumbleweed / Leap          (zypper)
#
#  Features installed:
#    Qt6, CMake, build tools, ffmpeg, yt-dlp, pipx,
#    demucs (htdemucs_ft AI model), torchcodec (audio-save fix)
#
#  Usage:
#    chmod +x install_linux.sh
#    ./install_linux.sh          ← do NOT run as root
# ==============================================================================
set -euo pipefail

RED='\033[0;31m'  GRN='\033[0;32m'  YLW='\033[1;33m'
BLU='\033[0;34m'  CYN='\033[0;36m'  BOLD='\033[1m'  NC='\033[0m'

info()    { echo -e "${CYN}[INFO]${NC}  $*"; }
success() { echo -e "${GRN}[OK]${NC}    $*"; }
warn()    { echo -e "${YLW}[WARN]${NC}  $*"; }
fail()    { echo -e "${RED}[ERR]${NC}   $*" >&2; exit 1; }
step()    { echo -e "\n${BOLD}${BLU}━━━  $*  ━━━${NC}"; }

print_banner() {
  cat <<'EOF'

  ███╗   ███╗██╗  ██╗███████╗    ██████╗
  ████╗ ████║██║  ██║██╔════╝    ██╔══██╗
  ██╔████╔██║███████║███████╗    ██║  ██║
  ██║╚██╔╝██║╚════██║╚════██║    ██║  ██║
  ██║ ╚═╝ ██║     ██║███████║    ██████╔╝
  ╚═╝     ╚═╝     ╚═╝╚══════╝    ╚═════╝

  m4s d v2.0 — Universal Downloader + AI Vocal Extractor
  Linux Installer v2.0.0
  https://github.com/mahmoudelsheikh7/M4S_D

  Features:
    · yt-dlp  (1,000+ sites, audio & video)
    · ffmpeg  (format conversion: MP3/M4A/WAV/FLAC, video audio extraction)
    · demucs  htdemucs_ft  (AI vocal isolation, shifts=2/4)
    · Qt6 C++17 GUI  (Dark/Light theme, Arabic/English)
    · Offline-First tool manager  (tools cached locally, no re-downloads)

EOF
}

# ─── Detect package manager ───────────────────────────────────────────────────

detect_pm() {
  if   command -v pacman  &>/dev/null; then echo "pacman"
  elif command -v apt-get &>/dev/null; then echo "apt"
  elif command -v dnf     &>/dev/null; then echo "dnf"
  elif command -v zypper  &>/dev/null; then echo "zypper"
  else fail "No supported package manager found (pacman/apt/dnf/zypper)."; fi
}

# ─── System dependencies ──────────────────────────────────────────────────────

install_system_deps() {
  local pm="$1"
  step "Installing system dependencies via $pm"

  case "$pm" in
    pacman)
      sudo pacman -Sy --noconfirm \
        qt6-base qt6-tools cmake base-devel git \
        ffmpeg yt-dlp \
        python python-pipx
      ;;
    apt)
      sudo apt-get update -qq
      sudo apt-get install -y \
        qt6-base-dev qt6-tools-dev cmake build-essential git \
        ffmpeg \
        python3 python3-pip pipx
      if ! command -v yt-dlp &>/dev/null; then
        info "Installing yt-dlp upstream binary …"
        sudo curl -fsSL \
          https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp \
          -o /usr/local/bin/yt-dlp
        sudo chmod a+rx /usr/local/bin/yt-dlp
      fi
      ;;
    dnf)
      sudo dnf install -y \
        https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-"$(rpm -E %fedora)".noarch.rpm \
        2>/dev/null || warn "RPM Fusion already enabled or unavailable."
      sudo dnf install -y \
        qt6-qtbase-devel qt6-qttools-devel cmake gcc-c++ make git \
        ffmpeg yt-dlp \
        python3 python3-pip pipx
      ;;
    zypper)
      sudo zypper --non-interactive refresh
      sudo zypper --non-interactive install \
        qt6-base-devel qt6-tools-devel cmake gcc-c++ make git \
        ffmpeg yt-dlp \
        python3 python3-pip python3-pipx
      ;;
  esac
  success "System dependencies installed."
}

# ─── Demucs via pipx ──────────────────────────────────────────────────────────

install_demucs() {
  step "Installing demucs (htdemucs_ft AI model) via pipx"

  if ! command -v pipx &>/dev/null; then
    info "pipx not in PATH — trying python3 -m pip install --user pipx …"
    python3 -m pip install --user pipx 2>&1 || warn "pip install pipx failed."
  fi

  export PATH="$HOME/.local/bin:$PATH"
  pipx ensurepath --force 2>/dev/null || true

  info "Running: pipx install demucs  (downloads PyTorch — may take 5–20 min, ~1–3 GB)"
  pipx install demucs --pip-args="--no-cache-dir" 2>&1 || {
    warn "pipx install failed. Trying upgrade path …"
    pipx upgrade demucs --pip-args="--no-cache-dir" 2>&1 || true
  }

  info "Running: pipx inject demucs torchcodec  (critical audio-save fix)"
  pipx inject demucs torchcodec --pip-args="--no-cache-dir" 2>&1 || {
    warn "torchcodec injection failed."
    warn "Manual fix:  pipx inject demucs torchcodec"
    warn "The app will still work but may hit audio-save errors on some systems."
  }

  if command -v demucs &>/dev/null 2>&1 || "$HOME/.local/bin/demucs" --help &>/dev/null 2>&1; then
    success "demucs + torchcodec ready at: $(command -v demucs 2>/dev/null || echo ~/.local/bin/demucs)"
  else
    warn "demucs could not be confirmed in PATH."
    warn "Add to PATH:  echo 'export PATH=\"\$HOME/.local/bin:\$PATH\"' >> ~/.bashrc && source ~/.bashrc"
  fi
}

# ─── Build ─────────────────────────────────────────────────────────────────────

build_app() {
  local src_dir="$1"
  step "Building m4s_d with CMake  (C++17, Qt6)"

  [[ -f "$src_dir/CMakeLists.txt" ]] || fail "CMakeLists.txt not found in $src_dir"
  [[ -f "$src_dir/main.cpp"       ]] || fail "main.cpp not found in $src_dir"

  local build_dir="$src_dir/build"
  rm -rf "$build_dir"
  mkdir -p "$build_dir"
  cd "$build_dir"

  cmake .. -DCMAKE_BUILD_TYPE=Release 2>&1 | tail -15
  make -j"$(nproc)" 2>&1

  [[ -f "m4s_d" ]] || fail "Build failed — binary not produced."
  success "Build succeeded: $build_dir/m4s_d"
  cd "$src_dir"
}

# ─── Install binary ────────────────────────────────────────────────────────────

install_binary() {
  local build_dir="$1/build"
  step "Installing binary to /usr/local/bin/m4s_d"
  sudo install -m 755 "$build_dir/m4s_d" /usr/local/bin/m4s_d
  success "Binary installed: /usr/local/bin/m4s_d"
}

# ─── Desktop entry ─────────────────────────────────────────────────────────────

create_desktop_entry() {
  step "Creating .desktop launcher entry"
  sudo tee /usr/share/applications/m4s_d.desktop >/dev/null <<'DESK'
[Desktop Entry]
Version=1.0
Type=Application
Name=m4s d
GenericName=Universal Downloader & Vocal Extractor
Comment=Download media with yt-dlp and isolate vocals with Meta Demucs AI. Bilingual Arabic/English. Dark/Light themes.
Exec=m4s_d
Icon=applications-multimedia
Terminal=false
Categories=AudioVideo;Network;Utility;
Keywords=youtube;download;vocal;demucs;yt-dlp;m4a;mp3;mp4;flac;wav;ai;arabic;
StartupWMClass=m4s_d
DESK

  command -v update-desktop-database &>/dev/null && \
    sudo update-desktop-database /usr/share/applications/ 2>/dev/null || true
  success ".desktop entry created."
}

# ─── Success banner ────────────────────────────────────────────────────────────

print_success() {
  cat <<'MSG'

  ╔══════════════════════════════════════════════════════════════╗
  ║           m4s d v2.0 — Installation Complete!                ║
  ╠══════════════════════════════════════════════════════════════╣
  ║                                                              ║
  ║  Launch:   m4s_d   (terminal)                                ║
  ║            "m4s d"  (application menu)                       ║
  ║                                                              ║
  ║  Formats:  Audio → MP3 · M4A · WAV · FLAC                    ║
  ║            Video → Best · 4K · 1080p · 720p · 480p           ║
  ║                                                              ║
  ║  No Music: demucs htdemucs_ft · shifts=2 (normal)            ║
  ║                               · shifts=4 (extreme mode)      ║
  ║            saves "Title (no music).[ext]"                    ║
  ║            auto-deletes original + demucs temp files         ║
  ║                                                              ║
  ║  Local Files: browse any video/audio file for processing     ║
  ║  Bilingual:   Arabic / English toggle (⚙ in toolbar)         ║
  ║  Themes:      Dark / Light mode toggle                       ║
  ║                                                              ║
  ║  NOTE: If demucs is not found, add to PATH:                  ║
  ║    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc  ║
  ║    source ~/.bashrc                                          ║
  ║                                                              ║
  ╚══════════════════════════════════════════════════════════════╝

MSG
}

# ─── Main ──────────────────────────────────────────────────────────────────────

main() {
  print_banner

  [[ "$EUID" -eq 0 ]] && fail "Do not run as root. The script uses sudo internally."

  local PM
  PM="$(detect_pm)"
  info "Package manager detected: $PM"

  install_system_deps "$PM"
  install_demucs

  local SCRIPT_DIR
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

  build_app     "$SCRIPT_DIR"
  install_binary "$SCRIPT_DIR"
  create_desktop_entry
  print_success
}

main "$@"
