@echo off
title Pripro Goat Rebirth Auto-Updater
echo =================================================
echo     Installing / Updating Pripro Goat Rebirth
echo =================================================
echo.

:: Minecraft versions directory
set "MC_DIR=%APPDATA%\.minecraft\versions\PriproGoatRebirth"
set "TEMP_ZIP=%TEMP%\PriproGoat.zip"
set "GDRIVE_ID=1StylMRAKwhpZtreEKpxlEI-l_eSWaYRQ"
set "GDRIVE_URL=https://drive.google.com/uc?export=download&id=%GDRIVE_ID%"

:: Check if curl exists
where curl >nul 2>nul
if %errorlevel% neq 0 (
    echo [*] Installing curl...
    powershell -Command "Invoke-WebRequest -Uri https://curl.se/windows/dl-8.7.1_2/curl-8.7.1_2-win64-mingw.zip -OutFile '%TEMP%\curl.zip'"
    powershell -Command "Expand-Archive -Path '%TEMP%\curl.zip' -DestinationPath '%TEMP%\curl' -Force"
    set "PATH=%TEMP%\curl;%PATH%"
)

:: Check if aria2c exists
where aria2c >nul 2>nul
if %errorlevel% neq 0 (
    echo [*] Installing aria2c...
    powershell -Command "Invoke-WebRequest -Uri https://github.com/aria2/aria2/releases/download/release-1.37.0/aria2-1.37.0-win-64bit-build1.zip -OutFile '%TEMP%\aria2.zip'"
    powershell -Command "Expand-Archive -Path '%TEMP%\aria2.zip' -DestinationPath '%TEMP%\aria2' -Force"
    set "PATH=%TEMP%\aria2;%TEMP%\aria2\aria2-1.37.0-win-64bit-build1;%PATH%"
)

:: Remove old version
if exist "%MC_DIR%" (
    echo [*] Removing old Pripro Goat Rebirth version...
    rmdir /s /q "%MC_DIR%"
)

:: Download modpack using aria2c (handles Google Drive large files)
echo [*] Downloading latest Pripro Goat Rebirth modpack...
aria2c -x 16 -s 16 -o "%TEMP_ZIP%" "%GDRIVE_URL%"

if not exist "%TEMP_ZIP%" (
    echo [!] Failed to download modpack! Check your internet connection.
    pause
    exit /b
)

:: Extract into versions folder
echo [*] Extracting modpack into .minecraft\versions\PriproGoatRebirth...
powershell -Command "Expand-Archive -Path '%TEMP_ZIP%' -DestinationPath '%APPDATA%\.minecraft\versions\' -Force"

:: Clean up
del "%TEMP_ZIP%"

:: Configure TLauncher RAM
set "TL_CONFIG=%APPDATA%\.tlauncher\tlauncher-2.0.properties"

echo [*] Setting TLauncher to use 8GB RAM...
if exist "%TL_CONFIG%" (
    powershell -Command "(Get-Content '%TL_CONFIG%') -replace '^memory=.*','memory=8192' | Set-Content '%TL_CONFIG%'"
) else (
    echo memory=8192 > "%TL_CONFIG%"
)

echo.
echo =================================================
echo   Pripro Goat Rebirth installed/updated!
echo   TLauncher memory set to 8GB.
echo   Select 'PriproGoatRebirth' in TLauncher -> Play!
echo =================================================
pause
exit
