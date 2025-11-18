#!/bin/bash

# Deploy Airflow Webserver as ACI
# Prerequisites: 
#   1. Run 'source 00-set-variables.sh' first
#   2. Complete steps 01-05

set -e

export MSYS_NO_PATHCONV=1
export MSYS2_ARG_CONV_EXCL="*"

echo "=== Deploying Airflow Webserver (ACI) ==="

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

echo "Creating ACI for Webserver..."

source configuration.txt
echo $STORAGE_ACCOUNT
echo $STORAGE_KEY
echo $FILE_SHARE_NAME

az container create \
  --name $ACI_WEBSERVER \
  --resource-group $RESOURCE_GROUP \
  --image ${ACR_LOGIN_SERVER}/airflow:latest \
  --registry-login-server $ACR_LOGIN_SERVER \
  --registry-username $ACR_USERNAME \
  --registry-password $ACR_PASSWORD \
  --os-type Linux \
  --cpu 1 \
  --memory 2 \
  --restart-policy Always \
  --assign-identity \
  --ports 8080 \
  --dns-name-label airflow-web-${RANDOM} \
  --command-line "bash -c 'airflow users create --username admin --password admin --firstname Admin --lastname User --role Admin --email admin@example.com || true && airflow webserver'" \
  --environment-variables \
    AIRFLOW__DATABASE__SQL_ALCHEMY_CONN="$AIRFLOW__DATABASE__SQL_ALCHEMY_CONN" \
    AIRFLOW__CORE__EXECUTOR=LocalExecutor \
    AIRFLOW__CORE__FERNET_KEY="$FERNET_KEY" \
    AIRFLOW__CORE__LOAD_EXAMPLES=False \
  --azure-file-volume-account-name $STORAGE_ACCOUNT \
  --azure-file-volume-account-key "$STORAGE_KEY" \
  --azure-file-volume-share-name $FILE_SHARE_NAME \
  --azure-file-volume-mount-path "/opt/airflow/logs" \
  --debug

# Get URL
export AIRFLOW_URL=$(az container show \
  --name $ACI_WEBSERVER \
  --resource-group $RESOURCE_GROUP \
  --query ipAddress.fqdn -o tsv)

echo ""
echo "✅ Webserver Deployed: $ACI_WEBSERVER"
echo ""
echo "🎉 Airflow UI: http://${AIRFLOW_URL}:8080"
echo "   Username: admin"
echo "   Password: admin"
echo ""
echo "Note: It may take 2-3 minutes for the webserver to fully start."
echo ""
echo "Check status:"
echo "  az container show --name $ACI_WEBSERVER --resource-group $RESOURCE_GROUP"
echo ""
echo "View logs:"
echo "  az container logs --name $ACI_WEBSERVER --resource-group $RESOURCE_GROUP --follow"
echo ""
echo "Next: Run ./08-setup-permissions.sh"
