@echo off
title YT Toolkit Setup

:MENU
cls

echo.
echo ===========================
echo        YT Toolkit Setup
echo ===========================
echo.
echo 1. Full Setup
echo 2. Check Installation
echo 3. Exit
echo.

set /p choice=Choose an option: 

if "%choice%"=="1" goto INSTALL
if "%choice%"=="2" goto CHECK
if "%choice%"=="3" exit

echo Invalid choice.
pause
goto MENU


:INSTALL
cls

echo.
echo ===========================
echo     Running Full Setup
echo ===========================
echo.

echo Step 1/3: Installing Python...
call Installers\install_python.bat

echo.
echo Step 2/3: Installing Media Tools...
call Installers\install_media_tools.bat

echo.
echo Step 3/3: Checking Installation...
call Utilities\check_installation.bat

echo.
echo Setup finished.
pause
goto MENU


:CHECK
call Utilities\check_installation.bat
goto MENU