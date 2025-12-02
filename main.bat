::[Bat To Exe Converter]
::
::YAwzoRdxOk+EWAnk
::fBw5plQjdG8=
::YAwzuBVtJxjWCl3EqQJgSA==
::ZR4luwNxJguZRRnk
::Yhs/ulQjdF+5
::cxAkpRVqdFKZSDk=
::cBs/ulQjdF+5
::ZR41oxFsdFKZSDk=
::eBoioBt6dFKZSDk=
::cRo6pxp7LAbNWATEpCI=
::egkzugNsPRvcWATEpCI=
::dAsiuh18IRvcCxnZtBJQ
::cRYluBh/LU+EWAnk
::YxY4rhs+aU+JeA==
::cxY6rQJ7JhzQF1fEqQJQ
::ZQ05rAF9IBncCkqN+0xwdVs0
::ZQ05rAF9IAHYFVzEqQJQ
::eg0/rx1wNQPfEVWB+kM9LVsJDGQ=
::fBEirQZwNQPfEVWB+kM9LVsJDGQ=
::cRolqwZ3JBvQF1fEqQJQ
::dhA7uBVwLU+EWDk=
::YQ03rBFzNR3SWATElA==
::dhAmsQZ3MwfNWATElA==
::ZQ0/vhVqMQ3MEVWAtB9wSA==
::Zg8zqx1/OA3MEVWAtB9wSA==
::dhA7pRFwIByZRRnk
::Zh4grVQjdCyDJGyX8VAjFBxRRAWMAE+1EbsQ5+n//Na+rVgJQeA6OIvUzbqCL+EX71ekQ8dj02Jf+A==
::YB416Ek+ZG8=
::
::
::978f952a14a936cc963da21a135fa983
@echo off
setlocal
title Gehana YouTube Downloader

echo =======================================
echo     Starting Gehana Downloader...
echo =======================================
echo.

set "HAS_YTDLP=0"
set "HAS_FFMPEG=0"

:: ==========================================
::  CHECK yt-dlp
:: ==========================================
echo Checking for yt-dlp...
where yt-dlp >nul 2>&1
if %errorlevel%==0 (
    set "HAS_YTDLP=1"
    echo yt-dlp found.
) else (
    echo yt-dlp not found. Installing...
    where winget >nul 2>&1
    if %errorlevel%==0 (
        winget install --id yt-dlp.yt-dlp -e
        where yt-dlp >nul 2>&1 && set "HAS_YTDLP=1"
    )
)

:: ==========================================
::  CHECK ffmpeg
:: ==========================================
echo.
echo Checking for ffmpeg...
where ffmpeg >nul 2>&1
if %errorlevel%==0 (
    set "HAS_FFMPEG=1"
    echo ffmpeg found.
) else (
    echo ffmpeg not found. Installing...
    where winget >nul 2>&1
    if %errorlevel%==0 (
        winget install --id Gyan.FFmpeg -e --source winget
        where ffmpeg >nul 2>&1 && set "HAS_FFMPEG=1"
    )
)

echo.
echo yt-dlp  : %HAS_YTDLP%
echo ffmpeg : %HAS_FFMPEG%
echo.

:: If yt-dlp still missing, downloader won't work
if "%HAS_YTDLP%"=="0" (
    echo ERROR: yt-dlp is missing and could not be installed.
    echo Downloader cannot run.
    pause
    exit /b
)

:: ffmpeg missing is only a warning — downloader still works
if "%HAS_FFMPEG%"=="0" (
    echo WARNING: ffmpeg is missing. Some formats may fail.
    echo Continuing anyway...
    echo.
    timeout /t 2 >nul
)

:: ==========================================
::  GO STRAIGHT TO DOWNLOADER
:: ==========================================
goto :downloader


:: ==========================================
::  DOWNLOADER MENU
:: ==========================================
:downloader
cls
title Gehana YouTube Downloader

:dlmenu
cls
echo ---------------------------------------
echo       Gehans YouTube Downloader
echo ---------------------------------------
echo.
echo Choose one option:
echo.
echo   [1] Song (audio only, OPUS)
echo   [2] Video (best quality, webm/mp4)
echo   [3] Exit
echo.
set /p choice=Enter your choice (1-3): 

if "%choice%"=="1" goto :song
if "%choice%"=="2" goto :video
if "%choice%"=="3" goto :quit

echo.
echo Invalid choice. Try again.
pause
goto :dlmenu


:song
cls
title Song Downloader
echo ---------------------------------------
echo Enter YouTube URL:
set /p URL=

yt-dlp --no-playlist --audio-format opus -x -o "%%(title)s.%%(ext)s" "%URL%"

echo.
echo Song downloaded. Press any key.
pause >nul
goto :dlmenu


:video
cls
title Video Downloader
echo ---------------------------------------
echo Enter YouTube URL:
set /p URL=

yt-dlp --no-playlist -f "bestvideo[ext=webm]+bestaudio[ext=webm]/bestvideo[ext=mp4]+bestaudio[ext=m4a]/best" -o "%%(title)s.%%(ext)s" "%URL%"

echo.
echo Video downloaded. Press any key.
pause >nul
goto :dlmenu


:quit
echo.
echo Goodbye.
pause >nul
exit /b
