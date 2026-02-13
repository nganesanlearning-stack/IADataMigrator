"""
Java Batch Processing DAG

This DAG demonstrates how to run a bash script that executes Java applications
in a batch processing workflow.
"""
from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.bash import BashOperator
from airflow.operators.python import PythonOperator
import logging
import os

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

# Base path for Java applications and data
JAVA_PATH = "/opt/airflow/java-apps"
DATA_FILE = f"{JAVA_PATH}/sample_data.csv"
OUTPUT_DIR = f"{JAVA_PATH}/output"
BATCH_SCRIPT = f"{JAVA_PATH}/process-data.sh"

# Create DAG
with DAG(
    'java_batch_processing_dag',
    default_args=default_args,
    description='Run Java batch processing script',
    schedule=None,  # Manual triggering only
    catchup=False,
    tags=['java', 'batch'],
) as dag:
    
    # Task 1: Prepare environment
    prepare_env = BashOperator(
        task_id='prepare_environment',
        bash_command=f'''
            mkdir -p {OUTPUT_DIR}
            chmod +x {BATCH_SCRIPT}
            cd {JAVA_PATH}
            
            # Compile all Java files
            echo "Compiling Java files..."
            javac *.java
            
            echo "Environment prepared successfully."
            ls -la
        ''',
    )
    
    # Task 2: Run the batch script
    run_batch = BashOperator(
        task_id='run_batch_process',
        bash_command=f'''
            cd {JAVA_PATH}
            echo "Starting batch process..."
            {BATCH_SCRIPT} {DATA_FILE} {OUTPUT_DIR}
        ''',
    )
    
    # Task 3: Log and verify results
    def verify_results(**context):
        """Python function to verify batch process results"""
        output_dir = context['templates_dict']['output_dir']
        logging.info(f"Verifying batch process results in {output_dir}")
        
        expected_files = ["processed_data.txt", "report.html"]
        found_files = []
        
        # Check if expected files were created
        for file in expected_files:
            file_path = os.path.join(output_dir, file)
            if os.path.exists(file_path):
                file_size = os.path.getsize(file_path)
                found_files.append(f"{file} (size: {file_size} bytes)")
                logging.info(f"Found output file: {file} with size {file_size} bytes")
            else:
                logging.warning(f"Output file not found: {file}")
        
        if len(found_files) == len(expected_files):
            logging.info("Batch process completed successfully!")
            return "All output files were generated correctly"
        else:
            logging.error(f"Batch process incomplete. Found {len(found_files)} of {len(expected_files)} expected files")
            return "Batch process may have failed to generate all outputs"
    
    verify_batch = PythonOperator(
        task_id='verify_batch_results',
        python_callable=verify_results,
        templates_dict={'output_dir': OUTPUT_DIR},
    )
    
    # Task 4: Archive results with timestamp
    archive_results = BashOperator(
        task_id='archive_results',
        bash_command=f'''
            # Create archive directory with timestamp
            TIMESTAMP=$(date +%Y%m%d_%H%M%S)
            ARCHIVE_DIR="{JAVA_PATH}/archives/batch_$TIMESTAMP"
            
            echo "Archiving results to $ARCHIVE_DIR"
            mkdir -p $ARCHIVE_DIR
            
            # Copy results to archive
            cp -r {OUTPUT_DIR}/* $ARCHIVE_DIR/
            
            # Create summary file
            echo "Batch process completed at: $(date)" > $ARCHIVE_DIR/summary.txt
            echo "Original data file: {DATA_FILE}" >> $ARCHIVE_DIR/summary.txt
            echo "Files archived:" >> $ARCHIVE_DIR/summary.txt
            ls -la $ARCHIVE_DIR >> $ARCHIVE_DIR/summary.txt
            
            echo "Results archived successfully to $ARCHIVE_DIR"
        ''',
    )
    
    # Set task dependencies
    prepare_env >> run_batch >> verify_batch >> archive_results
