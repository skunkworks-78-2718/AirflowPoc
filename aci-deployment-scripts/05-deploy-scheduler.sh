#!/bin/bash

# Deploy Airflow Scheduler as ACI
# Prerequisites: 
#   1. Run 'source 00-set-variables.sh' first
#   2. Complete steps 01-04

set -e

export MSYS_NO_PATHCONV=1
export MSYS2_ARG_CONV_EXCL="*"

echo "=== Deploying Airflow Scheduler (ACI) ==="

# Get required variables if not set
if [ -z "$ACR_LOGIN_SERVER" ]; then
  export ACR_LOGIN_SERVER=$(az acr show --name $ACR_NAME --query loginServer -o tsv)
fi

if [ -z "$ACR_USERNAME" ]; then
  export ACR_USERNAME=$(az acr credential show --name $ACR_NAME --query username -o tsv)
fi

if [ -z "$ACR_PASSWORD" ]; then
  export ACR_PASSWORD=$(az acr credential show --name $ACR_NAME --query "passwords[0].value" -o tsv)
fi

if [ -z "$AIRFLOW__DATABASE__SQL_ALCHEMY_CONN" ]; then
  export POSTGRES_HOST=$(az postgres flexible-server show \
    --name $POSTGRES_SERVER \
    --resource-group $RESOURCE_GROUP \
    --query fullyQualifiedDomainName -o tsv)
  export AIRFLOW__DATABASE__SQL_ALCHEMY_CONN="postgresql+psycopg2://${POSTGRES_USER}:${POSTGRES_PASSWORD}@${POSTGRES_HOST}:5432/${POSTGRES_DB}"
fi

echo "Creating ACI for Scheduler..."

source storage-config.txt
echo $STORAGE_ACCOUNT
echo $STORAGE_KEY
echo $FILE_SHARE_NAME

# az container create \
#   --name $ACI_SCHEDULER \
#   --resource-group $RESOURCE_GROUP \
#   --image ${ACR_LOGIN_SERVER}/airflow:latest \
#   --registry-login-server $ACR_LOGIN_SERVER \
#   --registry-username $ACR_USERNAME \
#   --registry-password $ACR_PASSWORD \
#   --os-type Linux \
#   --cpu 1 \
#   --memory 2 \
#   --restart-policy Always \
#   --assign-identity \
#   --command-line "bash -c 'airflow db migrate && airflow scheduler'" \
#   --azure-file-volume-account-name $STORAGE_ACCOUNT \
#   --azure-file-volume-account-key "$STORAGE_KEY" \
#   --azure-file-volume-share-name $FILE_SHARE_NAME \
#   --azure-file-volume-mount-path "/opt/airflow/logs" \
#   --environment-variables AIRFLOW__DATABASE__SQL_ALCHEMY_CONN="$AIRFLOW__DATABASE__SQL_ALCHEMY_CONN" AIRFLOW__CORE__EXECUTOR=LocalExecutor AIRFLOW__CORE__FERNET_KEY="$FERNET_KEY" AIRFLOW__CORE__LOAD_EXAMPLES=False ACR_LOGIN_SERVER="$ACR_LOGIN_SERVER" AZURE_RESOURCE_GROUP="$RESOURCE_GROUP" AZURE_LOCATION="$LOCATION" AZURE_SUBSCRIPTION_ID="$SUBSCRIPTION_ID"

echo "$FILE_SHARE_NAME" "$STORAGE_ACCOUNT" >/dev/null  # sanity
az container create \
  --name "$ACI_SCHEDULER" \
  --resource-group "$RESOURCE_GROUP" \
  --image "${ACR_LOGIN_SERVER}/airflow:latest" \
  --registry-login-server "$ACR_LOGIN_SERVER" \
  --registry-username "$ACR_USERNAME" \
  --registry-password "$ACR_PASSWORD" \
  --os-type Linux \
  --cpu 1 \
  --memory 2 \
  --restart-policy Always \
  --assign-identity \
  --command-line "bash -c 'airflow db migrate && airflow scheduler'" \
  --azure-file-volume-account-name "$STORAGE_ACCOUNT" \
  --azure-file-volume-account-key "$STORAGE_KEY" \
  --azure-file-volume-share-name "$FILE_SHARE_NAME" \
  --azure-file-volume-mount-path "/opt/airflow/logs" \
  --environment-variables \
    AIRFLOW__DATABASE__SQL_ALCHEMY_CONN="$AIRFLOW__DATABASE__SQL_ALCHEMY_CONN" \
    AIRFLOW__CORE__EXECUTOR=LocalExecutor \
    AIRFLOW__CORE__FERNET_KEY="$FERNET_KEY" \
    AIRFLOW__CORE__LOAD_EXAMPLES=False \
    ACR_LOGIN_SERVER="$ACR_LOGIN_SERVER" \
    AZURE_RESOURCE_GROUP="$RESOURCE_GROUP" \
    AZURE_LOCATION="$LOCATION" \
    AZURE_SUBSCRIPTION_ID="$SUBSCRIPTION_ID"


echo ""
echo "✅ Scheduler Deployed: $ACI_SCHEDULER"
echo ""
echo "Check status:"
echo "  az container show --name $ACI_SCHEDULER --resource-group $RESOURCE_GROUP"
echo ""
echo "View logs:"
echo "  az container logs --name $ACI_SCHEDULER --resource-group $RESOURCE_GROUP --follow"
echo ""
echo "Next: Run ./06-deploy-webserver.sh"