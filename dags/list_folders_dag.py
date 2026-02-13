"""
List Folders DAG

This DAG simply lists the folders in the specified directory
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

# Target directory to list folders in
TARGET_DIR = "/opt/airflow"

# Create DAG
with DAG(
    'list_folders_dag',
    default_args=default_args,
    description='List folders in a directory',
    schedule=None,  # Manual triggering only
    catchup=False,
    tags=['folders', 'utility'],
) as dag:
    
    # Task to list folders in the target directory
    list_folders = BashOperator(
        task_id='list_folders',
        bash_command=f'/opt/airflow/scripts/simulate-bat.sh {TARGET_DIR}',
    )
    
    # Task documentation
    list_folders.doc_md = """
    ## List Folders Task
    
    This task lists all folders in the specified directory.
    
    **Target Directory:** `/opt/airflow`
    
    It uses the script `/opt/airflow/scripts/simulate-bat.sh` which simulates 
    the functionality of the Windows batch file `list-folders.bat`.
    """
