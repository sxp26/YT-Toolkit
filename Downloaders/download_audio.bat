@echo off
set TOOLKIT=%~dp0..
set LOG=%TOOLKIT%\Logs\download_history.txt

title YT Audio Downloader

echo.
echo ===========================
echo       YT Audio Downloader
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
echo Downloading as %AUDIO%...

yt-dlp --js-runtimes node --remote-components ejs:github -x --audio-format %AUDIO% --audio-quality 0 -o "%SAVE%\%%(title)s.%%(ext)s" "%URL%"

if %errorlevel%==0 (
    call "%TOOLKIT%\Utilities\common.bat" :WriteLog "Audio" "%AUDIO%"
    echo.
    echo Download complete.
) else (
    echo.
    echo Download failed.
)

pause
