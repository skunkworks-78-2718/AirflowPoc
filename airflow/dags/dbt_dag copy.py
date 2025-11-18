from datetime import datetime, timedelta
from airflow import DAG
from airflow.providers.microsoft.azure.operators.container_instances import AzureContainerInstancesOperator

default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

dag = DAG(
    dag_id='dbt_transform_2',
    default_args=default_args,
    description='Run dbt models in Azure',
    schedule_interval=None,  # Manual trigger for POC
    start_date=datetime(2025, 1, 1),
    catchup=False,
    tags=['dbt', 'azure'],
)

dbt_run = AzureContainerInstancesOperator(
    task_id='dbt_run',
    ci_conn_id='azure_default',
    registry_conn_id='acr_default',
    resource_group='rg-aci-airflow-testdeployment3',
    name='dbt-run-{{ ts_nodash | lower }}',
    image='acrairflowflextestdeployment3.azurecr.io/dbt:latest',
    region='eastus',
    command=['dbt', 'run', '--debug'],
    cpu=1.0,
    memory_in_gb=2.0,
    dag=dag
)