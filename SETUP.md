# Step-by-Step Setup Guide for DBT Airflow Project

## Prerequisites Installation

1. **Install Docker Desktop**:
   - Windows: Download and install from [Docker Desktop for Windows](https://www.docker.com/products/docker-desktop)
   - Mac: Download and install from [Docker Desktop for Mac](https://www.docker.com/products/docker-desktop)
   - Linux: Follow [Docker Engine installation](https://docs.docker.com/engine/install/)

2. **Verify Docker Installation**:
```bash
# Check Docker version
docker --version

# Check Docker Compose version
docker-compose --version
```

## Project Setup

1. **Clone/Copy Project**:
```bash
# Create a new directory
mkdir dbt_airflow_project
cd dbt_airflow_project

# Copy all project files into this directory
# Ensure you have these essential directories:
# - airflow/
# - dbt/
# - docker-compose.yml
```

2. **Set File Permissions**:
```bash
# For Windows (in PowerShell as Administrator):
icacls * /reset
icacls * /grant Everyone:F /t

# For Mac/Linux:
chmod -R 755 ./dbt
chmod -R 755 ./airflow
chmod 644 docker-compose.yml
```

3. **Clean Docker Environment**:
```bash
# Remove all containers and volumes
docker-compose down -v

# Clean Docker system
docker system prune -a

# Remove all volumes
docker volume prune
```

4. **Environment Setup**:
```bash
# Create necessary directories if they don't exist
mkdir -p ./airflow/logs
mkdir -p ./airflow/plugins
mkdir -p ./dbt/logs

# Copy example env file (if provided)
cp .env.example .env
```

## Building and Starting Services

1. **Build Containers**:
```bash
# Build without cache
docker-compose build --no-cache
```

2. **Start Services**:
```bash
# Start all services in detached mode
docker-compose up -d
```

3. **Verify Services**:
```bash
# Check if all containers are running
docker-compose ps

# Check container logs
docker-compose logs
```

## Post-Installation Setup

1. **Initialize DBT**:
```bash
# Install DBT dependencies
docker-compose exec dbt dbt deps

# Run DBT debug to verify connection
docker-compose exec dbt dbt debug
```

2. **Setup Airflow**:
```bash
# Initialize Airflow DB
docker-compose exec airflow-webserver airflow db init

# Create Airflow admin user
docker-compose exec airflow-webserver airflow users create \
    --username admin \
    --firstname Admin \
    --lastname User \
    --role Admin \
    --email admin@example.com \
    --password admin
```

## Verify Installation

1. **Access Airflow UI**:
   - Open browser: http://localhost:8080
   - Login with:
     - Username: admin
     - Password: admin

2. **Verify DBT Models**:
```bash
# List all DBT models
docker-compose exec dbt dbt ls

# Run DBT models
docker-compose exec dbt dbt run

# Run DBT tests
docker-compose exec dbt dbt test
```

## Common Issues and Solutions

1. **Permission Issues**:
```bash
# If you see permission errors, run:
sudo chown -R $USER:$USER .
chmod -R u+rwx .
```

2. **Port Conflicts**:
   - Check if ports 8080, 1433, or 5432 are in use
   - Modify docker-compose.yml if needed

3. **Memory Issues**:
   - Ensure Docker has at least 4GB RAM allocated
   - In Docker Desktop: Settings → Resources → Memory

4. **Cache Issues**:
```bash
# If you see cache-related errors:
docker builder prune
docker-compose build --no-cache
```

## Project Structure Verification

Ensure you have all required files:
```
dbt_airflow_project/
├── airflow/
│   ├── dags/
│   │   └── dbt_dag.py
│   └── logs/
├── dbt/
│   ├── models/
│   │   ├── staging/
│   │   └── marts/
│   ├── dbt_project.yml
│   ├── packages.yml
│   └── profiles.yml
└── docker-compose.yml
```

## Testing the Setup

1. **Test DBT Connection**:
```bash
docker-compose exec dbt dbt debug
```

2. **Test Airflow DAG**:
```bash
# List DAGs
docker-compose exec airflow-webserver airflow dags list

# Test DBT DAG
docker-compose exec airflow-webserver airflow dags test dbt_transform
```

3. **Test Database Connections**:
```bash
# Test SQL Server connection
docker-compose exec sqlserver /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P YourStrong@Passw0rd -Q "SELECT @@VERSION"
```

## Maintenance

1. **Regular Cleanup**:
```bash
# Remove unused Docker resources
docker system prune

# Clean Airflow logs
docker-compose exec airflow-webserver airflow tasks clear dbt_transform
```

2. **Backup Important Files**:
   - dbt/models/
   - airflow/dags/
   - docker-compose.yml
   - .env (if exists)

## Support

If you encounter issues:
1. Check container logs: `docker-compose logs`
2. Verify file permissions
3. Ensure all required ports are available
4. Check Docker resource allocation

## Next Steps

After successful installation:
1. Review the README.md for project details
2. Check docker_commands.md for useful commands
3. Start developing your DBT models
4. Configure Airflow DAGs as needed 