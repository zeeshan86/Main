@echo off
setlocal EnableDelayedExpansion
chcp 65001 >nul
title Steam Downgrader-AHD-Tech[discord.gg/sv6EGxCRnC]
color 0A

echo.
echo ================================================
echo  Steam Downgrader-AHD-Tech[discord.gg/sv6EGxCRnC]
echo ================================================
echo.

echo ▶ Closing Steam...
taskkill /f /im steam.exe >nul 2>&1
timeout /t 5 /nobreak >nul

set "STEAM_PATH="

:: ===============================
:: 1) Registry (64-bit)
:: ===============================
for /f "tokens=2,*" %%A in (
    'reg query "HKLM\SOFTWARE\Wow6432Node\Valve\Steam" /v InstallPath 2^>nul'
) do (
    if exist "%%B\steam.exe" (
        set "STEAM_PATH=%%B"
        goto :FOUND
    )
)

:: ===============================
:: 2) Registry (32-bit)
:: ===============================
for /f "tokens=2,*" %%A in (
    'reg query "HKLM\SOFTWARE\Valve\Steam" /v InstallPath 2^>nul'
) do (
    if exist "%%B\steam.exe" (
        set "STEAM_PATH=%%B"
        goto :FOUND
    )
)

:: ===============================
:: 3) Start Menu Shortcut
:: ===============================
set "STEAM_LNK=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Steam\Steam.lnk"

if exist "%STEAM_LNK%" (
    for /f "delims=" %%I in (
        'powershell -NoProfile -Command ^
        "(New-Object -ComObject WScript.Shell).CreateShortcut('%STEAM_LNK%').TargetPath"'
    ) do (
        if exist "%%I" (
            set "STEAM_PATH=%%~dpI"
            set "STEAM_PATH=!STEAM_PATH:~0,-1!"
            goto :FOUND
        )
    )
)

:: ===============================
:: 4) Common paths (all drives)
:: ===============================
for %%D in (C D E F G H I J K L M N O P Q R S T U V W X Y Z) do (
    for %%P in (
        "%%D:\Steam"
        "%%D:\Program Files\Steam"
        "%%D:\Program Files (x86)\Steam"
    ) do (
        if exist "%%P\steam.exe" (
            set "STEAM_PATH=%%P"
            goto :FOUND
        )
    )
)

:FOUND
if not defined STEAM_PATH (
    echo ❌ Steam not found!
    pause
    exit /b
)

echo ✅ Steam found at:
echo %STEAM_PATH%
echo.

cd /d "%STEAM_PATH%"

echo ▶ Running Steam downgrade command...
steam.exe -forcesteamupdate -forcepackagedownload -overridepackageurl http://web.archive.org/web/20251122131734if_/media.steampowered.com/client -exitsteam

timeout /t 10 /nobreak >nul

echo ▶ Creating steam.cfg...
(
echo BootStrapperInhibitAll=enable
echo BootStrapperForceSelfUpdate=disable
) > steam.cfg

timeout /t 3 /nobreak >nul

echo ▶ Starting Steam...
start "" "%STEAM_PATH%\steam.exe"

echo.
echo ✅ Done!
pause
