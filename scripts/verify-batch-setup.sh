#!/bin/bash
# verify-batch-setup.sh
# Script to verify the Java batch processing setup

echo "====================================================="
echo "Java Batch Process Verification"
echo "====================================================="

# Check for Java files
echo "Checking Java files..."
cd /opt/airflow/java-apps
if [ -f "DataValidator.java" ] && [ -f "DataProcessor.java" ] && [ -f "ReportGenerator.java" ]; then
    echo "✅ All Java source files found"
else
    echo "❌ Missing some Java source files"
    ls -la *.java || echo "No Java files found"
fi

# Check for batch script
echo "Checking batch script..."
if [ -f "process-data.sh" ]; then
    echo "✅ Batch script found"
    
    # Make script executable
    chmod +x process-data.sh
    echo "Made batch script executable"
else
    echo "❌ Batch script not found"
fi

# Check for sample data
echo "Checking sample data..."
if [ -f "sample_data.csv" ]; then
    echo "✅ Sample data file found"
    echo "Contents:"
    head -n 5 sample_data.csv
else
    echo "❌ Sample data file not found"
fi

# Compile Java files
echo "Compiling Java files..."
javac *.java
if [ $? -eq 0 ]; then
    echo "✅ Java compilation successful"
    echo "Compiled files:"
    ls -la *.class
else
    echo "❌ Java compilation failed"
fi

# Check DAG file
echo "Checking DAG file..."
if [ -f "/opt/airflow/dags/java_batch_dag.py" ]; then
    echo "✅ Java batch DAG found"
else
    echo "❌ Java batch DAG not found"
fi

# Create output directory
echo "Setting up output directory..."
mkdir -p output
chmod 777 output
echo "✅ Output directory created and permissions set"

echo "====================================================="
echo "Verification complete!"
echo "====================================================="
echo ""
echo "To test the batch script directly, run:"
echo "cd /opt/airflow/java-apps && ./process-data.sh sample_data.csv output"
echo ""
echo "To trigger the DAG, access the Airflow web UI and manually trigger:"
echo "DAG name: java_batch_processing_dag"
echo "====================================================="
