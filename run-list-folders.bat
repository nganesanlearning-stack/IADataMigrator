@echo off
REM run-list-folders.bat - Run the folder listing utility locally on Windows

echo ========================================
echo Folder Listing Utility
echo ========================================
echo Executed at: %date% %time%
echo Current directory: %cd%
echo.

set TARGET_DIR=%1
if "%TARGET_DIR%"=="" set TARGET_DIR=C:\Docker\javaairflow

echo Listing folders in: %TARGET_DIR%
echo ========================================

dir /AD /B "%TARGET_DIR%"

echo.
echo ========================================
echo Listing complete!
echo ========================================

pause
