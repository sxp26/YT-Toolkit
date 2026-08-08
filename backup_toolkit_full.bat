@echo off
title Full YT Toolkit Backup

echo.
echo ===========================
echo    Full Toolkit Backup
echo ===========================
echo.

set SOURCE=%~dp0
set BACKUP_DIR=%USERPROFILE%\Desktop\YT Toolkit Backups

if not exist "%BACKUP_DIR%" mkdir "%BACKUP_DIR%"

set BACKUP_NAME=YT Toolkit Full Backup %date:/=-%

echo Creating full backup...

xcopy "%SOURCE%" "%BACKUP_DIR%\%BACKUP_NAME%" /E /I /H /Y

echo.
echo Full backup complete.
echo Saved to:
echo %BACKUP_DIR%\%BACKUP_NAME%

pause