from datetime import datetime, timedelta
from airflow import DAG
from airflow.providers.microsoft.azure.operators.container_instances import AzureContainerInstancesOperator
from azure.mgmt.containerinstance.models import ContainerGroupIdentity

default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

dag = DAG(
    dag_id='dbt_run_customers',
    default_args=default_args,
    description='Run specific dbt model in Azure',
    schedule_interval=None,  # Manual trigger
    start_date=datetime(2025, 1, 1),
    catchup=False,
    tags=['dbt', 'azure', 'single-model'],
)

# Run a specific model - change 'my_model_name' to your actual model name
dbt_run_model = AzureContainerInstancesOperator(
    task_id='dbt_run_my_model',
    ci_conn_id='azure_default',
    registry_conn_id='acr_default',
    resource_group='rg-aci-airflow-3-volume-mounts-ghactions',
    name='dbt-run-{{ ts_nodash | lower }}',
    image='acrairflow320814.azurecr.io/dbt:latest',
    region='eastus',
    command=['dbt', 'run', '--debug', '--select', 'stg_customers'],  # ← Specific model
    cpu=1.0,
    memory_in_gb=2.0,
    identity=ContainerGroupIdentity(
        type="UserAssigned",
        user_assigned_identities={
            "/subscriptions/806f08eb-d87e-45b7-b587-168e449632f8/resourcegroups/rg-aci-airflow-3-volume-mounts-ghactions/providers/Microsoft.ManagedIdentity/userAssignedIdentities/dbt-container-identity": {}
        }
    ),
    dag=dag
)
