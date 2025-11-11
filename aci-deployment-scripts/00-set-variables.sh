#!/bin/bash

# Environment Variables for ACI Deployment
# Source this file before running other scripts: source 00-set-variables.sh

RANDOM="adding_mounts_ghactions"
export RESOURCE_GROUP="rg-aci-airflow-3-volume-mounts-ghactions"
export LOCATION="eastus"
export ACR_NAME="acrairflow3${RANDOM}"  # Must be globally unique, lowercase only

# PostgreSQL settings
export POSTGRES_SERVER="pg-airflow3-${RANDOM}"
export POSTGRES_USER="airflow"
export POSTGRES_PASSWORD="ChangeMe123"
export POSTGRES_DB="airflow"

# Container names
export ACI_SCHEDULER="aci-scheduler3"
export ACI_WEBSERVER="aci-webserver3"

# Get subscription ID
export SUBSCRIPTION_ID=$(az account show --query id -o tsv)

# Generate Fernet key
export FERNET_KEY="vZ8VqvXsN9K4yJ3mR7pL2wH6tF5nD9xC8bV1aQ0uE4M="

echo "=== Variables Set ==="
echo "Resource Group: $RESOURCE_GROUP"
echo "Location: $LOCATION"
echo "ACR Name: $ACR_NAME"
echo "PostgreSQL Server: $POSTGRES_SERVER"
echo "Subscription ID: $SUBSCRIPTION_ID"
echo ""
echo "Next: Run ./01-create-resource-group.sh"
