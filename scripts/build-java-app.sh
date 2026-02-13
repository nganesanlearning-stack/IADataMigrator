#!/bin/bash
# Script to build the Java application in the Airflow environment

cd /opt/airflow/java-apps

echo "===== Building Java Application ====="
echo "Maven version:"
mvn -version

echo "Building project..."
mvn clean package

if [ $? -eq 0 ]; then
    echo "Build successful!"
    echo "JAR file created at: target/airflow-java-app-1.0-SNAPSHOT.jar"
    
    # List the files in the target directory
    echo "Files in target directory:"
    ls -la target/
    
    # Test the JAR file
    echo "Testing JAR execution..."
    java -jar target/airflow-java-app-1.0-SNAPSHOT.jar "test-argument"
else
    echo "Build failed!"
    exit 1
fi
