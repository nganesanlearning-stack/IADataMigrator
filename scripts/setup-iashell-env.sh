#!/bin/bash

# Setup iashell environment inside Airflow container
# This script ensures iashell has proper Java environment and permissions

echo "Setting up iashell environment..."

# Define paths
IASHELL_HOME="/opt/airflow/java-apps/iashell/iashell"
IASHELL_BIN="$IASHELL_HOME/bin"
JAVA_HOME="/opt/java/temurin-21"

# Print current Java environment
echo "=== Java Environment Information ==="
echo "JAVA_HOME: $JAVA_HOME"
echo "Java Version:"
$JAVA_HOME/bin/java -version

echo "Java Path: $JAVA_HOME/bin/java"
echo "Classpath for iashell: $IASHELL_HOME/lib/infoarchive-shell-25.2-exec.jar"

# Check if iashell directory exists
if [ ! -d "$IASHELL_HOME" ]; then
    echo "ERROR: iashell directory not found at $IASHELL_HOME"
    exit 1
fi

# Make iashell scripts executable
echo "Making iashell scripts executable..."
chmod +x "$IASHELL_BIN/iashell"
chmod +x "$IASHELL_BIN/iashell.bat"

# Create iashell logs directory if it doesn't exist
mkdir -p "$IASHELL_HOME/logs"
mkdir -p "$IASHELL_HOME/output"

# Set proper permissions
chown -R airflow:airflow "$IASHELL_HOME"

# Export environment variables for iashell
export JAVA_HOME="$JAVA_HOME"
export PATH="$JAVA_HOME/bin:$PATH"
export IASHELL_HOME="$IASHELL_HOME"

# Test iashell execution
echo "=== Testing iashell execution ==="
echo "Running iashell version check..."

cd "$IASHELL_BIN"
# Run iashell with version or help command to test if it works
"$IASHELL_BIN/iashell" --help 2>&1 || echo "iashell help command completed"

echo "=== iashell Environment Setup Complete ==="
echo "iashell binary location: $IASHELL_BIN/iashell"
echo "iashell.bat location: $IASHELL_BIN/iashell.bat"
echo "Java executable: $JAVA_HOME/bin/java"
echo "iashell home: $IASHELL_HOME"
