#!/bin/bash

# Cleanup - Delete All Resources
# Prerequisites: Run 'source 00-set-variables.sh' first

set -e

echo "=== CLEANUP WARNING ==="
echo "This will DELETE the following resource group and ALL resources inside:"
echo "  Resource Group: $RESOURCE_GROUP"
echo ""
read -p "Are you sure you want to continue? (yes/no): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
  echo "Cleanup cancelled."
  exit 0
fi

echo ""
echo "=== Starting Cleanup ==="

# Option 1: Fast cleanup (delete entire resource group)
echo "Deleting resource group (this will take 5-10 minutes)..."
az group delete --name $RESOURCE_GROUP --yes --no-wait

echo ""
echo "✅ Cleanup initiated"
echo ""
echo "The resource group is being deleted in the background."
echo "To check status:"
echo "  az group show --name $RESOURCE_GROUP"
echo ""
echo "Once deleted, you'll see:"
echo "  ERROR: ResourceGroupNotFound"

# Optional: List what's being deleted
echo ""
echo "Resources being deleted:"
az resource list --resource-group $RESOURCE_GROUP --output table 2>/dev/null || echo "  (Resource group already gone)"
