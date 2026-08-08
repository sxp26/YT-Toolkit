@echo off
title YT Tools Updater

echo.
echo ===========================
echo       YT Tools Update
echo ===========================
echo.

echo Updating yt-dlp...
py -m pip install -U yt-dlp

echo.
echo Update complete.
pause