@echo off
REM list-folders.bat - Simple batch file to list folders in a directory
REM To be triggered from Airflow DAG

echo ========================================
echo Folder Listing Utility
echo ========================================
echo Executed at: %date% %time%
echo Current directory: %cd%
echo.

REM Check if directory parameter is provided
if "%~1"=="" (
    echo No directory parameter provided. Using current directory.
    set TARGET_DIR=.
) else (
    echo Using provided directory: %~1
    set TARGET_DIR=%~1
)

echo.
echo Listing folders in: %TARGET_DIR%
echo ========================================

REM List only directories in the target folder
dir /AD /B "%TARGET_DIR%"

echo.
echo ========================================
echo Executing Java JAR file
echo ========================================

REM Execute the Java JAR file
if defined JAVA_HOME (
    echo Java Home is defined: %JAVA_HOME%
    "%JAVA_HOME%\bin\java" -jar "%TARGET_DIR%\HelloAirflow.jar"
) else (
    echo Java Home is not defined, trying to use java directly
    java -jar "%TARGET_DIR%\HelloAirflow.jar"
)

echo.
echo ========================================
echo Java execution complete!
echo ========================================

echo.
echo ========================================
echo Java Environment Information:
echo ----------------------------------------
echo JAVA_HOME: %JAVA_HOME%
if defined JAVA_HOME (
    if exist "%JAVA_HOME%\bin\java.exe" (
        "%JAVA_HOME%\bin\java" -version
    )
)
echo ========================================

echo.
echo ========================================
echo Listing complete!
echo ========================================

REM Return success
exit /b 0
