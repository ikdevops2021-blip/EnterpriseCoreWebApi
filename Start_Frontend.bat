@echo off
echo ==================================================
echo         STARTING DQMS FRONTEND APPLICATION       
echo ==================================================

:: 1. Check and terminate existing frontend process if running
call "%~dp0Stop_Frontend.bat" >nul 2>&1

:: 2. Launch DQMS Frontend Web Application
echo [INFO] Launching Frontend Web App on http://localhost:8085 ...
set "FRONTEND_DIR=%~dp0dqms_frontend"

if "%~1"=="" (
    start "DQMS Frontend (Port 8085)" /D "%FRONTEND_DIR%" cmd /c "flutter run -d web-server --web-port 8085 --web-hostname localhost"
) else (
    start "DQMS Frontend (Port 8085)" /D "%FRONTEND_DIR%" cmd /c "flutter run %* --web-port 8085 --web-hostname localhost"
)

ping -n 4 127.0.0.1 >nul
echo [SUCCESS] Frontend startup initiated.
echo [INFO] Web App URL: http://localhost:8085
echo ==================================================
