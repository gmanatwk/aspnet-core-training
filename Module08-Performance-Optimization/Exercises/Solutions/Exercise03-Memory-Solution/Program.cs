using MemoryOptimization.Services;
using Microsoft.Extensions.ObjectPool;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Register string processing services
builder.Services.AddScoped<IStringProcessor, IneffientStringProcessor>();
builder.Services.AddScoped<OptimizedStringProcessor>();
builder.Services.AddScoped<SpanStringProcessor>();

// Register buffer processing services
builder.Services.AddScoped<IBufferProcessor, IneffientBufferProcessor>();
builder.Services.AddScoped<OptimizedBufferProcessor>();

// Register object pooling
builder.Services.AddSingleton<ObjectPoolProvider, DefaultObjectPoolProvider>();
builder.Services.AddSingleton<IPooledObjectPolicy<ExpensiveObject>, ExpensiveObjectPolicy>();
builder.Services.AddSingleton(serviceProvider =>
{
    var provider = serviceProvider.GetRequiredService<ObjectPoolProvider>();
    var policy = serviceProvider.GetRequiredService<IPooledObjectPolicy<ExpensiveObject>>();
    return provider.Create(policy);
});

// Register data processing service
builder.Services.AddScoped<IDataProcessingService, DataProcessingService>();

// Register memory efficient services
builder.Services.AddSingleton<IMemoryEfficientService, MemoryEfficientService>();

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

app.Run();

public partial class Program { }
