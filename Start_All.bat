@echo off
echo ==================================================
echo   STARTING DQMS ENTERPRISE PLATFORM (API + UI)    
echo ==================================================

echo [1/2] Launching DNAQMS Backend Web API Server...
call "%~dp0Start_Api.bat"

echo.
echo [2/2] Launching DQMS Frontend Web Application...
call "%~dp0Start_Frontend.bat" %*

echo.
echo ==================================================
echo   ALL SERVICES STARTED SUCCESSFULLY               
echo ==================================================
echo   - Backend Web API:   http://localhost:5026/swagger
echo   - Frontend Web App:  http://localhost:8085
echo ==================================================
