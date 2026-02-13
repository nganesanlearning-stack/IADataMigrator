#!/bin/bash
# run-batch-file.sh - Helper script to run a Windows batch file in Airflow

# Set path to batch file and target directory
BATCH_FILE="/opt/airflow/java-apps/list-folders.bat"
TARGET_DIR="/opt/airflow/java-apps"

echo "===================================================="
echo "Enhanced Batch File Execution Helper"
echo "===================================================="
echo "Executed at: $(date)"
echo "Current directory: $(pwd)"
echo ""

# Check if batch file exists
echo "Checking batch file..."
if [ -f "$BATCH_FILE" ]; then
    echo "✅ Batch file found: $BATCH_FILE"
    echo "Batch file contents:"
    echo "----------------------------------------------------"
    cat "$BATCH_FILE"
    echo "----------------------------------------------------"
else
    echo "❌ Batch file not found: $BATCH_FILE"
    exit 1
fi

# Check Java environment
echo "Checking Java environment..."
echo "JAVA_HOME: $JAVA_HOME"
java -version 2>&1

# Check if HelloAirflow.jar exists
echo "Checking for JAR file..."
if [ -f "$TARGET_DIR/HelloAirflow.jar" ]; then
    echo "✅ JAR file found: $TARGET_DIR/HelloAirflow.jar"
    ls -la "$TARGET_DIR/HelloAirflow.jar"
else
    echo "❌ JAR file not found: $TARGET_DIR/HelloAirflow.jar"
    echo "Available JAR files:"
    find "$TARGET_DIR" -name "*.jar" -type f | sort
fi

# Try running with cmd.exe if available
echo "Checking for cmd.exe..."
if command -v cmd.exe &> /dev/null; then
    echo "✅ cmd.exe found, running batch file with cmd.exe..."
    cmd.exe /c "$BATCH_FILE" "$TARGET_DIR"
    EXIT_CODE=$?
    echo "Batch file execution completed with exit code: $EXIT_CODE"
    exit $EXIT_CODE
fi

# Try running with wine if available
echo "Checking for wine..."
if command -v wine &> /dev/null; then
    echo "✅ wine found, running batch file with wine..."
    wine cmd.exe /c "$BATCH_FILE" "$TARGET_DIR"
    EXIT_CODE=$?
    echo "Batch file execution completed with exit code: $EXIT_CODE"
    exit $EXIT_CODE
fi

# Fallback to simulating the batch file functionality
echo "❌ Neither cmd.exe nor wine is available."
echo "Simulating batch file functionality with bash..."

echo "========================================"
echo "Folder Listing Utility (Simulated)"
echo "========================================"
echo "Listing folders in: $TARGET_DIR"
echo "========================================"
find "$TARGET_DIR" -maxdepth 1 -type d | sort

echo ""
echo "========================================"
echo "Executing Java JAR directly"
echo "========================================"
if [ -f "$TARGET_DIR/HelloAirflow.jar" ]; then
    java -jar "$TARGET_DIR/HelloAirflow.jar"
else
    echo "JAR file not found, skipping Java execution"
fi

echo ""
echo "========================================"
echo "Java Environment Information:"
echo "========================================"
echo "JAVA_HOME: $JAVA_HOME"
java -version 2>&1

echo ""
echo "========================================"
echo "Execution complete!"
echo "========================================"

exit 0
