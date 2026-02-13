"""
enhanced_java_batch_dag.py - Enhanced DAG to run Windows batch file with Java

This DAG uses a helper script to ensure proper execution of a Windows batch file
that runs a Java JAR file from within an Airflow container.
"""
from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.bash import BashOperator

default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 0,
    'retry_delay': timedelta(minutes=1),
    'start_date': datetime(2025, 9, 9),
}

# Path to helper script
HELPER_SCRIPT = "/opt/airflow/scripts/run-batch-file.sh "
#HELPER_SCRIPT_JAY = "/opt/airflow/scripts/run_ia.sh "
#HELPER_SCRIPT_JAY = "/opt/airflow/scripts/iashell_harish.sh "
HELPER_SCRIPT_JAY = "/opt/airflow/scripts/iashell/bin/iashell.sh "

with DAG(
    'enhanced_java_batch_dag',
    default_args=default_args,
    description='Enhanced execution of Windows batch file with Java JAR',
    schedule=None,  # Manual triggering only
    catchup=False,
    tags=['windows', 'batch', 'java', 'enhanced'],
) as dag:
    
    # Make helper script executable
    prepare_script = BashOperator(
        task_id='prepare_script',
        bash_command=f'chmod +x {HELPER_SCRIPT}',
    )
    
     # Make helper script executable
    prepare_script_jay = BashOperator(
        task_id='prepare_script_jay',
        bash_command=f'chmod +x {HELPER_SCRIPT_JAY}',
    )
    
    # Run the helper script
    run_batch_file = BashOperator(
        task_id='run_batch_file',
        bash_command=f'bash {HELPER_SCRIPT}',
    )
    
     # Run the helper script JAY
    run_batch_file_jay = BashOperator(
        task_id='run_batch_file_jay',
        bash_command=f'bash {HELPER_SCRIPT_JAY}',
    )
    
    # Set task dependencies
    prepare_script >> run_batch_file >> prepare_script_jay >> run_batch_file_jay
    
    # Task documentation
    run_batch_file.doc_md = """
    ## Enhanced Java Batch File Execution
    
    This task uses a helper script to ensure proper execution of a Windows batch file
    that runs a Java JAR file from within the Airflow container.
    
    The helper script:
    1. Checks if the batch file exists and displays its contents
    2. Checks the Java environment
    3. Verifies the JAR file exists
    4. Tries multiple methods to run the batch file:
       - Using cmd.exe (if on Windows)
       - Using wine (if available)
       - Falling back to bash simulation if needed
    
    **Helper script:** `/opt/airflow/scripts/run-batch-file.sh`
    **Helper script Jay:** `/opt/airflow/scripts/run_ia.sh`
    **Batch file:** `/opt/airflow/java-apps/list-folders.bat`
    **JAR file:** `/opt/airflow/java-apps/HelloAirflow.jar`
    
    **Expected output:**
    - Complete execution log with detailed information
    - List of folders in the target directory
    - Output from the Java JAR execution
    - Java environment information
    """
