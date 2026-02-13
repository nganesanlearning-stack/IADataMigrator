"""
Java Task DAG

This DAG demonstrates running a Java program directly from Airflow
"""
from datetime import datetime, timedelta

from airflow import DAG
from airflow.operators.bash import BashOperator
from airflow.operators.python import PythonOperator
import logging

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

# Path to Java files
JAVA_PATH = "/opt/airflow/java-apps"
JAVA_CLASS = "AirflowJavaTask"

# Create DAG
with DAG(
    'java_task_dag',
    default_args=default_args,
    description='A DAG to run a Java program',
    schedule=None,  # Set to None for manual triggering only (Airflow 3.0 uses 'schedule' instead of 'schedule_interval')
    catchup=False,
    tags=['java', 'example'],
) as dag:
    
    # Task 1: Check if Java is available
    check_java = BashOperator(
        task_id='check_java_installation',
        bash_command='java -version',
    )
    
    # Task 2: Compile Java program
    compile_java = BashOperator(
        task_id='compile_java_program',
        bash_command=f'cd {JAVA_PATH} && javac {JAVA_CLASS}.java',
    )
    
    # Task 3: Run Java program with Airflow context
    run_java = BashOperator(
        task_id='run_java_program',
        bash_command=f'cd {JAVA_PATH} && java {JAVA_CLASS} '
                    f'"{{{{ ds }}}}" '  # Execution date
                    f'"{{{{ dag.dag_id }}}}" '  # DAG ID
                    f'"{{{{ task.task_id }}}}" '  # Task ID
                    f'"{{{{ run_id }}}}" '  # Run ID
                    f'"custom_parameter_1" '  # Custom parameter
                    f'"custom_parameter_2"',  # Custom parameter
    )
    
    # Task 4: Log the results of the Java task
    def log_java_results(**context):
        """Python function to log information about the Java task execution"""
        logging.info("Java task execution completed")
        logging.info(f"Execution date: {context['ds']}")
        logging.info(f"DAG ID: {context['dag'].dag_id}")
        logging.info(f"Task ID: {context['task'].task_id}")
        logging.info(f"Run ID: {context['run_id']}")
        return "Java task logging complete"
    
    log_execution = PythonOperator(
        task_id='log_java_execution',
        python_callable=log_java_results,
    )
    
    # Task 5: Report execution status
    report_status = BashOperator(
        task_id='report_execution_status',
        bash_command='echo "Java task execution completed at $(date)"',
    )
    
    # Set task dependencies
    check_java >> compile_java >> run_java >> log_execution >> report_status
