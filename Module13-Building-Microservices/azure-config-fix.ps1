#!/usr/bin/env pwsh

# Quick fix for Module 13 Azure configuration issue

Write-Host "🔧 Fixing Azure configuration for Module 13..." -ForegroundColor Cyan

# Check if we're in the right directory
if (-not (Test-Path "AzureECommerce")) {
    Write-Host "❌ AzureECommerce directory not found!" -ForegroundColor Red
    Write-Host "Please run this script from the Module13-Building-Microservices directory." -ForegroundColor Yellow
    exit 1
}

Set-Location AzureECommerce

# Check if setup-azure.ps1 exists
if (Test-Path "setup-azure.ps1") {
    Write-Host "✅ Found setup-azure.ps1" -ForegroundColor Green
    
    # Check if azure-config.ps1 already exists
    if (Test-Path "azure-config.ps1") {
        Write-Host "✅ azure-config.ps1 already exists" -ForegroundColor Green
    } else {
        Write-Host "⚠️  azure-config.ps1 not found. You need to run the setup script." -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Please run the following commands:" -ForegroundColor Cyan
        Write-Host "  cd AzureECommerce" -ForegroundColor White
        Write-Host "  .\setup-azure.ps1" -ForegroundColor White
        Write-Host ""
        Write-Host "This will create your Azure resources and generate azure-config.ps1" -ForegroundColor Yellow
        Write-Host ""
        
        $runNow = Read-Host "Do you want to run setup-azure.ps1 now? (Y/n)"
        if ($runNow -ne 'n' -and $runNow -ne 'N') {
            Write-Host "Running Azure setup..." -ForegroundColor Yellow
            & .\setup-azure.ps1
            
            if (Test-Path "azure-config.ps1") {
                Write-Host "✅ Azure configuration created successfully!" -ForegroundColor Green
                Write-Host "You can now run exercise03 or any other exercise." -ForegroundColor Cyan
            }
        }
    }
} else {
    Write-Host "❌ setup-azure.ps1 not found!" -ForegroundColor Red
    Write-Host "It looks like exercise01 wasn't completed properly." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Please run:" -ForegroundColor Cyan
    Write-Host "  .\launch-exercises.ps1 exercise01" -ForegroundColor White
    Write-Host ""
    Write-Host "Then run the setup-azure.ps1 script that gets created." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "📋 Summary:" -ForegroundColor Cyan
Write-Host "1. Exercise01 creates setup-azure.ps1" -ForegroundColor White
Write-Host "2. You must run setup-azure.ps1 to create Azure resources" -ForegroundColor White
Write-Host "3. setup-azure.ps1 creates azure-config.ps1 with your resource names" -ForegroundColor White
Write-Host "4. Other exercises use azure-config.ps1 to know your Azure resources" -ForegroundColor White