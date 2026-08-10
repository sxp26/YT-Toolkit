@echo off
set TOOLKIT=%~dp0..
set LOG=%TOOLKIT%\Logs\download_history.txt
set ARCHIVE=%TOOLKIT%\Logs\video_playlist_archive.txt

title YT Playlist Downloader

echo.
echo ===========================
echo     YT Playlist Downloader
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
echo Choose quality:
echo.
echo 1. 480p - Smaller file size
echo 2. 720p - Balanced
echo 3. 1080p - Higher quality
echo.

set /p QUALITY=Enter choice: 

if "%QUALITY%"=="1" set FORMAT=bv*[height^<=480]+ba/b[height^<=480]
if "%QUALITY%"=="2" set FORMAT=bv*[height^<=720]+ba/b[height^<=720]
if "%QUALITY%"=="3" set FORMAT=bv*[height^<=1080]+ba/b[height^<=1080]

if not defined FORMAT (
    echo Invalid choice. Using 720p.
    set FORMAT=bv*[height^<=720]+ba/b[height^<=720]
)

echo.
set /p RANGE=Enter playlist range e.g. 1-5 (or press Enter for the full playlist): 

set RANGEFLAG=
if not "%RANGE%"=="" set RANGEFLAG=--playlist-items %RANGE%

echo.
echo Downloading playlist...

py -m yt_dlp --js-runtimes node -f "%FORMAT%" --merge-output-format mp4 --download-archive "%ARCHIVE%" %RANGEFLAG% -o "%SAVE%\%%(playlist_index)s - %%(title)s.%%(ext)s" "%URL%"

if %errorlevel%==0 (
    call "%TOOLKIT%\Utilities\common.bat" :WriteLog "Playlist"
    echo.
    echo Playlist download complete.
) else (
    echo.
    echo Playlist download failed.
)

pause
