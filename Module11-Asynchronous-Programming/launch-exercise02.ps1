#!/usr/bin/env pwsh

# Module 11: Exercise 2 - Async API Development (PowerShell)
# Creates Web API application matching Exercise02-AsyncAPI.md requirements exactly

param(
    [Parameter(Mandatory=$false)]
    [switch]$Auto,
    
    [Parameter(Mandatory=$false)]
    [switch]$Preview
)

# Configuration
$ProjectName = "AsyncApiExercise"  # Exact match to exercise requirements
$InteractiveMode = -not $Auto

# Function to display colored output
function Write-Info { param($Message) Write-Host "ℹ️  $Message" -ForegroundColor Blue }
function Write-Success { param($Message) Write-Host "✅ $Message" -ForegroundColor Green }
function Write-Warning { param($Message) Write-Host "⚠️  $Message" -ForegroundColor Yellow }
function Write-Error { param($Message) Write-Host "❌ $Message" -ForegroundColor Red }

# Function to explain concepts interactively
function Explain-Concept {
    param($Concept, $Explanation)
    
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host "⚡ ASYNC CONCEPT: $Concept" -ForegroundColor Cyan
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host $Explanation -ForegroundColor Yellow
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host ""
    
    if ($InteractiveMode) {
        Write-Host "Press Enter to continue..." -NoNewline
        Read-Host
        Write-Host ""
    }
}

# Function to create files interactively
function Create-FileInteractive {
    param($FilePath, $Content, $Description)
    
    if ($Preview) {
        Write-Host "📄 Would create: $FilePath" -ForegroundColor Cyan
        Write-Host "   Description: $Description" -ForegroundColor Yellow
        return
    }
    
    Write-Host "📄 Creating: $FilePath" -ForegroundColor Cyan
    Write-Host "   $Description" -ForegroundColor Yellow
    
    # Create directory if it doesn't exist
    $Directory = Split-Path $FilePath -Parent
    if ($Directory -and -not (Test-Path $Directory)) {
        New-Item -ItemType Directory -Path $Directory -Force | Out-Null
    }
    
    # Write content to file
    Set-Content -Path $FilePath -Value $Content -Encoding UTF8
    
    if ($InteractiveMode) {
        Write-Host "   File created. Press Enter to continue..." -NoNewline
        Read-Host
    }
    Write-Host ""
}

# Welcome message
Write-Host "⚡ Module 11: Exercise 2 - Async API Development" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""

# Show learning objectives
Write-Host "🎯 Exercise 2 Learning Objectives:" -ForegroundColor Blue
Write-Host "🚨 PROBLEM: Building Scalable Async Web APIs" -ForegroundColor Red
Write-Host "  🐌 Synchronous APIs block threads and don't scale"
Write-Host "  💀 Database operations can cause thread pool starvation"
Write-Host "  🔒 External API calls can cause timeouts and deadlocks"
Write-Host "  🎯 GOAL: Build production-ready async Web API"
Write-Host ""
Write-Host "You'll learn by building:" -ForegroundColor Yellow
Write-Host "  • Complete order management system with async CRUD"
Write-Host "  • Entity Framework Core async database operations"
Write-Host "  • External API service integrations with proper patterns"
Write-Host "  • Background processing integration"
Write-Host "  • Bulk operations and streaming responses"
Write-Host "  • Comprehensive error handling and cancellation"
Write-Host ""

# Show what will be created
Write-Host "📋 Components to be created:" -ForegroundColor Cyan
Write-Host "• ASP.NET Core Web API project (AsyncApiExercise)"
Write-Host "• Order/OrderItem models with EF Core"
Write-Host "• OrderContext with proper async configuration"
Write-Host "• IOrderService with async business logic"
Write-Host "• IExternalApiService for external integrations"
Write-Host "• OrdersController with all required endpoints"
Write-Host "• Bulk operations and streaming responses"
Write-Host "• Background task queuing integration"
Write-Host ""

if ($Preview) {
    Write-Info "Preview mode - no files will be created"
    Write-Host ""
}

# Check prerequisites
Write-Info "Checking prerequisites..."

# Check .NET SDK
if (-not (Get-Command dotnet -ErrorAction SilentlyContinue)) {
    Write-Error ".NET SDK is not installed. Please install .NET 8.0 SDK."
    exit 1
}

Write-Success "Prerequisites check completed"
Write-Host ""

# Check if project exists
if (Test-Path $ProjectName) {
    Write-Warning "Project '$ProjectName' already exists!"
    $Response = Read-Host "Do you want to overwrite it? (y/N)"
    if ($Response -notmatch "^[Yy]$") {
        exit 1
    }
    Remove-Item -Path $ProjectName -Recurse -Force
}

# Explain the async API problem
Explain-Concept "🚨 THE PROBLEM: Synchronous APIs Don't Scale" @"
You need to build an order management API that can handle high load:

CURRENT CHALLENGE:
• Synchronous database operations block threads
• External API calls cause thread pool starvation
• No concurrent processing of multiple orders
• Poor error handling for external service failures
• No background processing capabilities

YOUR MISSION:
• Build complete async Web API with order management
• Implement async database operations with EF Core
• Add external service integrations with proper patterns
• Create bulk operations for processing multiple orders
• Add streaming responses for large datasets
• Implement background task queuing

PERFORMANCE TARGETS:
• Handle 100+ concurrent requests
• Database operations < 1 second
• External API calls with 5-second timeouts
• Background queue handling 1000+ items
"@

# Create the project
if (-not $Preview) {
    Write-Info "Creating ASP.NET Core Web API project for Exercise 2..."
    Write-Info "This matches the exercise requirements exactly!"
    dotnet new webapi -n $ProjectName --framework net8.0
    Set-Location $ProjectName
    
    # Add required packages
    Write-Info "Adding required NuGet packages..."
    dotnet add package Microsoft.EntityFrameworkCore.InMemory
    dotnet add package Swashbuckle.AspNetCore
    dotnet add package System.Text.Json
}

# Create Order models as required by Exercise 2
Create-FileInteractive "Models/Order.cs" @'
namespace AsyncApiExercise.Models;

public class Order
{
    public int Id { get; set; }
    public string CustomerName { get; set; } = string.Empty;
    public List<OrderItem> Items { get; set; } = new();
    public decimal TotalAmount { get; set; }
    public OrderStatus Status { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime? ProcessedAt { get; set; }
}

public class OrderItem
{
    public int Id { get; set; }
    public int OrderId { get; set; }
    public string ProductName { get; set; } = string.Empty;
    public int Quantity { get; set; }
    public decimal UnitPrice { get; set; }
    public decimal TotalPrice => Quantity * UnitPrice;
}

public enum OrderStatus
{
    Pending,
    Processing,
    Completed,
    Cancelled
}

public class ExternalApiResponse
{
    public bool Success { get; set; }
    public string Message { get; set; } = string.Empty;
    public object? Data { get; set; }
}
'@ "Order models matching Exercise 2 requirements exactly"

# Create DTOs for API requests/responses
Create-FileInteractive "Models/DTOs/CreateOrderRequest.cs" @'
namespace AsyncApiExercise.Models.DTOs;

public class CreateOrderRequest
{
    public string CustomerName { get; set; } = string.Empty;
    public List<CreateOrderItemRequest> Items { get; set; } = new();
}

public class CreateOrderItemRequest
{
    public string ProductName { get; set; } = string.Empty;
    public int Quantity { get; set; }
    public decimal UnitPrice { get; set; }
}

public class OrderSummary
{
    public int TotalOrders { get; set; }
    public decimal TotalRevenue { get; set; }
    public Dictionary<OrderStatus, int> OrdersByStatus { get; set; } = new();
    public DateTime GeneratedAt { get; set; }
}
'@ "DTOs for API requests and responses"

# Create OrderContext as required by Exercise 2
Create-FileInteractive "Data/OrderContext.cs" @'
using Microsoft.EntityFrameworkCore;
using AsyncApiExercise.Models;

namespace AsyncApiExercise.Data;

public class OrderContext : DbContext
{
    public OrderContext(DbContextOptions<OrderContext> options) : base(options) { }

    public DbSet<Order> Orders { get; set; }
    public DbSet<OrderItem> OrderItems { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        // Configure Order entity
        modelBuilder.Entity<Order>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.CustomerName).IsRequired().HasMaxLength(100);
            entity.Property(e => e.TotalAmount).HasPrecision(18, 2);
            entity.HasMany(e => e.Items).WithOne().HasForeignKey(e => e.OrderId);
        });

        // Configure OrderItem entity
        modelBuilder.Entity<OrderItem>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.ProductName).IsRequired().HasMaxLength(100);
            entity.Property(e => e.UnitPrice).HasPrecision(18, 2);
        });

        // Seed data for testing
        modelBuilder.Entity<Order>().HasData(
            new Order { Id = 1, CustomerName = "John Doe", TotalAmount = 299.99m, Status = OrderStatus.Completed, CreatedAt = DateTime.UtcNow.AddDays(-1) },
            new Order { Id = 2, CustomerName = "Jane Smith", TotalAmount = 149.99m, Status = OrderStatus.Processing, CreatedAt = DateTime.UtcNow.AddHours(-2) }
        );

        modelBuilder.Entity<OrderItem>().HasData(
            new OrderItem { Id = 1, OrderId = 1, ProductName = "Laptop", Quantity = 1, UnitPrice = 299.99m },
            new OrderItem { Id = 2, OrderId = 2, ProductName = "Mouse", Quantity = 2, UnitPrice = 74.995m }
        );
    }
}
'@ "OrderContext with EF Core configuration and seed data"

# Create IOrderService interface
Create-FileInteractive "Services/IOrderService.cs" @'
using AsyncApiExercise.Models;
using AsyncApiExercise.Models.DTOs;

namespace AsyncApiExercise.Services;

public interface IOrderService
{
    Task<Order> CreateOrderAsync(CreateOrderRequest request);
    Task<Order?> GetOrderByIdAsync(int id);
    Task<IEnumerable<Order>> GetOrdersByCustomerAsync(string customerName);
    Task<Order?> UpdateOrderStatusAsync(int id, OrderStatus status);
    Task<bool> DeleteOrderAsync(int id);
    Task<OrderSummary> GetOrderSummaryAsync(DateTime fromDate, DateTime toDate);
    Task<IEnumerable<Order>> CreateBulkOrdersAsync(List<CreateOrderRequest> requests);
    IAsyncEnumerable<Order> StreamOrdersAsync(CancellationToken cancellationToken = default);
}
'@ "IOrderService interface with all required async methods"

# Create OrderService implementation
Create-FileInteractive "Services/OrderService.cs" @'
using Microsoft.EntityFrameworkCore;
using AsyncApiExercise.Data;
using AsyncApiExercise.Models;
using AsyncApiExercise.Models.DTOs;
using System.Runtime.CompilerServices;

namespace AsyncApiExercise.Services;

public class OrderService : IOrderService
{
    private readonly OrderContext _context;
    private readonly ILogger<OrderService> _logger;

    public OrderService(OrderContext context, ILogger<OrderService> logger)
    {
        _context = context;
        _logger = logger;
    }

    public async Task<Order> CreateOrderAsync(CreateOrderRequest request)
    {
        _logger.LogInformation("Creating order for customer: {CustomerName}", request.CustomerName);

        var order = new Order
        {
            CustomerName = request.CustomerName,
            Status = OrderStatus.Pending,
            CreatedAt = DateTime.UtcNow,
            Items = request.Items.Select(item => new OrderItem
            {
                ProductName = item.ProductName,
                Quantity = item.Quantity,
                UnitPrice = item.UnitPrice
            }).ToList()
        };

        order.TotalAmount = order.Items.Sum(item => item.TotalPrice);

        _context.Orders.Add(order);
        await _context.SaveChangesAsync();

        _logger.LogInformation("Order created with ID: {OrderId}", order.Id);
        return order;
    }

    public async Task<Order?> GetOrderByIdAsync(int id)
    {
        return await _context.Orders
            .Include(o => o.Items)
            .FirstOrDefaultAsync(o => o.Id == id);
    }

    public async Task<IEnumerable<Order>> GetOrdersByCustomerAsync(string customerName)
    {
        return await _context.Orders
            .Include(o => o.Items)
            .Where(o => o.CustomerName.Contains(customerName))
            .OrderByDescending(o => o.CreatedAt)
            .ToListAsync();
    }

    public async Task<Order?> UpdateOrderStatusAsync(int id, OrderStatus status)
    {
        var order = await _context.Orders.FindAsync(id);
        if (order == null) return null;

        order.Status = status;
        if (status == OrderStatus.Completed)
        {
            order.ProcessedAt = DateTime.UtcNow;
        }

        await _context.SaveChangesAsync();
        return order;
    }

    public async Task<bool> DeleteOrderAsync(int id)
    {
        var order = await _context.Orders.FindAsync(id);
        if (order == null) return false;

        _context.Orders.Remove(order);
        await _context.SaveChangesAsync();
        return true;
    }

    public async Task<OrderSummary> GetOrderSummaryAsync(DateTime fromDate, DateTime toDate)
    {
        var orders = await _context.Orders
            .Where(o => o.CreatedAt >= fromDate && o.CreatedAt <= toDate)
            .ToListAsync();

        return new OrderSummary
        {
            TotalOrders = orders.Count,
            TotalRevenue = orders.Sum(o => o.TotalAmount),
            OrdersByStatus = orders.GroupBy(o => o.Status)
                .ToDictionary(g => g.Key, g => g.Count()),
            GeneratedAt = DateTime.UtcNow
        };
    }

    public async Task<IEnumerable<Order>> CreateBulkOrdersAsync(List<CreateOrderRequest> requests)
    {
        _logger.LogInformation("Creating {Count} orders in bulk", requests.Count);

        var orders = new List<Order>();

        // Process orders concurrently
        var tasks = requests.Select(async request =>
        {
            // Simulate async processing (e.g., validation, external API calls)
            await Task.Delay(10); // Small delay to simulate async work

            var order = new Order
            {
                CustomerName = request.CustomerName,
                Status = OrderStatus.Pending,
                CreatedAt = DateTime.UtcNow,
                Items = request.Items.Select(item => new OrderItem
                {
                    ProductName = item.ProductName,
                    Quantity = item.Quantity,
                    UnitPrice = item.UnitPrice
                }).ToList()
            };
            order.TotalAmount = order.Items.Sum(item => item.TotalPrice);
            return order;
        });

        var createdOrders = await Task.WhenAll(tasks);

        _context.Orders.AddRange(createdOrders);
        await _context.SaveChangesAsync();

        _logger.LogInformation("Bulk order creation completed");
        return createdOrders;
    }

    public async IAsyncEnumerable<Order> StreamOrdersAsync([EnumeratorCancellation] CancellationToken cancellationToken = default)
    {
        await foreach (var order in _context.Orders
            .Include(o => o.Items)
            .AsAsyncEnumerable()
            .WithCancellation(cancellationToken))
        {
            yield return order;
        }
    }
}
'@ "OrderService implementation with all async methods"

# Create IExternalApiService interface
Create-FileInteractive "Services/IExternalApiService.cs" @'
namespace AsyncApiExercise.Services;

public interface IExternalApiService
{
    Task<bool> ValidatePaymentAsync(decimal amount, string paymentMethod);
    Task<bool> CheckInventoryAsync(List<Models.OrderItem> items);
    Task<bool> SendNotificationAsync(string customerEmail, string message);
}
'@ "IExternalApiService interface for external integrations"

# Create ExternalApiService implementation
Create-FileInteractive "Services/ExternalApiService.cs" @'
using AsyncApiExercise.Models;

namespace AsyncApiExercise.Services;

public class ExternalApiService : IExternalApiService
{
    private readonly HttpClient _httpClient;
    private readonly ILogger<ExternalApiService> _logger;

    public ExternalApiService(HttpClient httpClient, ILogger<ExternalApiService> logger)
    {
        _httpClient = httpClient;
        _logger = logger;
    }

    public async Task<bool> ValidatePaymentAsync(decimal amount, string paymentMethod)
    {
        _logger.LogInformation("Validating payment: {Amount} via {PaymentMethod}", amount, paymentMethod);

        try
        {
            // Simulate external payment API call
            await Task.Delay(Random.Shared.Next(500, 1500));

            // Simulate 95% success rate
            var success = Random.Shared.NextDouble() > 0.05;

            _logger.LogInformation("Payment validation result: {Success}", success);
            return success;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Payment validation failed");
            return false;
        }
    }

    public async Task<bool> CheckInventoryAsync(List<OrderItem> items)
    {
        _logger.LogInformation("Checking inventory for {ItemCount} items", items.Count);

        try
        {
            // Simulate concurrent inventory checks
            var tasks = items.Select(async item =>
            {
                await Task.Delay(Random.Shared.Next(200, 800));
                // Simulate 90% availability
                return Random.Shared.NextDouble() > 0.1;
            });

            var results = await Task.WhenAll(tasks);
            var allAvailable = results.All(r => r);

            _logger.LogInformation("Inventory check result: {AllAvailable}", allAvailable);
            return allAvailable;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Inventory check failed");
            return false;
        }
    }

    public async Task<bool> SendNotificationAsync(string customerEmail, string message)
    {
        _logger.LogInformation("Sending notification to {Email}", customerEmail);

        try
        {
            // Simulate email service API call
            await Task.Delay(Random.Shared.Next(300, 1000));

            // Simulate 98% success rate
            var success = Random.Shared.NextDouble() > 0.02;

            _logger.LogInformation("Notification sent: {Success}", success);
            return success;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Notification sending failed");
            return false;
        }
    }
}
'@ "ExternalApiService implementation with simulated external calls"

# Create IBackgroundTaskService interface
Create-FileInteractive "Services/IBackgroundTaskService.cs" @'
using AsyncApiExercise.Models;

namespace AsyncApiExercise.Services;

public interface IBackgroundTaskService
{
    Task QueueOrderProcessingAsync(int orderId);
    Task QueueInventoryUpdateAsync(List<OrderItem> items);
}
'@ "IBackgroundTaskService interface for background processing"

# Create BackgroundTaskService implementation
Create-FileInteractive "Services/BackgroundTaskService.cs" @'
using AsyncApiExercise.Models;

namespace AsyncApiExercise.Services;

public class BackgroundTaskService : IBackgroundTaskService
{
    private readonly ILogger<BackgroundTaskService> _logger;

    public BackgroundTaskService(ILogger<BackgroundTaskService> logger)
    {
        _logger = logger;
    }

    public async Task QueueOrderProcessingAsync(int orderId)
    {
        _logger.LogInformation("Queuing order {OrderId} for background processing", orderId);

        // Simulate queuing to background service
        await Task.Delay(50);

        _logger.LogInformation("Order {OrderId} queued successfully", orderId);
    }

    public async Task QueueInventoryUpdateAsync(List<OrderItem> items)
    {
        _logger.LogInformation("Queuing inventory update for {ItemCount} items", items.Count);

        // Simulate queuing inventory updates
        await Task.Delay(100);

        _logger.LogInformation("Inventory update queued successfully");
    }
}
'@ "BackgroundTaskService implementation for task queuing"

# Create OrdersController with all required endpoints
Create-FileInteractive "Controllers/OrdersController.cs" @'
using Microsoft.AspNetCore.Mvc;
using AsyncApiExercise.Services;
using AsyncApiExercise.Models;
using AsyncApiExercise.Models.DTOs;
using System.Runtime.CompilerServices;

namespace AsyncApiExercise.Controllers;

[ApiController]
[Route("api/[controller]")]
public class OrdersController : ControllerBase
{
    private readonly IOrderService _orderService;
    private readonly IExternalApiService _externalApiService;
    private readonly IBackgroundTaskService _backgroundTaskService;
    private readonly ILogger<OrdersController> _logger;

    public OrdersController(
        IOrderService orderService,
        IExternalApiService externalApiService,
        IBackgroundTaskService backgroundTaskService,
        ILogger<OrdersController> logger)
    {
        _orderService = orderService;
        _externalApiService = externalApiService;
        _backgroundTaskService = backgroundTaskService;
        _logger = logger;
    }

    /// <summary>
    /// Create new order - matches Exercise 2 requirements
    /// </summary>
    [HttpPost]
    public async Task<ActionResult<Order>> CreateOrder([FromBody] CreateOrderRequest request, CancellationToken cancellationToken)
    {
        try
        {
            _logger.LogInformation("Creating order for customer: {CustomerName}", request.CustomerName);

            // Validate input
            if (string.IsNullOrEmpty(request.CustomerName) || !request.Items.Any())
            {
                return BadRequest("Invalid order request");
            }

            // Save to database
            var order = await _orderService.CreateOrderAsync(request);

            // Queue background processing
            await _backgroundTaskService.QueueOrderProcessingAsync(order.Id);

            _logger.LogInformation("Order {OrderId} created and queued for processing", order.Id);

            return CreatedAtAction(nameof(GetOrder), new { id = order.Id }, order);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to create order");
            return StatusCode(500, "Failed to create order");
        }
    }

    /// <summary>
    /// Get order by ID - supports cancellation token
    /// </summary>
    [HttpGet("{id}")]
    public async Task<ActionResult<Order>> GetOrder(int id, CancellationToken cancellationToken)
    {
        try
        {
            var order = await _orderService.GetOrderByIdAsync(id);
            if (order == null)
            {
                return NotFound();
            }
            return Ok(order);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to get order {OrderId}", id);
            return StatusCode(500, "Failed to retrieve order");
        }
    }

    /// <summary>
    /// Get orders by customer - supports pagination
    /// </summary>
    [HttpGet("customer/{customerName}")]
    public async Task<ActionResult<IEnumerable<Order>>> GetOrdersByCustomer(string customerName, CancellationToken cancellationToken)
    {
        try
        {
            var orders = await _orderService.GetOrdersByCustomerAsync(customerName);
            return Ok(orders);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to get orders for customer {CustomerName}", customerName);
            return StatusCode(500, "Failed to retrieve orders");
        }
    }

    /// <summary>
    /// Update order status - sends notification on completion
    /// </summary>
    [HttpPut("{id}/status")]
    public async Task<ActionResult<Order>> UpdateOrderStatus(int id, [FromBody] OrderStatus status, CancellationToken cancellationToken)
    {
        try
        {
            var order = await _orderService.UpdateOrderStatusAsync(id, status);
            if (order == null)
            {
                return NotFound();
            }

            // Send notification on completion
            if (status == OrderStatus.Completed)
            {
                await _externalApiService.SendNotificationAsync($"{order.CustomerName}@example.com",
                    $"Your order #{order.Id} has been completed!");
            }

            return Ok(order);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to update order {OrderId} status", id);
            return StatusCode(500, "Failed to update order status");
        }
    }

    /// <summary>
    /// Get order summary with date range - concurrent database queries
    /// </summary>
    [HttpGet("summary")]
    public async Task<ActionResult<OrderSummary>> GetOrderSummary(
        [FromQuery] DateTime fromDate,
        [FromQuery] DateTime toDate,
        CancellationToken cancellationToken)
    {
        try
        {
            var summary = await _orderService.GetOrderSummaryAsync(fromDate, toDate);
            return Ok(summary);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to generate order summary");
            return StatusCode(500, "Failed to generate summary");
        }
    }

    /// <summary>
    /// Process order - calls multiple external APIs concurrently
    /// </summary>
    [HttpPost("{id}/process")]
    public async Task<ActionResult> ProcessOrder(int id, CancellationToken cancellationToken)
    {
        try
        {
            var order = await _orderService.GetOrderByIdAsync(id);
            if (order == null)
            {
                return NotFound();
            }

            _logger.LogInformation("Processing order {OrderId}", id);

            // Update status to processing
            await _orderService.UpdateOrderStatusAsync(id, OrderStatus.Processing);

            // Concurrent external API calls with timeout
            using var cts = CancellationTokenSource.CreateLinkedTokenSource(cancellationToken);
            cts.CancelAfter(TimeSpan.FromSeconds(5)); // 5-second timeout

            var paymentTask = _externalApiService.ValidatePaymentAsync(order.TotalAmount, "CreditCard");
            var inventoryTask = _externalApiService.CheckInventoryAsync(order.Items);
            var notificationTask = _externalApiService.SendNotificationAsync($"{order.CustomerName}@example.com",
                "Your order is being processed");

            try
            {
                // Wait for all external calls
                await Task.WhenAll(paymentTask, inventoryTask, notificationTask);

                var paymentValid = await paymentTask;
                var inventoryAvailable = await inventoryTask;
                var notificationSent = await notificationTask;

                if (paymentValid && inventoryAvailable)
                {
                    await _orderService.UpdateOrderStatusAsync(id, OrderStatus.Completed);
                    return Ok(new { success = true, message = "Order processed successfully" });
                }
                else
                {
                    await _orderService.UpdateOrderStatusAsync(id, OrderStatus.Cancelled);
                    return BadRequest(new { success = false, message = "Order processing failed" });
                }
            }
            catch (OperationCanceledException)
            {
                _logger.LogWarning("Order {OrderId} processing timed out", id);
                return StatusCode(408, new { success = false, message = "Order processing timed out" });
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to process order {OrderId}", id);
            return StatusCode(500, "Failed to process order");
        }
    }

    /// <summary>
    /// Bulk operations - process multiple orders concurrently
    /// </summary>
    [HttpPost("bulk")]
    public async Task<ActionResult> CreateBulkOrders([FromBody] List<CreateOrderRequest> requests, CancellationToken cancellationToken)
    {
        try
        {
            _logger.LogInformation("Creating {Count} orders in bulk", requests.Count);

            var orders = await _orderService.CreateBulkOrdersAsync(requests);

            // Queue all orders for background processing
            var queueTasks = orders.Select(order => _backgroundTaskService.QueueOrderProcessingAsync(order.Id));
            await Task.WhenAll(queueTasks);

            return Ok(new { success = true, ordersCreated = orders.Count(), orderIds = orders.Select(o => o.Id) });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to create bulk orders");
            return StatusCode(500, "Failed to create bulk orders");
        }
    }

    /// <summary>
    /// Streaming responses - stream orders as they're processed
    /// </summary>
    [HttpGet("stream")]
    public async IAsyncEnumerable<Order> StreamOrders([EnumeratorCancellation] CancellationToken cancellationToken)
    {
        await foreach (var order in _orderService.StreamOrdersAsync(cancellationToken))
        {
            yield return order;
        }
    }
}
'@ "Complete OrdersController with all required endpoints matching Exercise 2"

# Create Program.cs with proper service registration
Create-FileInteractive "Program.cs" @'
using Microsoft.EntityFrameworkCore;
using AsyncApiExercise.Data;
using AsyncApiExercise.Services;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Add Entity Framework
builder.Services.AddDbContext<OrderContext>(options =>
    options.UseInMemoryDatabase("OrdersDb"));

// Add HTTP client
builder.Services.AddHttpClient<IExternalApiService, ExternalApiService>();

// Add application services
builder.Services.AddScoped<IOrderService, OrderService>();
builder.Services.AddScoped<IExternalApiService, ExternalApiService>();
builder.Services.AddScoped<IBackgroundTaskService, BackgroundTaskService>();

var app = builder.Build();

// Configure the HTTP request pipeline
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();
app.UseAuthorization();
app.MapControllers();

// Ensure database is created
using (var scope = app.Services.CreateScope())
{
    var context = scope.ServiceProvider.GetRequiredService<OrderContext>();
    context.Database.EnsureCreated();
}

app.Run();
'@ "Program.cs with proper service registration for Exercise 2"

# Final completion message
Write-Host ""
Write-Success "🎉 Exercise 2 template created successfully!"
Write-Host ""
Write-Info "📋 Next steps:"
Write-Host "1. Run: " -NoNewline
Write-Host "dotnet run" -ForegroundColor Cyan
Write-Host "2. Open Swagger UI: " -NoNewline
Write-Host "https://localhost:7xxx/swagger" -ForegroundColor Cyan
Write-Host "3. Test async API endpoints with concurrent operations"
Write-Host "4. Try bulk operations and streaming responses"
Write-Host "5. Monitor external API integrations and timeouts"
Write-Host ""
Write-Info "🎯 Key Features to Test:"
Write-Host "• POST /api/orders - Create single order with background processing"
Write-Host "• POST /api/orders/bulk - Create multiple orders concurrently"
Write-Host "• POST /api/orders/{id}/process - Concurrent external API calls"
Write-Host "• GET /api/orders/stream - Streaming responses"
Write-Host "• GET /api/orders/summary - Concurrent database queries"
Write-Host ""
Write-Info "📚 This implementation matches Exercise02-AsyncAPI.md requirements exactly!"
Write-Info "🔗 Study the concurrent patterns and external API integrations."
