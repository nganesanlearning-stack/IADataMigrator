@echo off
REM Quick Setup Script for Airflow + Java JDK 21 (Windows)
REM Run this script on the target machine after copying the project files

echo 🚀 Starting Airflow + Java JDK 21 Setup...

REM Check if Docker is installed
docker --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Docker not found. Please install Docker Desktop first.
    echo Visit: https://docs.docker.com/desktop/install/windows/
    pause
    exit /b 1
)

REM Check if Docker Compose is installed
docker-compose --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Docker Compose not found. Please install Docker Compose first.
    pause
    exit /b 1
)

echo ✅ Docker and Docker Compose found

REM Display versions
echo 🔍 Versions:
docker --version
docker-compose --version

REM Check if we're in the right directory
if not exist "docker-compose.yaml" (
    echo ❌ docker-compose.yaml not found. Please run this script from the javaairflow directory.
    pause
    exit /b 1
)

REM Stop any existing containers
echo 🛑 Stopping any existing containers...
docker-compose down 2>nul

REM Ask about cleanup
set /p cleanup="🧹 Do you want to clean up old Docker images? (y/N): "
if /i "%cleanup%"=="y" (
    echo 🧹 Cleaning up Docker system...
    docker system prune -f
)

REM Build images
echo 🔨 Building Docker images (this may take several minutes)...
docker-compose build --no-cache

if %errorlevel% neq 0 (
    echo ❌ Build failed. Check the error messages above.
    pause
    exit /b 1
)

REM Start services
echo 🚀 Starting services...
docker-compose up -d

if %errorlevel% neq 0 (
    echo ❌ Failed to start services. Check the error messages above.
    pause
    exit /b 1
)

REM Wait for services to start
echo ⏳ Waiting for services to start...
timeout /t 30 /nobreak >nul

REM Check status
echo 📊 Checking service status...
docker-compose ps

REM Test Java installation
echo ☕ Testing Java JDK 21 installation...
docker exec javaairflow-airflow-webserver-1 java -version

echo 🔧 Testing Maven installation...
docker exec javaairflow-airflow-webserver-1 mvn --version

REM Test Java application
echo 🧪 Testing Java application execution...
docker exec javaairflow-airflow-webserver-1 mkdir -p /opt/airflow/data
docker exec javaairflow-airflow-webserver-1 java -cp /opt/airflow/java-apps SimpleJavaApp

REM Test data processor
echo 📊 Testing data processor...
docker exec javaairflow-airflow-webserver-1 java -cp /opt/airflow/java-apps DataProcessor /opt/airflow/java-apps/sample_data.csv /opt/airflow/data/test_output.csv

echo.
echo 🎉 Setup Complete!
echo.
echo 📱 Access Points:
echo    Airflow Web UI: http://localhost:9580 (admin/admin)
echo    PgAdmin:        http://localhost:9550 (admin@admin.com/admin)
echo    PostgreSQL:     localhost:9532 (airflow/airflow)
echo.
echo 🔧 Common Commands:
echo    View logs:      docker-compose logs -f
echo    Stop services:  docker-compose down
echo    Restart:        docker-compose restart
echo    Enter container: docker exec -it javaairflow-airflow-webserver-1 bash
echo.
echo 📚 For detailed documentation, see DEPLOYMENT_GUIDE.md

pause
