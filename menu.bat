@echo off
title YT Toolkit Menu

:MENU
cls

echo ===========================
echo          YT Toolkit
echo ===========================
echo.
echo 1. Download Video
echo 2. Download Audio
echo 3. Download Video Playlist
echo 4. Download Audio Playlist
echo 5. Update yt-dlp
echo 6. Check Installation
echo 7. Exit
echo.

set /p choice=Choose an option: 

if "%choice%"=="1" goto VIDEO
if "%choice%"=="2" goto AUDIO
if "%choice%"=="3" goto VIDEOPLAYLIST
if "%choice%"=="4" goto AUDIOPLAYLIST
if "%choice%"=="5" goto UPDATE
if "%choice%"=="6" goto CHECK
if "%choice%"=="7" exit

echo Invalid choice.
pause
goto MENU


:VIDEO
call Downloaders\download_video.bat
goto MENU

:AUDIO
call Downloaders\download_audio.bat
goto MENU

:VIDEOPLAYLIST
call Downloaders\download_video_playlist.bat
goto MENU

:AUDIOPLAYLIST
call Downloaders\download_audio_playlist.bat
goto MENU

:UPDATE
call Utilities\update_tools.bat
goto MENU

:CHECK
call Utilities\check_installation.bat
goto MENU