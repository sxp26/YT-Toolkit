@echo off

if "%~1"=="" exit /b

set ACTION=%1
shift
goto %ACTION%

:: ============================================================
:: :GetFolder
:: Sets %SAVE% to the chosen download folder.
:: Remembers the last used folder in Config\last_folder.txt
:: and offers it as a default so you don't have to browse every time.
:: ============================================================
:GetFolder
set "CONFIG=%TOOLKIT%\Config\last_folder.txt"
set "LASTFOLDER="

if exist "%CONFIG%" set /p LASTFOLDER=<"%CONFIG%"

if defined LASTFOLDER (
    echo.
    echo Last used folder: %LASTFOLDER%
    set /p "USEDEFAULT=Press Enter to use it, or type N to browse for a new one: "

    if /i not "%USEDEFAULT%"=="N" (
        set "SAVE=%LASTFOLDER%"
        goto SaveFolder
    )
)

for /f "delims=" %%i in ('powershell -command "Add-Type -AssemblyName System.Windows.Forms; $f=New-Object System.Windows.Forms.FolderBrowserDialog; if($f.ShowDialog() -eq 'OK'){echo $f.SelectedPath}"') do set "SAVE=%%i"

:SaveFolder
if "%SAVE%"=="" exit /b

if not exist "%TOOLKIT%\Config" mkdir "%TOOLKIT%\Config"

> "%CONFIG%" echo %SAVE%

exit /b


:: ============================================================
:: :WriteLog
:: %~1 = Type (e.g. "Video", "Audio", "Playlist")
:: %~2 = Format (optional, e.g. "mp3") - leave blank if not used
:: Expects %LOG%, %URL%, %SAVE% to already be set by the caller.
:: ============================================================
:WriteLog
echo [%date% %time%] >> "%LOG%"
echo Type: %~1 >> "%LOG%"
if not "%~2"=="" echo Format: %~2 >> "%LOG%"
echo URL: "%URL%" >> "%LOG%"
echo Location: %SAVE% >> "%LOG%"
echo -------------------------------- >> "%LOG%"
exit /b
