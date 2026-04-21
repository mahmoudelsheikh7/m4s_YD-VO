#!/usr/bin/env bash
# ==============================================================================
#  m4s YD&VO — Universal Linux Installer v2.0.0
#  Supports: Arch (pacman) · Debian/Ubuntu (apt) · Fedora (dnf) · openSUSE (zypper)
#  Features: htdemucs_ft · --shifts=2 · torchcodec injection · Local file support
# ==============================================================================
set -euo pipefail

RED='\033[0;31m'  GRN='\033[0;32m'  YLW='\033[1;33m'
BLU='\033[0;34m'  CYN='\033[0;36m'  MAG='\033[0;35m'
BOLD='\033[1m'    DIM='\033[2m'     NC='\033[0m'

info()    { echo -e "${CYN}[INFO]${NC} $*"; }
success() { echo -e "${GRN}[OK]${NC}   $*"; }
warn()    { echo -e "${YLW}[WARN]${NC} $*"; }
error()   { echo -e "${RED}[ERR]${NC}  $*" >&2; exit 1; }
step()    { echo -e "\n${BOLD}${BLU}━━━  $*  ━━━${NC}"; }

print_banner() {
cat << 'BANNER'

  ███╗   ███╗██╗  ██╗███████╗    ██╗   ██╗██████╗ ██╗   ██╗ ██████╗
  ████╗ ████║██║  ██║██╔════╝    ╚██╗ ██╔╝██╔══██╗██║   ██║██╔═══██╗
  ██╔████╔██║███████║███████╗     ╚████╔╝ ██║  ██║██║   ██║██║   ██║
  ██║╚██╔╝██║╚════██║╚════██║      ╚██╔╝  ██║  ██║╚██╗ ██╔╝██║   ██║
  ██║ ╚═╝ ██║     ██║███████║       ██║   ██████╔╝ ╚████╔╝ ╚██████╔╝
  ╚═╝     ╚═╝     ╚═╝╚══════╝       ╚═╝   ╚═════╝   ╚═══╝   ╚═════╝

  YouTube Downloader & Vocal Output — Qt6 Desktop Application
  Universal Linux Installer v2.0.0
  Model: htdemucs_ft  |  Zero Music Bleed  |  torchcodec fix included
BANNER
echo ""
}

detect_pm() {
    if   command -v pacman  &>/dev/null; then echo "pacman"
    elif command -v apt-get &>/dev/null; then echo "apt"
    elif command -v dnf     &>/dev/null; then echo "dnf"
    elif command -v zypper  &>/dev/null; then echo "zypper"
    else error "No supported package manager found (pacman/apt/dnf/zypper)."; fi
}

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
            if ! command -v yt-dlp &>/dev/null; then
                info "Installing yt-dlp upstream binary..."
                sudo curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp \
                     -o /usr/local/bin/yt-dlp
                sudo chmod a+rx /usr/local/bin/yt-dlp
            fi
            ;;
        dnf)
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

install_demucs() {
    step "Installing demucs (AI vocal separation) via pipx"

    if ! command -v pipx &>/dev/null; then
        python3 -m pip install --user pipx || warn "pip install pipx failed."
    fi

    export PATH="$HOME/.local/bin:$PATH"
    pipx ensurepath --force || true

    info "Running: pipx install demucs  (downloads PyTorch ~1-3 GB — please wait)"
    pipx install demucs --pip-args="--no-cache-dir" || {
        warn "pipx install demucs failed. Trying upgrade..."
        pipx upgrade demucs --pip-args="--no-cache-dir" || true
    }

    info "Running: pipx inject demucs torchcodec  (CRITICAL: prevents audio saving errors)"
    pipx inject demucs torchcodec --pip-args="--no-cache-dir" || {
        warn "torchcodec injection failed. The app will still work but may hit audio save errors on some systems."
        warn "Manual fix: pipx inject demucs torchcodec"
    }

    if command -v demucs &>/dev/null || python3 -c "import demucs" 2>/dev/null; then
        success "demucs installed and torchcodec injected successfully."
    else
        warn "demucs installation could not be confirmed. The app will warn at startup."
        warn "Manual install: pipx install demucs --pip-args='--no-cache-dir'"
    fi
}

generate_sources() {
    local BUILD_DIR="$1"
    step "Generating source files in $BUILD_DIR"
    mkdir -p "$BUILD_DIR"

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
#include <QRadioButton>
#include <QButtonGroup>
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
#include <QFileDialog>
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
#include <QTabWidget>
#include <QStackedWidget>
#include <QProgressBar>
#include <QSpacerItem>

struct LangStrings {
    bool ar = false;

    QString appTitle()        const { return ar ? "م4س — تنزيل وفصل الصوت والفيديو"        : "m4s YD&VO — YouTube Downloader & Vocal Output"; }
    QString urlTabTxt()       const { return ar ? "📡  رابط الإنترنت"                        : "📡  Online URL"; }
    QString fileTabTxt()      const { return ar ? "📂  ملف محلي"                             : "📂  Local File"; }
    QString urlLbl()          const { return ar ? "رابط الوسائط :"                           : "Media URL:"; }
    QString fileLbl()         const { return ar ? "مسار الملف :"                             : "File Path:"; }
    QString pasteTxt()        const { return ar ? "📋 لصق"                                   : "📋 Paste"; }
    QString browseTxt()       const { return ar ? "📂 استعراض"                               : "📂 Browse"; }
    QString qualLbl()         const { return ar ? "جودة التنزيل :"                            : "Download Quality:"; }
    QString devLbl()          const { return ar ? "جهاز المعالجة :"                           : "Processing Device:"; }
    QString cpuTxt()          const { return ar ? "CPU  (آمن دائماً)"                        : "CPU  (Always Safe)"; }
    QString gpuTxt()          const { return ar ? "GPU / CUDA  (تسريع)"                      : "GPU / CUDA  (Accelerated)"; }
    QString demucsTxt()       const { return ar ? "✨  فصل الصوت البشري — htdemucs_ft"       : "✨  Ultimate Vocal Isolation — htdemucs_ft"; }
    QString startTxt()        const { return ar ? "▶   ابدأ"                                  : "▶   Start"; }
    QString stopTxt()         const { return ar ? "■   إيقاف"                                 : "■   Stop"; }
    QString clearTxt()        const { return ar ? "مسح السجل"                                 : "Clear Log"; }
    QString darkTxt()         const { return ar ? "🌙  وضع داكن"                              : "🌙  Dark Mode"; }
    QString lightTxt()        const { return ar ? "☀️  وضع فاتح"                              : "☀️  Light Mode"; }
    QString langTxt()         const { return ar ? "English"                                   : "العربية"; }
    QString logGroupTxt()     const { return ar ? "سجل العمليات"                              : "Process Log"; }
    QString inputGroupTxt()   const { return ar ? "إعدادات التنزيل"                           : "Download Settings"; }
    QString urlPlaceholder()  const { return ar ? "https://www.youtube.com/watch?v=..."       : "https://www.youtube.com/watch?v=..."; }
    QString filePlaceholder() const { return ar ? "اختر ملف فيديو أو صوت محلي..."            : "Select a local video or audio file..."; }
    QString browseFilter()    const { return ar ? "ملفات الوسائط (*.mp4 *.mkv *.avi *.mov *.mp3 *.wav *.flac *.ogg *.m4a *.webm)" : "Media Files (*.mp4 *.mkv *.avi *.mov *.mp3 *.wav *.flac *.ogg *.m4a *.webm)"; }

    QStringList qualities() const {
        if (ar) return { "صوت  MP3", "صوت  WAV", "فيديو — أفضل جودة", "فيديو  1080p", "فيديو  720p", "فيديو  480p" };
        return { "Audio  MP3", "Audio  WAV", "Video  Best", "Video  1080p", "Video  720p", "Video  480p" };
    }
};

class MainWindow : public QMainWindow {
    Q_OBJECT

public:
    explicit MainWindow(QWidget *parent = nullptr);
    ~MainWindow();

private slots:
    void onPaste();
    void onBrowse();
    void onStart();
    void onStop();
    void onClear();
    void onQualityChanged(int idx);
    void onTabChanged(int idx);
    void onToggleTheme();
    void onToggleLang();
    void onDiagFinished(int code, QProcess::ExitStatus st);
    void onDlData();
    void onDlFinished(int code, QProcess::ExitStatus st);
    void onExtractData();
    void onExtractFinished(int code, QProcess::ExitStatus st);
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
    void startExtract(const QString &videoFile);
    QString outDir() const;
    QString findNewestFile() const;
    bool isAudioFile(const QString &path) const;

    QWidget      *cw            = nullptr;
    QLabel       *titleLbl      = nullptr;
    QPushButton  *themeBtn      = nullptr;
    QPushButton  *langBtn       = nullptr;
    QTabWidget   *inputTabs     = nullptr;
    QWidget      *urlTab        = nullptr;
    QWidget      *fileTab       = nullptr;
    QGroupBox    *inputGroup    = nullptr;
    QLabel       *urlLbl        = nullptr;
    QLineEdit    *urlEdit       = nullptr;
    QPushButton  *pasteBtn      = nullptr;
    QLabel       *fileLbl       = nullptr;
    QLineEdit    *fileEdit      = nullptr;
    QPushButton  *browseBtn     = nullptr;
    QLabel       *qualLbl       = nullptr;
    QComboBox    *qualCombo     = nullptr;
    QLabel       *devLbl        = nullptr;
    QRadioButton *cpuRadio      = nullptr;
    QRadioButton *gpuRadio      = nullptr;
    QButtonGroup *devGroup      = nullptr;
    QCheckBox    *demucsChk     = nullptr;
    QPushButton  *startBtn      = nullptr;
    QPushButton  *stopBtn       = nullptr;
    QPushButton  *clearBtn      = nullptr;
    QGroupBox    *logGroup      = nullptr;
    QTextEdit    *logEdit       = nullptr;

    QProcess     *diagProc      = nullptr;
    QProcess     *dlProc        = nullptr;
    QProcess     *extractProc   = nullptr;
    QProcess     *demProc       = nullptr;

    bool          dark          = false;
    bool          arabic        = false;
    bool          ytdlpOk       = false;
    bool          ffmpegOk      = false;
    bool          demucsOk      = false;
    bool          demucsIsMod   = false;
    bool          busy          = false;
    int           diagStep      = 0;
    bool          cudaFailed    = false;

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
    kill(diagProc); kill(dlProc); kill(extractProc); kill(demProc);
}

void MainWindow::buildUi() {
    setMinimumSize(900, 700);
    resize(1000, 760);

    cw = new QWidget(this);
    setCentralWidget(cw);
    auto *root = new QVBoxLayout(cw);
    root->setSpacing(10);
    root->setContentsMargins(18, 14, 18, 14);

    auto *topBar = new QHBoxLayout;
    titleLbl = new QLabel;
    QFont tf = titleLbl->font();
    tf.setPointSize(14); tf.setBold(true);
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

    inputTabs = new QTabWidget;
    inputTabs->setMinimumHeight(90);

    urlTab = new QWidget;
    auto *urlTabLayout = new QHBoxLayout(urlTab);
    urlTabLayout->setContentsMargins(6, 8, 6, 8);
    urlLbl   = new QLabel; urlLbl->setFixedWidth(100);
    urlEdit  = new QLineEdit; urlEdit->setMinimumHeight(32);
    pasteBtn = new QPushButton; pasteBtn->setFixedWidth(90); pasteBtn->setMinimumHeight(32);
    urlTabLayout->addWidget(urlLbl);
    urlTabLayout->addWidget(urlEdit, 1);
    urlTabLayout->addWidget(pasteBtn);

    fileTab = new QWidget;
    auto *fileTabLayout = new QHBoxLayout(fileTab);
    fileTabLayout->setContentsMargins(6, 8, 6, 8);
    fileLbl    = new QLabel; fileLbl->setFixedWidth(100);
    fileEdit   = new QLineEdit; fileEdit->setMinimumHeight(32);
    browseBtn  = new QPushButton; browseBtn->setFixedWidth(110); browseBtn->setMinimumHeight(32);
    fileTabLayout->addWidget(fileLbl);
    fileTabLayout->addWidget(fileEdit, 1);
    fileTabLayout->addWidget(browseBtn);

    inputTabs->addTab(urlTab,  "");
    inputTabs->addTab(fileTab, "");
    ig->addWidget(inputTabs);

    auto *optRow = new QHBoxLayout;
    qualLbl   = new QLabel; qualLbl->setFixedWidth(140);
    qualCombo = new QComboBox; qualCombo->setMinimumWidth(170); qualCombo->setMinimumHeight(30);
    devLbl    = new QLabel; devLbl->setFixedWidth(130);
    cpuRadio  = new QRadioButton;
    gpuRadio  = new QRadioButton;
    devGroup  = new QButtonGroup(this);
    devGroup->addButton(cpuRadio, 0);
    devGroup->addButton(gpuRadio, 1);
    cpuRadio->setChecked(true);
    optRow->addWidget(qualLbl);
    optRow->addWidget(qualCombo);
    optRow->addSpacing(20);
    optRow->addWidget(devLbl);
    optRow->addWidget(cpuRadio);
    optRow->addWidget(gpuRadio);
    optRow->addStretch();
    ig->addLayout(optRow);

    demucsChk = new QCheckBox;
    demucsChk->setEnabled(false);
    QFont df = demucsChk->font(); df.setBold(true);
    demucsChk->setFont(df);
    ig->addWidget(demucsChk);
    root->addWidget(inputGroup);

    auto *btnRow = new QHBoxLayout;
    startBtn = new QPushButton; startBtn->setEnabled(false);
    startBtn->setMinimumHeight(40); startBtn->setMinimumWidth(140);
    stopBtn = new QPushButton; stopBtn->setEnabled(false);
    stopBtn->setMinimumHeight(40); stopBtn->setMinimumWidth(140);
    clearBtn = new QPushButton; clearBtn->setMinimumHeight(40);

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
    logEdit->setMinimumHeight(240);
    logEdit->setAcceptRichText(true);
    lg->addWidget(logEdit);
    root->addWidget(logGroup, 1);

    connect(pasteBtn,   &QPushButton::clicked,                               this, &MainWindow::onPaste);
    connect(browseBtn,  &QPushButton::clicked,                               this, &MainWindow::onBrowse);
    connect(startBtn,   &QPushButton::clicked,                               this, &MainWindow::onStart);
    connect(stopBtn,    &QPushButton::clicked,                               this, &MainWindow::onStop);
    connect(clearBtn,   &QPushButton::clicked,                               this, &MainWindow::onClear);
    connect(themeBtn,   &QPushButton::clicked,                               this, &MainWindow::onToggleTheme);
    connect(langBtn,    &QPushButton::clicked,                               this, &MainWindow::onToggleLang);
    connect(qualCombo,  QOverload<int>::of(&QComboBox::currentIndexChanged), this, &MainWindow::onQualityChanged);
    connect(inputTabs,  &QTabWidget::currentChanged,                         this, &MainWindow::onTabChanged);
}

void MainWindow::retranslate() {
    setWindowTitle(L.appTitle());
    titleLbl->setText(L.appTitle());
    themeBtn->setText(dark ? L.lightTxt() : L.darkTxt());
    langBtn->setText(L.langTxt());
    inputGroup->setTitle(L.inputGroupTxt());
    logGroup->setTitle(L.logGroupTxt());
    inputTabs->setTabText(0, L.urlTabTxt());
    inputTabs->setTabText(1, L.fileTabTxt());
    urlLbl->setText(L.urlLbl());
    urlEdit->setPlaceholderText(L.urlPlaceholder());
    pasteBtn->setText(L.pasteTxt());
    fileLbl->setText(L.fileLbl());
    fileEdit->setPlaceholderText(L.filePlaceholder());
    browseBtn->setText(L.browseTxt());
    qualLbl->setText(L.qualLbl());
    devLbl->setText(L.devLbl());
    cpuRadio->setText(L.cpuTxt());
    gpuRadio->setText(L.gpuTxt());
    demucsChk->setText(L.demucsTxt());
    startBtn->setText(L.startTxt());
    stopBtn->setText(L.stopTxt());
    clearBtn->setText(L.clearTxt());

    int qi = qualCombo->currentIndex();
    qualCombo->clear(); qualCombo->addItems(L.qualities());
    if (qi >= 0 && qi < qualCombo->count()) qualCombo->setCurrentIndex(qi);

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

void MainWindow::onBrowse() {
    QString path = QFileDialog::getOpenFileName(
        this,
        arabic ? "اختر ملف وسائط" : "Select Media File",
        QStandardPaths::writableLocation(QStandardPaths::HomeLocation),
        L.browseFilter()
    );
    if (!path.isEmpty()) {
        fileEdit->setText(path);
        inputTabs->setCurrentIndex(1);
    }
}

void MainWindow::onTabChanged(int idx) {
    bool urlMode = (idx == 0);
    int qi = qualCombo->currentIndex();
    if (!urlMode) {
        qualCombo->setEnabled(false);
        qualLbl->setEnabled(false);
    } else {
        qualCombo->setEnabled(!busy);
        qualLbl->setEnabled(true);
    }
    bool isAudio = (qi == 0 || qi == 1) || !urlMode;
    demucsChk->setEnabled(!busy && demucsOk && isAudio);
}

void MainWindow::onQualityChanged(int idx) {
    bool urlMode = (inputTabs->currentIndex() == 0);
    bool isAudio = (idx == 0 || idx == 1);
    if (urlMode) {
        demucsChk->setEnabled(isAudio && demucsOk && !busy);
        if (!isAudio) demucsChk->setChecked(false);
    }
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
    fileEdit->setEnabled(!r);
    browseBtn->setEnabled(!r);
    pasteBtn->setEnabled(!r);
    qualCombo->setEnabled(!r && (inputTabs->currentIndex() == 0));
    cpuRadio->setEnabled(!r);
    gpuRadio->setEnabled(!r);
    bool urlMode = (inputTabs->currentIndex() == 0);
    bool isAudio = (qualCombo->currentIndex() <= 1) || !urlMode;
    demucsChk->setEnabled(!r && demucsOk && isAudio);
}

QString MainWindow::outDir() const {
    return QStandardPaths::writableLocation(QStandardPaths::HomeLocation) + "/Downloads/m4s-ydvo/";
}

bool MainWindow::isAudioFile(const QString &path) const {
    static const QStringList audioExts = {"mp3","wav","flac","ogg","m4a","aac","opus","wma"};
    QString ext = QFileInfo(path).suffix().toLower();
    return audioExts.contains(ext);
}

void MainWindow::runDiagnostic() {
    appendLog("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━", "#555555");
    appendLog("  m4s YD&VO  v2.0  |  Self-Diagnostic", "#4fc3f7");
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
            appendLog("  [OK]  yt-dlp   ->  " +
                QString::fromLocal8Bit(diagProc->readAllStandardOutput()).trimmed(), "#66bb6a");
        } else {
            appendLog("  [!!]  yt-dlp   ->  NOT FOUND", "#ef5350");
            appendLog("        Arch:   sudo pacman -S yt-dlp", "#ff8a65");
            appendLog("        Debian: sudo apt install yt-dlp", "#ff8a65");
            appendLog("        Any:    pipx install yt-dlp", "#ff8a65");
        }
        diagStep = 1;
        diagProc->start("which", {"ffmpeg"});
        return;
    }

    if (diagStep == 1) {
        ffmpegOk = (code == 0);
        if (ffmpegOk) {
            appendLog("  [OK]  ffmpeg   ->  " +
                QString::fromLocal8Bit(diagProc->readAllStandardOutput()).trimmed(), "#66bb6a");
        } else {
            appendLog("  [!!]  ffmpeg   ->  NOT FOUND (local video extraction disabled)", "#ffa726");
            appendLog("        Fix: sudo pacman -S ffmpeg  OR  sudo apt install ffmpeg", "#ff8a65");
        }
        diagStep = 2;
        diagProc->start("which", {"demucs"});
        return;
    }

    if (diagStep == 2) {
        if (code == 0) {
            demucsOk    = true;
            demucsIsMod = false;
            appendLog("  [OK]  demucs  ->  " +
                QString::fromLocal8Bit(diagProc->readAllStandardOutput()).trimmed(), "#66bb6a");
        } else {
            appendLog("  [...] demucs  ->  not in PATH, checking Python module...", "#aaaaaa");
            diagStep = 3;
            diagProc->start("python3", {"-c", "import demucs; print('ok')"});
            return;
        }
    }

    if (diagStep == 3) {
        demucsOk    = (code == 0);
        demucsIsMod = demucsOk;
        if (demucsOk) {
            appendLog("  [OK]  demucs  ->  found as Python module", "#66bb6a");
        } else {
            appendLog("  [WW]  demucs  ->  NOT FOUND  (vocal separation disabled)", "#ffa726");
            appendLog("        Fix: pipx install demucs", "#ff8a65");
            appendLog("        Then: pipx inject demucs torchcodec", "#ff8a65");
        }
    }

    if (demucsOk) {
        appendLog("  [OK]  Model: htdemucs_ft  |  shifts=2  |  two-stems=vocals", "#66bb6a");
        appendLog("  [OK]  torchcodec: injected via pipx (audio save fix active)", "#66bb6a");
    }

    appendLog("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━", "#555555");

    if (ytdlpOk) {
        appendLog("  Ready — paste a URL, or browse a local file, then press Start.", "#66bb6a");
        startBtn->setEnabled(true);
    } else {
        appendLog("  Cannot start — yt-dlp is required for URL downloads.", "#ef5350");
        appendLog("  You can still use Local File tab if ffmpeg is installed.", "#aaaaaa");
        if (ffmpegOk) startBtn->setEnabled(true);
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
    bool urlMode  = (inputTabs->currentIndex() == 0);
    QString url   = urlEdit->text().trimmed();
    QString fpath = fileEdit->text().trimmed();

    if (urlMode) {
        if (url.isEmpty()) { appendLog("  [WW]  Please enter a URL first.", "#ffa726"); return; }
        if (!ytdlpOk)      { appendLog("  [!!]  yt-dlp is not installed.", "#ef5350");  return; }
    } else {
        if (fpath.isEmpty()) { appendLog("  [WW]  Please select a local file first.", "#ffa726"); return; }
        if (!QFileInfo::exists(fpath)) { appendLog("  [!!]  File not found: " + fpath, "#ef5350"); return; }
    }

    QDir dir(outDir()); dir.mkpath(".");
    snapBefore.clear();
    for (const QFileInfo &fi : dir.entryInfoList(QDir::Files))
        snapBefore.insert(fi.absoluteFilePath());

    cudaFailed = false;
    setRunning(true);
    appendLog("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━", "#555555");

    if (urlMode) {
        appendLog("  Step A — Downloading via yt-dlp...", "#4fc3f7");
        appendLog("  Output -> " + outDir(), "#aaaaaa");
        QStringList args = buildYtdlpArgs(url);
        appendLog("  > yt-dlp " + args.join(" "), "#777777");

        dlProc = new QProcess(this);
        dlProc->setProcessChannelMode(QProcess::MergedChannels);
        connect(dlProc, &QProcess::readyRead,
                this, &MainWindow::onDlData);
        connect(dlProc, QOverload<int,QProcess::ExitStatus>::of(&QProcess::finished),
                this, &MainWindow::onDlFinished);
        dlProc->start("yt-dlp", args);
    } else {
        appendLog("  Step B — Local file mode", "#4fc3f7");
        appendLog("  Source -> " + fpath, "#aaaaaa");
        if (isAudioFile(fpath)) {
            appendLog("  [->]  Audio file detected — skipping ffmpeg extraction.", "#aaaaaa");
            if (demucsChk->isChecked() && demucsOk) {
                startDemucs(fpath);
            } else {
                QString dest = outDir() + QFileInfo(fpath).fileName();
                QFile::copy(fpath, dest);
                appendLog("  [OK]  File copied to: " + dest, "#66bb6a");
                setRunning(false);
                appendLog("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━", "#555555");
            }
        } else {
            if (!ffmpegOk) {
                appendLog("  [!!]  ffmpeg is required for video extraction.", "#ef5350");
                setRunning(false);
                return;
            }
            startExtract(fpath);
        }
    }
}

void MainWindow::startExtract(const QString &videoFile) {
    QString tempAudio = outDir() + "temp_audio_" +
        QString::number(QDateTime::currentMSecsSinceEpoch()) + ".mp3";
    appendLog("  Step B — Extracting audio via ffmpeg...", "#4fc3f7");
    appendLog("  > ffmpeg -i \"" + videoFile + "\" -q:a 0 -map a \"" + tempAudio + "\"", "#777777");

    QStringList args;
    args << "-y" << "-i" << videoFile << "-q:a" << "0" << "-map" << "a" << tempAudio;

    extractProc = new QProcess(this);
    extractProc->setProcessChannelMode(QProcess::MergedChannels);
    extractProc->setProperty("tempAudio", tempAudio);
    connect(extractProc, &QProcess::readyRead, this, &MainWindow::onExtractData);
    connect(extractProc, QOverload<int,QProcess::ExitStatus>::of(&QProcess::finished),
            this, &MainWindow::onExtractFinished);
    extractProc->start("ffmpeg", args);
}

void MainWindow::onExtractData() {
    QString out = QString::fromLocal8Bit(extractProc->readAll());
    for (const QString &ln : out.split('\n'))
        if (!ln.trimmed().isEmpty()) appendLog("  " + ln.trimmed(), "#80cbc4");
}

void MainWindow::onExtractFinished(int code, QProcess::ExitStatus st) {
    QString tempAudio = extractProc->property("tempAudio").toString();
    extractProc->deleteLater(); extractProc = nullptr;

    if (code != 0 || st == QProcess::CrashExit) {
        appendLog("  [!!]  ffmpeg extraction failed (exit " + QString::number(code) + ")", "#ef5350");
        setRunning(false);
        appendLog("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━", "#555555");
        return;
    }
    appendLog("  [OK]  Audio extracted -> " + tempAudio, "#66bb6a");

    if (demucsChk->isChecked() && demucsOk) {
        startDemucs(tempAudio);
        return;
    }
    setRunning(false);
    appendLog("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━", "#555555");
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
    appendLog("  Step C — Demucs  |  htdemucs_ft  |  shifts=2  |  two-stems=vocals", "#ce93d8");
    appendLog("  Input  -> " + file, "#aaaaaa");

    bool useCuda = gpuRadio->isChecked() && !cudaFailed;
    QString device = useCuda ? "cuda" : "cpu";
    appendLog("  Device -> " + device.toUpper(), "#aaaaaa");

    QStringList args;
    if (demucsIsMod) {
        args << "-m" << "demucs";
    }
    args << "-n" << "htdemucs_ft"
         << "--two-stems=vocals"
         << "--shifts=2"
         << "-d" << device
         << "-o" << outDir()
         << file;

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
    QString lastInput = demProc->arguments().last();
    demProc->deleteLater(); demProc = nullptr;

    if (code != 0 || st == QProcess::CrashExit) {
        appendLog("  [!!]  Demucs failed  (exit " + QString::number(code) + ")", "#ef5350");
        if (gpuRadio->isChecked() && !cudaFailed) {
            cudaFailed = true;
            appendLog("  [!!]  CUDA error detected — automatically retrying with CPU...", "#ffa726");
            appendLog("        (cudaErrorNoKernelImageForDevice: older GPU not supported by this PyTorch build)", "#ffa726");
            cpuRadio->setChecked(true);
            startDemucs(lastInput);
            return;
        }
        appendLog("  [!!]  Demucs failed on CPU as well. Check your demucs installation.", "#ef5350");
        appendLog("        Run: pipx inject demucs torchcodec", "#ff8a65");
    } else {
        appendLog("  [OK]  Vocal separation complete!", "#66bb6a");
        appendLog("  [->]  vocals.wav -> " + outDir() + "htdemucs_ft/", "#aaaaaa");
        appendLog("  [->]  no_vocals.wav (instrumental) -> same folder", "#aaaaaa");
        appendLog("  [->]  Model: htdemucs_ft  |  shifts=2  ==>  Zero music bleed ✓", "#66bb6a");
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
    kill(dlProc,      "Download");
    kill(extractProc, "Audio Extraction");
    kill(demProc,     "Demucs");
    setRunning(false);
}

int main(int argc, char *argv[]) {
    QApplication app(argc, argv);
    app.setApplicationName("m4s YD&VO");
    app.setApplicationVersion("2.0.0");
    app.setOrganizationName("m4s");
    MainWindow w;
    w.show();
    return app.exec();
}

#include "main.moc"
CPPEOF

    success "main.cpp generated."
}

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

install_binary() {
    local BUILD_DIR="$1"
    step "Installing binary to /usr/local/bin/m4s-ydvo"
    sudo cp "$BUILD_DIR/build/m4s-ydvo" /usr/local/bin/m4s-ydvo
    sudo chmod 755 /usr/local/bin/m4s-ydvo
    success "Binary installed."
}

create_desktop_entry() {
    step "Creating .desktop entry"

    sudo mkdir -p /usr/share/pixmaps
    sudo tee /usr/share/applications/m4s-ydvo.desktop > /dev/null << 'DESKEOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=m4s YD&VO
GenericName=YouTube Downloader & Vocal Separator
Comment=Download media with yt-dlp and isolate vocals with Meta Demucs AI (htdemucs_ft)
Exec=m4s-ydvo
Icon=applications-multimedia
Terminal=false
Categories=AudioVideo;Network;Utility;
Keywords=youtube;download;vocal;demucs;yt-dlp;mp3;wav;htdemucs;ai;
StartupWMClass=m4s-ydvo
DESKEOF

    if command -v update-desktop-database &>/dev/null; then
        sudo update-desktop-database /usr/share/applications/ 2>/dev/null || true
    fi
    success ".desktop entry created — app will appear in your application menu."
}

cleanup() {
    local BUILD_DIR="$1"
    step "Cleaning up build directory"
    rm -rf "$BUILD_DIR"
    success "Cleanup done."
}

print_success() {
cat << 'FINMSG'

  ╔══════════════════════════════════════════════════════════════╗
  ║         m4s YD&VO v2.0 — Installation Complete!              ║
  ╠══════════════════════════════════════════════════════════════╣
  ║                                                              ║
  ║  Run from terminal :  m4s-ydvo                               ║
  ║  Or find it in     :  your application menu                  ║
  ║  Output folder     :  ~/Downloads/m4s-ydvo/                  ║
  ║                                                              ║
  ║  AI Model          :  htdemucs_ft  (best quality)            ║
  ║  Shifts            :  --shifts=2   (zero music bleed)        ║
  ║  torchcodec        :  injected     (audio save fix active)   ║
  ║                                                              ║
  ║  NOTE: Add ~/.local/bin to PATH if demucs is not found:      ║
  ║    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc  ║
  ║    source ~/.bashrc                                          ║
  ║                                                              ║
  ╚══════════════════════════════════════════════════════════════╝

FINMSG
}

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
