#!/bin/bash

# Create Resource Group
# Prerequisites: Run 'source 00-set-variables.sh' first

set -e

source configuration.txt

echo "=== Creating Resource Group ==="

az group create \
  --name $RESOURCE_GROUP \
  --location $LOCATION

echo ""
echo "✅ Resource Group Created: $RESOURCE_GROUP"
echo ""
echo "Next: Run ./02-create-acr.sh"
