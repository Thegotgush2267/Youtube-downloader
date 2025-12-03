import sys
import os
import subprocess
from PyQt5 import QtCore, QtGui, QtWidgets


class YtDlpWorker(QtCore.QObject):
    log_signal = QtCore.pyqtSignal(str)
    finished = QtCore.pyqtSignal(bool)

    def __init__(self, command, workdir):
        super().__init__()
        self.command = command
        self.workdir = workdir

    @QtCore.pyqtSlot()
    def run(self):
        try:
            process = subprocess.Popen(
                self.command,
                cwd=self.workdir,
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,
                text=True,
                encoding="utf-8",
                errors="replace"
            )
        except FileNotFoundError:
            self.log_signal.emit("ERROR: yt-dlp not found. Make sure it is installed and in PATH.\n")
            self.finished.emit(False)
            return

        for line in process.stdout:
            self.log_signal.emit(line)

        process.wait()
        success = process.returncode == 0
        self.finished.emit(success)


class MainWindow(QtWidgets.QMainWindow):
    def __init__(self):
        super().__init__()

        self.setWindowTitle("Gehana YouTube Downloader")
        self.setMinimumSize(800, 500)
        self.setWindowIcon(QtGui.QIcon())  # you can set a real icon here
        self.output_dir = os.path.expanduser("~")

        self._setup_ui()
        self._apply_style()

        self.worker_thread = None
        self.downloading = False

    def _setup_ui(self):
        central = QtWidgets.QWidget()
        self.setCentralWidget(central)

        layout = QtWidgets.QVBoxLayout(central)
        layout.setContentsMargins(30, 30, 30, 30)

        # Card container
        self.card = QtWidgets.QFrame()
        self.card.setObjectName("card")
        self.card.setFrameShape(QtWidgets.QFrame.StyledPanel)
        self.card.setFrameShadow(QtWidgets.QFrame.Raised)

        card_layout = QtWidgets.QVBoxLayout(self.card)
        card_layout.setContentsMargins(25, 25, 25, 25)
        card_layout.setSpacing(15)

        # Title
        title = QtWidgets.QLabel("Gehans YouTube Downloader")
        title.setObjectName("titleLabel")
        title.setAlignment(QtCore.Qt.AlignCenter)
        card_layout.addWidget(title)

        subtitle = QtWidgets.QLabel("Download youtube Videos As Audio Or Video in minuits")
        subtitle.setObjectName("subtitleLabel")
        subtitle.setAlignment(QtCore.Qt.AlignCenter)
        card_layout.addWidget(subtitle)

        card_layout.addSpacing(10)

        # URL input
        url_layout = QtWidgets.QHBoxLayout()
        url_label = QtWidgets.QLabel("YouTube URL:")
        self.url_edit = QtWidgets.QLineEdit()
        self.url_edit.setPlaceholderText("Paste YouTube URL here")
        url_layout.addWidget(url_label)
        url_layout.addWidget(self.url_edit)
        card_layout.addLayout(url_layout)

        # Mode selection
        mode_group = QtWidgets.QGroupBox("Download type")
        mode_layout = QtWidgets.QHBoxLayout(mode_group)
        self.radio_audio = QtWidgets.QRadioButton("Song (audio .opus)")
        self.radio_video = QtWidgets.QRadioButton("Video (best webm/mp4)")
        self.radio_audio.setChecked(True)
        mode_layout.addWidget(self.radio_audio)
        mode_layout.addWidget(self.radio_video)
        card_layout.addWidget(mode_group)

        # Output folder
        out_layout = QtWidgets.QHBoxLayout()
        out_label = QtWidgets.QLabel("Output folder:")
        self.out_display = QtWidgets.QLineEdit()
        self.out_display.setReadOnly(True)
        self.out_display.setText(self.output_dir)
        browse_btn = QtWidgets.QPushButton("Browse")
        browse_btn.clicked.connect(self.choose_folder)
        out_layout.addWidget(out_label)
        out_layout.addWidget(self.out_display)
        out_layout.addWidget(browse_btn)
        card_layout.addLayout(out_layout)

        # Download button + progress
        action_layout = QtWidgets.QHBoxLayout()
        self.download_btn = QtWidgets.QPushButton("Download")
        self.download_btn.clicked.connect(self.start_download)
        self.progress = QtWidgets.QProgressBar()
        self.progress.setTextVisible(False)
        self.progress.setRange(0, 1)
        self.progress.setValue(0)  # idle
        action_layout.addWidget(self.download_btn)
        action_layout.addWidget(self.progress)
        card_layout.addLayout(action_layout)

        # Log
        log_label = QtWidgets.QLabel("Log:")
        card_layout.addWidget(log_label)
        self.log_box = QtWidgets.QTextEdit()
        self.log_box.setReadOnly(True)
        card_layout.addWidget(self.log_box)

        # Add card to outer layout with shadow
        layout.addWidget(self.card)

        shadow = QtWidgets.QGraphicsDropShadowEffect(self)
        shadow.setBlurRadius(30)
        shadow.setXOffset(0)
        shadow.setYOffset(10)
        shadow.setColor(QtGui.QColor(0, 0, 0, 160))
        self.card.setGraphicsEffect(shadow)

    def _apply_style(self):
        # Dark theme, modern buttons, etc.
        self.setStyleSheet("""
            QMainWindow {
                background-color: #121212;
            }
            #card {
                background-color: #1E1E1E;
                border-radius: 16px;
            }
            #titleLabel {
                font-size: 22px;
                font-weight: 600;
                color: #FFFFFF;
            }
            #subtitleLabel {
                font-size: 12px;
                color: #AAAAAA;
            }
            QLabel {
                color: #DDDDDD;
            }
            QLineEdit {
                background-color: #252525;
                border: 1px solid #333333;
                border-radius: 6px;
                padding: 6px 8px;
                color: #FFFFFF;
                selection-background-color: #3A6EA5;
            }
            QLineEdit:focus {
                border: 1px solid #3A6EA5;
            }
            QGroupBox {
                border: 1px solid #333333;
                border-radius: 8px;
                margin-top: 10px;
                padding: 10px;
                color: #CCCCCC;
                font-weight: 500;
            }
            QGroupBox::title {
                subcontrol-origin: margin;
                subcontrol-position: top left;
                padding: 0 4px;
            }
            QRadioButton {
                color: #DDDDDD;
            }
            QPushButton {
                background-color: #3A6EA5;
                color: #FFFFFF;
                border-radius: 8px;
                padding: 8px 16px;
                border: none;
                font-weight: 500;
            }
            QPushButton:hover {
                background-color: #4B82C0;
            }
            QPushButton:pressed {
                background-color: #31557A;
            }
            QPushButton:disabled {
                background-color: #444444;
                color: #888888;
            }
            QTextEdit {
                background-color: #151515;
                border-radius: 8px;
                border: 1px solid #333333;
                color: #EEEEEE;
                padding: 6px;
            }
            QProgressBar {
                background-color: #252525;
                border-radius: 6px;
                border: 1px solid #333333;
            }
            QProgressBar::chunk {
                background-color: #3A6EA5;
                border-radius: 6px;
            }
        """)

    def choose_folder(self):
        folder = QtWidgets.QFileDialog.getExistingDirectory(
            self,
            "Choose output folder",
            self.output_dir
        )
        if folder:
            self.output_dir = folder
            self.out_display.setText(folder)

    def append_log(self, text: str):
        self.log_box.moveCursor(QtGui.QTextCursor.End)
        self.log_box.insertPlainText(text)
        self.log_box.moveCursor(QtGui.QTextCursor.End)

    def set_downloading(self, active: bool):
        self.downloading = active
        self.download_btn.setDisabled(active)
        self.url_edit.setDisabled(active)
        if active:
            self.progress.setRange(0, 0)  # busy / infinite
        else:
            self.progress.setRange(0, 1)
            self.progress.setValue(0)

    def start_download(self):
        if self.downloading:
            return

        url = self.url_edit.text().strip()
        if not url:
            QtWidgets.QMessageBox.critical(self, "Error", "Please enter a YouTube URL.")
            return

        if not os.path.isdir(self.output_dir):
            QtWidgets.QMessageBox.critical(self, "Error", "Output folder is invalid.")
            return

        # Build yt-dlp command
        if self.radio_audio.isChecked():
            # Audio mode: opus
            cmd = [
                "yt-dlp",
                "--ignore-config",
                "--no-playlist",
                "-x",
                "--audio-format", "opus",
                "-o", "%(title)s.%(ext)s",
                url,
            ]
        else:
            # Video mode: best video+audio
            cmd = [
                "yt-dlp",
                "--ignore-config",
                "--no-playlist",
                "-f", "bv*+ba/b",
                "-o", "%(title)s.%(ext)s",
                url,
            ]

        self.append_log("\n=== Starting download ===\n")
        self.set_downloading(True)

        # Threaded worker
        self.worker_thread = QtCore.QThread()
        self.worker = YtDlpWorker(cmd, self.output_dir)
        self.worker.moveToThread(self.worker_thread)

        self.worker_thread.started.connect(self.worker.run)
        self.worker.log_signal.connect(self.append_log)
        self.worker.finished.connect(self.download_finished)
        self.worker.finished.connect(self.worker_thread.quit)
        self.worker.finished.connect(self.worker.deleteLater)
        self.worker_thread.finished.connect(self.worker_thread.deleteLater)

        self.worker_thread.start()

    @QtCore.pyqtSlot(bool)
    def download_finished(self, success: bool):
        self.set_downloading(False)
        if success:
            self.append_log("=== Download finished successfully ===\n")
        else:
            self.append_log("=== Download failed ===\n")


def main():
    app = QtWidgets.QApplication(sys.argv)
    app.setApplicationName("Gehana YouTube Downloader")

    # Optional: enable high DPI scaling
    QtCore.QCoreApplication.setAttribute(QtCore.Qt.AA_EnableHighDpiScaling, True)

    window = MainWindow()
    window.show()

    sys.exit(app.exec_())


if __name__ == "__main__":
    main()
