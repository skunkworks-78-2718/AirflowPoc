# Airflow ACI Deployment Scripts

Complete deployment automation for Airflow with ephemeral DBT containers using Azure Container Instances (ACI).

## 📋 What This Deploys

```
Azure Container Registry (ACR)
└── airflow:latest (with DAGs baked in)
└── dbt:latest

Azure Container Instances (ACI):
├── Scheduler (persistent, runs 24/7)
└── Webserver (persistent, runs 24/7)

Azure PostgreSQL (Airflow metadata)

Ephemeral ACI:
└── DBT containers (auto-created by DAGs, auto-deleted after run)
```

## 🚀 Quick Start

### Prerequisites
- Azure CLI installed: `az login`
- GIT bash
- Docker installed and running
- Your Airflow and DBT code ready with Dockerfiles
- Recommend VS Code (run as Admin)

### Option 1: Run Everything at Once (Fastest)

cd aci-deployment-scripts
bash deploy-all.sh

### Option 2: Step-by-Step (Recommended for Learning)

```bash

# Run each step
source 00-set-variables.sh                            # Set environment variables
bash 01-create-resource-group.sh                      # Create resource group
bash 02-create-acr.sh                                 # Create container registry
bash 03-create-storage-account-fileshare.sh           # Create container registry
bash 04-create-postgres.sh                            # Create PostgreSQL database
bash 05-build-push-images.sh                          # Build and push images
bash 06-deploy-scheduler.sh                           # Deploy Airflow scheduler
bash 07-deploy-webserver.sh                           # Deploy Airflow webserver
```

## 📁 Script Descriptions

| Script | Purpose | Duration |
|--------|---------|----------|
| `00-set-variables.sh` | Set environment variables | 1 min |
| `01-create-resource-group.sh` | Create Azure resource group | 1 min |
| `02-create-acr.sh` | Create Azure Container Registry | 2 min |
| `04-create-postgres.sh` | Create PostgreSQL database | 5 min |
| `05-build-push-images.sh` | Build and push Docker images | 10 min |
| `06-deploy-scheduler.sh` | Deploy Airflow scheduler as ACI | 2 min |
| `07-deploy-webserver.sh` | Deploy Airflow webserver as ACI | 2 min |




**Total deployment time: ~25-30 minutes**

## 🔧 Configuration

## Don't adjust this I have it all set to be able to run from start. This will be easiest.

Edit `00-set-variables.sh` to customize:

```bash
export RESOURCE_GROUP="rg-aci-airflow"      # Your resource group name
export LOCATION="eastus"                     # Azure region
export ACR_NAME="acrairflow${RANDOM}"        # Registry name (must be unique)
export POSTGRES_PASSWORD="ChangeMe123!"      # Database password
```

## 📦 Required Files

Your project structure should look like:

```
project/
├── deployment-scripts/          # These scripts
│   ├── 00-set-variables.sh
│   ├── 01-create-resource-group.sh
│   ├── ...
│   └── README.md
├── airflow/
│   ├── Dockerfile               # Airflow image with DAGs
│   ├── dags/
│   │   └── your_dag.py         # With AzureContainerInstancesOperator
│   ├── plugins/
│   └── requirements.txt
└── dbt/
    ├── Dockerfile               # DBT image
    ├── models/
    ├── profiles.yml
    └── dbt_project.yml
```

### SET PERMISSIONS IN AZURE PORTAL
Azure Permissions setup in Portal
Need the following permissions

## Scheduler has Contributor on Resource Group
## Scheduler has AcrPull on ACR
## Webserver has AcrPull on ACR

## Step 1: Grant Contributor to Scheduler
    1. Go to Resource Groups → rg-aci-airflow-testdeployment3
    2. Click Access control (IAM)
    3. Click + Add → Add role assignment
    4. Select Contributor role → Next
    5. Click + Select members
    6. Search for aci-scheduler-testdeployment3
    7. Select it → Review + assign

## Step 2: Grant AcrPull to Scheduler
    1. Go to Container registries → Your ACR (e.g., acrairflow320814)
    2. Click Access control (IAM)
    3. Click + Add → Add role assignment
    4. Select AcrPull role → Next
    5. Click + Select members
    6. Search for aci-scheduler-testdeployment3
    7. Select it → Review + assign

## Step 3: Grant AcrPull to Webserver
    1. Same ACR → Access control (IAM)
    2. Click + Add → Add role assignment
    3. Select AcrPull role → Next
    4. Click + Select members
    5. Search for aci-webserver-testdeployment3
    6. Select it → Review + assign

### ADD Connections in Airflow UI

## 1. acr_default

<img width="2439" height="915" alt="image" src="https://github.com/user-attachments/assets/9c6761c0-25bb-48dc-a778-1a8bea281fb5" />

## 🎯 After Deployment


1. **Access Airflow UI**: The URL will be displayed at the end of deployment
   ```
   http://<random>.eastus.azurecontainer.io:8080
   Username: admin
   Password: admin
   ```

2. **Enable DAGs**: In the Airflow UI, toggle your DAGs on

3. **Trigger Test Run**: Click "Trigger DAG" and watch it create ephemeral ACI containers!

4. **Monitor**: 
   ```bash
   # Watch containers being created/deleted
   watch -n 2 'az container list --resource-group rg-aci-airflow --output table'
   
   # View scheduler logs
   az container logs --name aci-scheduler --resource-group rg-aci-airflow --follow
   
   # View webserver logs
   az container logs --name aci-webserver --resource-group rg-aci-airflow --follow
   ```

## 💰 Cost Estimate (2 weeks)

- **ACR**: ~$3
- **2 ACI containers** (Scheduler + Webserver, 24/7): ~$20
- **PostgreSQL**: ~$10
- **Ephemeral ACI** (DBT runs): ~$5
- **Total**: ~$40 for 2 weeks

## 🔄 Restarting Containers

If a container crashes:

```bash
# Restart scheduler
az container restart --name aci-scheduler --resource-group rg-aci-airflow

# Restart webserver
az container restart --name aci-webserver --resource-group rg-aci-airflow
```

## 🧹 Cleanup

When finished with POC:

```bash
./99-cleanup.sh
```

This deletes the entire resource group and all resources (~5-10 minutes).

## ❓ Troubleshooting

### Can't access Airflow UI?
Wait 2-3 minutes after deployment completes. Check webserver logs:
```bash
az container logs --name aci-webserver --resource-group rg-aci-airflow
```

### DAGs not showing up?
Restart scheduler:
```bash
az container restart --name aci-scheduler --resource-group rg-aci-airflow
```

### Ephemeral ACI creation failing?
Check permissions:
```bash
export PRINCIPAL_ID=$(az container show \
  --name aci-scheduler \
  --resource-group rg-aci-airflow \
  --query identity.principalId -o tsv)

az role assignment list --assignee $PRINCIPAL_ID --all
```

### PostgreSQL connection errors?
Verify connection string:
```bash
source 00-set-variables.sh
echo $AIRFLOW__DATABASE__SQL_ALCHEMY_CONN
```

## 📚 Next Steps

- [ ] Set up Azure Key Vault for secrets
- [ ] Configure Azure Monitor alerts
- [ ] Set up CI/CD with GitHub Actions
- [ ] Consider Azure Data Factory Managed Airflow for production

## 🤝 Support

For issues or questions:
1. Check logs: `az container logs --name <container-name> --resource-group <rg-name>`
2. List resources: `az resource list --resource-group <rg-name> --output table`
3. Check container status: `az container show --name <container-name> --resource-group <rg-name>`

---

**Happy deploying! 🚀**
