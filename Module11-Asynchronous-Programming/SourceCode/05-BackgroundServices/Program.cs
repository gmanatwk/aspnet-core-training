using BackgroundServices.Services;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddControllers();
builder.Services.AddHttpClient();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Add background services
builder.Services.AddSingleton<IBackgroundTaskQueue, BackgroundTaskQueue>();
builder.Services.AddHostedService<QueuedHostedService>();
builder.Services.AddHostedService<TimedHostedService>();
builder.Services.AddHostedService<FileMonitorService>();
builder.Services.AddHostedService<HealthCheckService>();

// Add scoped service for DI in background services
builder.Services.AddScoped<IScopedProcessingService, ScopedProcessingService>();

// Configuration for services
builder.Configuration.AddInMemoryCollection(new Dictionary<string, string?>
{
    ["FileMonitor:WatchPath"] = Path.Combine(Path.GetTempPath(), "BackgroundServiceDemo"),
    ["HealthCheck:Urls:0"] = "https://httpbin.org/status/200",
    ["HealthCheck:Urls:1"] = "https://jsonplaceholder.typicode.com/posts/1"
});

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();
app.UseAuthorization();
app.MapControllers();

// Ensure watch directory exists
var watchPath = builder.Configuration["FileMonitor:WatchPath"];
if (!string.IsNullOrEmpty(watchPath))
{
    Directory.CreateDirectory(watchPath);
    app.Logger.LogInformation("File monitor watch path: {WatchPath}", watchPath);
}

app.Run();