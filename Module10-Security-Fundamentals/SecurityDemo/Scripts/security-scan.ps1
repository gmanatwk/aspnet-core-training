#!/usr/bin/env pwsh

# Security Scanning Script for ASP.NET Core Application
param(
    [Parameter(Mandatory=$false)]
    [string]$TargetUrl = "https://localhost:5001",

    [Parameter(Mandatory=$false)]
    [string]$ReportPath = "security-report.html"
)

Write-Host "🔍 Starting security scan of $TargetUrl" -ForegroundColor Cyan

# Check if OWASP ZAP is available
if (Get-Command zap-baseline.py -ErrorAction SilentlyContinue) {
    Write-Host "Running OWASP ZAP baseline scan..." -ForegroundColor Yellow
    zap-baseline.py -t $TargetUrl -r $ReportPath
} else {
    Write-Warning "OWASP ZAP not found. Install from: https://www.zaproxy.org/"
}

# Basic security checks
Write-Host "Performing basic security checks..." -ForegroundColor Yellow

# Check SSL/TLS configuration
try {
    $response = Invoke-WebRequest -Uri $TargetUrl -Method HEAD -SkipCertificateCheck
    Write-Host "✅ Application is accessible" -ForegroundColor Green

    # Check security headers
    $headers = $response.Headers
    $securityHeaders = @(
        "Strict-Transport-Security",
        "Content-Security-Policy",
        "X-Frame-Options",
        "X-Content-Type-Options"
    )

    foreach ($header in $securityHeaders) {
        if ($headers.ContainsKey($header)) {
            Write-Host "✅ $header header present" -ForegroundColor Green
        } else {
            Write-Host "❌ $header header missing" -ForegroundColor Red
        }
    }
} catch {
    Write-Error "Failed to connect to $TargetUrl"
}

Write-Host "🔍 Security scan completed!" -ForegroundColor Green
Write-Host "📄 Report saved to: $ReportPath" -ForegroundColor Cyan
