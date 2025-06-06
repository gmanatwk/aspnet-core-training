#!/bin/bash

# Module 8 Interactive Exercise Launcher
# Performance Optimization

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Interactive mode flag
INTERACTIVE_MODE=true

# Function to pause and wait for user
pause_for_user() {
    if [ "$INTERACTIVE_MODE" = true ]; then
        echo -e "${YELLOW}Press Enter to continue...${NC}"
        read -r
    fi
}

# Function to show what will be created
preview_file() {
    local file_path=$1
    local description=$2
    
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}📄 Will create: $file_path${NC}"
    echo -e "${YELLOW}📝 Purpose: $description${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# Function to create file with preview
create_file_interactive() {
    local file_path=$1
    local content=$2
    local description=$3
    
    preview_file "$file_path" "$description"
    
    # Show first 20 lines of content
    echo -e "${GREEN}Content preview:${NC}"
    echo "$content" | head -20
    if [ $(echo "$content" | wc -l) -gt 20 ]; then
        echo -e "${YELLOW}... (content truncated for preview)${NC}"
    fi
    echo ""
    
    if [ "$INTERACTIVE_MODE" = true ]; then
        echo -e "${YELLOW}Create this file? (Y/n/s to skip all):${NC} \c"
        read -r response
        
        case $response in
            [nN])
                echo -e "${RED}⏭️  Skipped: $file_path${NC}"
                return
                ;;
            [sS])
                INTERACTIVE_MODE=false
                echo -e "${CYAN}📌 Switching to automatic mode...${NC}"
                ;;
        esac
    fi
    
    # Create directory if it doesn't exist
    mkdir -p "$(dirname "$file_path")"
    
    # Write content to file
    echo "$content" > "$file_path"
    echo -e "${GREEN}✅ Created: $file_path${NC}"
    echo ""
}

# Function to show learning objectives
show_learning_objectives() {
    local exercise=$1
    
    echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${MAGENTA}🎯 Learning Objectives${NC}"
    echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    case $exercise in
        "exercise01")
            echo -e "${CYAN}In this exercise, you will learn:${NC}"
            echo "  🚀 1. Implementing in-memory and distributed caching strategies"
            echo "  🚀 2. Response caching and output caching techniques"
            echo "  🚀 3. Cache invalidation and expiration policies"
            echo "  🚀 4. Redis integration for distributed scenarios"
            echo ""
            echo -e "${YELLOW}Key caching concepts:${NC}"
            echo "  • Memory cache vs distributed cache"
            echo "  • Cache-aside and write-through patterns"
            echo "  • Cache key design and naming strategies"
            echo "  • Performance monitoring and metrics"
            ;;
        "exercise02")
            echo -e "${CYAN}Building on Exercise 1, you will add:${NC}"
            echo "  📊 1. Database query optimization techniques"
            echo "  📊 2. Entity Framework performance tuning"
            echo "  📊 3. Connection pooling and query batching"
            echo "  📊 4. Database indexing strategies"
            echo ""
            echo -e "${YELLOW}Database optimization:${NC}"
            echo "  • Query execution plan analysis"
            echo "  • N+1 query problem solutions"
            echo "  • Lazy vs eager loading strategies"
            echo "  • Database connection management"
            ;;
        "exercise03")
            echo -e "${CYAN}Advanced performance patterns:${NC}"
            echo "  ⚡ 1. Asynchronous programming best practices"
            echo "  ⚡ 2. Memory management and garbage collection"
            echo "  ⚡ 3. CPU-bound vs I/O-bound optimization"
            echo "  ⚡ 4. Parallel processing and Task optimization"
            echo ""
            echo -e "${YELLOW}Performance concepts:${NC}"
            echo "  • Thread pool optimization"
            echo "  • Memory allocation patterns"
            echo "  • Async/await performance implications"
            echo "  • Resource pooling strategies"
            ;;
        "exercise04")
            echo -e "${CYAN}Monitoring and profiling:${NC}"
            echo "  📈 1. Application performance monitoring (APM)"
            echo "  📈 2. Custom metrics and telemetry"
            echo "  📈 3. Performance profiling tools"
            echo "  📈 4. Load testing and capacity planning"
            echo ""
            echo -e "${YELLOW}Monitoring tools:${NC}"
            echo "  • Built-in .NET performance counters"
            echo "  • Custom metrics with EventCounters"
            echo "  • Memory and CPU profiling"
            echo "  • Distributed tracing patterns"
            ;;
    esac
    
    echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    pause_for_user
}

# Function to show what will be created overview
show_creation_overview() {
    local exercise=$1
    
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}📋 Overview: What will be created${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    case $exercise in
        "exercise01")
            echo -e "${GREEN}🎯 Exercise 01: Caching Implementation${NC}"
            echo ""
            echo -e "${YELLOW}📋 What you'll build:${NC}"
            echo "  ✅ High-performance API with multiple caching layers"
            echo "  ✅ In-memory caching with IMemoryCache"
            echo "  ✅ Distributed caching with Redis"
            echo "  ✅ Response caching and output caching"
            echo ""
            echo -e "${BLUE}🚀 RECOMMENDED: Use the Complete Working Example${NC}"
            echo "  ${CYAN}cd SourceCode/PerformanceDemo && dotnet run${NC}"
            echo "  Then visit: ${CYAN}http://localhost:5000${NC} for performance testing"
            echo ""
            echo -e "${GREEN}📁 Template Structure:${NC}"
            echo "  PerformanceDemo/"
            echo "  ├── Controllers/"
            echo "  │   ├── ProductsController.cs   ${YELLOW}# Cached API endpoints${NC}"
            echo "  │   └── CacheController.cs      ${YELLOW}# Cache management${NC}"
            echo "  ├── Services/"
            echo "  │   ├── CacheService.cs         ${YELLOW}# Caching abstraction${NC}"
            echo "  │   └── ProductService.cs       ${YELLOW}# Business logic${NC}"
            echo "  ├── Middleware/"
            echo "  │   └── ResponseCacheMiddleware.cs ${YELLOW}# Custom caching${NC}"
            echo "  └── docker-compose.yml          ${YELLOW}# Redis setup${NC}"
            ;;
            
        "exercise02")
            echo -e "${GREEN}🎯 Exercise 02: Database Optimization${NC}"
            echo ""
            echo -e "${YELLOW}📋 Building on Exercise 1:${NC}"
            echo "  ✅ Entity Framework performance tuning"
            echo "  ✅ Query optimization and indexing"
            echo "  ✅ Connection pooling configuration"
            echo "  ✅ Database performance monitoring"
            echo ""
            echo -e "${GREEN}📁 New additions:${NC}"
            echo "  PerformanceDemo/"
            echo "  ├── Data/"
            echo "  │   ├── OptimizedDbContext.cs   ${YELLOW}# Performance-tuned context${NC}"
            echo "  │   └── QueryOptimizer.cs       ${YELLOW}# Query analysis tools${NC}"
            echo "  ├── Repositories/"
            echo "  │   └── OptimizedRepository.cs  ${YELLOW}# High-performance queries${NC}"
            echo "  └── Migrations/"
            echo "      └── AddIndexes.cs           ${YELLOW}# Database indexes${NC}"
            ;;
            
        "exercise03")
            echo -e "${GREEN}🎯 Exercise 03: Async and Memory Optimization${NC}"
            echo ""
            echo -e "${YELLOW}📋 Advanced performance patterns:${NC}"
            echo "  ✅ Asynchronous programming optimization"
            echo "  ✅ Memory management and pooling"
            echo "  ✅ CPU-bound task optimization"
            echo "  ✅ Resource pooling implementations"
            echo ""
            echo -e "${GREEN}📁 Performance structure:${NC}"
            echo "  PerformanceDemo/"
            echo "  ├── Services/"
            echo "  │   ├── AsyncOptimizedService.cs ${YELLOW}# Async best practices${NC}"
            echo "  │   └── MemoryPoolService.cs     ${YELLOW}# Memory optimization${NC}"
            echo "  ├── Utilities/"
            echo "  │   ├── ObjectPool.cs            ${YELLOW}# Object pooling${NC}"
            echo "  │   └── MemoryManager.cs         ${YELLOW}# Memory management${NC}"
            echo "  └── Benchmarks/"
            echo "      └── PerformanceBenchmarks.cs ${YELLOW}# Performance tests${NC}"
            ;;
            
        "exercise04")
            echo -e "${GREEN}🎯 Exercise 04: Monitoring and Profiling${NC}"
            echo ""
            echo -e "${YELLOW}📋 Performance monitoring tools:${NC}"
            echo "  ✅ Application Performance Monitoring (APM)"
            echo "  ✅ Custom metrics and telemetry"
            echo "  ✅ Performance profiling integration"
            echo "  ✅ Load testing and benchmarking"
            echo ""
            echo -e "${GREEN}📁 Monitoring structure:${NC}"
            echo "  PerformanceDemo/"
            echo "  ├── Monitoring/"
            echo "  │   ├── PerformanceCounters.cs  ${YELLOW}# Custom metrics${NC}"
            echo "  │   ├── TelemetryService.cs     ${YELLOW}# Telemetry collection${NC}"
            echo "  │   └── HealthMetrics.cs        ${YELLOW}# Health monitoring${NC}"
            echo "  ├── LoadTests/"
            echo "  │   └── ApiLoadTests.cs         ${YELLOW}# Load testing scripts${NC}"
            echo "  └── Profiling/"
            echo "      └── ProfilerConfiguration.cs ${YELLOW}# Profiler setup${NC}"
            ;;
    esac
    
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    pause_for_user
}

# Function to explain a concept
explain_concept() {
    local concept=$1
    local explanation=$2
    
    echo -e "${MAGENTA}💡 Concept: $concept${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "$explanation"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    pause_for_user
}

# Function to show available exercises
show_exercises() {
    echo -e "${CYAN}Module 8 - Performance Optimization${NC}"
    echo -e "${CYAN}Available Exercises:${NC}"
    echo ""
    echo "  - exercise01: Caching Implementation"
    echo "  - exercise02: Database Optimization"
    echo "  - exercise03: Async and Memory Optimization"
    echo "  - exercise04: Monitoring and Profiling"
    echo ""
    echo "Usage:"
    echo "  ./launch-exercises.sh <exercise-name> [options]"
    echo ""
    echo "Options:"
    echo "  --list          Show all available exercises"
    echo "  --auto          Skip interactive mode"
    echo "  --preview       Show what will be created without creating"
}

# Main script starts here
if [ $# -eq 0 ]; then
    echo -e "${RED}❌ Usage: $0 <exercise-name> [options]${NC}"
    echo ""
    show_exercises
    exit 1
fi

# Handle --list option
if [ "$1" == "--list" ]; then
    show_exercises
    exit 0
fi

EXERCISE_NAME=$1
PROJECT_NAME="PerformanceDemo"
PREVIEW_ONLY=false

# Parse options
shift
while [[ $# -gt 0 ]]; do
    case $1 in
        --auto)
            INTERACTIVE_MODE=false
            shift
            ;;
        --preview)
            PREVIEW_ONLY=true
            shift
            ;;
        *)
            shift
            ;;
    esac
done

# Validate exercise name
case $EXERCISE_NAME in
    "exercise01"|"exercise02"|"exercise03"|"exercise04")
        ;;
    *)
        echo -e "${RED}❌ Unknown exercise: $EXERCISE_NAME${NC}"
        echo ""
        show_exercises
        exit 1
        ;;
esac

# Welcome screen
echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${MAGENTA}🚀 Module 8: Performance Optimization${NC}"
echo -e "${MAGENTA}Exercise: $EXERCISE_NAME${NC}"
echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Show the recommended approach
echo -e "${GREEN}🎯 RECOMMENDED APPROACH:${NC}"
echo -e "${CYAN}For the best learning experience, use the complete working implementation:${NC}"
echo ""
echo -e "${YELLOW}1. Use the working source code:${NC}"
echo -e "   ${CYAN}cd SourceCode/PerformanceDemo${NC}"
echo -e "   ${CYAN}dotnet run${NC}"
echo -e "   ${CYAN}# Visit: http://localhost:5000 for performance testing${NC}"
echo ""
echo -e "${YELLOW}2. Or use Docker for complete setup with Redis:${NC}"
echo -e "   ${CYAN}cd SourceCode${NC}"
echo -e "   ${CYAN}docker-compose up --build${NC}"
echo -e "   ${CYAN}# Includes Redis, monitoring, and load testing tools${NC}"
echo ""
echo -e "${YELLOW}⚠️  The template created by this script is basic and may not match${NC}"
echo -e "${YELLOW}   all exercise requirements. The SourceCode version is complete!${NC}"
echo ""

if [ "$INTERACTIVE_MODE" = true ]; then
    echo -e "${YELLOW}🎮 Interactive Mode: ON${NC}"
    echo -e "${CYAN}You'll see what each file does before it's created${NC}"
else
    echo -e "${YELLOW}⚡ Automatic Mode: ON${NC}"
fi

echo ""
echo -n "Continue with template creation? (y/N): "
read -r response
if [[ ! "$response" =~ ^[Yy]$ ]]; then
    echo -e "${CYAN}💡 Great choice! Use the SourceCode version for the best experience.${NC}"
    exit 0
fi

# Show learning objectives
show_learning_objectives $EXERCISE_NAME

# Show creation overview
show_creation_overview $EXERCISE_NAME

if [ "$PREVIEW_ONLY" = true ]; then
    echo -e "${YELLOW}Preview mode - no files will be created${NC}"
    exit 0
fi

# Check if project exists in current directory
if [ -d "$PROJECT_NAME" ]; then
    if [[ $EXERCISE_NAME == "exercise02" ]] || [[ $EXERCISE_NAME == "exercise03" ]] || [[ $EXERCISE_NAME == "exercise04" ]]; then
        echo -e "${GREEN}✓ Found existing $PROJECT_NAME from previous exercise${NC}"
        echo -e "${CYAN}This exercise will build on your existing work${NC}"
        cd "$PROJECT_NAME"
        SKIP_PROJECT_CREATION=true
    else
        echo -e "${YELLOW}⚠️  Project '$PROJECT_NAME' already exists!${NC}"
        echo -n "Do you want to overwrite it? (y/N): "
        read -r response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            exit 1
        fi
        rm -rf "$PROJECT_NAME"
        SKIP_PROJECT_CREATION=false
    fi
else
    SKIP_PROJECT_CREATION=false
fi

# Exercise-specific implementation
if [[ $EXERCISE_NAME == "exercise01" ]]; then
    # Exercise 1: Caching Implementation

    explain_concept "Performance Optimization Fundamentals" \
"Performance optimization is about making applications faster and more efficient:
• Identify bottlenecks before optimizing
• Measure performance before and after changes
• Focus on the most impactful optimizations first
• Use caching to reduce expensive operations
• Optimize database queries and network calls"

    if [ "$SKIP_PROJECT_CREATION" = false ]; then
        echo -e "${CYAN}Creating high-performance Web API project...${NC}"
        dotnet new webapi -n "$PROJECT_NAME" --framework net8.0
        cd "$PROJECT_NAME"
        rm -f WeatherForecast.cs Controllers/WeatherForecastController.cs

        # Install performance packages
        echo -e "${CYAN}Installing performance optimization packages...${NC}"
        dotnet add package Microsoft.Extensions.Caching.Memory
        dotnet add package Microsoft.Extensions.Caching.StackExchangeRedis
        dotnet add package Microsoft.AspNetCore.ResponseCompression
        dotnet add package BenchmarkDotNet
        dotnet add package Microsoft.EntityFrameworkCore.InMemory

        # Update Program.cs with performance configuration
        create_file_interactive "Program.cs" \
'using Microsoft.AspNetCore.ResponseCompression;
using Microsoft.Extensions.Caching.Memory;
using PerformanceDemo.Services;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container
builder.Services.AddControllers();

// Add caching services
builder.Services.AddMemoryCache(options =>
{
    options.SizeLimit = 1024; // Limit cache size
});

// Add distributed caching (Redis)
builder.Services.AddStackExchangeRedisCache(options =>
{
    options.Configuration = builder.Configuration.GetConnectionString("Redis") ?? "localhost:6379";
    options.InstanceName = "PerformanceDemo";
});

// Add response compression
builder.Services.AddResponseCompression(options =>
{
    options.EnableForHttps = true;
    options.Providers.Add<BrotliCompressionProvider>();
    options.Providers.Add<GzipCompressionProvider>();
    options.MimeTypes = ResponseCompressionDefaults.MimeTypes.Concat(new[]
    {
        "application/json",
        "text/json"
    });
});

// Add output caching (new in .NET 8)
builder.Services.AddOutputCache(options =>
{
    options.AddBasePolicy(builder => builder.Cache());
    options.AddPolicy("Products", builder =>
        builder.Tag("products").Expire(TimeSpan.FromMinutes(10)));
});

// Register custom services
builder.Services.AddScoped<ICacheService, CacheService>();
builder.Services.AddScoped<IProductService, ProductService>();

// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new() { Title = "Performance Demo API", Version = "v1" });
});

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

// Add performance middleware
app.UseResponseCompression();
app.UseOutputCache();

app.UseCors("AllowAll");
app.UseHttpsRedirection();
app.UseAuthorization();
app.MapControllers();

// Add a root redirect to swagger
app.MapGet("/", () => Results.Redirect("/swagger"));

app.Run();' \
"Program.cs with comprehensive performance configuration"
    fi

    explain_concept "Caching Strategies" \
"Different caching approaches for different scenarios:
• Memory Cache: Fast, in-process caching for single instances
• Distributed Cache: Shared cache across multiple instances
• Response Cache: HTTP-level caching with proper headers
• Output Cache: New .NET 8 feature for endpoint caching
• Cache invalidation: Keeping cache data fresh and consistent"

    # Create Product model
    create_file_interactive "Models/Product.cs" \
'namespace PerformanceDemo.Models;

public class Product
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public decimal Price { get; set; }
    public string Category { get; set; } = string.Empty;
    public int StockQuantity { get; set; }
    public bool IsActive { get; set; } = true;
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
}

public class ProductSummary
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public decimal Price { get; set; }
    public string Category { get; set; } = string.Empty;
}

public class CacheStatistics
{
    public int TotalRequests { get; set; }
    public int CacheHits { get; set; }
    public int CacheMisses { get; set; }
    public double HitRatio => TotalRequests > 0 ? (double)CacheHits / TotalRequests * 100 : 0;
    public TimeSpan AverageResponseTime { get; set; }
}' \
"Product models optimized for caching scenarios"

    # Create cache service interface and implementation
    create_file_interactive "Services/ICacheService.cs" \
'namespace PerformanceDemo.Services;

public interface ICacheService
{
    Task<T?> GetAsync<T>(string key) where T : class;
    Task SetAsync<T>(string key, T value, TimeSpan? expiry = null) where T : class;
    Task RemoveAsync(string key);
    Task RemoveByPatternAsync(string pattern);
    Task<bool> ExistsAsync(string key);
}' \
"Cache service interface for abstraction"

    # Create cache service implementation
    create_file_interactive "Services/CacheService.cs" \
'using Microsoft.Extensions.Caching.Distributed;
using Microsoft.Extensions.Caching.Memory;
using System.Text.Json;

namespace PerformanceDemo.Services;

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
        try
        {
            // Try memory cache first (L1 cache)
            if (_memoryCache.TryGetValue(key, out T? cachedValue))
            {
                _logger.LogDebug("Cache hit (Memory): {Key}", key);
                return cachedValue;
            }

            // Try distributed cache (L2 cache)
            var distributedValue = await _distributedCache.GetStringAsync(key);
            if (!string.IsNullOrEmpty(distributedValue))
            {
                var deserializedValue = JsonSerializer.Deserialize<T>(distributedValue, _jsonOptions);

                // Store in memory cache for faster access
                _memoryCache.Set(key, deserializedValue, TimeSpan.FromMinutes(5));

                _logger.LogDebug("Cache hit (Distributed): {Key}", key);
                return deserializedValue;
            }

            _logger.LogDebug("Cache miss: {Key}", key);
            return null;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting cache value for key: {Key}", key);
            return null;
        }
    }

    public async Task SetAsync<T>(string key, T value, TimeSpan? expiry = null) where T : class
    {
        try
        {
            var defaultExpiry = expiry ?? TimeSpan.FromMinutes(30);

            // Set in memory cache
            _memoryCache.Set(key, value, defaultExpiry);

            // Set in distributed cache
            var serializedValue = JsonSerializer.Serialize(value, _jsonOptions);
            var options = new DistributedCacheEntryOptions
            {
                AbsoluteExpirationRelativeToNow = defaultExpiry
            };

            await _distributedCache.SetStringAsync(key, serializedValue, options);

            _logger.LogDebug("Cache set: {Key} (expires in {Expiry})", key, defaultExpiry);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error setting cache value for key: {Key}", key);
        }
    }

    public async Task RemoveAsync(string key)
    {
        try
        {
            _memoryCache.Remove(key);
            await _distributedCache.RemoveAsync(key);
            _logger.LogDebug("Cache removed: {Key}", key);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error removing cache value for key: {Key}", key);
        }
    }

    public async Task RemoveByPatternAsync(string pattern)
    {
        // TODO: Implement pattern-based cache invalidation
        // This is a simplified implementation
        _logger.LogWarning("Pattern-based cache removal not fully implemented: {Pattern}", pattern);
        await Task.CompletedTask;
    }

    public async Task<bool> ExistsAsync(string key)
    {
        try
        {
            if (_memoryCache.TryGetValue(key, out _))
                return true;

            var distributedValue = await _distributedCache.GetStringAsync(key);
            return !string.IsNullOrEmpty(distributedValue);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error checking cache existence for key: {Key}", key);
            return false;
        }
    }
}' \
"Multi-layer cache service with memory and distributed caching"

    # Create ProductService with caching
    create_file_interactive "Services/ProductService.cs" \
'using PerformanceDemo.Models;

namespace PerformanceDemo.Services;

public interface IProductService
{
    Task<IEnumerable<Product>> GetAllProductsAsync();
    Task<Product?> GetProductByIdAsync(int id);
    Task<IEnumerable<ProductSummary>> GetProductSummariesAsync();
    Task<Product> CreateProductAsync(Product product);
    Task UpdateProductAsync(int id, Product product);
    Task DeleteProductAsync(int id);
    Task<CacheStatistics> GetCacheStatisticsAsync();
}

public class ProductService : IProductService
{
    private readonly ICacheService _cacheService;
    private readonly ILogger<ProductService> _logger;
    private static readonly List<Product> _products = new();
    private static int _nextId = 1;
    private static readonly CacheStatistics _stats = new();

    // Cache keys
    private const string AllProductsCacheKey = "products:all";
    private const string ProductCacheKeyPrefix = "product:";
    private const string ProductSummariesCacheKey = "products:summaries";

    public ProductService(ICacheService cacheService, ILogger<ProductService> logger)
    {
        _cacheService = cacheService;
        _logger = logger;

        // Initialize with sample data if empty
        if (!_products.Any())
        {
            InitializeSampleData();
        }
    }

    public async Task<IEnumerable<Product>> GetAllProductsAsync()
    {
        var stopwatch = System.Diagnostics.Stopwatch.StartNew();
        _stats.TotalRequests++;

        try
        {
            var cachedProducts = await _cacheService.GetAsync<List<Product>>(AllProductsCacheKey);
            if (cachedProducts != null)
            {
                _stats.CacheHits++;
                _logger.LogInformation("Cache hit for all products");
                return cachedProducts;
            }

            _stats.CacheMisses++;
            _logger.LogInformation("Cache miss for all products - fetching from data source");

            // Simulate database delay
            await Task.Delay(100);

            var products = _products.ToList();
            await _cacheService.SetAsync(AllProductsCacheKey, products, TimeSpan.FromMinutes(10));

            return products;
        }
        finally
        {
            stopwatch.Stop();
            _stats.AverageResponseTime = TimeSpan.FromMilliseconds(
                (_stats.AverageResponseTime.TotalMilliseconds * (_stats.TotalRequests - 1) + stopwatch.ElapsedMilliseconds) / _stats.TotalRequests);
        }
    }

    public async Task<Product?> GetProductByIdAsync(int id)
    {
        var cacheKey = $"{ProductCacheKeyPrefix}{id}";
        _stats.TotalRequests++;

        var cachedProduct = await _cacheService.GetAsync<Product>(cacheKey);
        if (cachedProduct != null)
        {
            _stats.CacheHits++;
            return cachedProduct;
        }

        _stats.CacheMisses++;

        // Simulate database delay
        await Task.Delay(50);

        var product = _products.FirstOrDefault(p => p.Id == id);
        if (product != null)
        {
            await _cacheService.SetAsync(cacheKey, product, TimeSpan.FromMinutes(15));
        }

        return product;
    }

    public async Task<IEnumerable<ProductSummary>> GetProductSummariesAsync()
    {
        var cachedSummaries = await _cacheService.GetAsync<List<ProductSummary>>(ProductSummariesCacheKey);
        if (cachedSummaries != null)
        {
            return cachedSummaries;
        }

        // Simulate expensive operation
        await Task.Delay(200);

        var summaries = _products.Select(p => new ProductSummary
        {
            Id = p.Id,
            Name = p.Name,
            Price = p.Price,
            Category = p.Category
        }).ToList();

        await _cacheService.SetAsync(ProductSummariesCacheKey, summaries, TimeSpan.FromMinutes(5));
        return summaries;
    }

    public async Task<Product> CreateProductAsync(Product product)
    {
        product.Id = _nextId++;
        product.CreatedAt = DateTime.UtcNow;
        product.UpdatedAt = DateTime.UtcNow;

        _products.Add(product);

        // Invalidate related caches
        await _cacheService.RemoveAsync(AllProductsCacheKey);
        await _cacheService.RemoveAsync(ProductSummariesCacheKey);

        _logger.LogInformation("Created product {ProductId} and invalidated caches", product.Id);
        return product;
    }

    public async Task UpdateProductAsync(int id, Product product)
    {
        var existingProduct = _products.FirstOrDefault(p => p.Id == id);
        if (existingProduct == null)
        {
            throw new KeyNotFoundException($"Product with ID {id} not found");
        }

        existingProduct.Name = product.Name;
        existingProduct.Description = product.Description;
        existingProduct.Price = product.Price;
        existingProduct.Category = product.Category;
        existingProduct.StockQuantity = product.StockQuantity;
        existingProduct.IsActive = product.IsActive;
        existingProduct.UpdatedAt = DateTime.UtcNow;

        // Invalidate related caches
        await _cacheService.RemoveAsync($"{ProductCacheKeyPrefix}{id}");
        await _cacheService.RemoveAsync(AllProductsCacheKey);
        await _cacheService.RemoveAsync(ProductSummariesCacheKey);

        _logger.LogInformation("Updated product {ProductId} and invalidated caches", id);
    }

    public async Task DeleteProductAsync(int id)
    {
        var product = _products.FirstOrDefault(p => p.Id == id);
        if (product == null)
        {
            throw new KeyNotFoundException($"Product with ID {id} not found");
        }

        _products.Remove(product);

        // Invalidate related caches
        await _cacheService.RemoveAsync($"{ProductCacheKeyPrefix}{id}");
        await _cacheService.RemoveAsync(AllProductsCacheKey);
        await _cacheService.RemoveAsync(ProductSummariesCacheKey);

        _logger.LogInformation("Deleted product {ProductId} and invalidated caches", id);
    }

    public async Task<CacheStatistics> GetCacheStatisticsAsync()
    {
        await Task.CompletedTask;
        return _stats;
    }

    private void InitializeSampleData()
    {
        var sampleProducts = new[]
        {
            new Product { Id = _nextId++, Name = "Laptop Pro", Description = "High-performance laptop", Price = 1299.99m, Category = "Electronics", StockQuantity = 50 },
            new Product { Id = _nextId++, Name = "Wireless Mouse", Description = "Ergonomic wireless mouse", Price = 29.99m, Category = "Electronics", StockQuantity = 200 },
            new Product { Id = _nextId++, Name = "Coffee Mug", Description = "Ceramic coffee mug", Price = 12.99m, Category = "Kitchen", StockQuantity = 100 },
            new Product { Id = _nextId++, Name = "Desk Chair", Description = "Comfortable office chair", Price = 199.99m, Category = "Furniture", StockQuantity = 25 },
            new Product { Id = _nextId++, Name = "Notebook", Description = "Spiral-bound notebook", Price = 4.99m, Category = "Office", StockQuantity = 500 }
        };

        _products.AddRange(sampleProducts);
    }
}' \
"ProductService with comprehensive caching implementation"

    # Create ProductsController with caching
    create_file_interactive "Controllers/ProductsController.cs" \
'using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.OutputCaching;
using PerformanceDemo.Models;
using PerformanceDemo.Services;

namespace PerformanceDemo.Controllers;

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
    /// Get all products with caching
    /// </summary>
    [HttpGet]
    [OutputCache(PolicyName = "Products")]
    [ResponseCache(Duration = 300, Location = ResponseCacheLocation.Any, VaryByQueryKeys = new[] { "*" })]
    public async Task<ActionResult<IEnumerable<Product>>> GetProducts()
    {
        var stopwatch = System.Diagnostics.Stopwatch.StartNew();

        try
        {
            var products = await _productService.GetAllProductsAsync();

            stopwatch.Stop();
            _logger.LogInformation("GetProducts completed in {ElapsedMs}ms", stopwatch.ElapsedMilliseconds);

            return Ok(products);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting products");
            return StatusCode(500, "Internal server error");
        }
    }

    /// <summary>
    /// Get product by ID with caching
    /// </summary>
    [HttpGet("{id}")]
    [OutputCache(Duration = 900)] // 15 minutes
    public async Task<ActionResult<Product>> GetProduct(int id)
    {
        try
        {
            var product = await _productService.GetProductByIdAsync(id);

            if (product == null)
            {
                return NotFound($"Product with ID {id} not found");
            }

            return Ok(product);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting product {ProductId}", id);
            return StatusCode(500, "Internal server error");
        }
    }

    /// <summary>
    /// Get product summaries (lightweight cached data)
    /// </summary>
    [HttpGet("summaries")]
    [OutputCache(Duration = 300)]
    public async Task<ActionResult<IEnumerable<ProductSummary>>> GetProductSummaries()
    {
        try
        {
            var summaries = await _productService.GetProductSummariesAsync();
            return Ok(summaries);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting product summaries");
            return StatusCode(500, "Internal server error");
        }
    }

    /// <summary>
    /// Create a new product (invalidates cache)
    /// </summary>
    [HttpPost]
    public async Task<ActionResult<Product>> CreateProduct([FromBody] Product product)
    {
        try
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            var createdProduct = await _productService.CreateProductAsync(product);

            return CreatedAtAction(nameof(GetProduct), new { id = createdProduct.Id }, createdProduct);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error creating product");
            return StatusCode(500, "Internal server error");
        }
    }

    /// <summary>
    /// Update a product (invalidates cache)
    /// </summary>
    [HttpPut("{id}")]
    public async Task<IActionResult> UpdateProduct(int id, [FromBody] Product product)
    {
        try
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            await _productService.UpdateProductAsync(id, product);
            return NoContent();
        }
        catch (KeyNotFoundException)
        {
            return NotFound($"Product with ID {id} not found");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error updating product {ProductId}", id);
            return StatusCode(500, "Internal server error");
        }
    }

    /// <summary>
    /// Delete a product (invalidates cache)
    /// </summary>
    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteProduct(int id)
    {
        try
        {
            await _productService.DeleteProductAsync(id);
            return NoContent();
        }
        catch (KeyNotFoundException)
        {
            return NotFound($"Product with ID {id} not found");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error deleting product {ProductId}", id);
            return StatusCode(500, "Internal server error");
        }
    }

    /// <summary>
    /// Get cache performance statistics
    /// </summary>
    [HttpGet("cache/stats")]
    public async Task<ActionResult<CacheStatistics>> GetCacheStatistics()
    {
        try
        {
            var stats = await _productService.GetCacheStatisticsAsync();
            return Ok(stats);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting cache statistics");
            return StatusCode(500, "Internal server error");
        }
    }
}' \
"ProductsController with comprehensive caching and performance monitoring"

    # Create appsettings.json with performance configuration
    create_file_interactive "appsettings.json" \
'{
  "ConnectionStrings": {
    "Redis": "localhost:6379"
  },
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning",
      "PerformanceDemo": "Debug"
    }
  },
  "AllowedHosts": "*",
  "Performance": {
    "CacheSettings": {
      "DefaultExpiration": "00:30:00",
      "MemoryCacheSize": 1024,
      "EnableDistributedCache": true
    },
    "CompressionSettings": {
      "EnableCompression": true,
      "CompressionLevel": "Optimal"
    }
  }
}' \
"Configuration with performance and caching settings"

    # Create Docker Compose for Redis
    create_file_interactive "docker-compose.yml" \
'version: "3.8"

services:
  redis:
    image: redis:7-alpine
    container_name: performance-demo-redis
    ports:
      - "6379:6379"
    command: redis-server --appendonly yes
    volumes:
      - redis_data:/data
    restart: unless-stopped

  performance-demo:
    build: .
    container_name: performance-demo-api
    ports:
      - "5000:8080"
    depends_on:
      - redis
    environment:
      - ASPNETCORE_ENVIRONMENT=Development
      - ConnectionStrings__Redis=redis:6379
    restart: unless-stopped

volumes:
  redis_data:' \
"Docker Compose configuration with Redis for distributed caching"

    # Create performance guide
    create_file_interactive "PERFORMANCE_GUIDE.md" \
'# Exercise 1: Caching Implementation

## 🎯 Objective
Implement comprehensive caching strategies to improve API performance by 80%+.

## ⏱️ Time Allocation
**Total Time**: 40 minutes
- Setup and Configuration: 10 minutes
- Caching Implementation: 20 minutes
- Performance Testing: 10 minutes

## 🚀 Getting Started

### Step 1: Start Redis (Optional)
```bash
docker-compose up -d redis
```

### Step 2: Run the Application
```bash
dotnet run
```

### Step 3: Test Performance
```bash
# Test without cache (first request)
curl http://localhost:5000/api/products

# Test with cache (subsequent requests)
curl http://localhost:5000/api/products

# Check cache statistics
curl http://localhost:5000/api/products/cache/stats
```

## 🧪 Performance Exercises

### Exercise A: Cache Performance Testing
1. Make multiple requests to `/api/products`
2. Observe response times and cache hit ratios
3. Test cache invalidation by creating/updating products
4. Monitor cache statistics endpoint

### Exercise B: Cache Configuration
1. Experiment with different cache expiration times
2. Test memory vs distributed cache performance
3. Implement cache warming strategies
4. Add cache metrics and monitoring

### Exercise C: Advanced Caching Patterns
1. Implement cache-aside pattern variations
2. Add cache tags for better invalidation
3. Test cache serialization performance
4. Implement background cache refresh

## 📊 Performance Metrics to Monitor
- Response time improvement (target: 80% reduction)
- Cache hit ratio (target: >90% for repeated requests)
- Memory usage optimization
- Database query reduction

## ✅ Success Criteria
- [ ] Multi-layer caching is working correctly
- [ ] Cache invalidation works on data changes
- [ ] Performance improvements are measurable
- [ ] Cache statistics are accurate
- [ ] Redis integration is functional

## 🔄 Next Steps
After mastering caching, move on to Exercise 2 for database optimization.
' \
"Comprehensive performance guide with practical exercises"

    echo -e "${GREEN}🎉 Exercise 1 template created successfully!${NC}"
    echo ""
    echo -e "${YELLOW}📋 Next steps:${NC}"
    echo "1. Start Redis: ${CYAN}docker-compose up -d redis${NC}"
    echo "2. Run the API: ${CYAN}dotnet run${NC}"
    echo "3. Visit: ${CYAN}http://localhost:5000/swagger${NC}"
    echo "4. Test performance: ${CYAN}curl http://localhost:5000/api/products/cache/stats${NC}"
    echo "5. Follow the PERFORMANCE_GUIDE.md for optimization exercises"

elif [[ $EXERCISE_NAME == "exercise02" ]]; then
    echo -e "${CYAN}Exercise 2 implementation would be added here...${NC}"
    echo -e "${YELLOW}This exercise adds database optimization techniques${NC}"

elif [[ $EXERCISE_NAME == "exercise03" ]]; then
    echo -e "${CYAN}Exercise 3 implementation would be added here...${NC}"
    echo -e "${YELLOW}This exercise implements async and memory optimization${NC}"

elif [[ $EXERCISE_NAME == "exercise04" ]]; then
    echo -e "${CYAN}Exercise 4 implementation would be added here...${NC}"
    echo -e "${YELLOW}This exercise adds monitoring and profiling tools${NC}"

fi

echo ""
echo -e "${GREEN}✅ Module 8 Exercise Setup Complete!${NC}"
echo -e "${CYAN}Happy optimizing! 🚀⚡${NC}"
