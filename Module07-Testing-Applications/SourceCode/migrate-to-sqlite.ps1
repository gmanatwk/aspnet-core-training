#!/usr/bin/env pwsh

# Migration script to set up SQLite database
Write-Host "Setting up SQLite database for ProductCatalog API..." -ForegroundColor Cyan

# Navigate to API project
Set-Location ProductCatalog.API

# Remove any existing migrations for SQL Server
if (Test-Path "Migrations") {
    Write-Host "Removing old migrations..." -ForegroundColor Yellow
    Remove-Item -Path "Migrations" -Recurse -Force
}

# Create new migration for SQLite
Write-Host "Creating SQLite migration..." -ForegroundColor Green
dotnet ef migrations add InitialCreate

# Apply migration
Write-Host "Applying migration to create database..." -ForegroundColor Green
dotnet ef database update

Write-Host "✅ SQLite database setup complete!" -ForegroundColor Green
Write-Host "Database file created: products.db" -ForegroundColor Cyan