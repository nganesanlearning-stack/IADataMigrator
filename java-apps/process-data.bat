@echo off
REM process-data.bat - Windows batch file for Java data processing
REM This batch file runs a sequence of Java programs for data processing
REM To be triggered from an Airflow DAG

echo ============================================================
echo Java Data Processing Batch Script (Windows)
echo ============================================================
echo Script started at: %date% %time%
echo Current directory: %cd%

REM Check for arguments
echo Checking arguments...
if "%~1"=="" (
    echo ERROR: Missing required arguments!
    echo Usage: %0 ^<input_file^> [output_directory]
    exit /b 1
)

set INPUT_FILE=%~1
if "%~2"=="" (
    set OUTPUT_DIR=.\output
) else (
    set OUTPUT_DIR=%~2
)

echo Input file: %INPUT_FILE%
echo Output directory: %OUTPUT_DIR%

REM Create output directory if it doesn't exist
if not exist "%OUTPUT_DIR%" mkdir "%OUTPUT_DIR%"

REM Display Java version
echo ============================================================
echo Java Environment:
java -version
echo Java Home: %JAVA_HOME%
echo ============================================================

REM Execute first Java task - Data validation
echo Step 1: Validating data file...
java -cp . DataValidator "%INPUT_FILE%"
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Data validation failed with error code %ERRORLEVEL%
    exit /b %ERRORLEVEL%
)

REM Execute second Java task - Data processing
echo Step 2: Processing data...
java -cp . DataProcessor "%INPUT_FILE%" "%OUTPUT_DIR%\processed_data.txt"
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Data processing failed with error code %ERRORLEVEL%
    exit /b %ERRORLEVEL%
)

REM Execute third Java task - Generate report
echo Step 3: Generating report...
java -cp . ReportGenerator "%OUTPUT_DIR%\processed_data.txt" "%OUTPUT_DIR%\report.html"
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Report generation failed with error code %ERRORLEVEL%
    exit /b %ERRORLEVEL%
)

REM Print completion message
echo ============================================================
echo Batch processing completed successfully!
echo Output files in: %OUTPUT_DIR%
dir /b "%OUTPUT_DIR%"
echo Script completed at: %date% %time%
echo ============================================================

REM Return success
exit /b 0
