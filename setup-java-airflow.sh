#!/bin/bash
# setup-java-airflow.sh
# Script to set up Java environment in Apache Airflow containers
# Run as: docker-compose exec -u root airflow-scheduler bash -c "$(cat setup-java-airflow.sh)"

set -e

echo "================================================================"
echo "Java and Maven Setup for Apache Airflow"
echo "================================================================"
echo "Starting installation at: $(date)"
echo

# Check if running as root
if [ "$(id -u)" != "0" ]; then
   echo "❌ This script must be run as root" 
   echo "Please run with: docker-compose exec -u root airflow-scheduler bash -c \"$(cat setup-java-airflow.sh)\""
   exit 1
fi

# Function to display status messages
status() {
  echo
  echo "➡️ $1"
  echo "----------------------------------------------------------------"
}

# Function to check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Check for existing Java installation
status "Checking for existing Java installation"
if command_exists java; then
  echo "Java is already installed:"
  java -version
  JAVA_INSTALLED=true
else
  JAVA_INSTALLED=false
  echo "Java is not installed"
fi

# Check for existing Maven installation
status "Checking for existing Maven installation"
if command_exists mvn; then
  echo "Maven is already installed:"
  mvn --version
  MAVEN_INSTALLED=true
else
  MAVEN_INSTALLED=false
  echo "Maven is not installed"
fi

# Update package lists
status "Updating package lists"
apt-get update

# Install Java if not already installed
if [ "$JAVA_INSTALLED" = false ]; then
  status "Installing Java"
  apt-get install -y default-jdk
  echo "Java installation completed:"
  java -version
else
  echo "Skipping Java installation as it's already installed."
fi

# Install Maven if not already installed
if [ "$MAVEN_INSTALLED" = false ]; then
  status "Installing Maven"
  apt-get install -y maven
  echo "Maven installation completed:"
  mvn --version
else
  echo "Skipping Maven installation as it's already installed."
fi

# Set up environment variables
status "Setting up environment variables"
JAVA_HOME=$(readlink -f /usr/bin/javac | sed "s:/bin/javac::")
MAVEN_HOME=$(mvn --version | grep "Maven home" | sed 's/.*: //')

echo "JAVA_HOME=$JAVA_HOME"
echo "MAVEN_HOME=$MAVEN_HOME"

# Create environment variable configuration
cat > /etc/profile.d/java_maven_env.sh << EOF
export JAVA_HOME=$JAVA_HOME
export MAVEN_HOME=$MAVEN_HOME
export PATH=\$PATH:\$JAVA_HOME/bin:\$MAVEN_HOME/bin
EOF

chmod +x /etc/profile.d/java_maven_env.sh
source /etc/profile.d/java_maven_env.sh

# Create directories for Java applications
status "Setting up Java application directories"
mkdir -p /opt/airflow/java-apps/{src,lib,target}
chown -R airflow:airflow /opt/airflow/java-apps

# Create a simple test Java file
status "Creating a test Java application"
cat > /opt/airflow/java-apps/JavaTest.java << 'EOF'
public class JavaTest {
    public static void main(String[] args) {
        System.out.println("==============================================");
        System.out.println("Java is successfully integrated with Airflow!");
        System.out.println("==============================================");
        
        System.out.println("\nSystem Properties:");
        System.out.println("- Java Version: " + System.getProperty("java.version"));
        System.out.println("- Java Vendor: " + System.getProperty("java.vendor"));
        System.out.println("- Java Home: " + System.getProperty("java.home"));
        System.out.println("- OS Name: " + System.getProperty("os.name"));
        System.out.println("- User Name: " + System.getProperty("user.name"));
        
        System.out.println("\nEnvironment Variables:");
        System.out.println("- JAVA_HOME: " + System.getenv("JAVA_HOME"));
        System.out.println("- MAVEN_HOME: " + System.getenv("MAVEN_HOME"));
        System.out.println("- PATH: " + System.getenv("PATH"));
        
        System.out.println("\nCommand Line Arguments:");
        if (args.length > 0) {
            for (int i = 0; i < args.length; i++) {
                System.out.println("  Arg[" + i + "]: " + args[i]);
            }
        } else {
            System.out.println("  No arguments provided");
        }
        
        System.out.println("\nTest completed successfully!");
    }
}
EOF

chown airflow:airflow /opt/airflow/java-apps/JavaTest.java

# Compile and test the Java application
status "Compiling and testing Java application"
cd /opt/airflow/java-apps
javac JavaTest.java
java JavaTest "test_argument_1" "test_argument_2"

# Create an example DAG that runs the Java program
status "Creating an example Java DAG"
cat > /opt/airflow/dags/java_test_dag.py << 'EOF'
"""
Java Test DAG

This DAG demonstrates the Java integration with Apache Airflow
"""
from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.bash import BashOperator

# Define default arguments
default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=1),
    'start_date': datetime(2025, 9, 9),
}

# Create DAG
with DAG(
    'java_test_dag',
    default_args=default_args,
    description='Test Java integration with Airflow',
    schedule=None,  # Manual triggering only
    catchup=False,
    tags=['java', 'test'],
) as dag:

    # Task 1: Check Java environment
    check_env = BashOperator(
        task_id='check_java_environment',
        bash_command='''
            echo "=== Java Environment Check ==="
            echo "Java version:"
            java -version
            echo ""
            echo "Maven version:"
            mvn --version || echo "Maven not available"
        ''',
    )
    
    # Task 2: Run Java test program
    run_java = BashOperator(
        task_id='run_java_test',
        bash_command='''
            cd /opt/airflow/java-apps
            echo "Running Java test program..."
            java JavaTest "{{ ds }}" "{{ dag.dag_id }}" "{{ task.task_id }}"
        ''',
    )
    
    # Set task dependencies
    check_env >> run_java
EOF

chown airflow:airflow /opt/airflow/dags/java_test_dag.py

# Final status message
status "Installation complete!"
echo "Java and Maven have been successfully integrated with Apache Airflow."
echo "Test DAG created: java_test_dag"
echo
echo "To verify the installation, run the following commands:"
echo "  1. As airflow user: docker-compose exec airflow-scheduler java -version"
echo "  2. As airflow user: docker-compose exec airflow-scheduler mvn --version"
echo "  3. In the Airflow UI: Trigger the java_test_dag"
echo
echo "Installation completed at: $(date)"
echo "================================================================"
