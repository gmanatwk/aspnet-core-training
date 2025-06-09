using Microsoft.AspNetCore.Mvc;

namespace DebuggingDemo.Controllers;

[ApiController]
[Route("api/[controller]")]
public class SimpleTestController : ControllerBase
{
    private readonly ILogger<SimpleTestController> _logger;

    public SimpleTestController(ILogger<SimpleTestController> logger)
    {
        _logger = logger;
    }

    /// <summary>
    /// Very simple test endpoint - no dependencies
    /// </summary>
    [HttpGet("simple")]
    public ActionResult<object> SimpleTest()
    {
        // BREAKPOINT: Set breakpoint on this line
        var message = "Simple test endpoint hit!";
        
        // BREAKPOINT: Set breakpoint on this line too
        Console.WriteLine($"[DEBUG] {message} at {DateTime.UtcNow}");
        
        // BREAKPOINT: And another one here
        _logger.LogInformation("Simple test endpoint called");
        
        return Ok(new
        {
            Message = message,
            Timestamp = DateTime.UtcNow,
            Status = "Working"
        });
    }

    /// <summary>
    /// Another simple test
    /// </summary>
    [HttpGet("hello")]
    public ActionResult<string> Hello()
    {
        // BREAKPOINT: Set breakpoint here
        return Ok("Hello from SimpleTestController!");
    }
}
