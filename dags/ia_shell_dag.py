from airflow import DAG
from airflow.operators.bash import BashOperator
from datetime import datetime
from airflow.models import Variable

default_args = {
    "owner": "airflow",
    "retries": 0,
}

# Optionally keep JAVA_HOME in Airflow Variables, fallback to default
java_home = Variable.get("JAVA_HOME", default_var="/usr/lib/jvm/java-11-openjdk")

with DAG(
    dag_id="ia_shell_dag_no_redirect",
    default_args=default_args,
    start_date=datetime(2023, 1, 1),
    schedule=None,
    catchup=False,
    tags=["ia", "shell"],
) as dag:

    run_ia = BashOperator(
        task_id="run_ia",
        bash_command= 'run_ia.sh ',
        env={"JAVA_HOME": java_home, "PATH": f"{java_home}/bin:$PATH"},
        do_xcom_push=False,
    )

    run_ia
