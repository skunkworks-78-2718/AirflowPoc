#!/bin/bash

# Create PostgreSQL Database for Airflow Metadata
# Prerequisites: Run 'source 00-set-variables.sh' first

set -e

echo "=== Creating PostgreSQL Flexible Server ==="

source configuration.txt

az postgres flexible-server create \
  --name $POSTGRES_SERVER \
  --resource-group $RESOURCE_GROUP \
  --location "eastus2" \
  --admin-user $POSTGRES_USER \
  --admin-password $POSTGRES_PASSWORD \
  --sku-name Standard_B1ms \
  --tier Burstable \
  --public-access All \
  --storage-size 32 \
  --version 13

echo ""
echo "Creating Airflow database..."

az postgres flexible-server db create \
  --resource-group $RESOURCE_GROUP \
  --server-name $POSTGRES_SERVER \
  --database-name $POSTGRES_DB

echo ""
echo "Getting connection string..."

export POSTGRES_HOST=$(az postgres flexible-server show \
  --name $POSTGRES_SERVER \
  --resource-group $RESOURCE_GROUP \
  --query fullyQualifiedDomainName -o tsv)

export AIRFLOW__DATABASE__SQL_ALCHEMY_CONN="postgresql+psycopg2://${POSTGRES_USER}:${POSTGRES_PASSWORD}@${POSTGRES_HOST}:5432/${POSTGRES_DB}"

echo ""
echo "✅ PostgreSQL Created: $POSTGRES_SERVER"
echo "Host: $POSTGRES_HOST"
echo ""
echo "IMPORTANT: Save this connection string:"
echo "export AIRFLOW__DATABASE__SQL_ALCHEMY_CONN=\"$AIRFLOW__DATABASE__SQL_ALCHEMY_CONN\""
echo ""
echo "Next: Run ./05-build-push-images.sh"

# Save to file for later use
cat >> configuration.txt <<EOF
#POSTGRES CREDENTIALS
POSTGRES_SERVER=$POSTGRES_SERVER
POSTGRES_HOST=$POSTGRES_HOST

#IMPORTANT: Save this connection string:
AIRFLOW__DATABASE__SQL_ALCHEMY_CONN=$AIRFLOW__DATABASE__SQL_ALCHEMY_CONN
EOF

echo "✅ Configuration saved to configuration.txt"