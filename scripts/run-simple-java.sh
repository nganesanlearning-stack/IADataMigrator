#!/bin/bash
# Simple script to compile and run a Java application directly

echo "========================================="
echo "Java Application Runner"
echo "========================================="

# Go to the java-apps directory
cd /opt/airflow/java-apps

# Display Java version
echo "Java version:"
java -version
echo ""

# Compile the Java file
echo "Compiling Java application..."
javac SimpleJavaApp.java

# Check if compilation was successful
if [ $? -eq 0 ]; then
    echo "Compilation successful!"
    
    echo "Files in directory:"
    ls -la
    
    echo "Running Java application..."
    echo "----------------------------------------"
    java SimpleJavaApp "Argument1" "Argument2" "Hello from Airflow!"
    echo "----------------------------------------"
    
    echo "Execution complete!"
else
    echo "Compilation failed!"
    exit 1
fi

echo "========================================="
