# Quick Reference - Common Commands

## 🚀 Deployment

```bash
# Full automated deployment
./deploy-all.sh

# Or step-by-step
source 00-set-variables.sh
./01-create-resource-group.sh
./02-create-acr.sh
./03-create-postgres.sh
./04-build-push-images.sh
./05-deploy-scheduler.sh
./06-deploy-webserver.sh
./07-setup-permissions.sh
```

## 🔍 Monitoring

```bash
# List all containers
az container list --resource-group rg-aci-airflow --output table

# Watch containers (auto-refresh every 2 seconds)
watch -n 2 'az container list --resource-group rg-aci-airflow --output table'

# View scheduler logs
az container logs --name aci-scheduler --resource-group rg-aci-airflow --follow

# View webserver logs
az container logs --name aci-webserver --resource-group rg-aci-airflow --follow

# Check container status
az container show --name aci-scheduler --resource-group rg-aci-airflow --query instanceView.state
```

## 🔄 Container Management

```bash
# Restart scheduler
az container restart --name aci-scheduler --resource-group rg-aci-airflow

# Restart webserver
az container restart --name aci-webserver --resource-group rg-aci-airflow

# Delete and recreate scheduler (if stuck)
az container delete --name aci-scheduler --resource-group rg-aci-airflow --yes
./05-deploy-scheduler.sh
```

## 🐳 Image Management

```bash
# List images in ACR
az acr repository list --name <your-acr-name> --output table

# View image tags
az acr repository show-tags --name <your-acr-name> --repository airflow

# Rebuild and push images
./04-build-push-images.sh
```

## 🗄️ Database

```bash
# Connect to PostgreSQL
psql "postgresql://airflow:Quick123!@<postgres-host>:5432/airflow"

# Check database status
az postgres flexible-server show \
  --name <postgres-server-name> \
  --resource-group rg-aci-airflow

# View PostgreSQL logs
az postgres flexible-server server-logs list \
  --resource-group rg-aci-airflow \
  --server-name <postgres-server-name>
```

## 🔐 Permissions

```bash
# Get managed identity principal ID
export PRINCIPAL_ID=$(az container show \
  --name aci-scheduler \
  --resource-group rg-aci-airflow \
  --query identity.principalId -o tsv)

# List role assignments
az role assignment list --assignee $PRINCIPAL_ID --all --output table

# Re-grant permissions (if needed)
./07-setup-permissions.sh
```

## 🌐 Networking

```bash
# Get webserver URL
az container show \
  --name aci-webserver \
  --resource-group rg-aci-airflow \
  --query ipAddress.fqdn -o tsv

# Get webserver IP
az container show \
  --name aci-webserver \
  --resource-group rg-aci-airflow \
  --query ipAddress.ip -o tsv
```

## 🧹 Cleanup

```bash
# Delete everything
./99-cleanup.sh

# Or manually
az group delete --name rg-aci-airflow --yes --no-wait

# Check if deleted
az group show --name rg-aci-airflow
```

## 💰 Cost Management

```bash
# View current costs
az consumption usage list \
  --start-date $(date -d '7 days ago' +%Y-%m-%d) \
  --end-date $(date +%Y-%m-%d) \
  --query "[?contains(instanceName, 'aci-airflow')]"

# List all resources with costs
az resource list \
  --resource-group rg-aci-airflow \
  --output table
```

## 🐛 Troubleshooting

```bash
# Check resource group exists
az group show --name rg-aci-airflow

# List all resources
az resource list --resource-group rg-aci-airflow --output table

# Check container events
az container show \
  --name aci-scheduler \
  --resource-group rg-aci-airflow \
  --query instanceView.events

# Execute command inside container
az container exec \
  --name aci-scheduler \
  --resource-group rg-aci-airflow \
  --exec-command "airflow dags list"

# Test PostgreSQL connection from container
az container exec \
  --name aci-scheduler \
  --resource-group rg-aci-airflow \
  --exec-command "bash -c 'echo SELECT 1 | psql \"$AIRFLOW__DATABASE__SQL_ALCHEMY_CONN\"'"
```

## 📊 Airflow CLI (from within containers)

```bash
# List DAGs
az container exec \
  --name aci-scheduler \
  --resource-group rg-aci-airflow \
  --exec-command "airflow dags list"

# Trigger DAG
az container exec \
  --name aci-scheduler \
  --resource-group rg-aci-airflow \
  --exec-command "airflow dags trigger <dag-id>"

# Check DAG status
az container exec \
  --name aci-scheduler \
  --resource-group rg-aci-airflow \
  --exec-command "airflow dags state <dag-id> <execution-date>"
```

## 🔑 Environment Variables (for manual container creation)

```bash
export ACR_LOGIN_SERVER=$(az acr show --name <acr-name> --query loginServer -o tsv)
export ACR_USERNAME=$(az acr credential show --name <acr-name> --query username -o tsv)
export ACR_PASSWORD=$(az acr credential show --name <acr-name> --query "passwords[0].value" -o tsv)
export POSTGRES_HOST=$(az postgres flexible-server show --name <pg-name> --resource-group rg-aci-airflow --query fullyQualifiedDomainName -o tsv)
export AIRFLOW__DATABASE__SQL_ALCHEMY_CONN="postgresql+psycopg2://airflow:Quick123!@${POSTGRES_HOST}:5432/airflow"
```

---

**Pro Tip**: Save these commands in your shell history or create aliases for frequently used ones!

```bash
# Add to ~/.bashrc or ~/.zshrc
alias airflow-logs='az container logs --name aci-scheduler --resource-group rg-aci-airflow --follow'
alias airflow-restart='az container restart --name aci-scheduler --resource-group rg-aci-airflow'
alias airflow-url='az container show --name aci-webserver --resource-group rg-aci-airflow --query ipAddress.fqdn -o tsv'
```
