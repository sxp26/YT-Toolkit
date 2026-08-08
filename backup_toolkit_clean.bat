@echo off
title Clean YT Toolkit Backup

echo.
echo ===========================
echo    Clean Toolkit Backup
echo ===========================
echo.

set SOURCE=%~dp0
set BACKUP_DIR=%USERPROFILE%\Desktop\YT Toolkit Backups

if not exist "%BACKUP_DIR%" mkdir "%BACKUP_DIR%"

set BACKUP_NAME=YT Toolkit Clean Backup %date:/=-%

echo Creating clean backup...

xcopy "%SOURCE%" "%BACKUP_DIR%\%BACKUP_NAME%" /E /I /H /Y /EXCLUDE:backup_exclude.txt

echo.
echo Clean backup complete.
echo Saved to:
echo %BACKUP_DIR%\%BACKUP_NAME%

pause