"""
Windows Batch Java Processing DAG

This DAG demonstrates how to run a Windows batch (.bat) file
that executes Java applications in a batch processing workflow.
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
BATCH_FILE = f"{JAVA_PATH}/process-data.bat"

# Create DAG
with DAG(
    'windows_batch_processing_dag',
    default_args=default_args,
    description='Run Windows batch file for Java processing',
    schedule=None,  # Manual triggering only
    catchup=False,
    tags=['java', 'batch', 'windows'],
) as dag:
    
    # Task 1: Check for and prepare the batch file
    prepare_batch = BashOperator(
        task_id='prepare_batch_file',
        bash_command=f'''
            cd {JAVA_PATH}
            
            # Check if the batch file exists
            if [ -f "{BATCH_FILE}" ]; then
                echo "Batch file exists: {BATCH_FILE}"
            else
                echo "ERROR: Batch file not found at {BATCH_FILE}"
                exit 1
            fi
            
            # Ensure the Java files are compiled
            echo "Compiling Java files..."
            javac *.java
            
            # List available files
            echo "Available files in {JAVA_PATH}:"
            ls -la
        ''',
    )
    
    # Task 2: Execute the batch file using cmd.exe via Wine (if available) or simulated execution
    run_batch = BashOperator(
        task_id='run_windows_batch',
        bash_command=f'''
            cd {JAVA_PATH}
            
            # Create output directory
            mkdir -p {OUTPUT_DIR}
            
            # Attempt to detect Wine for Windows batch execution
            if command -v wine >/dev/null 2>&1; then
                echo "Wine detected, attempting to run Windows batch file..."
                wine cmd /c {BATCH_FILE} {DATA_FILE} {OUTPUT_DIR}
            else
                # If Wine is not available, we'll simulate batch execution by running Java directly
                echo "Wine not available. Simulating Windows batch file execution..."
                echo "Running batch steps manually..."
                
                # The batch file would run these commands, so we'll run them directly
                echo "Step 1: Validating data file..."
                java -cp . DataValidator {DATA_FILE}
                
                echo "Step 2: Processing data..."
                java -cp . DataProcessor {DATA_FILE} {OUTPUT_DIR}/processed_data.txt
                
                echo "Step 3: Generating report..."
                java -cp . ReportGenerator {OUTPUT_DIR}/processed_data.txt {OUTPUT_DIR}/report.html
                
                echo "Batch simulation completed."
            fi
            
            # Check if output files were created
            if [ -f "{OUTPUT_DIR}/processed_data.txt" ] && [ -f "{OUTPUT_DIR}/report.html" ]; then
                echo "Batch process completed successfully with expected outputs."
            else
                echo "ERROR: Batch process did not create expected output files."
                exit 1
            fi
        ''',
    )
    
    # Task 3: Log the execution details and archive results
    log_and_archive = BashOperator(
        task_id='log_and_archive_results',
        bash_command=f'''
            cd {JAVA_PATH}
            
            # Create archive directory with timestamp
            TIMESTAMP=$(date +%Y%m%d_%H%M%S)
            ARCHIVE_DIR="{JAVA_PATH}/archives/batch_$TIMESTAMP"
            
            echo "Archiving results to $ARCHIVE_DIR"
            mkdir -p $ARCHIVE_DIR
            
            # Copy results to archive
            cp -r {OUTPUT_DIR}/* $ARCHIVE_DIR/
            
            # Create summary file
            echo "Windows batch process completed at: $(date)" > $ARCHIVE_DIR/summary.txt
            echo "Original data file: {DATA_FILE}" >> $ARCHIVE_DIR/summary.txt
            echo "Files archived:" >> $ARCHIVE_DIR/summary.txt
            ls -la $ARCHIVE_DIR >> $ARCHIVE_DIR/summary.txt
            
            echo "Results archived successfully in $ARCHIVE_DIR"
            
            # Show file contents for verification
            echo "Contents of processed_data.txt:"
            cat {OUTPUT_DIR}/processed_data.txt | head -n 10
            
            echo "Contents of report.html (excerpt):"
            cat {OUTPUT_DIR}/report.html | grep -A 5 -B 5 "Data Processing Report" || true
        ''',
    )
    
    # Set task dependencies
    prepare_batch >> run_batch >> log_and_archive
