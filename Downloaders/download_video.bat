@echo off
set TOOLKIT=%~dp0..
set LOG=%TOOLKIT%\Logs\download_history.txt

title YT Video Downloader

echo.
echo ===========================
echo      YT Video Downloader
echo ===========================
echo.

set /p URL=Paste the YouTube URL: 

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

py -m yt_dlp --js-runtimes node -f "%FORMAT%" --merge-output-format mp4 -o "%SAVE%\%%(title)s.%%(ext)s" "%URL%"

if %errorlevel%==0 (
    call "%TOOLKIT%\Utilities\common.bat" :WriteLog "Video"
    echo.
    echo Download complete.
) else (
    echo.
    echo Download failed.
)

pause
