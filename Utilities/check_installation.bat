@echo off
title YT Toolkit Check

echo.
echo ===========================
echo      YT Toolkit Check
echo ===========================
echo.

echo Checking Python...

py --version >nul 2>&1

if %errorlevel%==0 (
    echo [OK] Python installed
    py --version
) else (
    echo [MISSING] Python not installed
)


echo.
echo Checking yt-dlp...

py -m yt_dlp --version >nul 2>&1

if %errorlevel%==0 (
    echo [OK] yt-dlp installed
    py -m yt_dlp --version
) else (
    echo [MISSING] yt-dlp not installed
)


echo.
echo Checking FFmpeg...

ffmpeg -version >nul 2>&1

if %errorlevel%==0 (
    echo [OK] FFmpeg installed
) else (
    echo [MISSING] FFmpeg not installed
)


echo.
echo Checking Node.js...

node -v >nul 2>&1

if %errorlevel%==0 (
    echo [OK] Node.js installed
    node -v
) else (
    echo [MISSING] Node.js not installed
)


echo.
echo ===========================
echo       Check Complete
echo ===========================

pause