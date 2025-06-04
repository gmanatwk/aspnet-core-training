var builder = WebApplication.CreateBuilder(args);

// Configure logging for development
builder.Logging.ClearProviders();
builder.Logging.AddConsole();
builder.Logging.AddDebug();

if (builder.Environment.IsDevelopment())
{
    builder.Logging.SetMinimumLevel(LogLevel.Debug);
}

// Add services to the container.
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Configure CORS
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowReactApp",
        policy =>
        {
            policy.WithOrigins("http://localhost:3000")
                  .AllowAnyHeader()
                  .AllowAnyMethod();
        });
});

var app = builder.Build();

// Get logger for startup
var logger = app.Services.GetRequiredService<ILogger<Program>>();
logger.LogInformation("Starting ASP.NET Core application...");

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
    logger.LogInformation("Swagger UI available at: /swagger");
}

// Add request logging middleware
app.Use(async (context, next) =>
{
    var startTime = DateTime.UtcNow;
    
    logger.LogInformation("Request {Method} {Path} started", 
        context.Request.Method, 
        context.Request.Path);
    
    await next.Invoke();
    
    var duration = DateTime.UtcNow - startTime;
    logger.LogInformation("Request {Method} {Path} finished in {Duration}ms with status {StatusCode}", 
        context.Request.Method, 
        context.Request.Path, 
        duration.TotalMilliseconds,
        context.Response.StatusCode);
});

app.UseHttpsRedirection();

app.UseCors("AllowReactApp");

app.UseAuthorization();

app.MapControllers();

// Serve static files from wwwroot
app.UseStaticFiles();

// Fallback to index.html for client-side routing
app.MapFallbackToFile("index.html");

logger.LogInformation("Application started. Listening on {Urls}", 
    string.Join(", ", builder.WebHost.GetSetting("urls") ?? "default"));

app.Run();