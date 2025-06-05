#!/bin/bash
# Script to initialize the debugging demo database

echo "Waiting for SQL Server to start..."
sleep 30

echo "Creating database..."
docker exec debugging-sqlserver /opt/mssql-tools/bin/sqlcmd \
  -S localhost -U sa -P 'YourStrong@Passw0rd123' \
  -Q "CREATE DATABASE DebuggingDemoDB"

echo "Database initialization complete!"
echo "You can now access:"
echo "  - API: http://localhost:5004"
echo "  - Health Checks UI: http://localhost:5005"
echo "  - Swagger: http://localhost:5004/swagger"