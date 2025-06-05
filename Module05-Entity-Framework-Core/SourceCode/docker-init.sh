#!/bin/bash
# Script to initialize databases after SQL Server starts

echo "Waiting for SQL Server to start..."
sleep 30

echo "Running database migrations..."
docker exec efcore-demo-api dotnet ef database update --context ProductCatalogContext
docker exec efcore-demo-api dotnet ef database update --context BookStoreContext

echo "Database initialization complete!"