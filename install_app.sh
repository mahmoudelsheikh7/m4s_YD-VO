#!/usr/bin/env bash
# ==============================================================================
#  m4s YD&VO — Universal Linux Installer
#  Supports: Arch (pacman) · Debian/Ubuntu (apt) · Fedora (dnf) · openSUSE (zypper)
# ==============================================================================
set -euo pipefail

# ── Colours ───────────────────────────────────────────────────────────────────
RED='\033[0;31m'  GRN='\033[0;32m'  YLW='\033[1;33m'
BLU='\033[0;34m'  CYN='\033[0;36m'  MAG='\033[0;35m'
BOLD='\033[1m'    DIM='\033[2m'     NC='\033[0m'

# ── Helpers ───────────────────────────────────────────────────────────────────
info()    { echo -e "${CYN}[INFO]${NC} $*"; }
success() { echo -e "${GRN}[OK]${NC}   $*"; }
warn()    { echo -e "${YLW}[WARN]${NC} $*"; }
error()   { echo -e "${RED}[ERR]${NC}  $*" >&2; exit 1; }
step()    { echo -e "\n${BOLD}${BLU}━━━  $*  ━━━${NC}"; }

# ── Banner ────────────────────────────────────────────────────────────────────
print_banner() {
cat << 'BANNER'

  ███╗   ███╗██╗  ██╗███████╗    ██╗   ██╗██████╗ ██╗   ██╗ ██████╗
  ████╗ ████║██║  ██║██╔════╝    ╚██╗ ██╔╝██╔══██╗██║   ██║██╔═══██╗
  ██╔████╔██║███████║███████╗     ╚████╔╝ ██║  ██║██║   ██║██║   ██║
  ██║╚██╔╝██║╚════██║╚════██║      ╚██╔╝  ██║  ██║╚██╗ ██╔╝██║   ██║
  ██║ ╚═╝ ██║     ██║███████║       ██║   ██████╔╝ ╚████╔╝ ╚██████╔╝
  ╚═╝     ╚═╝     ╚═╝╚══════╝       ╚═╝   ╚═════╝   ╚═══╝   ╚═════╝

  YouTube Downloader & Vocal Output — Qt6 Desktop Application
  Universal Linux Installer v1.0.0
BANNER
echo ""
}

# ── Package manager detection ─────────────────────────────────────────────────
detect_pm() {
    if   command -v pacman  &>/dev/null; then echo "pacman"
    elif command -v apt-get &>/dev/null; then echo "apt"
    elif command -v dnf     &>/dev/null; then echo "dnf"
    elif command -v zypper  &>/dev/null; then echo "zypper"
    else error "No supported package manager found (pacman/apt/dnf/zypper)."; fi
}

# ── System dependency installation ───────────────────────────────────────────
install_system_deps() {
    local pm="$1"
    step "Installing system dependencies via $pm"

    case "$pm" in
        pacman)
            sudo pacman -Sy --noconfirm \
                qt6-base qt6-tools qt6-svg \
                cmake base-devel git \
                ffmpeg yt-dlp \
                python python-pipx
            ;;
        apt)
            sudo apt-get update -qq
            sudo apt-get install -y \
                qt6-base-dev qt6-tools-dev libqt6svg6-dev \
                cmake build-essential git \
                ffmpeg \
                python3 python3-pip pipx
            # yt-dlp: prefer the upstream binary for freshness
            if ! command -v yt-dlp &>/dev/null; then
                info "Installing yt-dlp upstream binary..."
                sudo curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp \
                     -o /usr/local/bin/yt-dlp
                sudo chmod a+rx /usr/local/bin/yt-dlp
            fi
            ;;
        dnf)
            # Enable RPM Fusion for ffmpeg
            sudo dnf install -y \
                https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
                || warn "RPM Fusion may already be enabled."
            sudo dnf install -y \
                qt6-qtbase-devel qt6-qttools-devel qt6-qtsvg-devel \
                cmake gcc-c++ make git \
                ffmpeg yt-dlp \
                python3 python3-pip pipx
            ;;
        zypper)
            sudo zypper refresh
            sudo zypper install -y \
                qt6-base-devel qt6-tools-devel qt6-svg-devel \
                cmake gcc-c++ make git \
                ffmpeg yt-dlp \
                python3 python3-pip python3-pipx
            ;;
    esac
    success "System dependencies installed."
}

# ── pipx + demucs ─────────────────────────────────────────────────────────────
install_demucs() {
    step "Installing demucs (AI vocal separation) via pipx"

    # Ensure pipx is usable
    if ! command -v pipx &>/dev/null; then
        python3 -m pip install --user pipx || warn "pip install pipx failed; trying system path."
    fi

    # Add pipx bin dir to PATH for this session
    export PATH="$HOME/.local/bin:$PATH"
    pipx ensurepath --force || true

    info "Running: pipx install demucs  (this downloads PyTorch; ~1-3 GB — be patient)"
    pipx install demucs --pip-args="--no-cache-dir" || {
        warn "pipx install demucs failed. Trying upgrade..."
        pipx upgrade demucs --pip-args="--no-cache-dir" || true
    }

    if command -v demucs &>/dev/null || python3 -c "import demucs" 2>/dev/null; then
        success "demucs installed successfully."
    else
        warn "demucs installation could not be confirmed. The app will warn at startup."
        warn "You can install it later: pipx install demucs --pip-args='--no-cache-dir'"
    fi
}

# ── Generate source files ─────────────────────────────────────────────────────
generate_sources() {
    local BUILD_DIR="$1"
    step "Generating source files in $BUILD_DIR"
    mkdir -p "$BUILD_DIR"

    # ── CMakeLists.txt ────────────────────────────────────────────────────────
    cat << 'CMAKEEOF' > "$BUILD_DIR/CMakeLists.txt"
cmake_minimum_required(VERSION 3.16)
project(m4s-ydvo LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

find_package(Qt6 REQUIRED COMPONENTS Core Gui Widgets)

qt_add_executable(m4s-ydvo main.cpp)

target_link_libraries(m4s-ydvo PRIVATE Qt6::Core Qt6::Gui Qt6::Widgets)

install(TARGETS m4s-ydvo DESTINATION bin)
CMAKEEOF

    success "CMakeLists.txt generated."

    # ── main.cpp ──────────────────────────────────────────────────────────────
    cat << 'CPPEOF' > "$BUILD_DIR/main.cpp"
#include <QApplication>
#include <QMainWindow>
#include <QWidget>
#include <QVBoxLayout>
#include <QHBoxLayout>
#include <QLabel>
#include <QLineEdit>
#include <QPushButton>
#include <QComboBox>
#include <QCheckBox>
#include <QTextEdit>
#include <QProcess>
#include <QClipboard>
#include <QGroupBox>
#include <QScrollBar>
#include <QPalette>
#include <QColor>
#include <QFont>
#include <QDir>
#include <QStandardPaths>
#include <QTimer>
#include <QFrame>
#include <QFileInfo>
#include <QFileInfoList>
#include <QSet>
#include <QStyle>
#include <QStyleFactory>
#include <QSizePolicy>
#include <QDateTime>
#include <QString>
#include <QStringList>
#include <QGuiApplication>
#include <QScreen>
#include <QRect>

struct LangStrings {
    bool ar = false;

    QString appTitle()     const { return ar ? "م4س — تنزيل وفصل الصوت والفيديو"       : "m4s YD&VO — YouTube Downloader & Vocal Output"; }
    QString urlLbl()       const { return ar ? "رابط الوسائط :"                          : "Media URL:"; }
    QString pasteTxt()     const { return ar ? "📋 لصق"                                  : "📋 Paste"; }
    QString qualLbl()      const { return ar ? "جودة التنزيل :"                           : "Download Quality:"; }
    QString devLbl()       const { return ar ? "جهاز المعالجة :"                          : "Processing Device:"; }
    QString demucsTxt()    const { return ar ? "تشغيل Demucs — استخراج الصوت البشري"     : "Run Demucs — Extract Vocals"; }
    QString startTxt()     const { return ar ? "▶   ابدأ"                                 : "▶   Start"; }
    QString stopTxt()      const { return ar ? "■   إيقاف"                                : "■   Stop"; }
    QString clearTxt()     const { return ar ? "مسح السجل"                                : "Clear Log"; }
    QString darkTxt()      const { return ar ? "🌙  وضع داكن"                             : "🌙  Dark Mode"; }
    QString lightTxt()     const { return ar ? "☀️  وضع فاتح"                             : "☀️  Light Mode"; }
    QString langTxt()      const { return ar ? "English"                                  : "العربية"; }
    QString logGroupTxt()  const { return ar ? "سجل العمليات"                             : "Process Log"; }
    QString inputGroupTxt()const { return ar ? "إعدادات التنزيل"                          : "Download Settings"; }
    QString urlPlaceholder()const{ return ar ? "https://www.youtube.com/watch?v=..."      : "https://www.youtube.com/watch?v=..."; }

    QStringList qualities() const {
        if (ar) return { "صوت  MP3", "صوت  WAV", "فيديو — أفضل جودة", "فيديو  1080p", "فيديو  720p", "فيديو  480p" };
        return { "Audio  MP3", "Audio  WAV", "Video  Best", "Video  1080p", "Video  720p", "Video  480p" };
    }
    QStringList devices() const {
        if (ar) return { "CPU  (آمن دائماً)", "GPU / CUDA  (تسريع)" };
        return { "CPU  (Always Safe)", "GPU / CUDA  (Accelerated)" };
    }
};

class MainWindow : public QMainWindow {
    Q_OBJECT

public:
    explicit MainWindow(QWidget *parent = nullptr);
    ~MainWindow();

private slots:
    void onPaste();
    void onStart();
    void onStop();
    void onClear();
    void onQualityChanged(int idx);
    void onToggleTheme();
    void onToggleLang();
    void onDiagFinished(int code, QProcess::ExitStatus st);
    void onDlData();
    void onDlFinished(int code, QProcess::ExitStatus st);
    void onDemucsData();
    void onDemucsFinished(int code, QProcess::ExitStatus st);

private:
    void buildUi();
    void retranslate();
    void applyPalette();
    void runDiagnostic();
    void appendLog(const QString &text, const QString &hex = QString());
    void setRunning(bool r);
    QStringList buildYtdlpArgs(const QString &url) const;
    void startDemucs(const QString &file);
    QString outDir() const;
    QString findNewestFile() const;

    QWidget      *cw           = nullptr;
    QLabel       *titleLbl     = nullptr;
    QPushButton  *themeBtn     = nullptr;
    QPushButton  *langBtn      = nullptr;
    QGroupBox    *inputGroup   = nullptr;
    QLabel       *urlLbl       = nullptr;
    QLineEdit    *urlEdit      = nullptr;
    QPushButton  *pasteBtn     = nullptr;
    QLabel       *qualLbl      = nullptr;
    QComboBox    *qualCombo    = nullptr;
    QLabel       *devLbl       = nullptr;
    QComboBox    *devCombo     = nullptr;
    QCheckBox    *demucsChk    = nullptr;
    QPushButton  *startBtn     = nullptr;
    QPushButton  *stopBtn      = nullptr;
    QPushButton  *clearBtn     = nullptr;
    QGroupBox    *logGroup     = nullptr;
    QTextEdit    *logEdit      = nullptr;

    QProcess     *diagProc     = nullptr;
    QProcess     *dlProc       = nullptr;
    QProcess     *demProc      = nullptr;

    bool          dark         = false;
    bool          arabic       = false;
    bool          ytdlpOk      = false;
    bool          demucsOk     = false;
    bool          demucsIsMod  = false;
    bool          busy         = false;
    int           diagStep     = 0;

    QSet<QString> snapBefore;
    LangStrings   L;
};

MainWindow::MainWindow(QWidget *parent) : QMainWindow(parent) {
    buildUi();
    applyPalette();
    retranslate();
    QTimer::singleShot(400, this, &MainWindow::runDiagnostic);
}

MainWindow::~MainWindow() {
    auto kill = [](QProcess *p){ if (p && p->state() != QProcess::NotRunning) p->kill(); };
    kill(diagProc); kill(dlProc); kill(demProc);
}

void MainWindow::buildUi() {
    setMinimumSize(860, 660);
    resize(960, 720);

    cw = new QWidget(this);
    setCentralWidget(cw);
    auto *root = new QVBoxLayout(cw);
    root->setSpacing(10);
    root->setContentsMargins(18, 14, 18, 14);

    auto *topBar = new QHBoxLayout;
    titleLbl = new QLabel;
    QFont tf = titleLbl->font();
    tf.setPointSize(15); tf.setBold(true);
    titleLbl->setFont(tf);
    themeBtn = new QPushButton; themeBtn->setFixedWidth(130);
    langBtn  = new QPushButton; langBtn->setFixedWidth(90);
    topBar->addWidget(titleLbl, 1);
    topBar->addWidget(langBtn);
    topBar->addWidget(themeBtn);
    root->addLayout(topBar);

    auto *hRule1 = new QFrame;
    hRule1->setFrameShape(QFrame::HLine);
    hRule1->setFrameShadow(QFrame::Sunken);
    root->addWidget(hRule1);

    inputGroup = new QGroupBox;
    auto *ig = new QVBoxLayout(inputGroup);
    ig->setSpacing(10);

    auto *urlRow = new QHBoxLayout;
    urlLbl  = new QLabel; urlLbl->setFixedWidth(140);
    urlEdit = new QLineEdit; urlEdit->setMinimumHeight(32);
    pasteBtn = new QPushButton; pasteBtn->setFixedWidth(90); pasteBtn->setMinimumHeight(32);
    urlRow->addWidget(urlLbl);
    urlRow->addWidget(urlEdit, 1);
    urlRow->addWidget(pasteBtn);
    ig->addLayout(urlRow);

    auto *optRow = new QHBoxLayout;
    qualLbl  = new QLabel; qualLbl->setFixedWidth(140);
    qualCombo = new QComboBox; qualCombo->setMinimumWidth(180); qualCombo->setMinimumHeight(30);
    devLbl   = new QLabel; devLbl->setFixedWidth(130);
    devCombo = new QComboBox; devCombo->setMinimumWidth(200); devCombo->setMinimumHeight(30);
    optRow->addWidget(qualLbl);
    optRow->addWidget(qualCombo);
    optRow->addSpacing(24);
    optRow->addWidget(devLbl);
    optRow->addWidget(devCombo);
    optRow->addStretch();
    ig->addLayout(optRow);

    demucsChk = new QCheckBox; demucsChk->setEnabled(false);
    ig->addWidget(demucsChk);
    root->addWidget(inputGroup);

    auto *btnRow = new QHBoxLayout;
    startBtn = new QPushButton; startBtn->setEnabled(false);
    startBtn->setMinimumHeight(38); startBtn->setMinimumWidth(130);
    stopBtn = new QPushButton; stopBtn->setEnabled(false);
    stopBtn->setMinimumHeight(38); stopBtn->setMinimumWidth(130);
    clearBtn = new QPushButton; clearBtn->setMinimumHeight(38);

    QFont bf = startBtn->font(); bf.setBold(true); bf.setPointSize(11);
    startBtn->setFont(bf); stopBtn->setFont(bf);

    btnRow->addWidget(startBtn);
    btnRow->addWidget(stopBtn);
    btnRow->addStretch();
    btnRow->addWidget(clearBtn);
    root->addLayout(btnRow);

    auto *hRule2 = new QFrame;
    hRule2->setFrameShape(QFrame::HLine);
    hRule2->setFrameShadow(QFrame::Sunken);
    root->addWidget(hRule2);

    logGroup = new QGroupBox;
    auto *lg = new QVBoxLayout(logGroup);
    logEdit  = new QTextEdit;
    logEdit->setReadOnly(true);
    logEdit->setFont(QFont("Monospace", 9));
    logEdit->setMinimumHeight(220);
    logEdit->setAcceptRichText(true);
    lg->addWidget(logEdit);
    root->addWidget(logGroup, 1);

    connect(pasteBtn,  &QPushButton::clicked,                              this, &MainWindow::onPaste);
    connect(startBtn,  &QPushButton::clicked,                              this, &MainWindow::onStart);
    connect(stopBtn,   &QPushButton::clicked,                              this, &MainWindow::onStop);
    connect(clearBtn,  &QPushButton::clicked,                              this, &MainWindow::onClear);
    connect(themeBtn,  &QPushButton::clicked,                              this, &MainWindow::onToggleTheme);
    connect(langBtn,   &QPushButton::clicked,                              this, &MainWindow::onToggleLang);
    connect(qualCombo, QOverload<int>::of(&QComboBox::currentIndexChanged),this, &MainWindow::onQualityChanged);
}

void MainWindow::retranslate() {
    setWindowTitle(L.appTitle());
    titleLbl->setText(L.appTitle());
    themeBtn->setText(dark ? L.lightTxt() : L.darkTxt());
    langBtn->setText(L.langTxt());
    inputGroup->setTitle(L.inputGroupTxt());
    logGroup->setTitle(L.logGroupTxt());
    urlLbl->setText(L.urlLbl());
    urlEdit->setPlaceholderText(L.urlPlaceholder());
    pasteBtn->setText(L.pasteTxt());
    qualLbl->setText(L.qualLbl());
    devLbl->setText(L.devLbl());
    demucsChk->setText(L.demucsTxt());
    startBtn->setText(L.startTxt());
    stopBtn->setText(L.stopTxt());
    clearBtn->setText(L.clearTxt());

    int qi = qualCombo->currentIndex();
    int di = devCombo->currentIndex();
    qualCombo->clear(); qualCombo->addItems(L.qualities());
    devCombo->clear();  devCombo->addItems(L.devices());
    if (qi >= 0 && qi < qualCombo->count()) qualCombo->setCurrentIndex(qi);
    if (di >= 0 && di < devCombo->count())  devCombo->setCurrentIndex(di);

    Qt::LayoutDirection dir = arabic ? Qt::RightToLeft : Qt::LeftToRight;
    cw->setLayoutDirection(dir);
    logEdit->setLayoutDirection(Qt::LeftToRight);
}

void MainWindow::applyPalette() {
    QApplication::setStyle(QStyleFactory::create("Fusion"));
    if (!dark) {
        QApplication::setPalette(QApplication::style()->standardPalette());
        return;
    }
    QPalette p;
    p.setColor(QPalette::Window,          QColor(28,  28,  28));
    p.setColor(QPalette::WindowText,      QColor(220, 220, 220));
    p.setColor(QPalette::Base,            QColor(40,  40,  40));
    p.setColor(QPalette::AlternateBase,   QColor(50,  50,  50));
    p.setColor(QPalette::Text,            QColor(220, 220, 220));
    p.setColor(QPalette::Button,          QColor(55,  55,  55));
    p.setColor(QPalette::ButtonText,      QColor(220, 220, 220));
    p.setColor(QPalette::Highlight,       QColor(0,   122, 204));
    p.setColor(QPalette::HighlightedText, Qt::white);
    p.setColor(QPalette::Link,            QColor(80,  160, 255));
    p.setColor(QPalette::BrightText,      Qt::red);
    p.setColor(QPalette::Mid,             QColor(65,  65,  65));
    p.setColor(QPalette::Dark,            QColor(35,  35,  35));
    p.setColor(QPalette::Shadow,          QColor(20,  20,  20));
    p.setColor(QPalette::Disabled, QPalette::Text,       QColor(100,100,100));
    p.setColor(QPalette::Disabled, QPalette::ButtonText, QColor(100,100,100));
    p.setColor(QPalette::Disabled, QPalette::WindowText, QColor(100,100,100));
    QApplication::setPalette(p);
}

void MainWindow::onToggleTheme() { dark = !dark; applyPalette(); retranslate(); }
void MainWindow::onToggleLang()  { arabic = !arabic; L.ar = arabic; retranslate(); }
void MainWindow::onClear()       { logEdit->clear(); }
void MainWindow::onPaste()       { urlEdit->setText(QApplication::clipboard()->text().trimmed()); }

void MainWindow::onQualityChanged(int idx) {
    bool isAudio = (idx == 0 || idx == 1);
    demucsChk->setEnabled(isAudio && demucsOk);
    if (!isAudio) demucsChk->setChecked(false);
}

void MainWindow::appendLog(const QString &text, const QString &hex) {
    QString safe = text.toHtmlEscaped();
    QString html = hex.isEmpty()
        ? safe
        : QString("<span style='color:%1'>%2</span>").arg(hex, safe);
    logEdit->append(html);
    logEdit->verticalScrollBar()->setValue(logEdit->verticalScrollBar()->maximum());
}

void MainWindow::setRunning(bool r) {
    busy = r;
    startBtn->setEnabled(!r && ytdlpOk);
    stopBtn->setEnabled(r);
    urlEdit->setEnabled(!r);
    qualCombo->setEnabled(!r);
    devCombo->setEnabled(!r);
    pasteBtn->setEnabled(!r);
    demucsChk->setEnabled(!r && demucsOk && (qualCombo->currentIndex() <= 1));
}

QString MainWindow::outDir() const {
    return QStandardPaths::writableLocation(QStandardPaths::HomeLocation) + "/Downloads/m4s-ydvo/";
}

void MainWindow::runDiagnostic() {
    appendLog("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━", "#555555");
    appendLog("  m4s YD&VO  |  Self-Diagnostic", "#4fc3f7");
    appendLog("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━", "#555555");
    QDir(outDir()).mkpath(".");
    diagStep = 0;
    diagProc = new QProcess(this);
    connect(diagProc, QOverload<int,QProcess::ExitStatus>::of(&QProcess::finished),
            this, &MainWindow::onDiagFinished);
    diagProc->start("which", {"yt-dlp"});
}

void MainWindow::onDiagFinished(int code, QProcess::ExitStatus) {
    if (diagStep == 0) {
        ytdlpOk = (code == 0);
        if (ytdlpOk) {
            appendLog("  [OK]  yt-dlp   ->  " + diagProc->readAllStandardOutput().trimmed(), "#66bb6a");
        } else {
            appendLog("  [!!]  yt-dlp   ->  NOT FOUND", "#ef5350");
            appendLog("        Arch   :  sudo pacman -S yt-dlp", "#ff8a65");
            appendLog("        Debian :  sudo apt install yt-dlp", "#ff8a65");
            appendLog("        Any    :  pipx install yt-dlp", "#ff8a65");
        }
        diagStep = 1;
        diagProc->start("which", {"demucs"});
        return;
    }

    if (diagStep == 1) {
        if (code == 0) {
            demucsOk    = true;
            demucsIsMod = false;
            appendLog("  [OK]  demucs  ->  " + diagProc->readAllStandardOutput().trimmed(), "#66bb6a");
        } else {
            appendLog("  [...] demucs  ->  not in PATH, checking Python module...", "#aaaaaa");
            diagStep = 2;
            diagProc->start("python3", {"-c", "import demucs; print('ok')"});
            return;
        }
    }

    if (diagStep == 2) {
        demucsOk    = (code == 0);
        demucsIsMod = demucsOk;
        if (demucsOk) {
            appendLog("  [OK]  demucs  ->  found as Python module", "#66bb6a");
        } else {
            appendLog("  [WW]  demucs  ->  NOT FOUND  (vocal separation disabled)", "#ffa726");
            appendLog("        Fix: pipx install demucs --pip-args=\"--no-cache-dir\"", "#ff8a65");
        }
    }

    appendLog("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━", "#555555");
    if (ytdlpOk) {
        appendLog("  Ready — paste a URL and press Start.", "#66bb6a");
        startBtn->setEnabled(true);
    } else {
        appendLog("  Cannot start — yt-dlp is required.", "#ef5350");
    }
    appendLog("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━", "#555555");

    diagProc->deleteLater();
    diagProc = nullptr;
}

QStringList MainWindow::buildYtdlpArgs(const QString &url) const {
    QStringList a;
    a << "--no-playlist" << "--no-part"
      << "-o" << (outDir() + "%(title)s.%(ext)s");

    switch (qualCombo->currentIndex()) {
        case 0: a << "-x" << "--audio-format" << "mp3" << "--audio-quality" << "0";                                              break;
        case 1: a << "-x" << "--audio-format" << "wav";                                                                           break;
        case 2: a << "-f" << "bestvideo+bestaudio/best"                               << "--merge-output-format" << "mp4";        break;
        case 3: a << "-f" << "bestvideo[height<=1080]+bestaudio/best[height<=1080]"   << "--merge-output-format" << "mp4";        break;
        case 4: a << "-f" << "bestvideo[height<=720]+bestaudio/best[height<=720]"     << "--merge-output-format" << "mp4";        break;
        case 5: a << "-f" << "bestvideo[height<=480]+bestaudio/best[height<=480]"     << "--merge-output-format" << "mp4";        break;
        default:a << "-x" << "--audio-format" << "mp3" << "--audio-quality" << "0";                                              break;
    }
    a << url;
    return a;
}

QString MainWindow::findNewestFile() const {
    QDir dir(outDir());
    QFileInfoList fl = dir.entryInfoList(QDir::Files, QDir::Time);
    for (const QFileInfo &fi : fl)
        if (!snapBefore.contains(fi.absoluteFilePath())) return fi.absoluteFilePath();
    return fl.isEmpty() ? QString() : fl.first().absoluteFilePath();
}

void MainWindow::onStart() {
    QString url = urlEdit->text().trimmed();
    if (url.isEmpty()) { appendLog("  [WW]  Please enter a URL first.", "#ffa726"); return; }

    QDir dir(outDir()); dir.mkpath(".");
    snapBefore.clear();
    for (const QFileInfo &fi : dir.entryInfoList(QDir::Files))
        snapBefore.insert(fi.absoluteFilePath());

    setRunning(true);
    appendLog("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━", "#555555");
    appendLog("  Downloading...", "#4fc3f7");
    appendLog("  Output -> " + outDir(), "#aaaaaa");

    QStringList args = buildYtdlpArgs(url);
    appendLog("  > yt-dlp " + args.join(" "), "#777777");

    dlProc = new QProcess(this);
    dlProc->setProcessChannelMode(QProcess::MergedChannels);
    connect(dlProc, &QProcess::readyRead, this, &MainWindow::onDlData);
    connect(dlProc, QOverload<int,QProcess::ExitStatus>::of(&QProcess::finished),
            this, &MainWindow::onDlFinished);
    dlProc->start("yt-dlp", args);
}

void MainWindow::onDlData() {
    QString out = QString::fromLocal8Bit(dlProc->readAll());
    for (const QString &ln : out.split('\n'))
        if (!ln.trimmed().isEmpty()) appendLog("  " + ln.trimmed());
}

void MainWindow::onDlFinished(int code, QProcess::ExitStatus st) {
    dlProc->deleteLater(); dlProc = nullptr;
    if (code != 0 || st == QProcess::CrashExit) {
        appendLog("  [!!]  Download failed  (exit " + QString::number(code) + ")", "#ef5350");
        setRunning(false);
        appendLog("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━", "#555555");
        return;
    }
    appendLog("  [OK]  Download complete.", "#66bb6a");
    appendLog("  [->]  Saved to: " + outDir(), "#aaaaaa");

    if (demucsChk->isChecked() && demucsOk) {
        QString newest = findNewestFile();
        if (!newest.isEmpty()) { startDemucs(newest); return; }
        appendLog("  [WW]  Could not locate downloaded file for Demucs.", "#ffa726");
    }
    setRunning(false);
    appendLog("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━", "#555555");
}

void MainWindow::startDemucs(const QString &file) {
    appendLog("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━", "#555555");
    appendLog("  Demucs — Vocal Separation", "#ce93d8");
    appendLog("  Input  -> " + file, "#aaaaaa");

    bool useCuda = (devCombo->currentIndex() == 1);
    QString device = useCuda ? "cuda" : "cpu";

    QStringList args;
    if (demucsIsMod) args << "-m" << "demucs";
    args << "--device" << device << "-o" << outDir() << file;

    QString prog = demucsIsMod ? "python3" : "demucs";
    appendLog("  > " + prog + " " + args.join(" "), "#777777");

    demProc = new QProcess(this);
    demProc->setProcessChannelMode(QProcess::MergedChannels);
    connect(demProc, &QProcess::readyRead, this, &MainWindow::onDemucsData);
    connect(demProc, QOverload<int,QProcess::ExitStatus>::of(&QProcess::finished),
            this, &MainWindow::onDemucsFinished);
    demProc->start(prog, args);
}

void MainWindow::onDemucsData() {
    QString out = QString::fromLocal8Bit(demProc->readAll());
    for (const QString &ln : out.split('\n'))
        if (!ln.trimmed().isEmpty()) appendLog("  " + ln.trimmed(), "#ce93d8");
}

void MainWindow::onDemucsFinished(int code, QProcess::ExitStatus st) {
    demProc->deleteLater(); demProc = nullptr;
    if (code != 0 || st == QProcess::CrashExit) {
        appendLog("  [!!]  Demucs failed  (exit " + QString::number(code) + ")", "#ef5350");
        if (devCombo->currentIndex() == 1) {
            appendLog("  [!!]  CUDA error — switch Device to CPU and retry.", "#ffa726");
            appendLog("        This avoids cudaErrorNoKernelImageForDevice on older GPUs.", "#ffa726");
        }
    } else {
        appendLog("  [OK]  Vocal separation complete!", "#66bb6a");
        appendLog("  [->]  Stems saved to: " + outDir() + "separated/", "#aaaaaa");
    }
    setRunning(false);
    appendLog("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━", "#555555");
}

void MainWindow::onStop() {
    auto kill = [&](QProcess *p, const QString &name) {
        if (p && p->state() != QProcess::NotRunning) {
            p->kill();
            appendLog("  [--]  " + name + " stopped by user.", "#ffa726");
        }
    };
    kill(dlProc,  "Download");
    kill(demProc, "Demucs");
    setRunning(false);
}

int main(int argc, char *argv[]) {
    QApplication app(argc, argv);
    app.setApplicationName("m4s YD&VO");
    app.setApplicationVersion("1.0.0");
    app.setOrganizationName("m4s");
    MainWindow w;
    w.show();
    return app.exec();
}

#include "main.moc"
CPPEOF

    success "main.cpp generated."
}

# ── Build ─────────────────────────────────────────────────────────────────────
build_app() {
    local BUILD_DIR="$1"
    step "Building m4s-ydvo with CMake"

    cd "$BUILD_DIR"
    mkdir -p build && cd build

    cmake .. -DCMAKE_BUILD_TYPE=Release 2>&1 | tail -20
    make -j"$(nproc)" 2>&1

    if [[ ! -f "m4s-ydvo" ]]; then
        error "Build failed — binary not produced. Check cmake/make output above."
    fi
    success "Build succeeded."
    cd "$BUILD_DIR"
}

# ── Install binary ─────────────────────────────────────────────────────────────
install_binary() {
    local BUILD_DIR="$1"
    step "Installing binary to /usr/local/bin/m4s-ydvo"
    sudo cp "$BUILD_DIR/build/m4s-ydvo" /usr/local/bin/m4s-ydvo
    sudo chmod 755 /usr/local/bin/m4s-ydvo
    success "Binary installed."
}

# ── Desktop entry ─────────────────────────────────────────────────────────────
create_desktop_entry() {
    step "Creating .desktop entry"

    sudo mkdir -p /usr/share/pixmaps
    sudo tee /usr/share/applications/m4s-ydvo.desktop > /dev/null << 'DESKEOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=m4s YD&VO
GenericName=YouTube Downloader & Vocal Separator
Comment=Download media with yt-dlp and extract vocals with demucs
Exec=m4s-ydvo
Icon=applications-multimedia
Terminal=false
Categories=AudioVideo;Network;Utility;
Keywords=youtube;download;vocal;demucs;yt-dlp;mp3;wav;
StartupWMClass=m4s-ydvo
DESKEOF

    if command -v update-desktop-database &>/dev/null; then
        sudo update-desktop-database /usr/share/applications/ 2>/dev/null || true
    fi
    success ".desktop entry created — app will appear in your application menu."
}

# ── Cleanup ────────────────────────────────────────────────────────────────────
cleanup() {
    local BUILD_DIR="$1"
    step "Cleaning up build directory"
    rm -rf "$BUILD_DIR"
    success "Cleanup done."
}

# ── Final message ──────────────────────────────────────────────────────────────
print_success() {
cat << 'FINMSG'

  ╔═══════════════════════════════════════════════════════════╗
  ║          m4s YD&VO — Installation Complete!               ║
  ╠═══════════════════════════════════════════════════════════╣
  ║                                                           ║
  ║  Run from terminal :  m4s-ydvo                            ║
  ║  Or find it in     :  your application menu               ║
  ║  Output folder     :  ~/Downloads/m4s-ydvo/               ║
  ║                                                           ║
  ║  NOTE: Add ~/.local/bin to PATH if demucs is not found:   ║
  ║    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
  ║    source ~/.bashrc                                        ║
  ║                                                           ║
  ╚═══════════════════════════════════════════════════════════╝

FINMSG
}

# ── Entry point ───────────────────────────────────────────────────────────────
main() {
    print_banner

    if [[ "$EUID" -eq 0 ]]; then
        warn "Do not run this script as root. It uses sudo internally when needed."
        exit 1
    fi

    local PM
    PM=$(detect_pm)
    info "Detected package manager: $PM"

    install_system_deps "$PM"
    install_demucs

    local BUILD_DIR
    BUILD_DIR="$(mktemp -d /tmp/m4s-ydvo-build.XXXXXX)"
    info "Build directory: $BUILD_DIR"

    generate_sources "$BUILD_DIR"
    build_app        "$BUILD_DIR"
    install_binary   "$BUILD_DIR"
    create_desktop_entry
    cleanup          "$BUILD_DIR"
    print_success
}

main "$@"
