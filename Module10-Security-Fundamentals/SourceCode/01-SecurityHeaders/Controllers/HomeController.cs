using Microsoft.AspNetCore.Mvc;

namespace SecurityHeaders.Controllers;

public class HomeController : Controller
{
    private readonly ILogger<HomeController> _logger;

    public HomeController(ILogger<HomeController> logger)
    {
        _logger = logger;
    }

    public IActionResult Index()
    {
        _logger.LogInformation("Home page accessed from IP: {IP}", 
            HttpContext.Connection.RemoteIpAddress);
        return View();
    }

    public IActionResult SecurityTest()
    {
        ViewBag.Headers = HttpContext.Response.Headers
            .Where(h => h.Key.StartsWith("X-") || 
                       h.Key.Equals("Content-Security-Policy") ||
                       h.Key.Equals("Referrer-Policy") ||
                       h.Key.Equals("Permissions-Policy"))
            .ToDictionary(h => h.Key, h => h.Value.ToString());

        return View();
    }

    [ValidateAntiForgeryToken]
    [HttpPost]
    public IActionResult TestForm(string message)
    {
        if (string.IsNullOrWhiteSpace(message))
        {
            ModelState.AddModelError(nameof(message), "Message is required");
            return View("SecurityTest");
        }

        // Simulate processing with XSS protection
        var safeMessage = System.Web.HttpUtility.HtmlEncode(message);
        ViewBag.ProcessedMessage = safeMessage;
        
        _logger.LogInformation("Form submitted successfully with message length: {Length}", 
            message.Length);

        return View("SecurityTest");
    }

    public IActionResult Privacy()
    {
        return View();
    }

    [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
    public IActionResult Error()
    {
        return View();
    }
}
