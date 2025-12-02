@echo off
title Gehana YouTube Downloader

@echo off

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
            echo You need Windows 10/11 with App Installer installed.
            pause
            exit /b
        )

        echo Installing FFmpeg \(Gyan build\)...
        echo.

        :: Install FFmpeg Gyan exact ID
        winget install --id Gyan.FFmpeg -e --source winget

        if %errorlevel% neq 0 (
            echo.
            echo Something went wrong during installation.
            pause
            exit /b
        )

        echo.
        echo FFmpeg installation complete, homie.
        echo Type "ffmpeg -version" to check.
        echo.
        pause

    ) else (
        echo Installation cancelled.
        pause
    )
) else (
    echo FFmpeg is already installed.
    pause
)

:menu
cls
echo ---------------------------------------
echo       Gehans YouTube Downloader
echo ---------------------------------------
echo.
echo choose one option:
echo.
echo   [1] Song (audio only, OPUS)
echo   [2] Video (best quality, webm)
echo   [3] Exit
echo.
set /p choice=Enter your choice (1-3): 

if "%choice%"=="1" goto :song
if "%choice%"=="2" goto :video
if "%choice%"=="3" goto :end

echo.
echo Invalid choice. Please try again.
pause
goto :menu

:song
cls
title YouTube single SONG downloader

echo -----------------------------------------
echo Welcome to Gehans YouTube Song Downloader
echo -----------------------------------------
echo.
echo Enter YouTube URL:
set /p URL=

py -3.10 -m yt_dlp --no-playlist --audio-format opus -x -o "%%(title)s.%%(ext)s" "%URL%"

echo.
echo Song download complete. Press any key to return to the menu.
pause >nul
goto :menu

:video
cls
title YouTube single VIDEO downloader

echo ----------------------------------
echo Welcome to Gehans Video Downloader
echo ----------------------------------
echo.
echo Enter YouTube URL:
set /p URL=

rem Best attempt at high-quality video:
rem 1) best video+audio in webm if possible
rem 2) otherwise best mp4 video + m4a audio
rem 3) otherwise any best
py -3.10 -m yt_dlp --no-playlist -f "bestvideo[ext=webm]+bestaudio[ext=webm]/bestvideo[ext=mp4]+bestaudio[ext=m4a]/best" -o "%%(title)s.%%(ext)s" "%URL%"

echo.
echo Video download complete. Press any key to return to the menu.
pause >nul
goto :menu

:end
echo.
echo Goodbye. Press any key to exit.
pause >nul
