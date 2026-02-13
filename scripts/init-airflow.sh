#!/bin/bash
# Initialization script for Airflow with Java environment

echo "=== Initializing Airflow with Java Environment ==="

# Create necessary directories
echo "Creating directory structure..."
mkdir -p /opt/airflow/{dags,logs,plugins}
mkdir -p /opt/airflow/java-apps/{jars,libs,configs,logs}

# Set proper permissions
echo "Setting permissions..."
chown -R airflow:root /opt/airflow/java-apps
chmod -R 775 /opt/airflow/java-apps

# Create default JVM configuration if it doesn't exist
JVM_CONFIG="/opt/airflow/java-apps/configs/jvm.options"
if [ ! -f "$JVM_CONFIG" ]; then
    echo "Creating default JVM configuration..."
    cat > "$JVM_CONFIG" << 'EOF'
-Xms512m
-Xmx2g
-XX:+UseG1GC
-XX:MaxGCPauseMillis=200
-Djava.awt.headless=true
-Dfile.encoding=UTF-8
-Djava.security.egd=file:/dev/./urandom
-Duser.timezone=UTC
EOF
fi

# Test Java environment
echo "Testing Java environment..."
java -version
javac -version

# Create a simple test application
echo "Creating test Java application..."
cd /opt/airflow/java-apps
cat > TestApp.java << 'EOF'
public class TestApp {
    public static void main(String[] args) {
        System.out.println("Airflow Java Environment Test");
        System.out.println("Java Version: " + System.getProperty("java.version"));
        System.out.println("OS: " + System.getProperty("os.name"));
        System.out.println("Working Directory: " + System.getProperty("user.dir"));
        System.out.println("Available Processors: " + Runtime.getRuntime().availableProcessors());
        System.out.println("Max Memory: " + Runtime.getRuntime().maxMemory() / 1024 / 1024 + " MB");
        System.out.println("Test completed successfully!");
    }
}
EOF

# Compile and test the application
if javac TestApp.java && java TestApp; then
    echo "✓ Java environment test passed"
    rm TestApp.java TestApp.class
else
    echo "✗ Java environment test failed"
    exit 1
fi

echo "=== Airflow Java Environment Initialization Complete ==="
