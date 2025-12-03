o@echo off
title Gehana YouTube Downloader
echo NOTE: This is a deprecated version
:: Check if FFmpeg exists
ffmpeg -version >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo FFmpeg is not installed on this system.
    echo Would you like to install it?
    set /p perm=Y/N: 
    if /I "%perm%"=="Y" (
        :: Check if winget exists
        where winget >nul 2>&1
        if %errorlevel% neq 0 (
            echo Winget not found on this system.
            echo Install FFmpeg manually from: https://ffmpeg.org/download.html
            pause
            goto :menu
        )

        echo Installing FFmpeg using winget...
        winget install --id Gyan.FFmpeg --source winget
        echo FFmpeg installation complete.
        pause
    ) else (
        echo Cannot continue without FFmpeg.
        pause
        exit /b
    )
)

:menu
cls
echo ==========================================
echo        Gehana YouTube Downloader
echo ==========================================
echo.
echo 1) Download video
echo 2) Exit
echo.
set /p option=Choose an option: 

if "%option%"=="1" goto :download
if "%option%"=="2" goto :end
goto :menu

:download
cls
echo Enter YouTube video URL:
set /p URL=URL: 

if "%URL%"=="" goto :menu

echo.
echo Downloading using yt-dlp...
echo.

:: FIXED FORMAT STRING (your old one was cut / corrupted)
py -3.10 -m yt_dlp --no-playlist -f ^
"bestvideo[ext=webm]+bestaudio[ext=webm]/bestvideo[ext=mp4]+bestaudio[ext=m4a]/best" ^
-o "%%(title)s.%%(ext)s" "%URL%"

echo.
echo Video download complete. Press any key to return to the menu.
pause >nul
goto :menu

:end
echo.
echo Goodbye. Press any key to exit.
pause >nul


