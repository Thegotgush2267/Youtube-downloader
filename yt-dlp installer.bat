@echo off
title yt-dlp Installer (winget)

echo ================================
echo        yt-dlp Installer
echo     (via Windows Package Manager)
echo ================================
echo.

:: Check if winget exists
where winget >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: winget is not available on this system.
    echo Ensure you have Windows 10/11 with App Installer installed.
    pause
    exit /b
)

echo Installing yt-dlp using winget...
echo.

winget install --id yt-dlp.yt-dlp -e

echo.
echo Checking yt-dlp installation...

where yt-dlp >nul 2>&1
if %errorlevel%==0 (
    echo.
    echo SUCCESS: yt-dlp is installed and ready to use!
    echo.
    yt-dlp --version
    echo.
    pause
    exit /b
)

echo.
echo ERROR: yt-dlp installation failed.
echo Try again or install manually from:
echo https://github.com/yt-dlp/yt-dlp
echo.
pause
exit /b
