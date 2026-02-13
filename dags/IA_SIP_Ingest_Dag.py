from airflow.decorators import dag, task
from datetime import datetime, timedelta
import subprocess, os
from airflow.operators.bash import BashOperator
from airflow.operators.python import PythonOperator

OUTPUT_FOLDER = "/opt/airflow/data/output"

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

@dag(
    dag_id="IA_SIP_Ingest_Dag",
    default_args=default_args,
    schedule=None,
    start_date=datetime(2025, 1, 1),
    catchup=False,
    tags=["infoarchive", "iashell", "ingest", "sip"],
    description="DAG to create IAShell script and execute ingestion via .bat file"
)




def IA_SIP_Ingest_Dag(
    application_name: str = "CreditCardStatementsArchive",
    sipzips_folder: str = "/opt/airflow/data/sipzips/",
    iashell_path: str = "/opt/airflow/scripts/iashell/bin/iashell.sh"  # Update to Linux path or mount location
):
    @task()
    def get_valid_sip_zip(sipzips_folder: str):
        import zipfile
        valid_zips = []
        for fname in os.listdir(sipzips_folder):
            if fname.lower().endswith('.zip'):
                fpath = os.path.join(sipzips_folder, fname)
                try:
                    with zipfile.ZipFile(fpath, 'r') as zf:
                        bad_file = zf.testzip()
                        if bad_file is None:
                            valid_zips.append(fpath)
                except Exception as e:
                    print(f"❌ Corrupted zip skipped: {fpath} ({e})")
        if not valid_zips:
            raise FileNotFoundError(f"No valid SIP zip files found in {sipzips_folder}")
        # Optionally, pick the latest by modified time
        valid_zips.sort(key=lambda x: os.path.getmtime(x), reverse=True)
        print(f"✅ Using SIP zip: {valid_zips[0]}")
        return valid_zips[0]

    @task()
    def create_iashell_script(application_name: str, sip_zip_path: str):
        env  = os.environ.copy()
        #env["JAVA_HOME"] = "/usr/local/openjdk-11/bin/java"
        #env["PATH"] = "/usr/local/openjdk-11/bin/java/bin:"+env.get("PATH","")
        # Use the folder path for --from, not a specific zip file
        script_content = f"connect\ningest applications/{application_name} --from {sip_zip_path}\n"
        script_filename = f"install-{application_name}.iashell"
        script_path = os.path.join(OUTPUT_FOLDER, script_filename)
        os.makedirs(OUTPUT_FOLDER, exist_ok=True)
        with open(script_path, "w", encoding="utf-8") as f:
            f.write(script_content)
        print(f"✅ IAShell script written to {script_path}")
        return script_path


    @task()
    def run_iashell(bat_file: str, iashell_script: str):
        # Call the Linux-compatible iashell executable directly
        # Ensure iashell_path is passed as a string, not a DagParam object
        import sys
        env  = os.environ.copy()
        #env["JAVA_HOME"] = "/usr/local/openjdk-11/bin/java"
        #env["PATH"] = "/usr/local/openjdk-11/bin/java/bin:"+env.get("PATH","")
        if isinstance(bat_file, str):
            iashell_exec = bat_file
        else:
            iashell_exec = str(bat_file)
        command = f'"{iashell_exec}" script "{iashell_script}"'
        print(f"[DEBUG] Running command: {command}")
        try:
            proc = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, env=env)
            # Stream stdout
            while True:
                out_line = proc.stdout.readline()
                if out_line:
                    print(f"[IAShell STDOUT] {out_line.rstrip()}")
                elif proc.poll() is not None:
                    break
            # Stream any remaining stderr
            err_lines = proc.stderr.read()
            if err_lines:
                print(f"[IAShell STDERR] {err_lines.rstrip()}")
            retcode = proc.wait()
            if retcode != 0:
                raise Exception(f"IAShell exited with code {retcode}")
            return "IAShell completed successfully."
        except Exception as e:
            print(f"Unexpected error: {e}")
            raise

    # Use the folder path for ingestion, not a specific zip file
    iashell_script_path = create_iashell_script(application_name, sipzips_folder)
    # WARNING: The following task will fail in Linux environments because .bat files and 'cmd' are Windows-only.
    # To run ingestion in Linux, use a compatible shell script or run Airflow on Windows.
    run_iashell(iashell_path, iashell_script_path)


IA_SIP_Ingest_Dag = IA_SIP_Ingest_Dag()
