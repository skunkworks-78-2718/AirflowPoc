#!/bin/bash

# Download AdventureWorks database backup
wget https://github.com/Microsoft/sql-server-samples/releases/download/adventureworks/AdventureWorks2019.bak -O /tmp/AdventureWorks2019.bak

# Restore the database
/opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P YourStrongPassword1! -Q "RESTORE DATABASE AdventureWorks2019 FROM DISK = '/tmp/AdventureWorks2019.bak' WITH MOVE 'AdventureWorks2019' TO '/var/opt/mssql/data/AdventureWorks2019.mdf', MOVE 'AdventureWorks2019_log' TO '/var/opt/mssql/data/AdventureWorks2019_log.ldf'"

# Clean up
rm /tmp/AdventureWorks2019.bak 