# YT Toolkit

A simple yt-dlp based YouTube downloader toolkit for Windows. Menu-driven,
no coding required — just batch scripts wrapping yt-dlp.

## First Time Setup

1. Download or clone this repo.
2. Run `setup.bat`
3. Choose **1. Full Setup**

This installs:
- Python
- yt-dlp
- FFmpeg
- Node.js

After setup completes, use `menu.bat` for downloads.

## Daily Use

Open `menu.bat`:

1. **Download Video** — single video, quality selection (480p/720p/1080p)
2. **Download Audio** — extracts audio as MP3, M4A, or OPUS
3. **Download Video Playlist** — quality selection, optional range (e.g.
   `1-5`) or full playlist, skips items already downloaded
4. **Download Audio Playlist** — same as above, audio only
5. **Update yt-dlp** — updates to the latest version
6. **Check Installation** — verifies all tools are working

All download options remember your last save folder — press Enter to
reuse it, or type `N` to browse for a new one.

Paste the link as-is — no need to wrap it in quotes yourself.

## GUI (alternative to menu.bat)

[#gui-alternative-to-menubat](#gui-alternative-to-menubat)

If you'd rather use a proper window instead of the console menu, run
`GUI/yt_toolkit_gui.pyw` instead of `menu.bat`. It covers the same four
download options (video, audio, video playlist, audio playlist) with the
same quality/format choices, and shares the same `Config/last_folder.txt`
and `Logs/` files as the batch scripts — so you can switch between the two
freely without anything breaking or redownloading.

No extra setup needed — it uses `tkinter`, which ships with Python by
default.

## Folder Structure

```
Installers/     install_python.bat, install_media_tools.bat
Downloaders/    download_video.bat, download_audio.bat,
                download_video_playlist.bat, download_audio_playlist.bat
Utilities/      update_tools.bat, check_installation.bat, common.bat
                (common.bat holds shared helper functions - not run directly)
Logs/           download_history.txt, video_playlist_archive.txt,
                audio_playlist_archive.txt (generated on your machine,
                not tracked in this repo)
Config/         last_folder.txt (generated on your machine,
                not tracked in this repo)
GUI/            yt_toolkit_gui.pyw (optional GUI alternative to menu.bat)
```

## Requirements

- Windows 10/11
- Internet connection
- winget (included with modern Windows)

## Notes

- FFmpeg is required for combining video/audio and audio conversion.
- Node.js helps yt-dlp with some JavaScript-based site features.
- Update yt-dlp regularly — YouTube changes frequently and old versions
  break easily.
- Deleting a playlist archive file makes the next run of that playlist
  script treat everything as new and redownload it.

## Disclaimer

This toolkit is a convenience wrapper around
[yt-dlp](https://github.com/yt-dlp/yt-dlp), an open source project.
Downloading content you don't own or hold rights to may violate the
terms of service of the platform you're downloading from, regardless of
what tool is used. You're responsible for how you use this. Use it for
content you have the right to download (your own uploads, public domain
material, or content explicitly licensed for download).

## License

MIT — see [LICENSE](LICENSE).
