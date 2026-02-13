@echo off
REM setup-project.bat - Windows batch file to set up the project environment

echo =======================================================
echo Setting up Java Airflow Project Environment
echo =======================================================
echo.

REM Check if Docker is installed
where docker >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Docker not found in PATH
    echo Please install Docker Desktop for Windows first
    exit /b 1
)

REM Create project structure
echo Creating project directory structure...
mkdir dags 2>nul
mkdir logs 2>nul
mkdir plugins 2>nul
mkdir scripts 2>nul
mkdir java-apps 2>nul
mkdir java-apps\output 2>nul
mkdir java-apps\archives 2>nul
mkdir config 2>nul

REM Check if .env file exists
if not exist .env (
    echo Creating .env file...
    (
        echo AIRFLOW_UID=50000
        echo AIRFLOW_GID=50000
        echo _AIRFLOW_WWW_USER_USERNAME=airflow
        echo _AIRFLOW_WWW_USER_PASSWORD=airflow
    ) > .env
)

REM Make scripts executable with Git Bash if available
where bash >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    echo Making scripts executable with Git Bash...
    bash -c "chmod +x ./scripts/*.sh" 2>nul
)

echo.
echo =======================================================
echo Project structure created successfully!
echo =======================================================
echo.
echo Next steps:
echo 1. Run the Docker setup with: bash setup-docker-environment.sh
echo 2. Start containers with: docker-compose up -d
echo 3. Access Airflow web UI at: http://localhost:8080
echo 4. Username: airflow / Password: airflow
echo.
echo To run the Windows batch processing example:
echo 1. Trigger the "windows_batch_processing_dag" DAG from the Airflow UI
echo 2. Check logs to see the execution results
echo =======================================================
