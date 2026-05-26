@echo off
setlocal

:: Admin check
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Requesting administrator privileges...
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

cd /d "%~dp0"

:menu
cls
echo =====================================
echo        NETWORK ADAPTER MENU
echo =====================================
echo.
echo 1. Disable all network adapters
echo 2. Enable all network adapters
echo 3. Disable then Enable all
echo 4. Exit
echo.

choice /c 1234 /n /m "Select an option [1-4]: "
if errorlevel 4 goto end
if errorlevel 3 goto both
if errorlevel 2 goto enable
if errorlevel 1 goto disable

:disable
echo.
echo Disabling all network adapters...
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0network-on-off.ps1" -DisableAll
echo.
pause
goto menu

:enable
echo.
echo Enabling all network adapters...
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0network-on-off.ps1" -EnableAll
echo.
pause
goto menu

:both
echo.
echo Disabling all network adapters...
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0network-on-off.ps1" -DisableAll
timeout /t 2 >nul
echo.
echo Enabling all network adapters...
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0network-on-off.ps1" -EnableAll
echo.
pause
goto menu

:end
exit /b