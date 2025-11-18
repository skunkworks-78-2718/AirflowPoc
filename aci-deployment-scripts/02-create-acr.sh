#!/bin/bash

# Create Azure Container Registry
# Prerequisites: Run 'source 00-set-variables.sh' first

set -e

source configuration.txt

echo "=== Creating Azure Container Registry ==="

az acr create \
  --name $ACR_NAME \
  --resource-group $RESOURCE_GROUP \
  --sku Basic \
  --admin-enabled true

echo ""
echo "Getting ACR credentials..."

export ACR_LOGIN_SERVER=$(az acr show --name $ACR_NAME --query loginServer -o tsv)
export ACR_USERNAME=$(az acr credential show --name $ACR_NAME --query username -o tsv)
export ACR_PASSWORD=$(az acr credential show --name $ACR_NAME --query "passwords[0].value" -o tsv)

echo ""
echo "✅ ACR Created: $ACR_NAME"
echo "Login Server: $ACR_LOGIN_SERVER"
echo ""
echo "IMPORTANT: Save these for later scripts:"
echo "export ACR_LOGIN_SERVER=$ACR_LOGIN_SERVER"
echo "export ACR_USERNAME=$ACR_USERNAME"
echo "export ACR_PASSWORD=$ACR_PASSWORD"
echo ""
echo "Next: Run ./03-create-postgres.sh"


cat >> configuration.txt <<EOF
#ACR Credentials:

ACR_LOGIN_SERVER=$ACR_LOGIN_SERVER
ACR_USERNAME=$ACR_USERNAME
ACR_PASSWORD=$ACR_PASSWORD
EOF