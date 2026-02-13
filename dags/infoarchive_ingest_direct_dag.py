from airflow import DAG # type: ignore
from airflow.operators.python import PythonOperator # type: ignore
from datetime import datetime
import os
import requests # type: ignore
from requests.auth import HTTPBasicAuth # type: ignore

# Configuration
API_BASE = "http://10.73.91.23:8765/systemdata"
SIP_ZIP_FOLDER = "/opt/airflow/data/sipzips"

# DAG arguments
default_args = {
    'owner': 'airflow',
    'start_date': datetime(2025, 9, 17),
    'retries': 1,
}

from airflow.models.param import Param
with DAG(
    dag_id='infoarchive_sip_ingestion',
    default_args=default_args,
    schedule=None,
    catchup=False,
    tags=['infoarchive', 'sip', 'ingestion'],
    params={
        'application_name': Param('CreditCardStatementsArchive', type='string'),
        'bearer_token': Param('YOUR_BEARER_TOKEN_HERE', type='string'),
    }
) as dag:

    def fetch_ingest_url(application_name, bearer_token, **context):
        headers = {
            "Authorization": f"Bearer {bearer_token}",
            "Accept": "application/hal+json"
        }

        # Get tenant
        tenant_resp = requests.get(f"{API_BASE}/tenants", headers=headers)
        tenant_resp.raise_for_status()
        tenant_id = tenant_resp.json()["_embedded"]["tenants"][0]["id"]

        # Get application ID with pagination
        apps_url = f"{API_BASE}/tenants/{tenant_id}/applications"
        app_id = None
        available_names = []
        while apps_url:
            apps_resp = requests.get(apps_url, headers=headers)
            apps_resp.raise_for_status()
            data = apps_resp.json()
            applications = data["_embedded"]["applications"]
            for app in applications:
                available_names.append(app["name"])
                if app["name"] == application_name:
                    app_id = app["id"]
                    break
            if app_id:
                break
            # Get next page URL if available
            apps_url = data.get("_links", {}).get("next", {}).get("href")
        if not app_id:
            raise Exception(f"Application name '{application_name}' not found in InfoArchive applications. Available: {available_names}")

        # Get ingestDirect URL
        aips_url = f"{API_BASE}/applications/{app_id}/aips"
        aips_resp = requests.get(aips_url, headers=headers)
        aips_resp.raise_for_status()
        ingest_url = aips_resp.json()["_links"]["http://identifiers.emc.com/ingest-direct"]["href"]

        # Push to XCom
        context['ti'].xcom_push(key='ingest_url', value=ingest_url)

    def ingest_sips(bearer_token, **context):
        ingest_url = context['ti'].xcom_pull(key='ingest_url')
        headers = {
            "Authorization": f"Bearer {bearer_token}",
            "Content-Type": "application/octet-stream",
            "Accept": "application/json",
            "format": "sip_zip"
        }
        for filename in os.listdir(SIP_ZIP_FOLDER):
            if filename.endswith(".zip"):
                file_path = os.path.join(SIP_ZIP_FOLDER, filename)
                with open(file_path, 'rb') as f:
                    response = requests.post(ingest_url, headers=headers, data=f)
                    response.raise_for_status()
                    print(f"Ingested {filename}: {response.status_code}")

    get_ingest_url_task = PythonOperator(
        task_id='get_ingest_direct_url',
        python_callable=fetch_ingest_url,
        op_kwargs={
            'application_name': "{{ params.application_name }}",
            'bearer_token': "{{ params.bearer_token }}"
        },
    )

    ingest_sips_task = PythonOperator(
        task_id='ingest_sips_to_infoarchive',
        python_callable=ingest_sips,
        op_kwargs={
            'bearer_token': "{{ params.bearer_token }}"
        },
    )

    get_ingest_url_task >> ingest_sips_task
