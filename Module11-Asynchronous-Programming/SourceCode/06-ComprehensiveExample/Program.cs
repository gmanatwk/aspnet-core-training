using Microsoft.EntityFrameworkCore;
using Serilog;
using System.Diagnostics;
using System.Threading.Channels;

// Configure Serilog
Log.Logger = new LoggerConfiguration()
    .WriteTo.Console()
    .CreateLogger();

var builder = WebApplication.CreateBuilder(args);

// Add Serilog
builder.Host.UseSerilog();

// Add services to the container.
builder.Services.AddControllers();
builder.Services.AddSignalR();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Add Entity Framework
builder.Services.AddDbContext<ECommerceContext>(options =>
{
    options.UseInMemoryDatabase("ECommerceAsyncDemo");
    // For SQL Server, uncomment below and update connection string
    // options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection"));
});

// Add HttpClient
builder.Services.AddHttpClient();

// Add health checks
builder.Services.AddHealthChecks()
    .AddDbContextCheck<ECommerceContext>();

// Add application services
builder.Services.AddScoped<IOrderService, OrderService>();
builder.Services.AddScoped<IInventoryService, InventoryService>();
builder.Services.AddScoped<IPaymentService, PaymentService>();
builder.Services.AddScoped<INotificationService, NotificationService>();

// Add background services
builder.Services.AddSingleton<IBackgroundTaskQueue, BackgroundTaskQueue>();
builder.Services.AddHostedService<OrderProcessingService>();
builder.Services.AddHostedService<HealthMonitoringService>();

// Add memory cache
builder.Services.AddMemoryCache();

// Add AutoMapper
builder.Services.AddAutoMapper(typeof(Program));

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();
app.UseAuthorization();

// Add health check endpoints
app.MapHealthChecks("/health");
app.MapHealthChecks("/health/ready");
app.MapHealthChecks("/health/live");

// Map controllers and SignalR hubs
app.MapControllers();
app.MapHub<OrderHub>("/orderHub");

// Seed database
using (var scope = app.Services.CreateScope())
{
    var context = scope.ServiceProvider.GetRequiredService<ECommerceContext>();
    await SeedDataAsync(context);
}

app.Run();

static async Task SeedDataAsync(ECommerceContext context)
{
    if (!await context.Products.AnyAsync())
    {
        var products = new[]
        {
            new Product { Name = "Laptop", Price = 999.99m, Stock = 50 },
            new Product { Name = "Mouse", Price = 29.99m, Stock = 100 },
            new Product { Name = "Keyboard", Price = 79.99m, Stock = 75 },
            new Product { Name = "Monitor", Price = 299.99m, Stock = 25 }
        };

        context.Products.AddRange(products);
        await context.SaveChangesAsync();
    }
}

// Simple models for the demo
public class ECommerceContext : DbContext
{
    public ECommerceContext(DbContextOptions<ECommerceContext> options) : base(options) { }
    
    public DbSet<Order> Orders { get; set; }
    public DbSet<Product> Products { get; set; }
    public DbSet<OrderItem> OrderItems { get; set; }
}

public class Order
{
    public int Id { get; set; }
    public string CustomerId { get; set; } = string.Empty;
    public decimal TotalAmount { get; set; }
    public OrderStatus Status { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime? ProcessedAt { get; set; }
    public List<OrderItem> Items { get; set; } = new();
}

public class Product
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public decimal Price { get; set; }
    public int Stock { get; set; }
}

public class OrderItem
{
    public int Id { get; set; }
    public int OrderId { get; set; }
    public int ProductId { get; set; }
    public int Quantity { get; set; }
    public decimal Price { get; set; }
    public Product Product { get; set; } = null!;
}

public enum OrderStatus
{
    Pending,
    Processing,
    Completed,
    Failed,
    Cancelled
}

// Simple interfaces for demo
public interface IOrderService
{
    Task<Order> CreateOrderAsync(CreateOrderRequest request, CancellationToken cancellationToken);
    Task<Order?> GetOrderByIdAsync(int id, CancellationToken cancellationToken);
}

public interface IInventoryService
{
    Task<bool> CheckStockAsync(int productId, int quantity, CancellationToken cancellationToken);
}

public interface IPaymentService
{
    Task<bool> ProcessPaymentAsync(decimal amount, CancellationToken cancellationToken);
}

public interface INotificationService
{
    Task SendOrderConfirmationAsync(string customerId, int orderId, CancellationToken cancellationToken);
}

public interface IBackgroundTaskQueue
{
    void QueueBackgroundWorkItem(Func<CancellationToken, Task> workItem);
    Task<Func<CancellationToken, Task>> DequeueAsync(CancellationToken cancellationToken);
}

// Simple implementations for demo
public class OrderService : IOrderService
{
    private readonly ECommerceContext _context;
    private readonly ILogger<OrderService> _logger;

    public OrderService(ECommerceContext context, ILogger<OrderService> logger)
    {
        _context = context;
        _logger = logger;
    }

    public async Task<Order> CreateOrderAsync(CreateOrderRequest request, CancellationToken cancellationToken)
    {
        _logger.LogInformation("Creating order for customer {CustomerId}", request.CustomerId);

        var order = new Order
        {
            CustomerId = request.CustomerId,
            Status = OrderStatus.Pending,
            CreatedAt = DateTime.UtcNow,
            TotalAmount = request.Items.Sum(i => i.Price * i.Quantity)
        };

        _context.Orders.Add(order);
        await _context.SaveChangesAsync(cancellationToken);

        _logger.LogInformation("Order {OrderId} created successfully", order.Id);
        return order;
    }

    public async Task<Order?> GetOrderByIdAsync(int id, CancellationToken cancellationToken)
    {
        return await _context.Orders
            .Include(o => o.Items)
            .ThenInclude(i => i.Product)
            .FirstOrDefaultAsync(o => o.Id == id, cancellationToken);
    }
}

public class InventoryService : IInventoryService
{
    public async Task<bool> CheckStockAsync(int productId, int quantity, CancellationToken cancellationToken)
    {
        await Task.Delay(100, cancellationToken); // Simulate async work
        return true; // Simplified for demo
    }
}

public class PaymentService : IPaymentService
{
    public async Task<bool> ProcessPaymentAsync(decimal amount, CancellationToken cancellationToken)
    {
        await Task.Delay(500, cancellationToken); // Simulate payment processing
        return true; // Simplified for demo
    }
}

public class NotificationService : INotificationService
{
    private readonly ILogger<NotificationService> _logger;

    public NotificationService(ILogger<NotificationService> logger)
    {
        _logger = logger;
    }

    public async Task SendOrderConfirmationAsync(string customerId, int orderId, CancellationToken cancellationToken)
    {
        _logger.LogInformation("Sending order confirmation for order {OrderId} to customer {CustomerId}", orderId, customerId);
        await Task.Delay(200, cancellationToken); // Simulate email sending
    }
}

public class BackgroundTaskQueue : IBackgroundTaskQueue
{
    private readonly Channel<Func<CancellationToken, Task>> _queue;
    private readonly ChannelReader<Func<CancellationToken, Task>> _reader;
    private readonly ChannelWriter<Func<CancellationToken, Task>> _writer;

    public BackgroundTaskQueue(int capacity = 100)
    {
        var options = new BoundedChannelOptions(capacity)
        {
            FullMode = BoundedChannelFullMode.Wait
        };
        _queue = Channel.CreateBounded<Func<CancellationToken, Task>>(options);
        _reader = _queue.Reader;
        _writer = _queue.Writer;
    }

    public void QueueBackgroundWorkItem(Func<CancellationToken, Task> workItem)
    {
        _writer.TryWrite(workItem);
    }

    public async Task<Func<CancellationToken, Task>> DequeueAsync(CancellationToken cancellationToken)
    {
        return await _reader.ReadAsync(cancellationToken);
    }
}

public class OrderProcessingService : BackgroundService
{
    private readonly IBackgroundTaskQueue _taskQueue;
    private readonly ILogger<OrderProcessingService> _logger;

    public OrderProcessingService(IBackgroundTaskQueue taskQueue, ILogger<OrderProcessingService> logger)
    {
        _taskQueue = taskQueue;
        _logger = logger;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        while (!stoppingToken.IsCancellationRequested)
        {
            try
            {
                var workItem = await _taskQueue.DequeueAsync(stoppingToken);
                await workItem(stoppingToken);
            }
            catch (OperationCanceledException)
            {
                break;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error occurred executing work item");
            }
        }
    }
}

public class HealthMonitoringService : BackgroundService
{
    private readonly ILogger<HealthMonitoringService> _logger;

    public HealthMonitoringService(ILogger<HealthMonitoringService> logger)
    {
        _logger = logger;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        using var timer = new PeriodicTimer(TimeSpan.FromMinutes(1));

        while (await timer.WaitForNextTickAsync(stoppingToken))
        {
            _logger.LogInformation("Health check: System is running normally");
        }
    }
}

public class OrderHub : Microsoft.AspNetCore.SignalR.Hub
{
    public async Task JoinOrderGroup(string orderId)
    {
        await Groups.AddToGroupAsync(Context.ConnectionId, $"Order_{orderId}");
    }
}

public class CreateOrderRequest
{
    public string CustomerId { get; set; } = string.Empty;
    public List<CreateOrderItemRequest> Items { get; set; } = new();
}

public class CreateOrderItemRequest
{
    public int ProductId { get; set; }
    public int Quantity { get; set; }
    public decimal Price { get; set; }
}