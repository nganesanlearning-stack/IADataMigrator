"""
Custom Java Application DAG
This DAG compiles and runs a Java application using Maven
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
    'retry_delay': timedelta(minutes=2),
    'start_date': datetime(2025, 9, 9),
}

# Define paths
JAVA_APPS_DIR = "/opt/airflow/java-apps"
JAVA_JAR = f"{JAVA_APPS_DIR}/target/airflow-java-app-1.0-SNAPSHOT.jar"

# Create DAG
with DAG(
    'custom_java_application_dag',
    default_args=default_args,
    description='A DAG to run a custom Java application',
    schedule='@daily',  # Airflow 3.0 uses 'schedule' instead of 'schedule_interval'
    catchup=False,
    tags=['java', 'custom'],
) as dag:

    # Task 1: Check Java and Maven environment
    check_environment = BashOperator(
        task_id='check_environment',
        bash_command=f'''
            echo "===== Environment Check ====="
            echo "Current user: $(whoami)"
            echo "Current directory: $(pwd)"
            echo "PATH: $PATH"
            echo ""
            
            echo "Java version:"
            java -version
            echo ""
            
            echo "Checking for Maven:"
            which mvn || echo "Maven not found in PATH"
            
            # Try to locate Maven manually
            echo "Looking for Maven installation:"
            find /usr -name mvn 2>/dev/null || echo "Maven not found in /usr"
            
            echo ""
            echo "Working directory structure:"
            ls -la {JAVA_APPS_DIR}
        ''',
    )

    # Task 2: Build Java application with direct compile
    build_java_app = BashOperator(
        task_id='build_java_app',
        bash_command=f'''
            cd {JAVA_APPS_DIR}
            echo "Building Java application without Maven..."
            echo "Listing Java files:"
            ls -la *.java
            
            # Compile Java file directly with javac
            echo "Compiling Java files directly with javac..."
            javac *.java
            
            if [ $? -eq 0 ]; then
                echo "Compilation successful!"
                echo "Compiled class files:"
                ls -la *.class
            else
                echo "Compilation failed!"
                exit 1
            fi
        ''',
    )

    # Task 3: Run Java application directly from class
    run_java_app = BashOperator(
        task_id='run_java_app',
        bash_command=f'''
            cd {JAVA_APPS_DIR}
            echo "Running Java application directly from class file..."
            
            # Find the main class name (first try SimpleJavaApp, then AirflowJavaTask)
            for CLASS in SimpleJavaApp AirflowJavaTask; do
                if [ -f "$CLASS.class" ]; then
                    echo "Found class file: $CLASS.class"
                    java $CLASS "param1" "param2" "{{{{ ds }}}}" "{{{{ task_instance.task_id }}}}"
                    
                    if [ $? -eq 0 ]; then
                        echo "Java application executed successfully!"
                        exit 0
                    else
                        echo "Java application execution failed!"
                        exit 1
                    fi
                fi
            done
            
            echo "No suitable class file found! Available files:"
            ls -la
            exit 1
        ''',
    )

    # Set task dependencies
    check_environment >> build_java_app >> run_java_app
