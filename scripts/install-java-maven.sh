#!/bin/bash
# Script to install Java and Maven in Airflow containers

echo "==============================================="
echo "Java and Maven Installation for Airflow"
echo "==============================================="

# Check if running as root
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 
   echo "Please run with: docker-compose exec -u root airflow-scheduler /opt/airflow/scripts/install-java-maven.sh"
   exit 1
fi

echo "Installing Java..."
apt-get update
apt-get install -y default-jdk

echo "Java installation complete. Verifying:"
java -version

echo "Installing Maven..."
apt-get install -y maven

echo "Maven installation complete. Verifying:"
mvn -version

echo "Setting up environment variables..."
JAVA_HOME=$(readlink -f /usr/bin/javac | sed "s:/bin/javac::")
echo "JAVA_HOME=$JAVA_HOME"

# Set environment variables for the whole system
echo "export JAVA_HOME=$JAVA_HOME" > /etc/profile.d/java_home.sh
echo "export PATH=\$PATH:\$JAVA_HOME/bin" >> /etc/profile.d/java_home.sh
chmod +x /etc/profile.d/java_home.sh

# Create a simple Java test class in the airflow user's home directory
cat > /home/airflow/TestJava.java << 'EOF'
public class TestJava {
    public static void main(String[] args) {
        System.out.println("Java is working properly!");
        System.out.println("Java version: " + System.getProperty("java.version"));
        System.out.println("Java home: " + System.getProperty("java.home"));
    }
}
EOF

# Set permissions
chown airflow:airflow /home/airflow/TestJava.java

# Compile and run the test class
echo "Testing Java installation..."
cd /home/airflow
javac TestJava.java
java TestJava

echo "==============================================="
echo "Installation complete!"
echo "==============================================="
