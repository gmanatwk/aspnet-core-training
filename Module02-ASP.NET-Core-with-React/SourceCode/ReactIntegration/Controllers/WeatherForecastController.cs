using Microsoft.AspNetCore.Mvc;

namespace ReactIntegration.Controllers;

[ApiController]
[Route("api/[controller]")]
public class WeatherForecastController : ControllerBase
{
    private static readonly string[] Summaries = new[]
    {
        "Freezing", "Bracing", "Chilly", "Cool", "Mild", "Warm", "Balmy", "Hot", "Sweltering", "Scorching"
    };

    private readonly ILogger<WeatherForecastController> _logger;

    public WeatherForecastController(ILogger<WeatherForecastController> logger)
    {
        _logger = logger;
    }

    [HttpGet]
    public IEnumerable<WeatherForecast> Get()
    {
        _logger.LogInformation("Generating weather forecast data");
        
        var forecasts = Enumerable.Range(1, 5).Select(index => 
        {
            var forecast = new WeatherForecast
            {
                Date = DateOnly.FromDateTime(DateTime.Now.AddDays(index)),
                TemperatureC = Random.Shared.Next(-20, 55),
                Summary = Summaries[Random.Shared.Next(Summaries.Length)]
            };
            
            _logger.LogDebug("Generated forecast for {Date}: {Temp}°C, {Summary}", 
                forecast.Date, forecast.TemperatureC, forecast.Summary);
                
            return forecast;
        })
        .ToArray();
        
        _logger.LogInformation("Returning {Count} weather forecasts", forecasts.Length);
        return forecasts;
    }
}

public class WeatherForecast
{
    public DateOnly Date { get; set; }
    public int TemperatureC { get; set; }
    public int TemperatureF => 32 + (int)(TemperatureC / 0.5556);
    public string? Summary { get; set; }
}