#!/bin/bash
# Health check script for Java environment in Airflow

echo "=== Java Environment Health Check ==="

# Check Java installation
echo "1. Checking Java installation..."
if command -v java &> /dev/null; then
    java -version
    echo "✓ Java is installed and accessible"
else
    echo "✗ Java is not installed or not in PATH"
    exit 1
fi

# Check Java compiler
echo ""
echo "2. Checking Java compiler..."
if command -v javac &> /dev/null; then
    javac -version
    echo "✓ Java compiler is available"
else
    echo "✗ Java compiler (javac) is not available"
    exit 1
fi

# Check JAVA_HOME
echo ""
echo "3. Checking JAVA_HOME..."
if [ -n "$JAVA_HOME" ]; then
    echo "JAVA_HOME: $JAVA_HOME"
    if [ -d "$JAVA_HOME" ]; then
        echo "✓ JAVA_HOME directory exists"
    else
        echo "✗ JAVA_HOME directory does not exist"
        exit 1
    fi
else
    echo "⚠ JAVA_HOME is not set"
fi

# Check Java apps directory
echo ""
echo "4. Checking Java applications directory..."
JAVA_APPS_DIR="/opt/airflow/java-apps"
if [ -d "$JAVA_APPS_DIR" ]; then
    echo "✓ Java apps directory exists: $JAVA_APPS_DIR"
    echo "Directory contents:"
    ls -la "$JAVA_APPS_DIR"
else
    echo "✗ Java apps directory does not exist: $JAVA_APPS_DIR"
    exit 1
fi

# Check write permissions
echo ""
echo "5. Checking write permissions..."
TEST_FILE="$JAVA_APPS_DIR/test_write.tmp"
if touch "$TEST_FILE" 2>/dev/null; then
    rm "$TEST_FILE"
    echo "✓ Write permissions are correct"
else
    echo "✗ Cannot write to Java apps directory"
    exit 1
fi

# Test simple Java compilation and execution
echo ""
echo "6. Testing Java compilation and execution..."
cd "$JAVA_APPS_DIR"
cat > HealthCheck.java << 'EOF'
public class HealthCheck {
    public static void main(String[] args) {
        System.out.println("Java health check successful!");
        System.out.println("Java version: " + System.getProperty("java.version"));
        System.out.println("Current time: " + new java.util.Date());
    }
}
EOF

if javac HealthCheck.java && java HealthCheck; then
    rm -f HealthCheck.java HealthCheck.class
    echo "✓ Java compilation and execution test passed"
else
    echo "✗ Java compilation or execution test failed"
    exit 1
fi

# Check Maven (if available)
echo ""
echo "7. Checking Maven..."
if command -v mvn &> /dev/null; then
    mvn --version
    echo "✓ Maven is available"
else
    echo "⚠ Maven is not available (optional)"
fi

echo ""
echo "=== All Health Checks Passed! ==="
echo "Java environment is ready for Airflow tasks."
