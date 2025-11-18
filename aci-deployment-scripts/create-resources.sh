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
bash 01-create-resource-group.sh
echo ""

# Step 2: Create ACR
echo "Step 2: Creating Azure Container Registry..."
bash 02-create-acr.sh

echo "Step 3: Creating Azure Storage Account and FileShare..."
bash 03-create-storage-account-fileshare.sh


# Step 4: Create PostgreSQL
echo "Step 4: Creating PostgreSQL database..."
bash 04-create-postgres.sh


# Step 5: Build and push images
echo "Step 5: Building and pushing Docker images..."
bash 05-build-push-images.sh
echo ""

# Step 6: Deploy scheduler
echo "Step 6: Deploying Airflow scheduler..."
bash 06-deploy-scheduler.sh
echo ""

# Step 7: Deploy webserver
echo "Step 7: Deploying Airflow webserver..."
bash 07-deploy-webserver.sh
# echo ""

# # Step 8: Setup permissions
# echo "Step 8: Setting up permissions..."
# 08-setup-permissions.sh
# echo ""

# # Get final URL
# export AIRFLOW_URL=$(az container show \
#   --name $ACI_WEBSERVER \
#   --resource-group $RESOURCE_GROUP \
#   --query ipAddress.fqdn -o tsv)

# echo ""
# echo "=========================================="
# echo "  DEPLOYMENT COMPLETE!"
# echo "=========================================="
# echo ""
# echo "🎉 Airflow UI: http://${AIRFLOW_URL}:8080"
# echo "   Username: admin"
# echo "   Password: admin"
# echo ""
# echo "Resources created in: $RESOURCE_GROUP"
# echo ""
# echo "Next steps:"
# echo "  1. Wait 2-3 minutes for services to fully start"
# echo "  2. Access the Airflow UI"
# echo "  3. Enable your DAGs"
# echo "  4. Trigger a DAG to test ephemeral ACI containers"
# echo ""
# echo "To cleanup everything:"
# echo "  ./99-cleanup.sh"
