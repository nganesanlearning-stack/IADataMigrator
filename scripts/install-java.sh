#!/bin/bash
# Simple Java installation script for Airflow containers

echo "🔍 Checking for existing Java installation..."
if command -v java &> /dev/null; then
    echo "✅ Java is already installed:"
    java -version
    exit 0
fi

echo "📦 Installing Java 11..."

# Try using existing package manager first
if apt-get update --fix-missing && apt-get install -y default-jdk; then
    echo "✅ Java installed via package manager"
    java -version
    exit 0
fi

echo "⚠️  Package manager installation failed, trying manual installation..."

# Manual Java installation fallback
JAVA_VERSION="11.0.2"
JAVA_URL="https://download.java.net/java/GA/jdk11/9/GPL/openjdk-11.0.2_linux-x64_bin.tar.gz"

mkdir -p /opt/java
cd /tmp

if wget -q --no-check-certificate "$JAVA_URL" -O openjdk.tar.gz; then
    echo "📥 Downloaded Java, extracting..."
    tar -xzf openjdk.tar.gz -C /opt/java --strip-components=1
    
    # Set environment variables
    echo 'export JAVA_HOME=/opt/java' >> /etc/environment
    echo 'export PATH=$JAVA_HOME/bin:$PATH' >> /etc/environment
    
    export JAVA_HOME=/opt/java
    export PATH=$JAVA_HOME/bin:$PATH
    
    echo "✅ Java installed manually:"
    java -version
    
    # Clean up
    rm -f openjdk.tar.gz
else
    echo "❌ Failed to download Java"
    exit 1
fi
