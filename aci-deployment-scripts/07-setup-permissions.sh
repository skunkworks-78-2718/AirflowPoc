#!/bin/bash

# Setup Managed Identity and Permissions for ACI Creation
# Prerequisites: 
#   1. Run 'source 00-set-variables.sh' first
#   2. Complete steps 01-06

set -e

echo "=== Setting Up Permissions for Scheduler ==="

# Get the managed identity principal ID from the scheduler
export PRINCIPAL_ID=$(az container show \
  --name $ACI_SCHEDULER \
  --resource-group $RESOURCE_GROUP \
  --query identity.principalId -o tsv)

if [ -z "$PRINCIPAL_ID" ] || [ "$PRINCIPAL_ID" == "null" ]; then
  echo "ERROR: No managed identity found on scheduler."
  echo "The scheduler must be created with --assign-identity flag."
  exit 1
fi

echo "Managed Identity Principal ID: $PRINCIPAL_ID"

# Grant Contributor role on resource group (to create ephemeral ACI containers)
echo ""
echo "Granting Contributor role on resource group..."
az role assignment create \
  --assignee $PRINCIPAL_ID \
  --role "Contributor" \
  --scope "/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${RESOURCE_GROUP}"

# Grant ACR Pull permission
echo ""
echo "Granting ACR Pull permission..."
export ACR_ID=$(az acr show --name $ACR_NAME --query id -o tsv)

az role assignment create \
  --assignee $PRINCIPAL_ID \
  --role "AcrPull" \
  --scope $ACR_ID

echo ""
echo "=== PERMISSIONS CONFIGURED ==="
echo ""
echo "Scheduler ($ACI_SCHEDULER) can now:"
echo "  ✓ Create/delete ephemeral ACI containers in $RESOURCE_GROUP"
echo "  ✓ Pull images from $ACR_NAME"
echo ""
echo "=== DEPLOYMENT COMPLETE ==="
echo ""
echo "Next steps:"
echo "  1. Access Airflow UI (see output from step 06)"
echo "  2. Enable your DAGs in the UI"
echo "  3. Trigger a DAG and watch ephemeral DBT containers spin up!"
echo ""
echo "To verify:"
echo "  az container list --resource-group $RESOURCE_GROUP --output table"
