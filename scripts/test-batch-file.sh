#!/bin/bash
# test-batch-file.sh - Script to test running a Windows batch file in Docker

echo "====================================================="
echo "Windows Batch File Test"
echo "====================================================="

BATCH_FILE="/opt/airflow/java-apps/list-folders.bat"
TARGET_DIR="/opt/airflow"

# Check if batch file exists
echo "Checking batch file..."
if [ -f "$BATCH_FILE" ]; then
    echo "✅ Batch file found: $BATCH_FILE"
    cat "$BATCH_FILE"
else
    echo "❌ Batch file not found: $BATCH_FILE"
    exit 1
fi

# Check if we have cmd.exe (Windows container)
echo "Checking for cmd.exe..."
if command -v cmd.exe &> /dev/null; then
    echo "✅ cmd.exe found, running batch file directly..."
    cmd.exe /c "$BATCH_FILE" "$TARGET_DIR"
    exit $?
fi

# Check if we have wine
echo "Checking for wine..."
if command -v wine &> /dev/null; then
    echo "✅ wine found, running batch file with wine..."
    wine cmd.exe /c "$BATCH_FILE" "$TARGET_DIR"
    exit $?
fi

# Fallback to simulating the batch file with bash
echo "❌ Neither cmd.exe nor wine found."
echo "Simulating batch file functionality with bash..."

echo "========================================"
echo "Folder Listing Utility (Simulated)"
echo "========================================"
echo "Executed at: $(date)"
echo "Current directory: $(pwd)"
echo ""
echo "Listing folders in: $TARGET_DIR"
echo "========================================"

# List directories
find "$TARGET_DIR" -maxdepth 1 -type d | sort

echo ""
echo "========================================"
echo "Listing complete!"
echo "========================================"

echo "====================================================="
echo "Test complete!"
echo "====================================================="
