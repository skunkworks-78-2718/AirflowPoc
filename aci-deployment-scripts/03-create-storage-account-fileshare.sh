#!/bin/bash
set -e


source configuration.txt
# Variables
LOCATION="eastus"

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


export STORAGE_ACCOUNT=$STORAGE_ACCOUNT
export STORAGE_KEY=$STORAGE_KEY
export FILE_SHARE_NAME=$FILE_SHARE_NAME


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
cat >> configuration.txt <<EOF
#Storage Account Credentials:
STORAGE_KEY=$STORAGE_KEY
EOF

echo "✅ Configuration saved to configuration.txt"