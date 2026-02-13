"""
Example DAG demonstrating Java application execution in Airflow
"""
from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.bash import BashOperator
from airflow.operators.python import PythonOperator
import logging

# Default arguments for the DAG
default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'start_date': datetime(2025, 1, 1),
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

# Create the DAG
dag = DAG(
    'java_example_dag',
    default_args=default_args,
    description='Example DAG for running Java applications',
    schedule='@daily',  # Airflow 3.0 uses 'schedule' instead of 'schedule_interval'
    catchup=False,
    tags=['java', 'example'],
)

# Task 1: Check Java environment
check_java_env = BashOperator(
    task_id='check_java_environment',
    bash_command='''
    echo "=== Java Environment Check ==="
    echo "Java Version:"
    java -version
    echo ""
    echo "Java Home: $JAVA_HOME"
    echo "Java Path: $(which java)"
    echo ""
    echo "Available Java Apps Directory:"
    ls -la /opt/airflow/java-apps/
    echo ""
    echo "Maven Version (if available):"
    mvn --version || echo "Maven not available"
    ''',
    dag=dag,
)

# Task 2: Create a simple Java program
create_java_program = BashOperator(
    task_id='create_simple_java_program',
    bash_command='''
    cd /opt/airflow/java-apps
    
    # Create a simple Java program
    cat > HelloAirflow.java << 'EOF'
public class HelloAirflow {
    public static void main(String[] args) {
        System.out.println("Hello from Java in Airflow!");
        System.out.println("Current timestamp: " + System.currentTimeMillis());
        System.out.println("Java version: " + System.getProperty("java.version"));
        System.out.println("Operating system: " + System.getProperty("os.name"));
        
        // Process command line arguments
        if (args.length > 0) {
            System.out.println("Arguments received:");
            for (int i = 0; i < args.length; i++) {
                System.out.println("  Arg " + i + ": " + args[i]);
            }
        }
        
        // Simulate some processing
        try {
            Thread.sleep(2000); // Sleep for 2 seconds
            System.out.println("Processing completed successfully!");
        } catch (InterruptedException e) {
            System.err.println("Processing interrupted: " + e.getMessage());
            System.exit(1);
        }
    }
}
EOF
    
    echo "Java program created successfully"
    ''',
    dag=dag,
)

# Task 3: Compile Java program
compile_java_program = BashOperator(
    task_id='compile_java_program',
    bash_command='''
    cd /opt/airflow/java-apps
    
    echo "Compiling Java program..."
    javac HelloAirflow.java
    
    if [ $? -eq 0 ]; then
        echo "Java program compiled successfully"
        ls -la HelloAirflow.*
    else
        echo "Java compilation failed"
        exit 1
    fi
    ''',
    dag=dag,
)

# Task 4: Run Java program with arguments
run_java_program = BashOperator(
    task_id='run_java_program',
    bash_command='''
    cd /opt/airflow/java-apps
    
    echo "Running Java program..."
    java HelloAirflow "airflow-task" "{{ ds }}" "{{ task_instance.task_id }}"
    
    if [ $? -eq 0 ]; then
        echo "Java program executed successfully"
    else
        echo "Java program execution failed"
        exit 1
    fi
    ''',
    dag=dag,
)

# Task 5: Create and run JAR file
create_jar_file = BashOperator(
    task_id='create_jar_file',
    bash_command='''
    cd /opt/airflow/java-apps
    
    # Create manifest file
    cat > MANIFEST.MF << 'EOF'
Manifest-Version: 1.0
Main-Class: HelloAirflow

EOF
    
    # Create JAR file
    echo "Creating JAR file..."
    jar cfm HelloAirflow.jar MANIFEST.MF HelloAirflow.class
    
    if [ $? -eq 0 ]; then
        echo "JAR file created successfully"
        ls -la HelloAirflow.jar
        
        # Test JAR execution
        echo "Testing JAR execution..."
        java -jar HelloAirflow.jar "jar-test" "{{ ds }}"
    else
        echo "JAR creation failed"
        exit 1
    fi
    ''',
    dag=dag,
)

# Task 6: Java program with JVM options
run_java_with_options = BashOperator(
    task_id='run_java_with_jvm_options',
    bash_command='''
    cd /opt/airflow/java-apps
    
    echo "Running Java with JVM options..."
    java -Xms128m -Xmx512m -Djava.awt.headless=true -Duser.timezone=UTC HelloAirflow "jvm-options-test"
    
    echo "Checking Java process memory usage..."
    ps aux | grep java | grep -v grep || echo "No Java processes found"
    ''',
    dag=dag,
)

# Task 7: Cleanup
cleanup_files = BashOperator(
    task_id='cleanup_temp_files',
    bash_command='''
    cd /opt/airflow/java-apps
    
    echo "Cleaning up temporary files..."
    rm -f HelloAirflow.java HelloAirflow.class MANIFEST.MF
    
    # Keep the JAR file for future use
    echo "Keeping JAR file: HelloAirflow.jar"
    ls -la HelloAirflow.jar
    ''',
    dag=dag,
)

# Python task to log Java execution results
def log_java_execution_summary(**context):
    """Log summary of Java execution"""
    logging.info("Java execution pipeline completed successfully!")
    logging.info(f"Execution date: {context['ds']}")
    logging.info(f"DAG run ID: {context['dag_run'].run_id}")
    
    # You could add more sophisticated logging or monitoring here
    return "Java execution summary logged"

log_summary = PythonOperator(
    task_id='log_execution_summary',
    python_callable=log_java_execution_summary,
    dag=dag,
)

# Define task dependencies
check_java_env >> create_java_program >> compile_java_program >> run_java_program
run_java_program >> create_jar_file >> run_java_with_options >> cleanup_files >> log_summary
