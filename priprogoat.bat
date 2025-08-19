@echo off
title Installing Pripro Goat Rebirth Modpack
echo =========================================
echo     Installing Pripro Goat Rebirth
echo =========================================
echo.

:: Where TLauncher stores Minecraft data
set "MC_DIR=%APPDATA%\.minecraft"
set "VER_DIR=%MC_DIR%\versions\PriproGoatRebirth"

:: Make sure Minecraft folder exists
if not exist "%MC_DIR%" (
    echo [!] Could not find .minecraft folder. Run TLauncher at least once!
    pause
    exit /b
)

:: Temp folder for download
set "TEMP_ZIP=%TEMP%\pripro_modpack.zip"

echo [*] Downloading modpack...
powershell -Command "Invoke-WebRequest -Uri 'https://drive.google.com/uc?export=download&id=1StylMRAKwhpZtreEKpxlEI-l_eSWaYRQ' -OutFile '%TEMP_ZIP%'"

if not exist "%TEMP_ZIP%" (
    echo [!] Download failed. Check your internet connection!
    pause
    exit /b
)

echo [*] Extracting modpack into versions folder...
if not exist "%VER_DIR%" mkdir "%VER_DIR%"
powershell -Command "Expand-Archive -Path '%TEMP_ZIP%' -DestinationPath '%VER_DIR%' -Force"

echo [*] Cleaning up...
del "%TEMP_ZIP%"

echo.
echo =========================================
echo   Pripro Goat Rebirth installed!
echo   Open TLauncher -> Select version:
echo       "PriproGoatRebirth"
echo   -> Play!
echo =========================================
pause
exit
