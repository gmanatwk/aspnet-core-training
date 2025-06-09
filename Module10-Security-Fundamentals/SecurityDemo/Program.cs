using SecurityDemo.Middleware;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new() {
        Title = "Security Demo API",
        Version = "v1",
        Description = "ASP.NET Core Security Fundamentals Demo"
    });
});

// Configure HTTPS redirection properly
builder.Services.AddHttpsRedirection(options =>
{
    options.RedirectStatusCode = StatusCodes.Status307TemporaryRedirect;
    options.HttpsPort = 5051;
});

// Add controllers for API endpoints
builder.Services.AddControllers();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI(c =>
    {
        c.SwaggerEndpoint("/swagger/v1/swagger.json", "Security Demo API v1");
        c.RoutePrefix = "swagger";
    });
}

// Security middleware - order matters!
app.UseSecurityHeaders(); // Custom security headers middleware
app.UseHttpsRedirection();

app.UseAuthorization();

app.MapControllers();

// Add root redirect to swagger
app.MapGet("/", () => Results.Redirect("/swagger"));

app.Run();
