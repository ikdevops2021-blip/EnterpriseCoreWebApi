@echo off
echo ==================================================
echo         STOPPING DQMS FRONTEND APPLICATION       
echo ==================================================

set "FOUND=0"
for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":8085" ^| findstr "LISTENING"') do (
    echo [INFO] Terminating frontend process PID: %%a listening on port 8085...
    taskkill /PID %%a /F >nul 2>&1
    set "FOUND=1"
)

:: Also terminate any flutter process running dqms_frontend
for /f "tokens=2 delims=," %%a in ('wmic process where "name='dart.exe' and commandline like '%%dqms_frontend%%'" get processid /format:csv 2^>nul ^| findstr /r "[0-9]"') do (
    echo [INFO] Terminating Dart/Flutter process PID: %%a...
    taskkill /PID %%a /F >nul 2>&1
    set "FOUND=1"
)

if "%FOUND%"=="0" (
    echo [INFO] No running frontend processes detected on port 8085.
) else (
    echo [SUCCESS] Frontend server stopped successfully.
)
