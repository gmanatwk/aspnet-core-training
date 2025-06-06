# Module 1 Interactive Exercise Launcher
# Introduction to ASP.NET Core

param(
    [Parameter(Position=0)]
    [string]$ExerciseName,
    
    [switch]$List,
    [switch]$Auto,
    [switch]$Preview
)

# Colors for output
$OriginalColor = $Host.UI.RawUI.ForegroundColor

# Interactive mode flag
$InteractiveMode = -not $Auto

# Function to write colored output
function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
}

# Function to pause and wait for user
function Pause-ForUser {
    if ($InteractiveMode) {
        Write-ColorOutput "Press Enter to continue..." -Color Yellow
        Read-Host
    }
}

# Function to show what will be created
function Preview-File {
    param(
        [string]$FilePath,
        [string]$Description
    )
    
    Write-ColorOutput ("=" * 60) -Color Cyan
    Write-ColorOutput "File: $FilePath" -Color Blue
    Write-ColorOutput "Purpose: $Description" -Color Yellow
    Write-ColorOutput ("=" * 60) -Color Cyan
}

# Function to create file with preview
function New-FileInteractive {
    param(
        [string]$FilePath,
        [string]$Content,
        [string]$Description
    )
    
    Preview-File -FilePath $FilePath -Description $Description
    
    # Show first 20 lines of content
    Write-ColorOutput "Content preview:" -Color Green
    $lines = $Content -split "`n"
    $preview = $lines[0..19] -join "`n"
    Write-Host $preview
    
    if ($lines.Count -gt 20) {
        Write-ColorOutput "... (content truncated for preview)" -Color Yellow
    }
    Write-Host ""
    
    if ($InteractiveMode) {
        $response = Read-Host "Create this file? (Y/n/s to skip all)"
        
        switch ($response.ToLower()) {
            'n' {
                Write-ColorOutput "Skipped: $FilePath" -Color Red
                return
            }
            's' {
                $script:InteractiveMode = $false
                Write-ColorOutput "Switching to automatic mode..." -Color Cyan
            }
        }
    }
    
    # Create directory if it doesn't exist
    $directory = Split-Path -Parent $FilePath
    if ($directory -and -not (Test-Path $directory)) {
        New-Item -ItemType Directory -Path $directory -Force | Out-Null
    }
    
    # Write content to file
    Set-Content -Path $FilePath -Value $Content -Encoding UTF8
    Write-ColorOutput "Created: $FilePath" -Color Green
    Write-Host ""
}

# Function to show learning objectives
function Show-LearningObjectives {
    param([string]$Exercise)
    
    Write-ColorOutput ("=" * 60) -Color Magenta
    Write-ColorOutput "Learning Objectives" -Color Magenta
    Write-ColorOutput ("=" * 60) -Color Magenta
    
    switch ($Exercise) {
        "exercise01" {
            Write-ColorOutput "In this exercise, you will learn:" -Color Cyan
            Write-Host "  - How to create your first ASP.NET Core application"
            Write-Host "  - Understanding the project structure"
            Write-Host "  - Running and testing your application"
            Write-Host "  - Making basic modifications"
            Write-Host ""
            Write-ColorOutput "Key concepts:" -Color Yellow
            Write-Host "  - Web application templates"
            Write-Host "  - Razor Pages basics"
            Write-Host "  - Static files and wwwroot"
            Write-Host "  - Hot reload functionality"
        }
        "exercise02" {
            Write-ColorOutput "Building on Exercise 1, you will explore:" -Color Cyan
            Write-Host "  - Deep dive into project structure"
            Write-Host "  - Understanding Program.cs"
            Write-Host "  - Configuration with appsettings.json"
            Write-Host "  - Pages and layout system"
            Write-Host ""
            Write-ColorOutput "Key concepts:" -Color Yellow
            Write-Host "  - Service configuration"
            Write-Host "  - Middleware pipeline"
            Write-Host "  - Dependency injection basics"
            Write-Host "  - Environment-based configuration"
        }
        "exercise03" {
            Write-ColorOutput "Advanced topics for your first app:" -Color Cyan
            Write-Host "  - Custom middleware implementation"
            Write-Host "  - Configuration providers"
            Write-Host "  - Request pipeline customization"
            Write-Host "  - Error handling"
            Write-Host ""
            Write-ColorOutput "Key concepts:" -Color Yellow
            Write-Host "  - Middleware order matters"
            Write-Host "  - Custom request handling"
            Write-Host "  - Application lifetime"
            Write-Host "  - Health checks"
        }
    }
    
    Write-ColorOutput ("=" * 60) -Color Magenta
    Pause-ForUser
}

# Function to explain a concept
function Explain-Concept {
    param(
        [string]$Concept,
        [string]$Explanation
    )
    
    Write-ColorOutput "Concept: $Concept" -Color Magenta
    Write-ColorOutput ("=" * 60) -Color Cyan
    Write-Host $Explanation
    Write-ColorOutput ("=" * 60) -Color Cyan
    Pause-ForUser
}

# Function to show available exercises
function Show-Exercises {
    Write-ColorOutput "Module 1 - Introduction to ASP.NET Core" -Color Cyan
    Write-ColorOutput "Available Exercises:" -Color Cyan
    Write-Host ""
    Write-Host "  - exercise01: Create Your First App"
    Write-Host "  - exercise02: Explore Project Structure"
    Write-Host "  - exercise03: Configuration and Middleware"
    Write-Host ""
    Write-Host "Usage:"
    Write-Host "  .\launch-exercises.ps1 <exercise-name> [options]"
    Write-Host ""
    Write-Host "Options:"
    Write-Host "  -List          Show all available exercises"
    Write-Host "  -Auto          Skip interactive mode"
    Write-Host "  -Preview       Show what will be created without creating"
}

# Main script starts here
if ($List) {
    Show-Exercises
    exit 0
}

if (-not $ExerciseName) {
    Write-ColorOutput "Usage: .\launch-exercises.ps1 <exercise-name> [options]" -Color Red
    Write-Host ""
    Show-Exercises
    exit 1
}

$PROJECT_NAME = "MyFirstWebApp"
$PREVIEW_ONLY = $Preview

# Validate exercise name
if ($ExerciseName -notin @("exercise01", "exercise02", "exercise03")) {
    Write-ColorOutput "Unknown exercise: $ExerciseName" -Color Red
    Write-Host ""
    Show-Exercises
    exit 1
}

# Welcome screen
Write-ColorOutput ("=" * 60) -Color Magenta
Write-ColorOutput "Module 1: Introduction to ASP.NET Core" -Color Magenta
Write-ColorOutput "Exercise: $ExerciseName" -Color Magenta
Write-ColorOutput ("=" * 60) -Color Magenta
Write-Host ""

if ($InteractiveMode) {
    Write-ColorOutput "Interactive Mode: ON" -Color Yellow
    Write-ColorOutput "You'll see what each file does before it's created" -Color Cyan
} else {
    Write-ColorOutput "Automatic Mode: ON" -Color Yellow
}

Write-Host ""
Pause-ForUser

# Show learning objectives
Show-LearningObjectives -Exercise $ExerciseName

if ($PREVIEW_ONLY) {
    Write-ColorOutput "Preview mode - no files will be created" -Color Yellow
    exit 0
}

# Check if project exists in current directory
$SKIP_PROJECT_CREATION = $false
if (Test-Path $PROJECT_NAME) {
    if ($ExerciseName -in @("exercise02", "exercise03")) {
        Write-ColorOutput "Found existing $PROJECT_NAME from previous exercise" -Color Green
        Write-ColorOutput "This exercise will build on your existing work" -Color Cyan
        Set-Location $PROJECT_NAME
        $SKIP_PROJECT_CREATION = $true
    } else {
        Write-ColorOutput "Project '$PROJECT_NAME' already exists!" -Color Yellow
        $response = Read-Host "Do you want to overwrite it? (y/N)"
        if ($response -notmatch '^[Yy]$') {
            exit 1
        }
        Remove-Item -Recurse -Force $PROJECT_NAME
        $SKIP_PROJECT_CREATION = $false
    }
} else {
    $SKIP_PROJECT_CREATION = $false
}

# Exercise-specific implementation
switch ($ExerciseName) {
    "exercise01" {
        $conceptExplanation = @"
Razor Pages is a page-based programming model:
* Simpler than MVC for page-focused scenarios
* Each page has a .cshtml file (view) and .cshtml.cs file (code-behind)
* Uses the @page directive to make it a Razor Page
* Great for CRUD operations and form handling
"@
        Explain-Concept -Concept "ASP.NET Core Razor Pages" -Explanation $conceptExplanation
        
        if (-not $SKIP_PROJECT_CREATION) {
            Write-ColorOutput "Creating new Razor Pages project..." -Color Cyan
            dotnet new webapp -n "$PROJECT_NAME" --framework net8.0
            Set-Location $PROJECT_NAME
        }
        
        $exerciseGuideContent = @'
# Exercise 1: Create Your First App

## Your Tasks:
1. Modify Pages/Index.cshtml to display a custom welcome message
2. Add custom CSS in wwwroot/css/site.css
3. Create a new Razor Page called About
4. Test hot reload functionality

## Key Files to Explore:
- Program.cs - Application configuration
- Pages/Index.cshtml - Home page view
- Pages/Index.cshtml.cs - Code-behind file
- wwwroot/ - Static files

## Step-by-Step Instructions:

### Task 1: Modify the home page
Open Pages/Index.cshtml and replace the content with your own welcome message.

### Task 2: Add custom styling
Add these styles to wwwroot/css/site.css:
```css
.welcome-banner {
    background-color: #007acc;
    color: white;
    padding: 2rem;
    text-align: center;
    border-radius: 8px;
}
```

### Task 3: Create About page
Run: `dotnet new page -n About -o Pages`

### Task 4: Test hot reload
Make changes while the app is running to see instant updates!

## Testing:
Run with: dotnet run
Navigate to: https://localhost:5001
'@
        
        New-FileInteractive -FilePath "EXERCISE_GUIDE.md" -Description "Exercise guide with detailed instructions" -Content $exerciseGuideContent
        
        # Add TODO comments to Index.cshtml
        $indexModifiedContent = @'
@page
@model IndexModel
@{
    ViewData["Title"] = "Home page";
}

<div class="text-center">
    @* TODO: Exercise 1.1 - Replace this with your custom welcome message *@
    <h1 class="display-4">Welcome to ASP.NET Core!</h1>
    
    @* TODO: Exercise 1.2 - Add a div with class="welcome-banner" *@
    
    @* TODO: Exercise 1.3 - Add a link to your About page *@
    <p>Learn about <a href="https://learn.microsoft.com/aspnet/core">building Web apps with ASP.NET Core</a>.</p>
</div>

@* TODO: Exercise 1.4 - Add a section showing the current time using C# *@
@* HINT: Use @DateTime.Now *@
'@
        
        New-FileInteractive -FilePath "Pages/Index_Modified.cshtml" -Description "Modified Index page with TODO markers" -Content $indexModifiedContent
        
        Write-ColorOutput "Note: Replace Pages/Index.cshtml with the content from Pages/Index_Modified.cshtml" -Color Yellow
    }
    
    "exercise02" {
        $conceptExplanation = @"
Understanding the ASP.NET Core project structure:
* Program.cs - The entry point that configures services and middleware
* Pages folder - Contains Razor Pages (.cshtml and .cshtml.cs files)
* wwwroot - Static files served directly (CSS, JS, images)
* appsettings.json - Configuration settings
* Properties/launchSettings.json - Development server settings
"@
        Explain-Concept -Concept "Project Structure Deep Dive" -Explanation $conceptExplanation
        
        Write-ColorOutput "Enhancing existing project for Exercise 2..." -Color Cyan
        
        $projectStructureGuide = @'
# Project Structure Deep Dive

## Directory Structure:
```
MyFirstWebApp/
├── Pages/                    # Razor Pages
│   ├── Shared/              # Shared layouts and partials
│   │   ├── _Layout.cshtml   # Main layout template
│   │   └── _ValidationScriptsPartial.cshtml
│   ├── _ViewImports.cshtml  # Global using statements
│   ├── _ViewStart.cshtml    # Sets default layout
│   ├── Index.cshtml         # Home page view
│   └── Index.cshtml.cs      # Home page code-behind
├── wwwroot/                 # Static files
│   ├── css/                # Stylesheets
│   ├── js/                 # JavaScript
│   └── lib/                # Client-side libraries
├── Program.cs              # Application entry point
├── appsettings.json        # Configuration
└── appsettings.Development.json # Dev-specific config
```

## Your Tasks:
1. Add a custom configuration setting in appsettings.json
2. Read and display it in Index.cshtml.cs
3. Create a custom layout page
4. Add a Privacy page with the new layout

## Code Examples:

### Task 1: Add to appsettings.json
```json
{
  "MyApp": {
    "WelcomeMessage": "Welcome to My Custom App!",
    "Version": "1.0.0"
  }
}
```

### Task 2: Read in Index.cshtml.cs
```csharp
public class IndexModel : PageModel
{
    private readonly IConfiguration _configuration;
    
    public string WelcomeMessage { get; set; }
    
    public IndexModel(IConfiguration configuration)
    {
        _configuration = configuration;
    }
    
    public void OnGet()
    {
        WelcomeMessage = _configuration["MyApp:WelcomeMessage"];
    }
}
```
'@
        
        New-FileInteractive -FilePath "PROJECT_STRUCTURE_GUIDE.md" -Description "Detailed guide for exploring project structure" -Content $projectStructureGuide
        
        # Create example configuration code
        $configExampleContent = @'
// Example: Reading configuration in different ways

// Method 1: Using IConfiguration directly
public class ExampleService
{
    private readonly IConfiguration _configuration;
    
    public ExampleService(IConfiguration configuration)
    {
        _configuration = configuration;
    }
    
    public void ReadConfig()
    {
        // Read a simple value
        var welcomeMsg = _configuration["MyApp:WelcomeMessage"];
        
        // Read a section
        var myAppSection = _configuration.GetSection("MyApp");
        var version = myAppSection["Version"];
    }
}

// Method 2: Using Options pattern (recommended)
public class MyAppOptions
{
    public string WelcomeMessage { get; set; }
    public string Version { get; set; }
}

// In Program.cs:
// builder.Services.Configure<MyAppOptions>(
//     builder.Configuration.GetSection("MyApp"));

// Then inject IOptions<MyAppOptions> in your classes
'@
        
        New-FileInteractive -FilePath "ExampleCode/ConfigurationExample.cs" -Description "Example code showing configuration patterns" -Content $configExampleContent
    }
    
    "exercise03" {
        $conceptExplanation = @"
The middleware pipeline handles HTTP requests and responses:
* Middleware components execute in order
* Each can process the request and/or response
* Can short-circuit the pipeline or pass to the next
* Order matters! (e.g., UseAuthentication before UseAuthorization)

Common middleware:
* UseStaticFiles - Serves files from wwwroot
* UseRouting - Matches URLs to endpoints
* UseAuthentication - Who are you?
* UseAuthorization - What can you do?
"@
        Explain-Concept -Concept "Middleware Pipeline" -Explanation $conceptExplanation
        
        Write-ColorOutput "Adding middleware concepts to existing project..." -Color Cyan
        
        $middlewareContent = @'
using System.Diagnostics;

namespace MyFirstWebApp.Middleware
{
    public class RequestTimingMiddleware
    {
        private readonly RequestDelegate _next;
        private readonly ILogger<RequestTimingMiddleware> _logger;

        public RequestTimingMiddleware(RequestDelegate next, ILogger<RequestTimingMiddleware> logger)
        {
            _next = next;
            _logger = logger;
        }

        public async Task InvokeAsync(HttpContext context)
        {
            // Start timing
            var stopwatch = Stopwatch.StartNew();
            
            // Store the original response body stream
            var originalBodyStream = context.Response.Body;
            
            try
            {
                // Call the next middleware
                await _next(context);
            }
            finally
            {
                // Stop timing
                stopwatch.Stop();
                
                // Log the request timing
                _logger.LogInformation(
                    "Request {Method} {Path} took {ElapsedMilliseconds}ms",
                    context.Request.Method,
                    context.Request.Path,
                    stopwatch.ElapsedMilliseconds);
                
                // Add timing header
                context.Response.Headers.Add("X-Response-Time", 
                    $"{stopwatch.ElapsedMilliseconds}ms");
            }
        }
    }

    // Extension method to register middleware
    public static class RequestTimingMiddlewareExtensions
    {
        public static IApplicationBuilder UseRequestTiming(
            this IApplicationBuilder builder)
        {
            return builder.UseMiddleware<RequestTimingMiddleware>();
        }
    }
}
'@
        
        New-FileInteractive -FilePath "Middleware/RequestTimingMiddleware.cs" -Description "Custom middleware to measure request processing time" -Content $middlewareContent
        
        $programWithMiddleware = @'
var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddRazorPages();

// TODO: Exercise 3.1 - Add health checks service
// builder.Services.AddHealthChecks();

// TODO: Exercise 3.2 - Add custom services
// builder.Services.AddSingleton<IMyService, MyService>();

var app = builder.Build();

// Configure the HTTP request pipeline.

// TODO: Exercise 3.3 - Add request logging middleware
app.Use(async (context, next) =>
{
    var path = context.Request.Path;
    var method = context.Request.Method;
    
    Console.WriteLine($"[{DateTime.Now:HH:mm:ss}] {method} {path}");
    
    await next();
    
    var statusCode = context.Response.StatusCode;
    Console.WriteLine($"[{DateTime.Now:HH:mm:ss}] Response: {statusCode}");
});

// TODO: Exercise 3.4 - Add custom timing middleware
// app.UseRequestTiming();

if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Error");
    app.UseHsts();
}
else
{
    app.UseDeveloperExceptionPage();
}

app.UseHttpsRedirection();
app.UseStaticFiles();
app.UseRouting();
app.UseAuthorization();
app.MapRazorPages();

// TODO: Exercise 3.5 - Map health check endpoint
// app.MapHealthChecks("/health");

// TODO: Exercise 3.6 - Add a minimal API endpoint
app.MapGet("/api/time", () => new { time = DateTime.Now });

app.Run();
'@
        
        New-FileInteractive -FilePath "Program_WithMiddleware.cs" -Description "Program.cs with middleware exercises" -Content $programWithMiddleware
        
        $middlewareExercise = @'
# Middleware and Configuration Exercise

## Understanding the Pipeline
The request flows through middleware in this order:
1. Logging (custom)
2. Exception Handling
3. HTTPS Redirection
4. Static Files
5. Routing
6. Authorization
7. Endpoints (Razor Pages)

## Your Tasks:
1. Add custom timing middleware
2. Implement health checks
3. Add environment-specific configuration
4. Create custom error pages
5. Add a minimal API endpoint

## Testing Your Middleware:
1. Run the app and watch the console for request logs
2. Check response headers for X-Response-Time
3. Visit /health to see health check status
4. Visit /api/time for the minimal API

## Advanced Challenge:
Create middleware that:
- Blocks requests from certain IPs
- Adds security headers
- Compresses responses

## Tips:
- Middleware order matters!
- Use app.Environment to check environment
- Don't forget to register services before using them
'@
        
        New-FileInteractive -FilePath "MIDDLEWARE_EXERCISE.md" -Description "Comprehensive middleware exercise guide" -Content $middlewareExercise
    }
}

Write-Host ""
Write-ColorOutput ("=" * 60) -Color Green
Write-ColorOutput "Exercise setup complete!" -Color Green
Write-ColorOutput ("=" * 60) -Color Green
Write-Host ""
Write-ColorOutput "Next Steps:" -Color Yellow
Write-Host "1. Review the created files and understand their purpose"
Write-Host "2. Follow the exercise guide step by step"
Write-Host "3. Run your application: " -NoNewline
Write-ColorOutput "dotnet run" -Color Blue
Write-Host ""
Write-Host "4. Test your changes at: " -NoNewline
Write-ColorOutput "https://localhost:5001" -Color Blue
Write-Host ""
Write-Host ""
Write-ColorOutput "Happy learning!" -Color Cyan