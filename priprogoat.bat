@echo off
title Pripro Goat Rebirth Installer
setlocal enabledelayedexpansion

:: =====================================
:: Admin Check
:: =====================================
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo ############################################
    echo Publisher : Pripro Studios
    echo The Pripro Goat Installer Needs Admin Access!
    echo ############################################
    echo.
    echo Press YES to continue, or NO to quit.
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

:: =====================================
:: Error Handler
:: =====================================
:ErrorHandler
echo.
echo [!] ERROR OCCURRED!
echo Step: %1
echo Error Code: %errorlevel%
echo.
echo Please send this error to:
echo   Email: priprothezpro101@gmail.com
echo   Discord: Priprothezpro101
echo.
pause
exit /b %errorlevel%

:: =====================================
:: Banner
:: =====================================
echo ###########################################################
echo #  PRIPRO GOAT REBIRTH INSTALLER - PRIPRO STUDIOS         #
echo ###########################################################
echo.

:: =====================================
:: Ask if auto-select modpack
:: =====================================
choice /M "Automatically set Pripro Goat in TLauncher?"
if errorlevel 2 (
    set AUTOSELECT=0
    echo [*] User will select modpack manually.
) else (
    set AUTOSELECT=1
    echo [*] Pripro Goat will be set automatically.
)

:: =====================================
:: Step 1: Java
:: =====================================
:CheckJava
echo [*] Checking Java...
java -version >nul 2>&1
if %errorlevel% neq 0 (
    echo [*] Java not found. Installing JDK 21...
    powershell -Command "Invoke-WebRequest -Uri https://download.oracle.com/java/21/latest/jdk-21_windows-x64_bin.msi -OutFile jdk21.msi" || goto :ErrorHandler JavaDownload
    msiexec /i jdk21.msi /qn /norestart || goto :ErrorHandler JavaInstall
    del jdk21.msi
)
echo [*] Java OK.
echo.

:: =====================================
:: Step 2: TLauncher
:: =====================================
:InstallTLauncher
echo [*] Checking TLauncher...
set "TL_DIR=%APPDATA%\.tlauncher"
if not exist "%TL_DIR%\tlauncher.jar" (
    echo [*] TLauncher not found. Installing...
    powershell -Command "Invoke-WebRequest -Uri https://tlauncher.org/jar -OutFile tlauncher.jar" || goto :ErrorHandler TLDownload
    mkdir "%TL_DIR%"
    move tlauncher.jar "%TL_DIR%\tlauncher.jar" || goto :ErrorHandler TLMove
)
echo [*] TLauncher OK.
echo.

:: =====================================
:: Step 3: Download Modpack
:: =====================================
:DownloadModpack
echo [*] Downloading Pripro Goat Modpack...
set "FILE_ID=1StylMRAKwhpZtreEKpxlEI-l_eSWaYRQ"
set "OUT_FILE=PriproGoat.zip"
set "PACK_DIR=%APPDATA%\.minecraft\versions\PriproGoat"

if exist "%PACK_DIR%" rmdir /s /q "%PACK_DIR%"
mkdir "%PACK_DIR%" || goto :ErrorHandler PackDir

where curl >nul 2>&1
if %errorlevel%==0 (
    curl -c cookies.txt -s -L "https://drive.google.com/uc?export=download&id=%FILE_ID%" -o temp.html || goto :ErrorHandler Curl1
    for /f "tokens=2 delims==&" %%G in ('findstr /i "confirm=" temp.html') do set CONFIRM=%%G
    curl -Lb cookies.txt -L "https://drive.google.com/uc?export=download&confirm=%CONFIRM%&id=%FILE_ID%" -o "%OUT_FILE%" || goto :ErrorHandler Curl2
    del cookies.txt temp.html
) else (
    aria2c -x 16 -s 16 -o "%OUT_FILE%" "https://drive.google.com/uc?export=download&id=%FILE_ID%" || goto :ErrorHandler Aria
)

powershell -Command "Expand-Archive -Force '%OUT_FILE%' '%PACK_DIR%'" || goto :ErrorHandler Unzip
del "%OUT_FILE%"
echo [*] Modpack installed in: %PACK_DIR%
echo.

:: =====================================
:: Step 4: RAM + Swap
:: =====================================
:ConfigureRAM
echo [*] Configuring RAM and swap...
:: Get RAM in MB
for /f "skip=1 tokens=2 delims==" %%a in ('wmic computersystem get TotalPhysicalMemory /value') do set mem=%%a
set /a ramGB=!mem! / 1024 / 1024 / 1024
echo [*] System RAM: %ramGB% GB

set "TL_CFG=%APPDATA%\.tlauncher\tlauncher-2.0.properties"
if not exist "%TL_CFG%" > "%TL_CFG%" echo memory=8192

if %ramGB% GEQ 16 (
    echo [*] >=16GB RAM → No swap required.
) else if %ramGB% GEQ 8 (
    echo [*] 8–15GB RAM → Force 8GB allocation, no swap.
) else (
    echo [!] <8GB RAM detected. Modpack needs 8GB minimum.
    echo [*] Checking storage...
    for /f "tokens=3" %%D in ('dir /-C %SystemDrive%^|find "bytes free"') do set freeSpace=%%D
    set /a freeGB=%freeSpace:~0,-9%
    echo [*] Free space: %freeGB% GB

    if %freeGB% LSS 4 (
        echo [!] Not enough storage for swap. Aborting.
        goto :ErrorHandler SwapSpace
    )

    echo [*] Creating 4GB swap file...
    powershell -Command "Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management' -Name PagingFiles -Value 'C:\pagefile.sys 4096 4096'"
    echo [!] Reboot required for swap changes.
    set needReboot=1
)

:: Always set 8GB in TLauncher
powershell -Command "(Get-Content '%TL_CFG%') -replace '^memory=.*','memory=8192' | Set-Content '%TL_CFG%'"

:: Username
findstr /b "login=" "%TL_CFG%" >nul
if %errorlevel%==0 (
    for /f "tokens=2 delims==" %%U in ('findstr /b "login=" "%TL_CFG%"') do set "username=%%U"
    echo [*] Keeping username: %username%
) else (
    for /f %%A in ('powershell -Command "[System.Guid]::NewGuid().ToString().Substring(0,8)"') do set "rand=%%A"
    set "username=Goat%rand%"
    echo [*] Setting username: %username%
    echo login=%username%>>"%TL_CFG%"
)

if %AUTOSELECT%==1 (
    echo [*] Auto-selecting PriproGoat in TLauncher...
    echo selectedVersion=PriproGoat>>"%TL_CFG%"
)

echo [*] TLauncher ready with 8GB RAM and username=%username%
echo.

:: =====================================
:: Finish
:: =====================================
echo ###########################################################
echo # Pripro Goat Installer Finished!                        #
echo ###########################################################
if defined needReboot (
    echo [!] System must reboot for swap settings to apply!
)
pause
exit /b 0
