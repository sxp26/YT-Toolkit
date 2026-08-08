@echo off
title Python Installer

echo.
echo ===========================
echo       Python Setup
echo ===========================
echo.

echo Checking Python...

py --version >nul 2>&1

if %errorlevel%==0 (
    echo Python is already installed.
    py --version
) else (
    echo Python not found.
    echo Installing Python...

    winget install Python.Python.3.13 --accept-package-agreements --accept-source-agreements

    echo.
    echo Python installation finished.
)

echo.
echo ===========================
echo       Setup Complete
echo ===========================

pause