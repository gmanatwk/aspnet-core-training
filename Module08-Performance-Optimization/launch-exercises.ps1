# Module 8 Interactive Exercise Launcher - PowerShell Version
# Performance Optimization

param(
    [Parameter(Mandatory=$false)]
    [string]$ExerciseName,
    
    [Parameter(Mandatory=$false)]
    [switch]$List,
    
    [Parameter(Mandatory=$false)]
    [switch]$Auto,
    
    [Parameter(Mandatory=$false)]
    [switch]$Preview
)

# Set error action preference
$ErrorActionPreference = "Stop"

# Interactive mode flag
$InteractiveMode = -not $Auto

# Function to pause and wait for user
function Wait-ForUser {
    if ($InteractiveMode) {
        Write-Host "Press Enter to continue..." -ForegroundColor Yellow
        Read-Host
    }
}

# Function to show what will be created
function Show-FilePreview {
    param(
        [string]$FilePath,
        [string]$Description
    )
    
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host "[FILE] Will create: $FilePath" -ForegroundColor Blue
    Write-Host "[INFO] Purpose: $Description" -ForegroundColor Yellow
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
}

# Function to create file with preview
function New-FileInteractive {
    param(
        [string]$FilePath,
        [string]$Content,
        [string]$Description
    )
    
    Show-FilePreview -FilePath $FilePath -Description $Description
    
    # Show first 20 lines of content
    Write-Host "Content preview:" -ForegroundColor Green
    $ContentLines = $Content -split "`n"
    $PreviewLines = $ContentLines | Select-Object -First 20
    $PreviewLines | ForEach-Object { Write-Host $_ }
    
    if ($ContentLines.Count -gt 20) {
        Write-Host "... (content truncated for preview)" -ForegroundColor Yellow
    }
    Write-Host ""
    
    if ($InteractiveMode) {
        $Response = Read-Host "Create this file? (Y/n/s to skip all)"
        
        switch ($Response.ToLower()) {
            "n" {
                Write-Host "[SKIP] Skipped: $FilePath" -ForegroundColor Red
                return
            }
            "s" {
                $script:InteractiveMode = $false
                Write-Host "📌 Switching to automatic mode..." -ForegroundColor Cyan
            }
        }
    }
    
    # Create directory if it doesn't exist
    $Directory = Split-Path -Path $FilePath -Parent
    if ($Directory -and -not (Test-Path -Path $Directory)) {
        New-Item -ItemType Directory -Path $Directory -Force | Out-Null
    }
    
    # Write content to file
    $Content | Out-File -FilePath $FilePath -Encoding UTF8
    Write-Host "✅ Created: $FilePath" -ForegroundColor Green
    Write-Host ""
}

# Function to show learning objectives
function Show-LearningObjectives {
    param([string]$Exercise)
    
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Magenta
    Write-Host "🎯 Learning Objectives" -ForegroundColor Magenta
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Magenta
    
    switch ($Exercise) {
        "exercise01" {
            Write-Host "In this exercise, you will learn:" -ForegroundColor Cyan
            Write-Host "  🚀 1. Implementing in-memory and distributed caching strategies" -ForegroundColor White
            Write-Host "  🚀 2. Response caching and output caching techniques" -ForegroundColor White
            Write-Host "  🚀 3. Cache invalidation and expiration policies" -ForegroundColor White
            Write-Host "  🚀 4. Redis integration for distributed scenarios" -ForegroundColor White
            Write-Host ""
            Write-Host "Key caching concepts:" -ForegroundColor Yellow
            Write-Host "  • Memory cache vs distributed cache" -ForegroundColor White
            Write-Host "  • Cache-aside and write-through patterns" -ForegroundColor White
            Write-Host "  • Cache key design and naming strategies" -ForegroundColor White
            Write-Host "  • Performance monitoring and metrics" -ForegroundColor White
        }
        "exercise02" {
            Write-Host "Building on Exercise 1, you will add:" -ForegroundColor Cyan
            Write-Host "  📊 1. Database query optimization techniques" -ForegroundColor White
            Write-Host "  📊 2. Entity Framework performance tuning" -ForegroundColor White
            Write-Host "  📊 3. Connection pooling and query batching" -ForegroundColor White
            Write-Host "  📊 4. Database indexing strategies" -ForegroundColor White
            Write-Host ""
            Write-Host "Database optimization:" -ForegroundColor Yellow
            Write-Host "  • Query execution plan analysis" -ForegroundColor White
            Write-Host "  • N+1 query problem solutions" -ForegroundColor White
            Write-Host "  • Lazy vs eager loading strategies" -ForegroundColor White
            Write-Host "  • Database connection management" -ForegroundColor White
        }
        "exercise03" {
            Write-Host "Advanced performance patterns:" -ForegroundColor Cyan
            Write-Host "  ⚡ 1. Asynchronous programming best practices" -ForegroundColor White
            Write-Host "  ⚡ 2. Memory management and garbage collection" -ForegroundColor White
            Write-Host "  ⚡ 3. CPU-bound vs I/O-bound optimization" -ForegroundColor White
            Write-Host "  ⚡ 4. Parallel processing and Task optimization" -ForegroundColor White
            Write-Host ""
            Write-Host "Performance concepts:" -ForegroundColor Yellow
            Write-Host "  • Thread pool optimization" -ForegroundColor White
            Write-Host "  • Memory allocation patterns" -ForegroundColor White
            Write-Host "  • Async/await performance implications" -ForegroundColor White
            Write-Host "  • Resource pooling strategies" -ForegroundColor White
        }
        "exercise04" {
            Write-Host "Monitoring and profiling:" -ForegroundColor Cyan
            Write-Host "  📈 1. Application performance monitoring (APM)" -ForegroundColor White
            Write-Host "  📈 2. Custom metrics and telemetry" -ForegroundColor White
            Write-Host "  📈 3. Performance profiling tools" -ForegroundColor White
            Write-Host "  📈 4. Load testing and capacity planning" -ForegroundColor White
            Write-Host ""
            Write-Host "Monitoring tools:" -ForegroundColor Yellow
            Write-Host "  • Built-in .NET performance counters" -ForegroundColor White
            Write-Host "  • Custom metrics with EventCounters" -ForegroundColor White
            Write-Host "  • Memory and CPU profiling" -ForegroundColor White
            Write-Host "  • Distributed tracing patterns" -ForegroundColor White
        }
    }
    
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Magenta
    Wait-ForUser
}

# Function to show what will be created overview
function Show-CreationOverview {
    param([string]$Exercise)
    
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host "📋 Overview: What will be created" -ForegroundColor Cyan
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    
    switch ($Exercise) {
        "exercise01" {
            Write-Host "🎯 Exercise 01: Caching Implementation" -ForegroundColor Green
            Write-Host ""
            Write-Host "📋 What you'll build:" -ForegroundColor Yellow
            Write-Host "  ✅ High-performance API with multiple caching layers" -ForegroundColor White
            Write-Host "  ✅ In-memory caching with IMemoryCache" -ForegroundColor White
            Write-Host "  ✅ Distributed caching with Redis" -ForegroundColor White
            Write-Host "  ✅ Response caching and output caching" -ForegroundColor White
            Write-Host ""
            Write-Host "🚀 RECOMMENDED: Use the Complete Working Example" -ForegroundColor Blue
            Write-Host "  Set-Location SourceCode\PerformanceDemo; dotnet run" -ForegroundColor Cyan
            Write-Host "  Then visit: http://localhost:5000 for performance testing" -ForegroundColor Cyan
            Write-Host ""
            Write-Host "📁 Template Structure:" -ForegroundColor Green
            Write-Host "  PerformanceDemo/" -ForegroundColor White
            Write-Host "  ├── Controllers/" -ForegroundColor White
            Write-Host "  │   ├── ProductsController.cs   # Cached API endpoints" -ForegroundColor Yellow
            Write-Host "  │   └── CacheController.cs      # Cache management" -ForegroundColor Yellow
            Write-Host "  ├── Services/" -ForegroundColor White
            Write-Host "  │   ├── CacheService.cs         # Caching abstraction" -ForegroundColor Yellow
            Write-Host "  │   └── ProductService.cs       # Business logic" -ForegroundColor Yellow
            Write-Host "  ├── Middleware/" -ForegroundColor White
            Write-Host "  │   └── ResponseCacheMiddleware.cs # Custom caching" -ForegroundColor Yellow
            Write-Host "  └── docker-compose.yml          # Redis setup" -ForegroundColor Yellow
        }
        "exercise02" {
            Write-Host "🎯 Exercise 02: Database Optimization" -ForegroundColor Green
            Write-Host ""
            Write-Host "📋 Building on Exercise 1:" -ForegroundColor Yellow
            Write-Host "  ✅ Entity Framework performance tuning" -ForegroundColor White
            Write-Host "  ✅ Query optimization and indexing" -ForegroundColor White
            Write-Host "  ✅ Connection pooling configuration" -ForegroundColor White
            Write-Host "  ✅ Database performance monitoring" -ForegroundColor White
        }
        "exercise03" {
            Write-Host "🎯 Exercise 03: Async and Memory Optimization" -ForegroundColor Green
            Write-Host ""
            Write-Host "📋 Advanced performance patterns:" -ForegroundColor Yellow
            Write-Host "  ✅ Asynchronous programming optimization" -ForegroundColor White
            Write-Host "  ✅ Memory management and pooling" -ForegroundColor White
            Write-Host "  ✅ CPU-bound task optimization" -ForegroundColor White
            Write-Host "  ✅ Resource pooling implementations" -ForegroundColor White
        }
        "exercise04" {
            Write-Host "🎯 Exercise 04: Monitoring and Profiling" -ForegroundColor Green
            Write-Host ""
            Write-Host "📋 Performance monitoring tools:" -ForegroundColor Yellow
            Write-Host "  ✅ Application Performance Monitoring (APM)" -ForegroundColor White
            Write-Host "  ✅ Custom metrics and telemetry" -ForegroundColor White
            Write-Host "  ✅ Performance profiling integration" -ForegroundColor White
            Write-Host "  ✅ Load testing and benchmarking" -ForegroundColor White
        }
    }
    
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Wait-ForUser
}

# Function to explain a concept
function Show-Concept {
    param(
        [string]$ConceptName,
        [string]$Explanation
    )
    
    Write-Host "💡 Concept: $ConceptName" -ForegroundColor Magenta
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host $Explanation -ForegroundColor White
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Wait-ForUser
}

# Function to show available exercises
function Show-Exercises {
    Write-Host "Module 8 - Performance Optimization" -ForegroundColor Cyan
    Write-Host "Available Exercises:" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  - exercise01: Caching Implementation" -ForegroundColor White
    Write-Host "  - exercise02: Database Optimization" -ForegroundColor White
    Write-Host "  - exercise03: Async and Memory Optimization" -ForegroundColor White
    Write-Host "  - exercise04: Monitoring and Profiling" -ForegroundColor White
    Write-Host ""
    Write-Host "Usage:" -ForegroundColor White
    Write-Host "  .\launch-exercises.ps1 <exercise-name> [options]" -ForegroundColor White
    Write-Host ""
    Write-Host "Options:" -ForegroundColor White
    Write-Host "  -List           Show all available exercises" -ForegroundColor White
    Write-Host "  -Auto           Skip interactive mode" -ForegroundColor White
    Write-Host "  -Preview        Show what will be created without creating" -ForegroundColor White
}

# Main script logic
if ($List) {
    Show-Exercises
    exit 0
}

if (-not $ExerciseName) {
    Write-Host "❌ Usage: .\launch-exercises.ps1 <exercise-name> [options]" -ForegroundColor Red
    Write-Host ""
    Show-Exercises
    exit 1
}

$ProjectName = "PerformanceDemo"

# Validate exercise name
$ValidExercises = @("exercise01", "exercise02", "exercise03", "exercise04")
if ($ExerciseName -notin $ValidExercises) {
    Write-Host "❌ Unknown exercise: $ExerciseName" -ForegroundColor Red
    Write-Host ""
    Show-Exercises
    exit 1
}

# Welcome screen
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Magenta
Write-Host "🚀 Module 8: Performance Optimization" -ForegroundColor Magenta
Write-Host "Exercise: $ExerciseName" -ForegroundColor Magenta
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Magenta
Write-Host ""

# Show the recommended approach
Write-Host "🎯 RECOMMENDED APPROACH:" -ForegroundColor Green
Write-Host "For the best learning experience, use the complete working implementation:" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Use the working source code:" -ForegroundColor Yellow
Write-Host "   Set-Location SourceCode\PerformanceDemo" -ForegroundColor Cyan
Write-Host "   dotnet run" -ForegroundColor Cyan
Write-Host "   # Visit: http://localhost:5000 for performance testing" -ForegroundColor Cyan
Write-Host ""
Write-Host "2. Or use Docker for complete setup with Redis:" -ForegroundColor Yellow
Write-Host "   Set-Location SourceCode" -ForegroundColor Cyan
Write-Host "   docker-compose up --build" -ForegroundColor Cyan
Write-Host "   # Includes Redis, monitoring, and load testing tools" -ForegroundColor Cyan
Write-Host ""
Write-Host "⚠️  The template created by this script is basic and may not match" -ForegroundColor Yellow
Write-Host "   all exercise requirements. The SourceCode version is complete!" -ForegroundColor Yellow
Write-Host ""

if ($InteractiveMode) {
    Write-Host "🎮 Interactive Mode: ON" -ForegroundColor Yellow
    Write-Host "You'll see what each file does before it's created" -ForegroundColor Cyan
} else {
    Write-Host "⚡ Automatic Mode: ON" -ForegroundColor Yellow
}

Write-Host ""
$Response = Read-Host "Continue with template creation? (y/N)"
if ($Response -notmatch "^[Yy]$") {
    Write-Host "💡 Great choice! Use the SourceCode version for the best experience." -ForegroundColor Cyan
    exit 0
}

# Show learning objectives
Show-LearningObjectives -Exercise $ExerciseName

# Show creation overview
Show-CreationOverview -Exercise $ExerciseName

if ($Preview) {
    Write-Host "🔍 Preview mode - no files will be created" -ForegroundColor Yellow
    exit 0
}

# Check if project exists in current directory
$SkipProjectCreation = $false
if (Test-Path $ProjectName) {
    if ($ExerciseName -eq "exercise02" -or $ExerciseName -eq "exercise03" -or $ExerciseName -eq "exercise04") {
        Write-Host "✅ Found existing $ProjectName from previous exercise" -ForegroundColor Green
        Write-Host "🔧 This exercise will build on your existing work" -ForegroundColor Cyan
        Set-Location $ProjectName
        $SkipProjectCreation = $true
    } else {
        Write-Host "⚠️ Project '$ProjectName' already exists!" -ForegroundColor Yellow
        $Response = Read-Host "Do you want to overwrite it? (y/N)"
        if ($Response -notmatch "^[Yy]$") {
            exit 1
        }
        Remove-Item -Path $ProjectName -Recurse -Force
        $SkipProjectCreation = $false
    }
} else {
    $SkipProjectCreation = $false
}

# Exercise-specific implementation
switch ($ExerciseName) {
    "exercise01" {
        # Exercise 1: Caching Implementation

        Show-Concept -ConceptName "Performance Optimization with Caching" -Explanation @"
Caching is one of the most effective performance optimization techniques:
• In-Memory Caching: Fast access to frequently used data
• Distributed Caching: Shared cache across multiple instances
• Response Caching: Cache entire HTTP responses
• Output Caching: Cache rendered content
• Cache-Aside Pattern: Load data on cache miss
• Write-Through Pattern: Update cache and data store simultaneously
"@

        if (-not $SkipProjectCreation) {
            Write-Host "🏗️ Creating high-performance API with caching..." -ForegroundColor Cyan

            # Create project directory
            New-Item -ItemType Directory -Name $ProjectName -Force
            Set-Location $ProjectName

            # Create solution and API project
            dotnet new sln -n $ProjectName
            dotnet new webapi -n "$ProjectName.API" --framework net8.0

            Set-Location "$ProjectName.API"
            Remove-Item -Path "WeatherForecast.cs" -Force -ErrorAction SilentlyContinue
            Remove-Item -Path "Controllers/WeatherForecastController.cs" -Force -ErrorAction SilentlyContinue
            Set-Location ".."

            # Add project to solution
            dotnet sln add "$ProjectName.API"

            # Install caching packages
            Set-Location "$ProjectName.API"
            Write-Host "📦 Installing caching and performance packages..." -ForegroundColor Cyan
            dotnet add package Microsoft.Extensions.Caching.Memory
            dotnet add package Microsoft.Extensions.Caching.StackExchangeRedis
            dotnet add package StackExchange.Redis
            dotnet add package Microsoft.AspNetCore.OutputCaching
            dotnet add package Microsoft.EntityFrameworkCore.InMemory
            dotnet add package BenchmarkDotNet
            Set-Location ".."
        } else {
            # We're already in the project directory from the check above
        }

        Show-Concept -ConceptName "Cache-First Architecture" -Explanation @"
Building applications with caching as a first-class citizen:
• Cache Service Abstraction: Unified interface for different cache types
• Cache Key Strategy: Consistent and predictable key naming
• Cache Expiration Policies: Time-based and dependency-based expiration
• Cache Warming: Pre-loading frequently accessed data
• Cache Invalidation: Removing stale data efficiently
"@

        # Create Product model
        New-FileInteractive -FilePath "$ProjectName.API/Models/Product.cs" -Description "Product model optimized for caching scenarios" -Content @'
using System.ComponentModel.DataAnnotations;

namespace PerformanceDemo.API.Models;

public class Product
{
    public int Id { get; set; }

    [Required]
    [StringLength(200)]
    public string Name { get; set; } = string.Empty;

    [StringLength(2000)]
    public string Description { get; set; } = string.Empty;

    [Range(0.01, double.MaxValue)]
    public decimal Price { get; set; }

    [Range(0, int.MaxValue)]
    public int StockQuantity { get; set; }

    public string Category { get; set; } = string.Empty;

    public bool IsActive { get; set; } = true;

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public DateTime LastModified { get; set; } = DateTime.UtcNow;

    // Cache-friendly properties
    public string CacheKey => $"product:{Id}";
    public TimeSpan CacheDuration => TimeSpan.FromMinutes(15);
}
'@

        # Create cache service interface
        New-FileInteractive -FilePath "$ProjectName.API/Services/ICacheService.cs" -Description "Cache service abstraction for multiple cache providers" -Content @'
namespace PerformanceDemo.API.Services;

public interface ICacheService
{
    Task<T?> GetAsync<T>(string key) where T : class;
    Task SetAsync<T>(string key, T value, TimeSpan? expiration = null) where T : class;
    Task RemoveAsync(string key);
    Task RemoveByPatternAsync(string pattern);
    Task<bool> ExistsAsync(string key);
    Task<T> GetOrSetAsync<T>(string key, Func<Task<T>> getItem, TimeSpan? expiration = null) where T : class;
}
'@

        # Create cache service implementation
        New-FileInteractive -FilePath "$ProjectName.API/Services/CacheService.cs" -Description "Multi-layer cache service with memory and distributed caching" -Content @'
using Microsoft.Extensions.Caching.Distributed;
using Microsoft.Extensions.Caching.Memory;
using System.Text.Json;

namespace PerformanceDemo.API.Services;

public class CacheService : ICacheService
{
    private readonly IMemoryCache _memoryCache;
    private readonly IDistributedCache _distributedCache;
    private readonly ILogger<CacheService> _logger;
    private readonly JsonSerializerOptions _jsonOptions;

    public CacheService(
        IMemoryCache memoryCache,
        IDistributedCache distributedCache,
        ILogger<CacheService> logger)
    {
        _memoryCache = memoryCache;
        _distributedCache = distributedCache;
        _logger = logger;
        _jsonOptions = new JsonSerializerOptions
        {
            PropertyNamingPolicy = JsonNamingPolicy.CamelCase
        };
    }

    public async Task<T?> GetAsync<T>(string key) where T : class
    {
        // Try memory cache first (L1)
        if (_memoryCache.TryGetValue(key, out T? cachedItem))
        {
            _logger.LogDebug("Cache hit (Memory): {Key}", key);
            return cachedItem;
        }

        // Try distributed cache (L2)
        var distributedValue = await _distributedCache.GetStringAsync(key);
        if (distributedValue != null)
        {
            _logger.LogDebug("Cache hit (Distributed): {Key}", key);
            var item = JsonSerializer.Deserialize<T>(distributedValue, _jsonOptions);

            // Store in memory cache for faster access
            _memoryCache.Set(key, item, TimeSpan.FromMinutes(5));
            return item;
        }

        _logger.LogDebug("Cache miss: {Key}", key);
        return null;
    }

    public async Task SetAsync<T>(string key, T value, TimeSpan? expiration = null) where T : class
    {
        var defaultExpiration = expiration ?? TimeSpan.FromMinutes(30);

        // Set in memory cache
        _memoryCache.Set(key, value, defaultExpiration);

        // Set in distributed cache
        var serializedValue = JsonSerializer.Serialize(value, _jsonOptions);
        var options = new DistributedCacheEntryOptions
        {
            AbsoluteExpirationRelativeToNow = defaultExpiration
        };

        await _distributedCache.SetStringAsync(key, serializedValue, options);
        _logger.LogDebug("Cache set: {Key} (expires in {Expiration})", key, defaultExpiration);
    }

    public async Task RemoveAsync(string key)
    {
        _memoryCache.Remove(key);
        await _distributedCache.RemoveAsync(key);
        _logger.LogDebug("Cache removed: {Key}", key);
    }

    public async Task RemoveByPatternAsync(string pattern)
    {
        // Note: This is a simplified implementation
        // In production, you'd need a more sophisticated pattern matching
        _logger.LogWarning("Pattern-based cache removal not fully implemented: {Pattern}", pattern);
        await Task.CompletedTask;
    }

    public async Task<bool> ExistsAsync(string key)
    {
        if (_memoryCache.TryGetValue(key, out _))
            return true;

        var distributedValue = await _distributedCache.GetStringAsync(key);
        return distributedValue != null;
    }

    public async Task<T> GetOrSetAsync<T>(string key, Func<Task<T>> getItem, TimeSpan? expiration = null) where T : class
    {
        var cachedItem = await GetAsync<T>(key);
        if (cachedItem != null)
            return cachedItem;

        var item = await getItem();
        await SetAsync(key, item, expiration);
        return item;
    }
}
'@

        # Create ProductService with caching
        New-FileInteractive -FilePath "$ProjectName.API/Services/ProductService.cs" -Description "Product service with intelligent caching strategies" -Content @'
using PerformanceDemo.API.Models;

namespace PerformanceDemo.API.Services;

public interface IProductService
{
    Task<Product?> GetProductAsync(int id);
    Task<List<Product>> GetProductsAsync();
    Task<List<Product>> GetProductsByCategoryAsync(string category);
    Task<Product> CreateProductAsync(Product product);
    Task UpdateProductAsync(Product product);
    Task DeleteProductAsync(int id);
    Task<List<Product>> SearchProductsAsync(string searchTerm);
}

public class ProductService : IProductService
{
    private readonly ICacheService _cacheService;
    private readonly ILogger<ProductService> _logger;
    private static readonly List<Product> _products = GenerateProducts();

    public ProductService(ICacheService cacheService, ILogger<ProductService> logger)
    {
        _cacheService = cacheService;
        _logger = logger;
    }

    public async Task<Product?> GetProductAsync(int id)
    {
        var cacheKey = $"product:{id}";

        return await _cacheService.GetOrSetAsync(cacheKey, async () =>
        {
            _logger.LogInformation("Loading product {ProductId} from data source", id);

            // Simulate database delay
            await Task.Delay(100);

            return _products.FirstOrDefault(p => p.Id == id);
        }, TimeSpan.FromMinutes(15));
    }

    public async Task<List<Product>> GetProductsAsync()
    {
        var cacheKey = "products:all";

        return await _cacheService.GetOrSetAsync(cacheKey, async () =>
        {
            _logger.LogInformation("Loading all products from data source");

            // Simulate database delay
            await Task.Delay(200);

            return _products.Where(p => p.IsActive).ToList();
        }, TimeSpan.FromMinutes(10));
    }

    public async Task<List<Product>> GetProductsByCategoryAsync(string category)
    {
        var cacheKey = $"products:category:{category.ToLower()}";

        return await _cacheService.GetOrSetAsync(cacheKey, async () =>
        {
            _logger.LogInformation("Loading products for category {Category} from data source", category);

            // Simulate database delay
            await Task.Delay(150);

            return _products.Where(p => p.IsActive &&
                                      p.Category.Equals(category, StringComparison.OrdinalIgnoreCase))
                            .ToList();
        }, TimeSpan.FromMinutes(20));
    }

    public async Task<Product> CreateProductAsync(Product product)
    {
        product.Id = _products.Max(p => p.Id) + 1;
        product.CreatedAt = DateTime.UtcNow;
        product.LastModified = DateTime.UtcNow;

        _products.Add(product);

        // Invalidate related caches
        await _cacheService.RemoveAsync("products:all");
        await _cacheService.RemoveAsync($"products:category:{product.Category.ToLower()}");

        _logger.LogInformation("Created product {ProductId}", product.Id);
        return product;
    }

    public async Task UpdateProductAsync(Product product)
    {
        var existingProduct = _products.FirstOrDefault(p => p.Id == product.Id);
        if (existingProduct != null)
        {
            var oldCategory = existingProduct.Category;

            existingProduct.Name = product.Name;
            existingProduct.Description = product.Description;
            existingProduct.Price = product.Price;
            existingProduct.StockQuantity = product.StockQuantity;
            existingProduct.Category = product.Category;
            existingProduct.IsActive = product.IsActive;
            existingProduct.LastModified = DateTime.UtcNow;

            // Invalidate caches
            await _cacheService.RemoveAsync($"product:{product.Id}");
            await _cacheService.RemoveAsync("products:all");
            await _cacheService.RemoveAsync($"products:category:{oldCategory.ToLower()}");
            await _cacheService.RemoveAsync($"products:category:{product.Category.ToLower()}");

            _logger.LogInformation("Updated product {ProductId}", product.Id);
        }
    }

    public async Task DeleteProductAsync(int id)
    {
        var product = _products.FirstOrDefault(p => p.Id == id);
        if (product != null)
        {
            _products.Remove(product);

            // Invalidate caches
            await _cacheService.RemoveAsync($"product:{id}");
            await _cacheService.RemoveAsync("products:all");
            await _cacheService.RemoveAsync($"products:category:{product.Category.ToLower()}");

            _logger.LogInformation("Deleted product {ProductId}", id);
        }
    }

    public async Task<List<Product>> SearchProductsAsync(string searchTerm)
    {
        var cacheKey = $"products:search:{searchTerm.ToLower()}";

        return await _cacheService.GetOrSetAsync(cacheKey, async () =>
        {
            _logger.LogInformation("Searching products for term: {SearchTerm}", searchTerm);

            // Simulate search delay
            await Task.Delay(300);

            return _products.Where(p => p.IsActive &&
                                      (p.Name.Contains(searchTerm, StringComparison.OrdinalIgnoreCase) ||
                                       p.Description.Contains(searchTerm, StringComparison.OrdinalIgnoreCase)))
                            .ToList();
        }, TimeSpan.FromMinutes(5));
    }

    private static List<Product> GenerateProducts()
    {
        var categories = new[] { "Electronics", "Clothing", "Books", "Home", "Sports" };
        var products = new List<Product>();

        for (int i = 1; i <= 100; i++)
        {
            products.Add(new Product
            {
                Id = i,
                Name = $"Product {i}",
                Description = $"Description for product {i}",
                Price = Random.Shared.Next(10, 1000),
                StockQuantity = Random.Shared.Next(0, 100),
                Category = categories[Random.Shared.Next(categories.Length)],
                IsActive = true,
                CreatedAt = DateTime.UtcNow.AddDays(-Random.Shared.Next(1, 365)),
                LastModified = DateTime.UtcNow.AddDays(-Random.Shared.Next(1, 30))
            });
        }

        return products;
    }
}
'@

        # Create ProductsController with caching
        New-FileInteractive -FilePath "$ProjectName.API/Controllers/ProductsController.cs" -Description "Products API controller with response caching and output caching" -Content @'
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.OutputCaching;
using PerformanceDemo.API.Models;
using PerformanceDemo.API.Services;

namespace PerformanceDemo.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class ProductsController : ControllerBase
{
    private readonly IProductService _productService;
    private readonly ILogger<ProductsController> _logger;

    public ProductsController(IProductService productService, ILogger<ProductsController> logger)
    {
        _productService = productService;
        _logger = logger;
    }

    /// <summary>
    /// Get all products with output caching
    /// </summary>
    [HttpGet]
    [OutputCache(Duration = 300, VaryByQuery = new[] { "category" })]
    [ResponseCache(Duration = 300, Location = ResponseCacheLocation.Any)]
    public async Task<ActionResult<List<Product>>> GetProducts([FromQuery] string? category = null)
    {
        var stopwatch = System.Diagnostics.Stopwatch.StartNew();

        List<Product> products;
        if (string.IsNullOrEmpty(category))
        {
            products = await _productService.GetProductsAsync();
        }
        else
        {
            products = await _productService.GetProductsByCategoryAsync(category);
        }

        stopwatch.Stop();
        _logger.LogInformation("GetProducts completed in {ElapsedMs}ms", stopwatch.ElapsedMilliseconds);

        Response.Headers.Add("X-Response-Time", $"{stopwatch.ElapsedMilliseconds}ms");
        return Ok(products);
    }

    /// <summary>
    /// Get product by ID with output caching
    /// </summary>
    [HttpGet("{id}")]
    [OutputCache(Duration = 600, VaryByRouteValue = new[] { "id" })]
    [ResponseCache(Duration = 600, Location = ResponseCacheLocation.Any, VaryByHeader = "Accept")]
    public async Task<ActionResult<Product>> GetProduct(int id)
    {
        var stopwatch = System.Diagnostics.Stopwatch.StartNew();

        var product = await _productService.GetProductAsync(id);

        stopwatch.Stop();
        _logger.LogInformation("GetProduct({ProductId}) completed in {ElapsedMs}ms", id, stopwatch.ElapsedMilliseconds);

        if (product == null)
        {
            return NotFound();
        }

        Response.Headers.Add("X-Response-Time", $"{stopwatch.ElapsedMilliseconds}ms");
        Response.Headers.Add("X-Cache-Key", $"product:{id}");

        return Ok(product);
    }

    /// <summary>
    /// Search products with short-term caching
    /// </summary>
    [HttpGet("search")]
    [OutputCache(Duration = 120, VaryByQuery = new[] { "q" })]
    public async Task<ActionResult<List<Product>>> SearchProducts([FromQuery] string q)
    {
        if (string.IsNullOrWhiteSpace(q))
        {
            return BadRequest("Search term is required");
        }

        var stopwatch = System.Diagnostics.Stopwatch.StartNew();

        var products = await _productService.SearchProductsAsync(q);

        stopwatch.Stop();
        _logger.LogInformation("SearchProducts('{SearchTerm}') completed in {ElapsedMs}ms", q, stopwatch.ElapsedMilliseconds);

        Response.Headers.Add("X-Response-Time", $"{stopwatch.ElapsedMilliseconds}ms");
        Response.Headers.Add("X-Search-Term", q);

        return Ok(products);
    }

    /// <summary>
    /// Create product (invalidates caches)
    /// </summary>
    [HttpPost]
    public async Task<ActionResult<Product>> CreateProduct(Product product)
    {
        var createdProduct = await _productService.CreateProductAsync(product);
        return CreatedAtAction(nameof(GetProduct), new { id = createdProduct.Id }, createdProduct);
    }

    /// <summary>
    /// Update product (invalidates caches)
    /// </summary>
    [HttpPut("{id}")]
    public async Task<IActionResult> UpdateProduct(int id, Product product)
    {
        if (id != product.Id)
        {
            return BadRequest();
        }

        await _productService.UpdateProductAsync(product);
        return NoContent();
    }

    /// <summary>
    /// Delete product (invalidates caches)
    /// </summary>
    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteProduct(int id)
    {
        await _productService.DeleteProductAsync(id);
        return NoContent();
    }
}
'@

        # Create CacheController for cache management
        New-FileInteractive -FilePath "$ProjectName.API/Controllers/CacheController.cs" -Description "Cache management and monitoring controller" -Content @'
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Caching.Memory;
using PerformanceDemo.API.Services;

namespace PerformanceDemo.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class CacheController : ControllerBase
{
    private readonly ICacheService _cacheService;
    private readonly IMemoryCache _memoryCache;
    private readonly ILogger<CacheController> _logger;

    public CacheController(ICacheService cacheService, IMemoryCache memoryCache, ILogger<CacheController> logger)
    {
        _cacheService = cacheService;
        _memoryCache = memoryCache;
        _logger = logger;
    }

    /// <summary>
    /// Get cache statistics
    /// </summary>
    [HttpGet("stats")]
    public IActionResult GetCacheStats()
    {
        // Note: This is a simplified implementation
        // In production, you'd use more sophisticated cache monitoring
        var stats = new
        {
            MemoryCacheType = _memoryCache.GetType().Name,
            Timestamp = DateTime.UtcNow,
            Message = "Cache statistics would be available with proper monitoring setup"
        };

        return Ok(stats);
    }

    /// <summary>
    /// Clear all caches
    /// </summary>
    [HttpDelete("clear")]
    public async Task<IActionResult> ClearCache()
    {
        // Clear memory cache (simplified - in production you'd need proper cache key tracking)
        if (_memoryCache is MemoryCache mc)
        {
            mc.Compact(1.0);
        }

        _logger.LogWarning("Cache cleared manually");
        return Ok(new { Message = "Cache cleared", Timestamp = DateTime.UtcNow });
    }

    /// <summary>
    /// Warm up cache with frequently accessed data
    /// </summary>
    [HttpPost("warmup")]
    public async Task<IActionResult> WarmUpCache()
    {
        var stopwatch = System.Diagnostics.Stopwatch.StartNew();

        // Warm up product caches
        var productService = HttpContext.RequestServices.GetRequiredService<IProductService>();

        // Pre-load all products
        await productService.GetProductsAsync();

        // Pre-load products by category
        var categories = new[] { "Electronics", "Clothing", "Books", "Home", "Sports" };
        foreach (var category in categories)
        {
            await productService.GetProductsByCategoryAsync(category);
        }

        // Pre-load first 10 individual products
        for (int i = 1; i <= 10; i++)
        {
            await productService.GetProductAsync(i);
        }

        stopwatch.Stop();
        _logger.LogInformation("Cache warmed up in {ElapsedMs}ms", stopwatch.ElapsedMilliseconds);

        return Ok(new
        {
            Message = "Cache warmed up successfully",
            ElapsedMs = stopwatch.ElapsedMilliseconds,
            Timestamp = DateTime.UtcNow
        });
    }

    /// <summary>
    /// Test cache performance
    /// </summary>
    [HttpGet("performance-test")]
    public async Task<IActionResult> PerformanceTest()
    {
        var results = new List<object>();
        var productService = HttpContext.RequestServices.GetRequiredService<IProductService>();

        // Test 1: Cold cache
        var stopwatch = System.Diagnostics.Stopwatch.StartNew();
        await productService.GetProductAsync(1);
        stopwatch.Stop();
        results.Add(new { Test = "Cold Cache", ElapsedMs = stopwatch.ElapsedMilliseconds });

        // Test 2: Warm cache
        stopwatch.Restart();
        await productService.GetProductAsync(1);
        stopwatch.Stop();
        results.Add(new { Test = "Warm Cache", ElapsedMs = stopwatch.ElapsedMilliseconds });

        // Test 3: Multiple requests
        stopwatch.Restart();
        var tasks = Enumerable.Range(1, 10).Select(i => productService.GetProductAsync(i));
        await Task.WhenAll(tasks);
        stopwatch.Stop();
        results.Add(new { Test = "10 Concurrent Requests", ElapsedMs = stopwatch.ElapsedMilliseconds });

        return Ok(new { Results = results, Timestamp = DateTime.UtcNow });
    }
}
'@

        # Create Program.cs with caching configuration
        New-FileInteractive -FilePath "$ProjectName.API/Program.cs" -Description "Application startup with comprehensive caching configuration" -Content @'
using PerformanceDemo.API.Services;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new() { Title = "Performance Demo API", Version = "v1" });
    c.IncludeXmlComments(Path.Combine(AppContext.BaseDirectory, "PerformanceDemo.API.xml"), true);
});

// Configure caching services
builder.Services.AddMemoryCache(options =>
{
    options.SizeLimit = 1024; // Limit memory cache size
});

// Configure distributed cache (Redis)
builder.Services.AddStackExchangeRedisCache(options =>
{
    options.Configuration = builder.Configuration.GetConnectionString("Redis") ?? "localhost:6379";
    options.InstanceName = "PerformanceDemo";
});

// Configure output caching
builder.Services.AddOutputCache(options =>
{
    options.AddBasePolicy(builder => builder.Expire(TimeSpan.FromMinutes(10)));
    options.AddPolicy("ProductPolicy", builder =>
        builder.Expire(TimeSpan.FromMinutes(15))
               .SetVaryByQuery("category", "q"));
});

// Configure response caching
builder.Services.AddResponseCaching(options =>
{
    options.MaximumBodySize = 1024 * 1024; // 1MB
    options.UseCaseSensitivePaths = false;
});

// Register application services
builder.Services.AddScoped<ICacheService, CacheService>();
builder.Services.AddScoped<IProductService, ProductService>();

// Add CORS for development
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyMethod()
              .AllowAnyHeader();
    });
});

var app = builder.Build();

// Configure the HTTP request pipeline
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI(c =>
    {
        c.SwaggerEndpoint("/swagger/v1/swagger.json", "Performance Demo API v1");
        c.RoutePrefix = "swagger";
    });
}

app.UseCors("AllowAll");

// Add caching middleware
app.UseResponseCaching();
app.UseOutputCache();

app.UseHttpsRedirection();
app.UseAuthorization();

app.MapControllers();

// Add a root redirect to swagger
app.MapGet("/", () => Results.Redirect("/swagger"));

app.Run();
'@

        # Create Docker Compose for Redis
        New-FileInteractive -FilePath "docker-compose.yml" -Description "Docker Compose configuration with Redis for distributed caching" -Content @'
version: '3.8'

services:
  redis:
    image: redis:7-alpine
    container_name: performance-demo-redis
    ports:
      - "6379:6379"
    command: redis-server --appendonly yes
    volumes:
      - redis_data:/data
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 30s
      timeout: 10s
      retries: 3

  api:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: performance-demo-api
    ports:
      - "5000:80"
    environment:
      - ASPNETCORE_ENVIRONMENT=Development
      - ConnectionStrings__Redis=redis:6379
    depends_on:
      redis:
        condition: service_healthy

volumes:
  redis_data:
'@

        # Create Dockerfile
        New-FileInteractive -FilePath "Dockerfile" -Description "Dockerfile for containerized deployment" -Content @'
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 80

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY ["PerformanceDemo.API/PerformanceDemo.API.csproj", "PerformanceDemo.API/"]
RUN dotnet restore "PerformanceDemo.API/PerformanceDemo.API.csproj"
COPY . .
WORKDIR "/src/PerformanceDemo.API"
RUN dotnet build "PerformanceDemo.API.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "PerformanceDemo.API.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "PerformanceDemo.API.dll"]
'@

        Write-Host "✅ Exercise 1 template created successfully!" -ForegroundColor Green
        Write-Host ""
        Write-Host "🚀 Next steps:" -ForegroundColor Yellow
        Write-Host "1. Build the solution: dotnet build" -ForegroundColor Cyan
        Write-Host "2. Start Redis: docker-compose up redis -d" -ForegroundColor Cyan
        Write-Host "3. Run the API: dotnet run --project PerformanceDemo.API" -ForegroundColor Cyan
        Write-Host "4. Visit: http://localhost:5000/swagger" -ForegroundColor Cyan
        Write-Host "5. Test caching performance with /api/cache/performance-test" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "💡 Performance testing tips:" -ForegroundColor Blue
        Write-Host "  - Use /api/cache/warmup to pre-load caches" -ForegroundColor White
        Write-Host "  - Monitor response times with X-Response-Time headers" -ForegroundColor White
        Write-Host "  - Compare cold vs warm cache performance" -ForegroundColor White
        Write-Host "  - Test different cache expiration strategies" -ForegroundColor White
    }

    "exercise02" {
        # Exercise 2: Database Optimization Techniques

        Show-Concept -ConceptName "Database Performance Optimization" -Explanation @"
Database optimization is crucial for application performance:
• Query Optimization: Efficient SQL queries and execution plans
• Entity Framework Tuning: Proper configuration and usage patterns
• Connection Pooling: Reusing database connections efficiently
• Indexing Strategies: Creating appropriate database indexes
• N+1 Query Problem: Avoiding excessive database round trips
• Lazy vs Eager Loading: Choosing the right loading strategy
"@

        if (-not $SkipProjectCreation) {
            Write-Host "❌ Exercise 2 requires Exercise 1 to be completed first!" -ForegroundColor Red
            Write-Host "📝 Please run: .\launch-exercises.ps1 exercise01" -ForegroundColor Yellow
            exit 1
        }

        Write-Host "📦 Adding database optimization packages..." -ForegroundColor Cyan
        Set-Location "$ProjectName.API"
        dotnet add package Microsoft.EntityFrameworkCore.SqlServer
        dotnet add package Microsoft.EntityFrameworkCore.Tools
        dotnet add package Microsoft.EntityFrameworkCore.Design
        Set-Location ".."

        # Create DbContext with performance optimizations
        New-FileInteractive -FilePath "$ProjectName.API/Data/PerformanceDbContext.cs" -Description "Entity Framework DbContext with performance optimizations" -Content @'
using Microsoft.EntityFrameworkCore;
using PerformanceDemo.API.Models;

namespace PerformanceDemo.API.Data;

public class PerformanceDbContext : DbContext
{
    public PerformanceDbContext(DbContextOptions<PerformanceDbContext> options) : base(options)
    {
    }

    public DbSet<Product> Products { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        // Configure Product entity
        modelBuilder.Entity<Product>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Name).IsRequired().HasMaxLength(200);
            entity.Property(e => e.Description).HasMaxLength(2000);
            entity.Property(e => e.Category).IsRequired().HasMaxLength(100);
            entity.Property(e => e.Price).HasColumnType("decimal(18,2)");

            // Add indexes for performance
            entity.HasIndex(e => e.Category).HasDatabaseName("IX_Products_Category");
            entity.HasIndex(e => e.IsActive).HasDatabaseName("IX_Products_IsActive");
            entity.HasIndex(e => new { e.Category, e.IsActive }).HasDatabaseName("IX_Products_Category_IsActive");
            entity.HasIndex(e => e.Name).HasDatabaseName("IX_Products_Name");
        });

        base.OnModelCreating(modelBuilder);
    }

    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
    {
        if (!optionsBuilder.IsConfigured)
        {
            // Performance optimizations
            optionsBuilder.EnableSensitiveDataLogging(false);
            optionsBuilder.EnableServiceProviderCaching();
            optionsBuilder.EnableDetailedErrors(false);
        }
    }
}
'@

        Write-Host "✅ Exercise 2 database optimization template created!" -ForegroundColor Green
        Write-Host "🚀 Next steps:" -ForegroundColor Yellow
        Write-Host "1. Configure connection string in appsettings.json" -ForegroundColor Cyan
        Write-Host "2. Add DbContext to Program.cs" -ForegroundColor Cyan
        Write-Host "3. Run migrations: dotnet ef migrations add InitialCreate" -ForegroundColor Cyan
        Write-Host "4. Update database: dotnet ef database update" -ForegroundColor Cyan
    }

    "exercise03" {
        # Exercise 3: Async and Memory Optimization

        Show-Concept -ConceptName "Asynchronous Programming and Memory Management" -Explanation @"
Advanced performance optimization techniques:
• Async/Await Best Practices: Proper asynchronous programming patterns
• Memory Management: Reducing allocations and garbage collection pressure
• Object Pooling: Reusing expensive objects
• Span<T> and Memory<T>: High-performance memory operations
• ValueTask: Optimizing async operations
• ConfigureAwait: Avoiding deadlocks and improving performance
"@

        if (-not $SkipProjectCreation) {
            Write-Host "❌ Exercise 3 requires Exercises 1 and 2 to be completed first!" -ForegroundColor Red
            Write-Host "📝 Please run exercises in order: exercise01, exercise02, exercise03" -ForegroundColor Yellow
            exit 1
        }

        # Create memory optimization service
        New-FileInteractive -FilePath "$ProjectName.API/Services/MemoryOptimizedService.cs" -Description "Service demonstrating memory optimization techniques" -Content @'
using System.Buffers;
using System.Text;

namespace PerformanceDemo.API.Services;

public interface IMemoryOptimizedService
{
    ValueTask<string> ProcessDataAsync(ReadOnlyMemory<byte> data);
    Task<List<T>> ProcessBatchAsync<T>(IEnumerable<T> items, Func<T, Task<T>> processor);
}

public class MemoryOptimizedService : IMemoryOptimizedService
{
    private readonly ArrayPool<byte> _arrayPool;
    private readonly ILogger<MemoryOptimizedService> _logger;

    public MemoryOptimizedService(ILogger<MemoryOptimizedService> logger)
    {
        _arrayPool = ArrayPool<byte>.Shared;
        _logger = logger;
    }

    public async ValueTask<string> ProcessDataAsync(ReadOnlyMemory<byte> data)
    {
        // Use Span<T> for high-performance operations
        var span = data.Span;

        // Rent array from pool to avoid allocations
        var buffer = _arrayPool.Rent(data.Length * 2);

        try
        {
            // Process data efficiently
            for (int i = 0; i < span.Length; i++)
            {
                buffer[i] = (byte)(span[i] ^ 0xFF); // Simple transformation
            }

            // Convert to string efficiently
            return Encoding.UTF8.GetString(buffer, 0, span.Length);
        }
        finally
        {
            // Always return rented arrays
            _arrayPool.Return(buffer);
        }
    }

    public async Task<List<T>> ProcessBatchAsync<T>(IEnumerable<T> items, Func<T, Task<T>> processor)
    {
        // Use ConfigureAwait(false) for library code
        var tasks = items.Select(item => processor(item)).ToArray();
        var results = await Task.WhenAll(tasks).ConfigureAwait(false);
        return results.ToList();
    }
}
'@

        Write-Host "✅ Exercise 3 async and memory optimization template created!" -ForegroundColor Green
        Write-Host "🚀 Focus on:" -ForegroundColor Yellow
        Write-Host "1. Proper async/await usage patterns" -ForegroundColor Cyan
        Write-Host "2. Memory allocation reduction techniques" -ForegroundColor Cyan
        Write-Host "3. Object pooling for expensive resources" -ForegroundColor Cyan
    }

    "exercise04" {
        # Exercise 4: Monitoring and Profiling Tools

        Show-Concept -ConceptName "Application Performance Monitoring" -Explanation @"
Monitoring and profiling are essential for performance optimization:
• Application Performance Monitoring (APM): Real-time performance tracking
• Custom Metrics: Business-specific performance indicators
• Profiling Tools: Memory and CPU usage analysis
• Load Testing: Capacity planning and bottleneck identification
• Distributed Tracing: End-to-end request tracking
• Performance Counters: System-level metrics
"@

        if (-not $SkipProjectCreation) {
            Write-Host "❌ Exercise 4 requires Exercises 1, 2, and 3 to be completed first!" -ForegroundColor Red
            Write-Host "📝 Please run exercises in order: exercise01, exercise02, exercise03, exercise04" -ForegroundColor Yellow
            exit 1
        }

        Write-Host "📦 Adding monitoring packages..." -ForegroundColor Cyan
        Set-Location "$ProjectName.API"
        dotnet add package System.Diagnostics.DiagnosticSource
        dotnet add package Microsoft.Extensions.Diagnostics.HealthChecks
        Set-Location ".."

        # Create performance monitoring service
        New-FileInteractive -FilePath "$ProjectName.API/Services/PerformanceMonitoringService.cs" -Description "Performance monitoring and metrics collection service" -Content @'
using System.Diagnostics;
using System.Diagnostics.Metrics;

namespace PerformanceDemo.API.Services;

public class PerformanceMonitoringService
{
    private readonly Meter _meter;
    private readonly Counter<long> _requestCounter;
    private readonly Histogram<double> _requestDuration;
    private readonly ILogger<PerformanceMonitoringService> _logger;

    public PerformanceMonitoringService(ILogger<PerformanceMonitoringService> logger)
    {
        _logger = logger;
        _meter = new Meter("PerformanceDemo.API");
        _requestCounter = _meter.CreateCounter<long>("requests_total", "count", "Total number of requests");
        _requestDuration = _meter.CreateHistogram<double>("request_duration", "ms", "Request duration in milliseconds");
    }

    public void RecordRequest(string endpoint, double durationMs, int statusCode)
    {
        _requestCounter.Add(1, new KeyValuePair<string, object?>("endpoint", endpoint),
                               new KeyValuePair<string, object?>("status_code", statusCode));

        _requestDuration.Record(durationMs, new KeyValuePair<string, object?>("endpoint", endpoint));

        _logger.LogInformation("Request to {Endpoint} completed in {Duration}ms with status {StatusCode}",
                              endpoint, durationMs, statusCode);
    }
}
'@

        Write-Host "✅ Exercise 4 monitoring and profiling template created!" -ForegroundColor Green
        Write-Host "🚀 Next steps:" -ForegroundColor Yellow
        Write-Host "1. Integrate performance monitoring middleware" -ForegroundColor Cyan
        Write-Host "2. Set up custom metrics collection" -ForegroundColor Cyan
        Write-Host "3. Configure health checks" -ForegroundColor Cyan
        Write-Host "4. Implement load testing scenarios" -ForegroundColor Cyan
    }
}

Write-Host ""
Write-Host "============================================================" -ForegroundColor Green
Write-Host "✅ Module 8 Exercise setup complete!" -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Green
Write-Host ""
Write-Host "🚀 Next Steps:" -ForegroundColor Yellow
Write-Host "1. Review the created files and understand their purpose" -ForegroundColor White
Write-Host "2. Build and run the application to test performance" -ForegroundColor White
Write-Host "3. Experiment with different caching strategies" -ForegroundColor White
Write-Host "4. Use the SourceCode version for complete implementations" -ForegroundColor White
Write-Host ""
Write-Host "💡 Happy optimizing! ⚡" -ForegroundColor Cyan
