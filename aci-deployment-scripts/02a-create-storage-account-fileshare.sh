#!/bin/bash
set -e

# Variables
RESOURCE_GROUP="rg-aci-airflow-3-volume-mounts-ghactions"
LOCATION="eastus"
STORAGE_ACCOUNT="stairflowlogs$(date +%s)"
FILE_SHARE_NAME="airflow-logs"

echo "=================================================="
echo "Creating Storage Account and File Share for Logs"
echo "=================================================="

# Create storage account
echo "Creating storage account: $STORAGE_ACCOUNT"
az storage account create \
  --name $STORAGE_ACCOUNT \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION \
  --sku Standard_LRS \
  --kind StorageV2

echo "Storage account created successfully!"

# Create file share
echo "Creating file share: $FILE_SHARE_NAME"
az storage share create \
  --name $FILE_SHARE_NAME \
  --account-name $STORAGE_ACCOUNT \
  --quota 10

echo "File share created successfully!"

# Get storage key
echo "Retrieving storage account key..."
STORAGE_KEY=$(az storage account keys list \
  --account-name $STORAGE_ACCOUNT \
  --resource-group $RESOURCE_GROUP \
  --query "[0].value" -o tsv)

echo ""
echo "=================================================="
echo "✅ Storage Setup Complete!"
echo "=================================================="
echo "Storage Account: $STORAGE_ACCOUNT"
echo "File Share: $FILE_SHARE_NAME"
echo "Storage Key: $STORAGE_KEY"
echo ""
echo "⚠️  SAVE THESE VALUES - You'll need them for container deployment!"
echo "=================================================="

# Save to file for later use
cat > storage-config.txt <<EOF
STORAGE_ACCOUNT=$STORAGE_ACCOUNT
STORAGE_KEY=$STORAGE_KEY
FILE_SHARE_NAME=$FILE_SHARE_NAME
EOF

echo "✅ Configuration saved to storage-config.txt"