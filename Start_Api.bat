@echo off
echo ==================================================
echo         STARTING DNAQMS WEB API SERVER           
echo ==================================================

:: 1. Check if DNAQMSAPI process is already running and terminate it
tasklist /FI "IMAGENAME eq DNAQMSAPI.Api.exe" 2>NUL | find /I /N "DNAQMSAPI.Api.exe">NUL
if "%ERRORLEVEL%"=="0" (
    echo [INFO] Found existing DNAQMSAPI.Api process running. Terminating...
    taskkill /IM DNAQMSAPI.Api.exe /F
    timeout /t 2 /nobreak >nul
)

:: 2. Check if dotnet process running the API project is present and terminate it
for /f "tokens=2 delims=," %%a in ('wmic process where "name='dotnet.exe' and commandline like '%%DNAQMSAPI.Api.csproj%%'" get processid /format:csv 2^>nul ^| findstr /r "[0-9]"') do (
    echo [INFO] Terminating dotnet API background process PID: %%a...
    taskkill /PID %%a /F >nul 2>&1
)

:: 3. Start DNAQMSAPI Web Server in a new window
echo [INFO] Launching Web API on http://localhost:5026 ...
start "DNAQMSAPI Server" dotnet run --project "%~dp0DNAQMSAPI\DNAQMSAPI.Api\DNAQMSAPI.Api.csproj"

timeout /t 3 /nobreak >nul
echo [SUCCESS] Web API startup initiated. Swagger UI available at http://localhost:5026/swagger
