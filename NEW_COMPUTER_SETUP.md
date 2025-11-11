# Step-by-Step Guide: Setting Up Project on a New Computer

## Prerequisites
1. Install Docker Desktop
   - Download from [Docker Desktop website](https://www.docker.com/products/docker-desktop)
   - Install and start Docker Desktop
   - Ensure Docker is running (you should see the Docker icon in your system tray)

## Step 1: Project Setup
1. Create project directory:
```bash
mkdir dbt_airflow_project
cd dbt_airflow_project
```

2. Create required directories:
```bash
mkdir -p airflow/dags
mkdir -p airflow/logs
mkdir -p airflow/plugins
mkdir -p dbt/models
mkdir -p dbt/logs
mkdir -p sqlserver/backup
```

## Step 2: Download Required Files

1. Download AdventureWorks Database:
   - Go to [Microsoft AdventureWorks Sample Databases](https://learn.microsoft.com/en-us/sql/samples/adventureworks-install-configure)
   - Download "AdventureWorks2019.bak"
   - Place it in `sqlserver/backup/` directory

2. Copy these essential files to your project:
   - `docker-compose.yml`
   - `restore-db.sh`
   - `dbt_project.yml`
   - `packages.yml`
   - Your DBT models from `dbt/models/`
   - Your Airflow DAGs from `airflow/dags/`

## Step 3: Set Up Environment

1. Set file permissions (Windows PowerShell as Administrator):
```bash
icacls * /reset
icacls * /grant Everyone:F /t
```

## Step 4: Start Services

1. Build and start containers:
```bash
# Build containers
docker-compose build --no-cache

# Start services
docker-compose up -d
```

2. Wait for services to start (about 1-2 minutes)

## Step 5: Initialize Database

1. Make restore script executable (Windows):
```bash
# For Windows, you don't need to run chmod
# The script will be executed inside the container where Linux commands work
```

2. Run database restore:
```bash
docker-compose exec sqlserver /opt/mssql-tools/bin/bash /restore-db.sh
```

## Step 6: Set Up DBT

1. Install DBT dependencies:
```bash
docker-compose exec dbt dbt deps
```

2. Run DBT debug to verify connection:
```bash
docker-compose exec dbt dbt debug
```

## Step 7: Set Up Airflow

1. Initialize Airflow database:
```bash
docker-compose exec airflow-webserver airflow db init
```

2. Create Airflow admin user:
```bash
docker-compose exec airflow-webserver airflow users create \
    --username admin \
    --firstname Admin \
    --lastname User \
    --role Admin \
    --email admin@example.com \
    --password admin
```

## Step 8: Verify Setup

1. Check if all containers are running:
```bash
docker-compose ps
```

2. Access Airflow UI:
   - Open browser: http://localhost:8080
   - Login with:
     - Username: admin
     - Password: admin

3. Test DBT models:
```bash
docker-compose exec dbt dbt run
```

## Common Issues and Solutions

1. **Port Conflicts**
   - If ports 8080, 1433, or 5432 are in use:
   - Stop other services using these ports
   - Or modify ports in docker-compose.yml

2. **Permission Issues**
   - Run PowerShell as Administrator
   - Re-run permission commands:
     ```bash
     icacls * /reset
     icacls * /grant Everyone:F /t
     ```

3. **Database Connection Issues**
   - Check if SQL Server is running:
     ```bash
     docker-compose ps sqlserver
     ```
   - Verify database restore:
     ```bash
     docker-compose exec sqlserver /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P YourStrongPassword1! -Q "SELECT name FROM sys.databases"
     ```

4. **Docker Issues**
   - If containers won't start:
     ```bash
     docker-compose down -v
     docker system prune -a
     docker-compose up -d
     ```

5. **Command Not Found Errors**
   - If you see errors like `chmod: command not found`:
     - These commands are meant to run inside Linux containers, not on Windows
     - Skip any Linux-specific commands when running on Windows
     - Use the Docker commands that execute these inside the containers

## Need Help?

If you encounter any issues:
1. Check container logs:
```bash
docker-compose logs
```

2. Verify each service:
```bash
# Check SQL Server
docker-compose exec sqlserver /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P YourStrong@Passw0rd -Q "SELECT @@VERSION"

# Check DBT
docker-compose exec dbt dbt debug

# Check Airflow
docker-compose exec airflow-webserver airflow version
```

3. Common commands for troubleshooting:
```bash
# Restart a specific service
docker-compose restart [service_name]

# View logs for a specific service
docker-compose logs [service_name]

# Rebuild a specific service
docker-compose build [service_name]
``` 