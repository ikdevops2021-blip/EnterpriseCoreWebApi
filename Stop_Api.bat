@echo off
echo ==================================================
echo         STOPPING DNAQMS WEB API SERVER           
echo ==================================================

:: 1. Terminate DNAQMSAPI.Api.exe process if running
tasklist /FI "IMAGENAME eq DNAQMSAPI.Api.exe" 2>NUL | find /I /N "DNAQMSAPI.Api.exe">NUL
if "%ERRORLEVEL%"=="0" (
    echo [INFO] Terminating DNAQMSAPI.Api.exe...
    taskkill /IM DNAQMSAPI.Api.exe /F >nul 2>&1
) else (
    echo [INFO] No standalone DNAQMSAPI.Api.exe process found.
)

:: 2. Terminate dotnet process running the API project
set "FOUND=0"
for /f "tokens=2 delims=," %%a in ('wmic process where "name='dotnet.exe' and commandline like '%%DNAQMSAPI.Api%%'" get processid /format:csv 2^>nul ^| findstr /r "[0-9]"') do (
    echo [INFO] Terminating dotnet API process PID: %%a...
    taskkill /PID %%a /F >nul 2>&1
    set "FOUND=1"
)

:: 3. Terminate any remaining listener on port 5026
for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":5026" ^| findstr "LISTENING"') do (
    echo [INFO] Terminating API listener PID: %%a on port 5026...
    taskkill /PID %%a /F >nul 2>&1
    set "FOUND=1"
)

if "%FOUND%"=="0" (
    echo [INFO] No running dotnet API processes found.
)

echo [SUCCESS] Web API Server stopped successfully.
