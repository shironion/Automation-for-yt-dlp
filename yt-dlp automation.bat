@echo off
SETLOCAL ENABLEDELAYEDEXPANSION
echo Running yt-dlp automation...

rem Get the link from clipboard
for /f "delims=" %%a in ('powershell -command "Get-Clipboard"') do set "link=%%a"

if not defined link (
    echo No link found in clipboard.
    pause
    exit /b
)

rem Show available formats
yt-dlp --list-formats "!link!"

rem Ask for format
set /p format="Enter the desired format (eg. 299+140): "
if not defined format set "format=140"

rem Ask for destination
echo Choose a destination:
echo [1] Desktop
echo [2] Downloads
echo [3] Choose Custom Folder (GUI)
set /p choice="Enter choice (1-3): "
if not defined choice set "choice=3"

rem Set destination
set "metadata_args="
if "%choice%"=="1" set "destination=%USERPROFILE%\Desktop"
if "%choice%"=="2" set "destination=%USERPROFILE%\Downloads"
if "%choice%"=="3" (
    for /f "delims=" %%F in ('powershell -command "Add-Type -AssemblyName System.Windows.Forms; $f=New-Object System.Windows.Forms.FolderBrowserDialog; $f.ShowDialog() | Out-Null; $f.SelectedPath"') do set "destination=%%F"
)

if not defined destination (
    echo No valid choice, using default.
    set "destination=%USERPROFILE%\Desktop"
)

rem === Perform the download
:download
yt-dlp -P "!destination!" -f "!format!" -o "%%(title)s.%%(ext)s" "!link!"

IF %ERRORLEVEL% NEQ 0 (
    echo Error detected. Attempting to update yt-dlp...
    yt-dlp -U
    echo Retrying download...
    yt-dlp -P "!destination!" -f "!format!" -o "%%(title)s.%%(ext)s" "!link!"
    IF %ERRORLEVEL% NEQ 0 (
        echo Still failed after update. Exiting.
        pause
        exit /b 1
    )
)

echo Completed successfully.

pause
exit /b 0
