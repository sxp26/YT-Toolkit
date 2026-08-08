import os
import queue
import subprocess
import sys
import threading
import tkinter as tk
from datetime import datetime
from pathlib import Path
from tkinter import filedialog, messagebox, ttk

# This file is meant to live in a "GUI" folder inside the toolkit root,
# next to Downloaders/, Installers/, Utilities/, Logs/, Config/.
# When packaged into an .exe by PyInstaller, __file__ points to a temp
# extraction folder instead of the real exe location, so this checks for
# that case and uses sys.executable instead.
if getattr(sys, "frozen", False):
    SCRIPT_DIR = Path(sys.executable).resolve().parent
else:
    SCRIPT_DIR = Path(__file__).resolve().parent
TOOLKIT_DIR = SCRIPT_DIR.parent
CONFIG_DIR = TOOLKIT_DIR / "Config"
LOGS_DIR = TOOLKIT_DIR / "Logs"
CONFIG_FILE = CONFIG_DIR / "last_folder.txt"
LOG_FILE = LOGS_DIR / "download_history.txt"
VIDEO_ARCHIVE = LOGS_DIR / "video_playlist_archive.txt"
AUDIO_ARCHIVE = LOGS_DIR / "audio_playlist_archive.txt"

QUALITY_FORMATS = {
    "480p": "bv*[height<=480]+ba/b[height<=480]",
    "720p": "bv*[height<=720]+ba/b[height<=720]",
    "1080p": "bv*[height<=1080]+ba/b[height<=1080]",
}

NO_WINDOW = getattr(subprocess, "CREATE_NO_WINDOW", 0)


def load_last_folder():
    if CONFIG_FILE.exists():
        try:
            return CONFIG_FILE.read_text(encoding="utf-8").strip()
        except OSError:
            return ""
    return ""


def save_last_folder(folder):
    CONFIG_DIR.mkdir(parents=True, exist_ok=True)
    CONFIG_FILE.write_text(folder, encoding="utf-8")


def write_log(entry_type, url, folder, fmt=None):
    LOGS_DIR.mkdir(parents=True, exist_ok=True)
    lines = [
        f"[{datetime.now().strftime('%a %m/%d/%Y %H:%M:%S')}]",
        f"Type: {entry_type}",
    ]
    if fmt:
        lines.append(f"Format: {fmt}")
    lines.append(f'URL: "{url}"')
    lines.append(f"Location: {folder}")
    lines.append("--------------------------------")
    with LOG_FILE.open("a", encoding="utf-8") as f:
        f.write("\n".join(lines) + "\n")


class YTToolkitGUI(tk.Tk):
    def __init__(self):
        super().__init__()
        self.title("YT Toolkit")
        self.geometry("680x580")
        self.minsize(600, 500)

        self.download_thread = None
        self.output_queue = queue.Queue()

        self._build_widgets()
        self._poll_queue()

    # ---------- UI construction ----------

    def _build_widgets(self):
        pad = {"padx": 10, "pady": 6}

        mode_frame = ttk.LabelFrame(self, text="What do you want to download?")
        mode_frame.pack(fill="x", **pad)

        self.media_type = tk.StringVar(value="Video")
        ttk.Radiobutton(mode_frame, text="Video", variable=self.media_type,
                         value="Video", command=self._on_type_change).pack(side="left", padx=10, pady=6)
        ttk.Radiobutton(mode_frame, text="Audio", variable=self.media_type,
                         value="Audio", command=self._on_type_change).pack(side="left", padx=10, pady=6)

        self.is_playlist = tk.BooleanVar(value=False)
        ttk.Checkbutton(mode_frame, text="This is a playlist", variable=self.is_playlist,
                         command=self._on_type_change).pack(side="left", padx=20, pady=6)

        url_frame = ttk.Frame(self)
        url_frame.pack(fill="x", **pad)
        ttk.Label(url_frame, text="URL:").pack(side="left")
        self.url_var = tk.StringVar()
        ttk.Entry(url_frame, textvariable=self.url_var).pack(side="left", fill="x", expand=True, padx=8)

        self.range_frame = ttk.Frame(self)
        ttk.Label(self.range_frame, text="Playlist range (e.g. 1-5, blank = all):").pack(side="left")
        self.range_var = tk.StringVar()
        ttk.Entry(self.range_frame, textvariable=self.range_var, width=15).pack(side="left", padx=8)

        self.option_frame = ttk.Frame(self)
        self.option_frame.pack(fill="x", **pad)
        self.option_label = ttk.Label(self.option_frame, text="Quality:")
        self.option_label.pack(side="left")
        self.quality_var = tk.StringVar(value="720p")
        self.audio_format_var = tk.StringVar(value="mp3")
        self.option_combo = ttk.Combobox(self.option_frame, textvariable=self.quality_var,
                                          values=["480p", "720p", "1080p"], state="readonly", width=15)
        self.option_combo.pack(side="left", padx=8)

        folder_frame = ttk.Frame(self)
        folder_frame.pack(fill="x", **pad)
        ttk.Label(folder_frame, text="Save to:").pack(side="left")
        self.folder_var = tk.StringVar(value=load_last_folder())
        ttk.Entry(folder_frame, textvariable=self.folder_var, state="readonly").pack(
            side="left", fill="x", expand=True, padx=8)
        ttk.Button(folder_frame, text="Browse...", command=self._browse_folder).pack(side="left")

        action_frame = ttk.Frame(self)
        action_frame.pack(fill="x", **pad)
        self.download_btn = ttk.Button(action_frame, text="Download", command=self._start_download)
        self.download_btn.pack(side="left")
        self.status_var = tk.StringVar(value="Ready.")
        ttk.Label(action_frame, textvariable=self.status_var).pack(side="left", padx=12)

        output_frame = ttk.LabelFrame(self, text="Output")
        output_frame.pack(fill="both", expand=True, **pad)
        self.output_text = tk.Text(output_frame, wrap="word", state="disabled", height=14)
        scrollbar = ttk.Scrollbar(output_frame, command=self.output_text.yview)
        self.output_text.configure(yscrollcommand=scrollbar.set)
        self.output_text.pack(side="left", fill="both", expand=True)
        scrollbar.pack(side="right", fill="y")

        tools_frame = ttk.Frame(self)
        tools_frame.pack(fill="x", **pad)
        ttk.Button(tools_frame, text="Update yt-dlp", command=self._update_ytdlp).pack(side="left")
        ttk.Button(tools_frame, text="Check Installation", command=self._check_installation).pack(
            side="left", padx=8)

        self._on_type_change()

    def _on_type_change(self):
        if self.is_playlist.get():
            self.range_frame.pack(fill="x", padx=10, pady=6, before=self.option_frame)
        else:
            self.range_frame.forget()

        if self.media_type.get() == "Video":
            self.option_label.configure(text="Quality:")
            self.option_combo.configure(textvariable=self.quality_var,
                                         values=["480p", "720p", "1080p"])
        else:
            self.option_label.configure(text="Format:")
            self.option_combo.configure(textvariable=self.audio_format_var,
                                         values=["mp3", "m4a", "opus"])

    # ---------- Actions ----------

    def _browse_folder(self):
        folder = filedialog.askdirectory(title="Choose a folder to save to")
        if folder:
            self.folder_var.set(folder)
            save_last_folder(folder)

    def _log_output(self, text):
        self.output_text.configure(state="normal")
        self.output_text.insert("end", text)
        self.output_text.see("end")
        self.output_text.configure(state="disabled")

    def _poll_queue(self):
        try:
            while True:
                line = self.output_queue.get_nowait()
                self._log_output(line)
        except queue.Empty:
            pass
        self.after(100, self._poll_queue)

    def _start_download(self):
        if self.download_thread and self.download_thread.is_alive():
            messagebox.showinfo("YT Toolkit", "A download is already running.")
            return

        url = self.url_var.get().strip()
        folder = self.folder_var.get().strip()

        if not url:
            messagebox.showwarning("YT Toolkit", "Paste a URL first.")
            return
        if not folder:
            messagebox.showwarning("YT Toolkit", "Choose a save folder first.")
            return

        media_type = self.media_type.get()
        playlist = self.is_playlist.get()
        rng = self.range_var.get().strip()

        cmd = ["yt-dlp", "--js-runtimes", "node", "--remote-components", "ejs:github"]

        log_type_parts = []
        fmt_for_log = None

        if media_type == "Video":
            quality = self.quality_var.get()
            fmt = QUALITY_FORMATS.get(quality, QUALITY_FORMATS["720p"])
            cmd += ["-f", fmt, "--merge-output-format", "mp4"]
            log_type_parts.append("Video")
        else:
            audio_fmt = self.audio_format_var.get()
            cmd += ["-x", "--audio-format", audio_fmt, "--audio-quality", "0"]
            log_type_parts.append("Audio")
            fmt_for_log = audio_fmt

        if playlist:
            log_type_parts.append("Playlist")
            archive = VIDEO_ARCHIVE if media_type == "Video" else AUDIO_ARCHIVE
            LOGS_DIR.mkdir(parents=True, exist_ok=True)
            cmd += ["--download-archive", str(archive)]
            if rng:
                cmd += ["--playlist-items", rng]
            out_template = os.path.join(folder, "%(playlist_index)s - %(title)s.%(ext)s")
        else:
            out_template = os.path.join(folder, "%(title)s.%(ext)s")

        cmd += ["-o", out_template, url]

        entry_type = " ".join(log_type_parts)

        self.download_btn.configure(state="disabled")
        self.status_var.set("Downloading...")
        self._log_output(f"\n> Starting {entry_type.lower()} download...\n\n")

        self.download_thread = threading.Thread(
            target=self._run_download, args=(cmd, entry_type, url, folder, fmt_for_log), daemon=True)
        self.download_thread.start()

    def _run_download(self, cmd, entry_type, url, folder, fmt_for_log):
        success = False
        try:
            process = subprocess.Popen(
                cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                text=True, bufsize=1, creationflags=NO_WINDOW)
            for line in process.stdout:
                self.output_queue.put(line)
            process.wait()
            success = process.returncode == 0
        except FileNotFoundError:
            self.output_queue.put("\nyt-dlp was not found. Use Check Installation below.\n")
        except Exception as exc:
            self.output_queue.put(f"\nError: {exc}\n")

        if success:
            write_log(entry_type, url, folder, fmt_for_log)
            self.output_queue.put("\nDownload complete.\n")
        else:
            self.output_queue.put("\nDownload failed.\n")

        self.after(0, self._download_finished, success)

    def _download_finished(self, success):
        self.download_btn.configure(state="normal")
        self.status_var.set("Done." if success else "Failed.")

    def _run_tool_command(self, cmd, label):
        self._log_output(f"\n> {label}...\n")

        def worker():
            try:
                process = subprocess.Popen(
                    cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                    text=True, bufsize=1, creationflags=NO_WINDOW)
                for line in process.stdout:
                    self.output_queue.put(line)
                process.wait()
            except FileNotFoundError:
                self.output_queue.put(f"\n{cmd[0]} was not found on this system.\n")
            except Exception as exc:
                self.output_queue.put(f"\nError: {exc}\n")
            self.output_queue.put(f"\n{label} finished.\n")

        threading.Thread(target=worker, daemon=True).start()

    def _update_ytdlp(self):
        self._run_tool_command(["py", "-m", "pip", "install", "-U", "yt-dlp"], "Updating yt-dlp")

    def _check_installation(self):
        self._log_output("\n> Checking installation...\n")

        def worker():
            checks = [
                ("Python", ["py", "--version"]),
                ("yt-dlp", ["py", "-m", "yt_dlp", "--version"]),
                ("FFmpeg", ["ffmpeg", "-version"]),
                ("Node.js", ["node", "-v"]),
            ]
            for name, check_cmd in checks:
                try:
                    result = subprocess.run(
                        check_cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                        text=True, creationflags=NO_WINDOW)
                    first_line = result.stdout.strip().splitlines()[0] if result.stdout.strip() else ""
                    if result.returncode == 0:
                        self.output_queue.put(f"[OK] {name} installed  {first_line}\n")
                    else:
                        self.output_queue.put(f"[MISSING] {name} not installed\n")
                except FileNotFoundError:
                    self.output_queue.put(f"[MISSING] {name} not installed\n")
            self.output_queue.put("\nCheck complete.\n")

        threading.Thread(target=worker, daemon=True).start()


if __name__ == "__main__":
    app = YTToolkitGUI()
    app.mainloop()
