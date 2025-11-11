#!/bin/bash

# Wait for SQL Server to be ready
echo "Waiting for SQL Server to be ready..."
sleep 30s

# Set variables
SERVER="localhost"
USER="sa"
PASSWORD="YourStrongPassword1!"
DATABASE="AdventureWorks"

# Create database if it doesn't exist
/opt/mssql-tools/bin/sqlcmd -S $SERVER -U $USER -P YourStrongPassword1! -Q "IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = '${DATABASE}') CREATE DATABASE ${DATABASE}"

# Check if backup file exists
if [ -f "/tmp/opt/mssql/backup/AdventureWorks2019.bak" ]; then
    echo "Restoring database from backup..."
    
    # Restore database from backup
    /opt/mssql-tools/bin/sqlcmd -S $SERVER -U $USER -P YourStrongPassword1! -Q "
    RESTORE DATABASE ${DATABASE} 
    FROM DISK = '/var/opt/mssql/backup/AdventureWorks2019.bak'
    WITH MOVE 'AdventureWorks2017' TO '/var/opt/mssql/data/${DATABASE}.mdf',
    MOVE 'AdventureWorks2017_log' TO '/var/opt/mssql/data/${DATABASE}_log.ldf',
    REPLACE"
else
    echo "Backup file not found. Please ensure AdventureWorks2019.bak is in the correct location."
    exit 1
fi

# Verify database restoration
/opt/mssql-tools/bin/sqlcmd -S $SERVER -U $USER -P YourStrongPassword1! -Q "SELECT name FROM sys.databases WHERE name = '${DATABASE}'"

echo "Database restoration completed!" 