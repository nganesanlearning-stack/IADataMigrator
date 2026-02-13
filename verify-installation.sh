#!/bin/bash

# Verification Script for Airflow + Java JDK 21 Setup
# Run this script to verify all components are working correctly

set -e

echo "🔍 Airflow + Java JDK 21 Verification Script"
echo "=============================================="

# Function to check if container is running
check_container() {
    if docker ps --format "table {{.Names}}" | grep -q "$1"; then
        echo "✅ $1 is running"
        return 0
    else
        echo "❌ $1 is not running"
        return 1
    fi
}

# Function to test command in container
test_command() {
    local container=$1
    local command=$2
    local description=$3
    
    echo "🧪 Testing: $description"
    if docker exec $container $command >/dev/null 2>&1; then
        echo "✅ $description - PASSED"
    else
        echo "❌ $description - FAILED"
        return 1
    fi
}

echo ""
echo "1. 📊 Checking Container Status"
echo "--------------------------------"

containers=(
    "javaairflow-airflow-webserver-1"
    "javaairflow-airflow-scheduler-1"
    "javaairflow-airflow-worker-1"
    "javaairflow-airflow-triggerer-1"
    "javaairflow-postgres-1"
    "javaairflow-redis-1"
)

all_running=true
for container in "${containers[@]}"; do
    if ! check_container $container; then
        all_running=false
    fi
done

if [ "$all_running" = false ]; then
    echo ""
    echo "❌ Some containers are not running. Please check with: docker-compose ps"
    exit 1
fi

echo ""
echo "2. ☕ Testing Java Installation"
echo "--------------------------------"

# Test Java version
echo "🧪 Testing Java version..."
java_version=$(docker exec javaairflow-airflow-webserver-1 java -version 2>&1 | head -n 1)
if echo "$java_version" | grep -q "21.0"; then
    echo "✅ Java JDK 21 - INSTALLED ($java_version)"
else
    echo "❌ Java JDK 21 - NOT FOUND ($java_version)"
    exit 1
fi

# Test Java compiler
test_command "javaairflow-airflow-webserver-1" "javac -version" "Java Compiler (javac)"

echo ""
echo "3. 🔧 Testing Maven Installation"
echo "---------------------------------"

# Test Maven version
echo "🧪 Testing Maven version..."
maven_version=$(docker exec javaairflow-airflow-webserver-1 mvn --version 2>&1 | head -n 1)
if echo "$maven_version" | grep -q "Apache Maven"; then
    echo "✅ Maven - INSTALLED ($maven_version)"
else
    echo "❌ Maven - NOT FOUND"
    exit 1
fi

echo ""
echo "4. 📁 Testing Directory Structure"
echo "----------------------------------"

directories=(
    "/opt/airflow/java-apps"
    "/opt/airflow/java-apps/configs"
    "/opt/airflow/java-apps/jars"
    "/opt/airflow/java-apps/libs"
    "/opt/airflow/java-apps/logs"
    "/opt/airflow/dags"
)

for dir in "${directories[@]}"; do
    if docker exec javaairflow-airflow-webserver-1 test -d "$dir"; then
        echo "✅ Directory exists: $dir"
    else
        echo "❌ Directory missing: $dir"
    fi
done

echo ""
echo "5. 🧪 Testing Java Application Execution"
echo "-----------------------------------------"

# Create test directory
docker exec javaairflow-airflow-webserver-1 mkdir -p /opt/airflow/data

# Test SimpleJavaApp
echo "🧪 Testing SimpleJavaApp execution..."
if docker exec javaairflow-airflow-webserver-1 java -cp /opt/airflow/java-apps SimpleJavaApp >/dev/null 2>&1; then
    echo "✅ SimpleJavaApp - EXECUTED SUCCESSFULLY"
else
    echo "❌ SimpleJavaApp - EXECUTION FAILED"
fi

# Test DataProcessor
echo "🧪 Testing DataProcessor execution..."
if docker exec javaairflow-airflow-webserver-1 java -cp /opt/airflow/java-apps DataProcessor /opt/airflow/java-apps/sample_data.csv /opt/airflow/data/verify_output.csv >/dev/null 2>&1; then
    echo "✅ DataProcessor - EXECUTED SUCCESSFULLY"
    
    # Check if output file was created
    if docker exec javaairflow-airflow-webserver-1 test -f /opt/airflow/data/verify_output.csv; then
        echo "✅ DataProcessor - OUTPUT FILE CREATED"
    else
        echo "❌ DataProcessor - OUTPUT FILE NOT CREATED"
    fi
else
    echo "❌ DataProcessor - EXECUTION FAILED"
fi

echo ""
echo "6. 🌐 Testing Web Interface Connectivity"
echo "-----------------------------------------"

# Test Airflow webserver port
if curl -s -o /dev/null -w "%{http_code}" http://localhost:9580 | grep -q "200\|302"; then
    echo "✅ Airflow Web UI - ACCESSIBLE (http://localhost:9580)"
else
    echo "❌ Airflow Web UI - NOT ACCESSIBLE (http://localhost:9580)"
fi

echo ""
echo "7. 📝 Testing Environment Variables"
echo "------------------------------------"

# Check Java environment variables
java_home=$(docker exec javaairflow-airflow-webserver-1 echo '$JAVA_HOME')
maven_home=$(docker exec javaairflow-airflow-webserver-1 echo '$MAVEN_HOME')

if [ "$java_home" = "/opt/java/temurin-21" ]; then
    echo "✅ JAVA_HOME - CORRECTLY SET ($java_home)"
else
    echo "❌ JAVA_HOME - INCORRECTLY SET ($java_home)"
fi

if [ "$maven_home" = "/opt/maven" ]; then
    echo "✅ MAVEN_HOME - CORRECTLY SET ($maven_home)"
else
    echo "❌ MAVEN_HOME - INCORRECTLY SET ($maven_home)"
fi

echo ""
echo "8. 📋 System Summary"
echo "--------------------"

echo "Container Status:"
docker-compose ps --format "table {{.Service}}\t{{.State}}\t{{.Ports}}"

echo ""
echo "Java Information:"
docker exec javaairflow-airflow-webserver-1 java -version 2>&1 | head -n 3

echo ""
echo "Maven Information:"
docker exec javaairflow-airflow-webserver-1 mvn --version | head -n 2

echo ""
echo "🎉 Verification Complete!"
echo ""
echo "📱 Quick Access:"
echo "   Airflow Web UI: http://localhost:9580"
echo "   Username: admin"
echo "   Password: admin"
echo ""
echo "🔧 Next Steps:"
echo "   1. Access the Airflow Web UI"
echo "   2. Explore the available DAGs"
echo "   3. Run a test DAG to verify Java integration"
echo "   4. Create your own Java-based DAGs"
