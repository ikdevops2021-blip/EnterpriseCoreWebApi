@echo off
title Stop DQMS Full Stack Enterprise Platform
echo ==================================================
echo   STOPPING DQMS ENTERPRISE PLATFORM (API + UI)    
echo ==================================================

echo [1/2] Stopping DNAQMS Backend Web API Server...
call "%~dp0Stop_Api.bat"

echo.
echo [2/2] Stopping DQMS Frontend Web Application...
call "%~dp0Stop_Frontend.bat"

echo.
echo ==================================================
echo   ALL SERVICES TERMINATED CLEANLY                 
echo ==================================================
