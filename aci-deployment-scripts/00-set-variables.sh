#!/bin/bash

# Environment Variables for ACI Deployment
# Source this file before running other scripts: source 00-set-variables.sh

export description="testdeployment3"
export RESOURCE_GROUP="rg-aci-airflow-$description"
export LOCATION="eastus"
export ACR_NAME="acrairflowflex$description"  # Must be globally unique, lowercase only

#Storage Account Settings
export STORAGE_ACCOUNT="flexcareairflowlogging"
export FILE_SHARE_NAME="flexcareairflowlogs"

# PostgreSQL settings
export POSTGRES_SERVER="pg-airflow-$description"
export POSTGRES_USER="airflow"
export POSTGRES_PASSWORD="ChangeMe123"
export POSTGRES_DB="airflow"

# Container names
export ACI_SCHEDULER="aci-scheduler-$description"
export ACI_WEBSERVER="aci-webserver-$description"

# Get subscription ID
export SUBSCRIPTION_ID=$(az account show --query id -o tsv)

# Generate Fernet key
export FERNET_KEY=""

echo "=== Variables Set ==="
echo "Resource Group: $RESOURCE_GROUP"
echo "Location: $LOCATION"
echo "ACR Name: $ACR_NAME"
echo "PostgreSQL Server: $POSTGRES_SERVER"
echo "Subscription ID: $SUBSCRIPTION_ID"
echo ""
echo "Next: Run ./01-create-resource-group.sh"


cat >> configuration.txt <<EOF
RESOURCE_GROUP=$RESOURCE_GROUP
LOCATION=$LOCATION
ACR_NAME=$ACR_NAME
SUBSCRIPTION_ID=$SUBSCRIPTION_ID

#Storage Account Settings
STORAGE_ACCOUNT=$STORAGE_ACCOUNT
FILE_SHARE_NAME=$FILE_SHARE_NAME

# PostgreSQL settings
POSTGRES_USER=$POSTGRES_USER
POSTGRES_PASSWORD=$POSTGRES_PASSWORD
POSTGRES_DB=$POSTGRES_DB

# Container names
ACI_SCHEDULER=$ACI_SCHEDULER
ACI_WEBSERVER=$ACI_WEBSERVER

# Get subscription ID
SUBSCRIPTION_ID=$SUBSCRIPTION_ID

# Generate Fernet key
FERNET_KEY=$FERNET_KEY
EOF