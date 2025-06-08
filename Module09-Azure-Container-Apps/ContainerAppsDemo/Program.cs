var builder = WebApplication.CreateBuilder(args);

// Add services to the container
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Add health checks as required by Exercise 1
builder.Services.AddHealthChecks();

var app = builder.Build();

// Configure the HTTP request pipeline
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

// Remove HTTPS redirection for container compatibility
// app.UseHttpsRedirection();

app.UseAuthorization();

// Add health check endpoint as required by Exercise 1
app.MapHealthChecks("/healthz");

// Map controllers
app.MapControllers();

app.Run();
