@echo off
set TOOLKIT=%~dp0..
set LOG=%TOOLKIT%\Logs\download_history.txt
set ARCHIVE=%TOOLKIT%\Logs\audio_playlist_archive.txt

title YT Audio Playlist Downloader

echo.
echo ===========================
echo   YT Audio Playlist Downloader
echo ===========================
echo.

set /p URL=Paste the playlist URL: 

call "%TOOLKIT%\Utilities\common.bat" :GetFolder

if "%SAVE%"=="" (
    echo No folder selected.
    pause
    exit
)

echo.
echo Choose audio format:
echo.
echo 1. MP3 (Most compatible)
echo 2. M4A (Better quality/size balance)
echo 3. OPUS (Best quality/size)
echo.

set /p FORMAT=Enter choice: 

if "%FORMAT%"=="1" set AUDIO=mp3
if "%FORMAT%"=="2" set AUDIO=m4a
if "%FORMAT%"=="3" set AUDIO=opus

if not defined AUDIO (
    echo Invalid choice. Using MP3.
    set AUDIO=mp3
)

echo.
set /p RANGE=Enter playlist range e.g. 1-5 (or press Enter for the full playlist): 

set RANGEFLAG=
if not "%RANGE%"=="" set RANGEFLAG=--playlist-items %RANGE%

echo.
echo Downloading playlist as %AUDIO%...

py -m yt_dlp --js-runtimes node -x --audio-format %AUDIO% --audio-quality 0 --download-archive "%ARCHIVE%" %RANGEFLAG% -o "%SAVE%\%%(playlist_index)s - %%(title)s.%%(ext)s" "%URL%"

if %errorlevel%==0 (
    call "%TOOLKIT%\Utilities\common.bat" :WriteLog "Audio Playlist" "%AUDIO%"
    echo.
    echo Playlist download complete.
) else (
    echo.
    echo Playlist download failed.
)

pause
