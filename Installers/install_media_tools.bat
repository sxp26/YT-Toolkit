@echo off
title YT Media Tools Installer

echo.
echo ===========================
echo    YT Media Tools Setup
echo ===========================
echo.

echo Checking FFmpeg...

ffmpeg -version >nul 2>&1

if %errorlevel%==0 (
    echo FFmpeg is already installed.
) else (
    echo FFmpeg not found.
    echo Installing FFmpeg...

    winget install Gyan.FFmpeg --accept-package-agreements --accept-source-agreements
)


echo.
echo Checking Node.js...

node -v >nul 2>&1

if %errorlevel%==0 (
    echo Node.js is already installed.
    node -v
) else (
    echo Node.js not found.
    echo Installing Node.js...

    winget install OpenJS.NodeJS.LTS --accept-package-agreements --accept-source-agreements
)


echo.
echo Checking yt-dlp...

py -m yt_dlp --version >nul 2>&1

if %errorlevel%==0 (
    echo yt-dlp is already installed.
    echo Updating yt-dlp...

    py -m pip install -U yt-dlp
) else (
    echo yt-dlp not found.
    echo Installing yt-dlp...

    py -m pip install -U yt-dlp
)


echo.
echo ===========================
echo      Setup Complete
echo ===========================

pause