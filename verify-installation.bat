@echo off
REM Verification Script for Airflow + Java JDK 21 Setup (Windows)
REM Run this script to verify all components are working correctly

echo 🔍 Airflow + Java JDK 21 Verification Script
echo ==============================================

echo.
echo 1. 📊 Checking Container Status
echo --------------------------------

REM Check if containers are running
docker ps --format "table {{.Names}}" | findstr "javaairflow-airflow-webserver-1" >nul
if %errorlevel% equ 0 (
    echo ✅ javaairflow-airflow-webserver-1 is running
) else (
    echo ❌ javaairflow-airflow-webserver-1 is not running
    goto :error
)

docker ps --format "table {{.Names}}" | findstr "javaairflow-airflow-scheduler-1" >nul
if %errorlevel% equ 0 (
    echo ✅ javaairflow-airflow-scheduler-1 is running
) else (
    echo ❌ javaairflow-airflow-scheduler-1 is not running
)

docker ps --format "table {{.Names}}" | findstr "javaairflow-postgres-1" >nul
if %errorlevel% equ 0 (
    echo ✅ javaairflow-postgres-1 is running
) else (
    echo ❌ javaairflow-postgres-1 is not running
)

echo.
echo 2. ☕ Testing Java Installation
echo --------------------------------

echo 🧪 Testing Java version...
docker exec javaairflow-airflow-webserver-1 java -version 2>nul
if %errorlevel% equ 0 (
    echo ✅ Java JDK - INSTALLED
) else (
    echo ❌ Java JDK - NOT FOUND
    goto :error
)

echo 🧪 Testing Java compiler...
docker exec javaairflow-airflow-webserver-1 javac -version 2>nul
if %errorlevel% equ 0 (
    echo ✅ Java Compiler - AVAILABLE
) else (
    echo ❌ Java Compiler - NOT FOUND
)

echo.
echo 3. 🔧 Testing Maven Installation
echo ---------------------------------

echo 🧪 Testing Maven version...
docker exec javaairflow-airflow-webserver-1 mvn --version >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ Maven - INSTALLED
) else (
    echo ❌ Maven - NOT FOUND
    goto :error
)

echo.
echo 4. 📁 Testing Directory Structure
echo ----------------------------------

docker exec javaairflow-airflow-webserver-1 test -d /opt/airflow/java-apps >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ Directory exists: /opt/airflow/java-apps
) else (
    echo ❌ Directory missing: /opt/airflow/java-apps
)

docker exec javaairflow-airflow-webserver-1 test -d /opt/airflow/dags >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ Directory exists: /opt/airflow/dags
) else (
    echo ❌ Directory missing: /opt/airflow/dags
)

echo.
echo 5. 🧪 Testing Java Application Execution
echo -----------------------------------------

REM Create test directory
docker exec javaairflow-airflow-webserver-1 mkdir -p /opt/airflow/data >nul 2>&1

echo 🧪 Testing SimpleJavaApp execution...
docker exec javaairflow-airflow-webserver-1 java -cp /opt/airflow/java-apps SimpleJavaApp >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ SimpleJavaApp - EXECUTED SUCCESSFULLY
) else (
    echo ❌ SimpleJavaApp - EXECUTION FAILED
)

echo 🧪 Testing DataProcessor execution...
docker exec javaairflow-airflow-webserver-1 java -cp /opt/airflow/java-apps DataProcessor /opt/airflow/java-apps/sample_data.csv /opt/airflow/data/verify_output.csv >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ DataProcessor - EXECUTED SUCCESSFULLY
    
    REM Check if output file was created
    docker exec javaairflow-airflow-webserver-1 test -f /opt/airflow/data/verify_output.csv >nul 2>&1
    if %errorlevel% equ 0 (
        echo ✅ DataProcessor - OUTPUT FILE CREATED
    ) else (
        echo ❌ DataProcessor - OUTPUT FILE NOT CREATED
    )
) else (
    echo ❌ DataProcessor - EXECUTION FAILED
)

echo.
echo 6. 🌐 Testing Web Interface Connectivity
echo -----------------------------------------

REM Test Airflow webserver port (simplified check)
echo 🧪 Testing Airflow Web UI accessibility...
curl -s -o nul -w "%%{http_code}" http://localhost:9580 | findstr "200 302" >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ Airflow Web UI - ACCESSIBLE (http://localhost:9580)
) else (
    echo ❌ Airflow Web UI - NOT ACCESSIBLE (http://localhost:9580)
)

echo.
echo 7. 📋 System Summary
echo --------------------

echo Container Status:
docker-compose ps

echo.
echo Java Information:
docker exec javaairflow-airflow-webserver-1 java -version 2>&1

echo.
echo Maven Information:
docker exec javaairflow-airflow-webserver-1 mvn --version 2>&1

echo.
echo 🎉 Verification Complete!
echo.
echo 📱 Quick Access:
echo    Airflow Web UI: http://localhost:9580
echo    Username: admin
echo    Password: admin
echo.
echo 🔧 Next Steps:
echo    1. Access the Airflow Web UI
echo    2. Explore the available DAGs
echo    3. Run a test DAG to verify Java integration
echo    4. Create your own Java-based DAGs

goto :end

:error
echo.
echo ❌ Verification failed. Please check the setup and try again.
echo Run 'docker-compose ps' to check container status.

:end
pause
