# Step 5: Build and push images
echo "Step 5: Building and pushing Docker images..."
bash 05-build-push-images.sh
echo ""

# Step 6: Deploy scheduler
echo "Step 6: Deploying Airflow scheduler..."
bash 06-deploy-scheduler.sh
echo ""

# Step 7: Deploy webserver
echo "Step 7: Deploying Airflow webserver..."
bash 07-deploy-webserver.sh
echo ""

# # Step 8: Setup permissions
# echo "Step 8: Setting up permissions..."
# 08-setup-permissions.sh
# echo ""

# Get final URL
export AIRFLOW_URL=$(az container show \
  --name $ACI_WEBSERVER \
  --resource-group $RESOURCE_GROUP \
  --query ipAddress.fqdn -o tsv)

echo ""
echo "=========================================="
echo "  DEPLOYMENT COMPLETE!"
echo "=========================================="
echo ""
echo "🎉 Airflow UI: http://${AIRFLOW_URL}:8080"
echo "   Username: admin"
echo "   Password: admin"
echo ""
echo "Resources created in: $RESOURCE_GROUP"
echo ""
echo "Next steps:"
echo "  1. Wait 2-3 minutes for services to fully start"
echo "  2. Access the Airflow UI"
echo "  3. Enable your DAGs"
echo "  4. Trigger a DAG to test ephemeral ACI containers"
echo ""

cat >> configuration.txt <<EOF

Airflow URL: $AIRFLOW_URL
Airflow UI: http://${AIRFLOW_URL}:8080
   Username: admin
   Password: admin

Resources created in: $RESOURCE_GROUP

Next steps:
  1. Wait 2-3 minutes for services to fully start
  2. Access the Airflow UI
  3. Enable your DAGs
  4. Trigger a DAG to test ephemeral ACI containers

EOF
