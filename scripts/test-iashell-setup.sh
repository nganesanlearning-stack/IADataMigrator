#!/bin/bash

# Test iashell Setup Inside Docker Container
# This script should be run inside the Airflow Docker container to test iashell functionality

echo "========================================="
echo "Testing iashell Setup in Docker Container"
echo "========================================="

# Set environment variables
export JAVA_HOME="/opt/java/temurin-21"
export IASHELL_HOME="/opt/airflow/java-apps/iashell/iashell"
export IASHELL_BIN="$IASHELL_HOME/bin"
export PATH="$JAVA_HOME/bin:$PATH"

echo "Environment Variables:"
echo "JAVA_HOME: $JAVA_HOME"
echo "IASHELL_HOME: $IASHELL_HOME"
echo "IASHELL_BIN: $IASHELL_BIN"
echo "PATH: $PATH"
echo ""

# Test 1: Check Java Installation
echo "=== Test 1: Java Installation ==="
if [ -x "$JAVA_HOME/bin/java" ]; then
    echo "✓ Java executable found"
    echo "Java version:"
    "$JAVA_HOME/bin/java" -version
else
    echo "✗ Java executable not found at $JAVA_HOME/bin/java"
fi
echo ""

# Test 2: Check iashell Files
echo "=== Test 2: iashell Files ==="
files_to_check=(
    "$IASHELL_BIN/iashell"
    "$IASHELL_BIN/iashell.bat"
    "$IASHELL_HOME/lib/infoarchive-shell-25.2-exec.jar"
    "$IASHELL_HOME/config"
    "$IASHELL_HOME/logs"
)

for file in "${files_to_check[@]}"; do
    if [ -e "$file" ]; then
        echo "✓ Found: $file"
    else
        echo "✗ Missing: $file"
    fi
done
echo ""

# Test 3: Directory Structure
echo "=== Test 3: Directory Structure ==="
echo "iashell home directory contents:"
ls -la "$IASHELL_HOME/" 2>/dev/null || echo "Directory not accessible"
echo ""

echo "iashell bin directory contents:"
ls -la "$IASHELL_BIN/" 2>/dev/null || echo "Directory not accessible"
echo ""

echo "iashell lib directory contents:"
ls -la "$IASHELL_HOME/lib/" 2>/dev/null || echo "Directory not accessible"
echo ""

# Test 4: Permissions
echo "=== Test 4: File Permissions ==="
chmod +x "$IASHELL_BIN/iashell" 2>/dev/null
chmod +x "$IASHELL_BIN/iashell.bat" 2>/dev/null

echo "iashell script permissions:"
ls -l "$IASHELL_BIN/iashell" 2>/dev/null || echo "File not found"
ls -l "$IASHELL_BIN/iashell.bat" 2>/dev/null || echo "File not found"
echo ""

# Test 5: Create Test Directories
echo "=== Test 5: Creating Test Directories ==="
mkdir -p "$IASHELL_HOME/logs"
mkdir -p "$IASHELL_HOME/output"
mkdir -p "$IASHELL_HOME/temp"

echo "Created directories:"
ls -la "$IASHELL_HOME/" | grep -E "(logs|output|temp)"
echo ""

# Test 6: Test iashell Execution
echo "=== Test 6: iashell Execution Test ==="
cd "$IASHELL_BIN"

# Create test command file
TEST_COMMANDS_FILE="/tmp/test_iashell_commands.txt"
cat > "$TEST_COMMANDS_FILE" << 'EOF'
help
version
exit
EOF

echo "Test commands file created:"
cat "$TEST_COMMANDS_FILE"
echo ""

echo "Attempting to run iashell with test commands..."
if [ -x "./iashell" ]; then
    echo "Running: ./iashell < $TEST_COMMANDS_FILE"
    timeout 30s ./iashell < "$TEST_COMMANDS_FILE" 2>&1 || echo "iashell execution completed (exit code: $?)"
else
    echo "iashell script not executable or not found"
fi
echo ""

# Test 7: Test Wrapper Script
echo "=== Test 7: Wrapper Script Test ==="
WRAPPER_SCRIPT="/opt/airflow/scripts/iashell-wrapper.sh"
if [ -f "$WRAPPER_SCRIPT" ]; then
    echo "Testing wrapper script: $WRAPPER_SCRIPT"
    chmod +x "$WRAPPER_SCRIPT"
    
    echo "Running wrapper script environment check:"
    "$WRAPPER_SCRIPT" --env 2>&1 || echo "Wrapper script completed"
    
    echo ""
    echo "Running wrapper script test:"
    "$WRAPPER_SCRIPT" --test 2>&1 || echo "Wrapper script test completed"
else
    echo "Wrapper script not found: $WRAPPER_SCRIPT"
fi
echo ""

# Test 8: Cleanup
echo "=== Test 8: Cleanup ==="
rm -f "$TEST_COMMANDS_FILE"
echo "Test files cleaned up"
echo ""

# Test 9: Summary
echo "=== Test Summary ==="
echo "Java Home: $JAVA_HOME"
echo "iashell Home: $IASHELL_HOME"
echo "Test completed at: $(date)"
echo ""

echo "Next steps:"
echo "1. Run the Airflow DAGs to test iashell integration"
echo "2. Check logs in $IASHELL_HOME/logs/"
echo "3. Check output in $IASHELL_HOME/output/"
echo "4. Monitor Airflow UI for DAG execution status"
echo ""

echo "========================================="
echo "iashell Setup Test Completed"
echo "========================================="
