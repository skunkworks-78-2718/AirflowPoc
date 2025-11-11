#!/bin/bash

# Deploy Everything - Run All Scripts in Sequence
# This script runs all deployment steps automatically

set -e

echo "=========================================="
echo "  AIRFLOW ACI DEPLOYMENT - FULL DEPLOY"
echo "=========================================="
echo ""

# Step 0: Load variables
echo "Step 0: Loading variables..."
source 00-set-variables.sh
echo ""

# Step 1: Create resource group
echo "Step 1: Creating resource group..."
./01-create-resource-group.sh
echo ""

# Step 2: Create ACR
echo "Step 2: Creating Azure Container Registry..."
./02-create-acr.sh

# Re-export ACR variables from step 2
export ACR_LOGIN_SERVER=$(az acr show --name $ACR_NAME --query loginServer -o tsv)
export ACR_USERNAME=$(az acr credential show --name $ACR_NAME --query username -o tsv)
export ACR_PASSWORD=$(az acr credential show --name $ACR_NAME --query "passwords[0].value" -o tsv)
echo ""

# Step 3: Create PostgreSQL
echo "Step 3: Creating PostgreSQL database..."
./03-create-postgres.sh

# Re-export Postgres connection from step 3
export POSTGRES_HOST=$(az postgres flexible-server show \
  --name $POSTGRES_SERVER \
  --resource-group $RESOURCE_GROUP \
  --query fullyQualifiedDomainName -o tsv)
export AIRFLOW__DATABASE__SQL_ALCHEMY_CONN="postgresql+psycopg2://${POSTGRES_USER}:${POSTGRES_PASSWORD}@${POSTGRES_HOST}:5432/${POSTGRES_DB}"
echo ""

# Step 4: Build and push images
echo "Step 4: Building and pushing Docker images..."
./04-build-push-images.sh
echo ""

# Step 5: Deploy scheduler
echo "Step 5: Deploying Airflow scheduler..."
./05-deploy-scheduler.sh
echo ""

# Step 6: Deploy webserver
echo "Step 6: Deploying Airflow webserver..."
./06-deploy-webserver.sh
echo ""

# Step 7: Setup permissions
echo "Step 7: Setting up permissions..."
./07-setup-permissions.sh
echo ""

# Get final URL
export AIRFLOW_URL=$(az container show \
  --name $ACI_WEBSERVER \
  --resource-group $RESOURCE_GROUP \
  --query ipAddress.fqdn -o tsv)

echo ""
echo "=========================================="
echo "  DEPLOYMENT COMPLETE!"
echo "=========================================="
echo ""
echo "🎉 Airflow UI: http://${AIRFLOW_URL}:8080"
echo "   Username: admin"
echo "   Password: admin"
echo ""
echo "Resources created in: $RESOURCE_GROUP"
echo ""
echo "Next steps:"
echo "  1. Wait 2-3 minutes for services to fully start"
echo "  2. Access the Airflow UI"
echo "  3. Enable your DAGs"
echo "  4. Trigger a DAG to test ephemeral ACI containers"
echo ""
echo "To cleanup everything:"
echo "  ./99-cleanup.sh"
