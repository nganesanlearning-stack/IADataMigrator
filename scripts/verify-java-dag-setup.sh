#!/bin/bash
# Script to verify Java setup for Airflow DAGs

echo "========================================"
echo "Java-Airflow Integration Setup Checker"
echo "========================================"

# Check Java installation
echo "Checking Java installation..."
java -version
if [ $? -eq 0 ]; then
    echo "✅ Java is properly installed"
else
    echo "❌ Java is not installed or not in PATH"
    exit 1
fi

# Check Java file existence
JAVA_FILE="/opt/airflow/java-apps/AirflowJavaTask.java"
echo "Checking for Java file at: $JAVA_FILE"
if [ -f "$JAVA_FILE" ]; then
    echo "✅ Java file exists"
else
    echo "❌ Java file not found at $JAVA_FILE"
    exit 1
fi

# Check DAG file existence
DAG_FILE="/opt/airflow/dags/java_task_dag.py"
echo "Checking for DAG file at: $DAG_FILE"
if [ -f "$DAG_FILE" ]; then
    echo "✅ DAG file exists"
else
    echo "❌ DAG file not found at $DAG_FILE"
    exit 1
fi

# Try compiling the Java file
echo "Attempting to compile Java file..."
cd /opt/airflow/java-apps
javac AirflowJavaTask.java
if [ $? -eq 0 ]; then
    echo "✅ Java compilation successful"
    ls -la AirflowJavaTask.class
else
    echo "❌ Java compilation failed"
    exit 1
fi

# Try running the Java class
echo "Attempting to run Java class..."
java AirflowJavaTask "test_arg1" "test_arg2"
if [ $? -eq 0 ]; then
    echo "✅ Java execution successful"
else
    echo "❌ Java execution failed"
    exit 1
fi

# Check permissions on DAG folder
echo "Checking permissions on DAG folder..."
ls -la /opt/airflow/dags/
echo ""

# Check Airflow webserver status
echo "Checking Airflow webserver status..."
ps aux | grep airflow-webserver | grep -v grep
if [ $? -eq 0 ]; then
    echo "✅ Airflow webserver appears to be running"
else
    echo "❌ Airflow webserver may not be running"
fi

echo "========================================"
echo "Setup check complete"
echo "========================================"
echo ""
echo "To trigger the DAG:"
echo "1. Access Airflow web UI (usually at http://localhost:8080)"
echo "2. Navigate to DAGs list"
echo "3. Find 'java_task_dag'"
echo "4. Enable the DAG if it's not enabled (toggle switch)"
echo "5. Click the 'Trigger DAG' button (play icon)"
echo "6. Monitor the execution in the UI"
echo "========================================"
