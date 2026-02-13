"""
Windows Batch File DAG

This simple DAG demonstrates running a Windows batch (.bat) file from Airflow
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

# Path to the batch file
BATCH_FILE = "/opt/airflow/java-apps/list-folders.bat"
TARGET_DIR = "/opt/airflow"

# Create DAG
with DAG(
    'windows_batch_file_dag',
    default_args=default_args,
    description='Run a Windows batch file in Airflow',
    schedule=None,  # Manual triggering only
    catchup=False,
    tags=['windows', 'batch'],
) as dag:
    
    # Task to list the batch file
    list_batch_file = BashOperator(
        task_id='list_batch_file',
        bash_command=f'ls -la {BATCH_FILE}',
    )
    
    # Task to run the batch file with Wine (if in Linux container)
    run_with_wine = BashOperator(
        task_id='run_batch_with_wine',
        bash_command=f'''
            # First try running with cmd.exe (if on Windows)
            if command -v cmd.exe &> /dev/null; then
                echo "Running with cmd.exe..."
                cmd.exe /c {BATCH_FILE} {TARGET_DIR}
            # Otherwise try with wine (if installed in container)
            elif command -v wine &> /dev/null; then
                echo "Running with wine..."
                wine cmd.exe /c {BATCH_FILE} {TARGET_DIR}
            # Fallback to simulating the batch file functionality with bash
            else
                echo "Neither cmd.exe nor wine found, simulating batch file functionality..."
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
                echo "Listing complete!"
                echo "========================================"
            fi
        ''',
    )
    
    # Set task dependencies
    list_batch_file >> run_with_wine
