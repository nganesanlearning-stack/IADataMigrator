"""
java_list_folders_dag.py - DAG to execute a Windows batch file that runs Java JAR

This DAG demonstrates how to run a Windows batch file that executes a Java JAR file
from within an Airflow container.
"""
from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.bash import BashOperator

default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=1),
    'start_date': datetime(2025, 9, 9),
}

# Path to the batch file and JAR file
BATCH_FILE = "/opt/airflow/java-apps/list-folders.bat"
TARGET_DIR = "/opt/airflow/java-apps"

with DAG(
    'java_list_folders_dag',
    default_args=default_args,
    description='Execute a Windows batch file that runs a Java JAR',
    schedule=None,  # Manual triggering only
    catchup=False,
    tags=['windows', 'batch', 'java'],
) as dag:
    
    # Task to check Java environment
    check_java = BashOperator(
        task_id='check_java_env',
        bash_command='''
            echo "========================================"
            echo "Checking Java Environment"
            echo "========================================"
            echo "JAVA_HOME: $JAVA_HOME"
            java -version 2>&1
            echo "========================================"
        ''',
    )
    
    # Task to run the batch file using appropriate method
    run_batch_file = BashOperator(
        task_id='run_batch_file',
        bash_command=f'''
            echo "========================================"
            echo "Executing Batch File for Java JAR"
            echo "========================================"
            
            # Set this to capture all outputs properly
            set -o verbose
            
            # First check if cmd.exe is available (Windows container)
            if command -v cmd.exe &> /dev/null; then
                echo "Running with cmd.exe..."
                cmd.exe /c {BATCH_FILE} {TARGET_DIR}
                exit $?
            fi
            
            # Check if wine is available
            if command -v wine &> /dev/null; then
                echo "Running with wine..."
                wine cmd.exe /c {BATCH_FILE} {TARGET_DIR}
                exit $?
            fi
            
            # Fallback to direct Java execution if neither cmd.exe nor wine is available
            echo "Neither cmd.exe nor wine is available. Running Java directly..."
            echo "========================================"
            echo "Folder Listing Utility (Simulated)"
            echo "========================================"
            echo "Executed at: $(date)"
            echo "Current directory: $(pwd)"
            echo ""
            echo "Listing folders in: {TARGET_DIR}"
            echo "========================================"
            find {TARGET_DIR} -maxdepth 1 -type d | sort
            
            echo ""
            echo "========================================"
            echo "Executing Java JAR directly"
            echo "========================================"
            # Make sure JAR file exists before trying to run it
            if [ -f "{TARGET_DIR}/HelloAirflow.jar" ]; then
                echo "JAR file found, executing..."
                java -jar {TARGET_DIR}/HelloAirflow.jar
            else
                echo "JAR file not found: {TARGET_DIR}/HelloAirflow.jar"
                echo "Available JAR files:"
                find {TARGET_DIR} -name "*.jar" | sort
            fi
            
            echo ""
            echo "========================================"
            echo "Java Environment Information:"
            echo "----------------------------------------"
            echo "JAVA_HOME: $JAVA_HOME"
            java -version 2>&1
            echo "========================================"
            
            echo ""
            echo "========================================"
            echo "Execution complete!"
            echo "========================================"
        ''',
    )
    
    # Set task dependencies
    check_java >> run_batch_file
    
    # Task documentation
    run_batch_file.doc_md = """
    ## Java Batch File Execution Task
    
    This task executes a Windows batch file that runs a Java JAR file from within the Airflow container.
    
    The task performs the following steps:
    1. Checks if cmd.exe is available (Windows container)
    2. Checks if wine is available (Linux container with Wine)
    3. Falls back to direct Java execution if neither is available
    
    **Batch file location:** `/opt/airflow/java-apps/list-folders.bat`
    **JAR file location:** `/opt/airflow/java-apps/HelloAirflow.jar`
    
    **Expected output:**
    - List of folders in the specified directory
    - Output from the Java JAR execution
    - Java environment information
    """
