#!/bin/bash

# Build and Push Docker Images to ACR
# Prerequisites: 
#   1. Run 'source 00-set-variables.sh' first
#   2. Complete steps 01-03
#   3. Have Dockerfiles ready in ../airflow and ../dbt directories

set -e

echo "=== Building and Pushing Docker Images ==="

# Check if ACR_LOGIN_SERVER is set
if [ -z "$ACR_LOGIN_SERVER" ]; then
  echo "Getting ACR login server..."
  export ACR_LOGIN_SERVER=$(az acr show --name $ACR_NAME --query loginServer -o tsv)
fi

# Login to ACR
echo "Logging into ACR: $ACR_LOGIN_SERVER..."
az acr login --name $ACR_NAME

# Navigate to project root
cd ..

# Build and push Airflow image
echo ""
echo "Building Airflow image..."
docker build -t ${ACR_LOGIN_SERVER}/airflow:latest -f airflow/Dockerfile ./airflow

echo "Pushing Airflow image to ACR..."
docker push ${ACR_LOGIN_SERVER}/airflow:latest

# Build and push DBT image
echo ""
echo "Building DBT image..."
docker build -t ${ACR_LOGIN_SERVER}/dbt:latest -f dbt/Dockerfile ./dbt

echo "Pushing DBT image to ACR..."
docker push ${ACR_LOGIN_SERVER}/dbt:latest

# Verify images
echo ""
echo "=== Images Pushed Successfully ==="
echo "Verifying images in ACR..."
az acr repository list --name $ACR_NAME --output table

echo ""
echo "Images available:"
echo "  ${ACR_LOGIN_SERVER}/airflow:latest"
echo "  ${ACR_LOGIN_SERVER}/dbt:latest"
echo ""
echo "Next: Run ./05-deploy-scheduler.sh"
