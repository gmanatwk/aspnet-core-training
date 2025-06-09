# PowerShell script to start the SSR vs CSR demonstration
# This script starts all three applications needed for the demo

param(
    [switch]$SkipInstall,
    [switch]$ApiOnly,
    [switch]$Help
)

if ($Help) {
    Write-Host "SSR vs CSR Demo Startup Script" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Usage: .\start-ssr-demo.ps1 [options]" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Options:" -ForegroundColor Green
    Write-Host "  -SkipInstall    Skip npm install steps"
    Write-Host "  -ApiOnly        Start only the ASP.NET Core API"
    Write-Host "  -Help           Show this help message"
    Write-Host ""
    Write-Host "This script will start:" -ForegroundColor Cyan
    Write-Host "  1. ASP.NET Core API (Port 5000)"
    Write-Host "  2. React SPA - CSR (Port 5173)"
    Write-Host "  3. Next.js SSR (Port 3001)"
    Write-Host ""
    exit 0
}

Write-Host "🚀 Starting SSR vs CSR Demonstration" -ForegroundColor Magenta
Write-Host "=" * 50 -ForegroundColor Cyan

# Function to check if a port is in use
function Test-Port {
    param([int]$Port)
    try {
        $connection = New-Object System.Net.Sockets.TcpClient
        $connection.Connect("localhost", $Port)
        $connection.Close()
        return $true
    }
    catch {
        return $false
    }
}

# Check prerequisites
Write-Host "🔍 Checking prerequisites..." -ForegroundColor Yellow

# Check .NET
try {
    $dotnetVersion = dotnet --version
    Write-Host "✅ .NET SDK: $dotnetVersion" -ForegroundColor Green
}
catch {
    Write-Host "❌ .NET SDK not found. Please install .NET 8.0 SDK" -ForegroundColor Red
    exit 1
}

# Check Node.js
try {
    $nodeVersion = node --version
    Write-Host "✅ Node.js: $nodeVersion" -ForegroundColor Green
}
catch {
    Write-Host "❌ Node.js not found. Please install Node.js 18+" -ForegroundColor Red
    exit 1
}

# Check for port conflicts
$ports = @(5000, 5173, 3001)
$conflicts = @()

foreach ($port in $ports) {
    if (Test-Port $port) {
        $conflicts += $port
    }
}

if ($conflicts.Count -gt 0) {
    Write-Host "⚠️  Port conflicts detected: $($conflicts -join ', ')" -ForegroundColor Yellow
    Write-Host "Please stop applications using these ports or they will fail to start." -ForegroundColor Yellow
    Write-Host ""
}

# Install dependencies if not skipped
if (-not $SkipInstall) {
    Write-Host "📦 Installing dependencies..." -ForegroundColor Yellow
    
    # Install React SPA dependencies
    if (Test-Path "ClientApp/package.json") {
        Write-Host "Installing React SPA dependencies..." -ForegroundColor Cyan
        Set-Location "ClientApp"
        npm install
        Set-Location ".."
    }
    
    # Install Next.js dependencies
    if (Test-Path "NextJsApp/package.json") {
        Write-Host "Installing Next.js dependencies..." -ForegroundColor Cyan
        Set-Location "NextJsApp"
        npm install
        Set-Location ".."
    }
    
    Write-Host "✅ Dependencies installed" -ForegroundColor Green
}

Write-Host ""
Write-Host "🎯 Starting applications..." -ForegroundColor Yellow

# Start ASP.NET Core API
Write-Host "Starting ASP.NET Core API (Port 5000)..." -ForegroundColor Cyan
$apiJob = Start-Job -ScriptBlock {
    Set-Location $using:PWD
    dotnet run --urls "http://localhost:5000"
}

Start-Sleep -Seconds 3

if ($ApiOnly) {
    Write-Host "✅ API started successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "🌐 Access Points:" -ForegroundColor Cyan
    Write-Host "  API: http://localhost:5000" -ForegroundColor White
    Write-Host "  Swagger: http://localhost:5000/swagger" -ForegroundColor White
    Write-Host ""
    Write-Host "Press Ctrl+C to stop the API" -ForegroundColor Yellow
    
    try {
        Wait-Job $apiJob
    }
    finally {
        Stop-Job $apiJob -ErrorAction SilentlyContinue
        Remove-Job $apiJob -ErrorAction SilentlyContinue
    }
    exit 0
}

# Start React SPA (CSR)
Write-Host "Starting React SPA - CSR (Port 5173)..." -ForegroundColor Cyan
$reactJob = Start-Job -ScriptBlock {
    Set-Location $using:PWD
    Set-Location "ClientApp"
    npm run dev
}

Start-Sleep -Seconds 2

# Start Next.js SSR
Write-Host "Starting Next.js SSR (Port 3001)..." -ForegroundColor Cyan
$nextJob = Start-Job -ScriptBlock {
    Set-Location $using:PWD
    Set-Location "NextJsApp"
    npm run dev
}

Start-Sleep -Seconds 5

Write-Host ""
Write-Host "🎉 All applications started!" -ForegroundColor Green
Write-Host "=" * 50 -ForegroundColor Cyan
Write-Host ""
Write-Host "🌐 Access Points:" -ForegroundColor Cyan
Write-Host "  📊 ASP.NET Core API: http://localhost:5000" -ForegroundColor White
Write-Host "  📚 API Documentation: http://localhost:5000/swagger" -ForegroundColor White
Write-Host "  💻 React SPA (CSR): http://localhost:5173" -ForegroundColor Yellow
Write-Host "  🚀 Next.js SSR: http://localhost:3001" -ForegroundColor Blue
Write-Host ""
Write-Host "🎓 Teaching Demonstrations:" -ForegroundColor Magenta
Write-Host "  1. Compare initial loading (throttle network to Slow 3G)" -ForegroundColor White
Write-Host "  2. View page source (Right-click → View Page Source)" -ForegroundColor White
Write-Host "  3. Disable JavaScript (DevTools → Settings → Disable JS)" -ForegroundColor White
Write-Host "  4. Run Lighthouse audits on both applications" -ForegroundColor White
Write-Host ""
Write-Host "📖 For detailed teaching guide, see: SSR-vs-CSR-TEACHING-GUIDE.md" -ForegroundColor Cyan
Write-Host ""
Write-Host "Press Ctrl+C to stop all applications" -ForegroundColor Yellow

try {
    # Wait for any job to complete (which means one failed)
    Wait-Job $apiJob, $reactJob, $nextJob -Any
}
finally {
    Write-Host ""
    Write-Host "🛑 Stopping all applications..." -ForegroundColor Yellow
    
    Stop-Job $apiJob, $reactJob, $nextJob -ErrorAction SilentlyContinue
    Remove-Job $apiJob, $reactJob, $nextJob -ErrorAction SilentlyContinue
    
    Write-Host "✅ All applications stopped" -ForegroundColor Green
}
