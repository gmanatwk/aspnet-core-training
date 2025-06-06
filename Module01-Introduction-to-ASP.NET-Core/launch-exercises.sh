#!/bin/bash

# Module 1 Interactive Exercise Launcher
# Introduction to ASP.NET Core

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Interactive mode flag
INTERACTIVE_MODE=true

# Function to pause and wait for user
pause_for_user() {
    if [ "$INTERACTIVE_MODE" = true ]; then
        echo -e "${YELLOW}Press Enter to continue...${NC}"
        read -r
    fi
}

# Function to show what will be created
preview_file() {
    local file_path=$1
    local description=$2
    
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}📄 Will create: $file_path${NC}"
    echo -e "${YELLOW}📝 Purpose: $description${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# Function to create file with preview
create_file_interactive() {
    local file_path=$1
    local content=$2
    local description=$3
    
    preview_file "$file_path" "$description"
    
    # Show first 20 lines of content
    echo -e "${GREEN}Content preview:${NC}"
    echo "$content" | head -20
    if [ $(echo "$content" | wc -l) -gt 20 ]; then
        echo -e "${YELLOW}... (content truncated for preview)${NC}"
    fi
    echo ""
    
    if [ "$INTERACTIVE_MODE" = true ]; then
        echo -e "${YELLOW}Create this file? (Y/n/s to skip all):${NC} \c"
        read -r response
        
        case $response in
            [nN])
                echo -e "${RED}⏭️  Skipped: $file_path${NC}"
                return
                ;;
            [sS])
                INTERACTIVE_MODE=false
                echo -e "${CYAN}📌 Switching to automatic mode...${NC}"
                ;;
        esac
    fi
    
    # Create directory if it doesn't exist
    mkdir -p "$(dirname "$file_path")"
    
    # Write content to file
    echo "$content" > "$file_path"
    echo -e "${GREEN}✅ Created: $file_path${NC}"
    echo ""
}

# Function to show learning objectives
show_learning_objectives() {
    local exercise=$1
    
    echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${MAGENTA}🎯 Learning Objectives${NC}"
    echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    case $exercise in
        "exercise01")
            echo -e "${CYAN}In this exercise, you will learn:${NC}"
            echo "  📚 1. How to create your first ASP.NET Core application"
            echo "  📚 2. Understanding the project structure"
            echo "  📚 3. Running and testing your application"
            echo "  📚 4. Making basic modifications"
            echo ""
            echo -e "${YELLOW}Key concepts:${NC}"
            echo "  • Web application templates"
            echo "  • Razor Pages basics"
            echo "  • Static files and wwwroot"
            echo "  • Hot reload functionality"
            ;;
        "exercise02")
            echo -e "${CYAN}Building on Exercise 1, you will explore:${NC}"
            echo "  📁 1. Deep dive into project structure"
            echo "  📁 2. Understanding Program.cs"
            echo "  📁 3. Configuration with appsettings.json"
            echo "  📁 4. Pages and layout system"
            echo ""
            echo -e "${YELLOW}Key concepts:${NC}"
            echo "  • Service configuration"
            echo "  • Middleware pipeline"
            echo "  • Dependency injection basics"
            echo "  • Environment-based configuration"
            ;;
        "exercise03")
            echo -e "${CYAN}Advanced topics for your first app:${NC}"
            echo "  ⚙️ 1. Custom middleware implementation"
            echo "  ⚙️ 2. Configuration providers"
            echo "  ⚙️ 3. Request pipeline customization"
            echo "  ⚙️ 4. Error handling"
            echo ""
            echo -e "${YELLOW}Key concepts:${NC}"
            echo "  • Middleware order matters"
            echo "  • Custom request handling"
            echo "  • Application lifetime"
            echo "  • Health checks"
            ;;
    esac
    
    echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    pause_for_user
}

# Function to explain a concept
explain_concept() {
    local concept=$1
    local explanation=$2
    
    echo -e "${MAGENTA}💡 Concept: $concept${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "$explanation"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    pause_for_user
}

# Function to show available exercises
show_exercises() {
    echo -e "${CYAN}Module 1 - Introduction to ASP.NET Core${NC}"
    echo -e "${CYAN}Available Exercises:${NC}"
    echo ""
    echo "  - exercise01: Create Your First App"
    echo "  - exercise02: Explore Project Structure"
    echo "  - exercise03: Configuration and Middleware"
    echo ""
    echo "Usage:"
    echo "  ./launch-exercises.sh <exercise-name> [options]"
    echo ""
    echo "Options:"
    echo "  --list          Show all available exercises"
    echo "  --auto          Skip interactive mode"
    echo "  --preview       Show what will be created without creating"
}

# Main script starts here
if [ $# -eq 0 ]; then
    echo -e "${RED}❌ Usage: $0 <exercise-name> [options]${NC}"
    echo ""
    show_exercises
    exit 1
fi

# Handle --list option
if [ "$1" == "--list" ]; then
    show_exercises
    exit 0
fi

EXERCISE_NAME=$1
PROJECT_NAME="MyFirstWebApp"
PREVIEW_ONLY=false

# Parse options
shift
while [[ $# -gt 0 ]]; do
    case $1 in
        --auto)
            INTERACTIVE_MODE=false
            shift
            ;;
        --preview)
            PREVIEW_ONLY=true
            shift
            ;;
        *)
            shift
            ;;
    esac
done

# Validate exercise name
case $EXERCISE_NAME in
    "exercise01"|"exercise02"|"exercise03")
        ;;
    *)
        echo -e "${RED}❌ Unknown exercise: $EXERCISE_NAME${NC}"
        echo ""
        show_exercises
        exit 1
        ;;
esac

# Welcome screen
echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${MAGENTA}🚀 Module 1: Introduction to ASP.NET Core${NC}"
echo -e "${MAGENTA}Exercise: $EXERCISE_NAME${NC}"
echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

if [ "$INTERACTIVE_MODE" = true ]; then
    echo -e "${YELLOW}🎮 Interactive Mode: ON${NC}"
    echo -e "${CYAN}You'll see what each file does before it's created${NC}"
else
    echo -e "${YELLOW}⚡ Automatic Mode: ON${NC}"
fi

echo ""
pause_for_user

# Show learning objectives
show_learning_objectives $EXERCISE_NAME

if [ "$PREVIEW_ONLY" = true ]; then
    echo -e "${YELLOW}Preview mode - no files will be created${NC}"
    exit 0
fi

# Check if project exists in current directory
if [ -d "$PROJECT_NAME" ]; then
    if [[ $EXERCISE_NAME == "exercise02" ]] || [[ $EXERCISE_NAME == "exercise03" ]]; then
        echo -e "${GREEN}✓ Found existing $PROJECT_NAME from previous exercise${NC}"
        echo -e "${CYAN}This exercise will build on your existing work${NC}"
        cd "$PROJECT_NAME"
        SKIP_PROJECT_CREATION=true
    else
        echo -e "${YELLOW}⚠️  Project '$PROJECT_NAME' already exists!${NC}"
        echo -n "Do you want to overwrite it? (y/N): "
        read -r response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            exit 1
        fi
        rm -rf "$PROJECT_NAME"
        SKIP_PROJECT_CREATION=false
    fi
else
    SKIP_PROJECT_CREATION=false
fi

# Exercise-specific implementation
if [[ $EXERCISE_NAME == "exercise01" ]]; then
    
    explain_concept "ASP.NET Core Razor Pages" \
"Razor Pages is a page-based programming model:
• Simpler than MVC for page-focused scenarios
• Each page has a .cshtml file (view) and .cshtml.cs file (code-behind)
• Uses the @page directive to make it a Razor Page
• Great for CRUD operations and form handling"
    
    if [ "$SKIP_PROJECT_CREATION" = false ]; then
        echo -e "${CYAN}Creating new Razor Pages project...${NC}"
        dotnet new webapp -n "$PROJECT_NAME" --framework net8.0
        cd "$PROJECT_NAME"
    fi
    
    create_file_interactive "EXERCISE_GUIDE.md" \
'# Exercise 1: Create Your First App

## Your Tasks:
1. ✏️ Modify Pages/Index.cshtml to display a custom welcome message
2. 🎨 Add custom CSS in wwwroot/css/site.css
3. 📝 Create a new Razor Page called About
4. 🧪 Test hot reload functionality

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
Navigate to: https://localhost:5001' \
"Exercise guide with detailed instructions"
    
    # Add TODO comments to Index.cshtml
    create_file_interactive "Pages/Index_Modified.cshtml" \
'@page
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
@* HINT: Use @DateTime.Now *@' \
"Modified Index page with TODO markers"
    
    echo -e "${YELLOW}📌 Note: Replace Pages/Index.cshtml with the content from Pages/Index_Modified.cshtml${NC}"
    
elif [[ $EXERCISE_NAME == "exercise02" ]]; then
    
    explain_concept "Project Structure Deep Dive" \
"Understanding the ASP.NET Core project structure:
• Program.cs - The entry point that configures services and middleware
• Pages folder - Contains Razor Pages (.cshtml and .cshtml.cs files)
• wwwroot - Static files served directly (CSS, JS, images)
• appsettings.json - Configuration settings
• Properties/launchSettings.json - Development server settings"
    
    echo -e "${CYAN}Enhancing existing project for Exercise 2...${NC}"
    
    create_file_interactive "PROJECT_STRUCTURE_GUIDE.md" \
'# Project Structure Deep Dive

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
1. 📋 Add a custom configuration setting in appsettings.json
2. 💻 Read and display it in Index.cshtml.cs
3. 🎨 Create a custom layout page
4. 📄 Add a Privacy page with the new layout

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
```' \
"Detailed guide for exploring project structure"
    
    # Create example configuration code
    create_file_interactive "ExampleCode/ConfigurationExample.cs" \
'// Example: Reading configuration in different ways

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

// Then inject IOptions<MyAppOptions> in your classes' \
"Example code showing configuration patterns"
    
elif [[ $EXERCISE_NAME == "exercise03" ]]; then
    
    explain_concept "Middleware Pipeline" \
"The middleware pipeline handles HTTP requests and responses:
• Middleware components execute in order
• Each can process the request and/or response
• Can short-circuit the pipeline or pass to the next
• Order matters! (e.g., UseAuthentication before UseAuthorization)

Common middleware:
• UseStaticFiles - Serves files from wwwroot
• UseRouting - Matches URLs to endpoints
• UseAuthentication - Who are you?
• UseAuthorization - What can you do?"
    
    echo -e "${CYAN}Adding middleware concepts to existing project...${NC}"
    
    create_file_interactive "Middleware/RequestTimingMiddleware.cs" \
'using System.Diagnostics;

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
}' \
"Custom middleware to measure request processing time"
    
    create_file_interactive "Program_WithMiddleware.cs" \
'var builder = WebApplication.CreateBuilder(args);

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

app.Run();' \
"Program.cs with middleware exercises"
    
    create_file_interactive "MIDDLEWARE_EXERCISE.md" \
'# Middleware and Configuration Exercise

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
1. ⏱️ Add custom timing middleware
2. 📊 Implement health checks
3. 🔧 Add environment-specific configuration
4. 📝 Create custom error pages
5. 🚀 Add a minimal API endpoint

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
- Do not forget to register services before using them' \
"Comprehensive middleware exercise guide"
fi

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}🎉 Exercise setup complete!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${YELLOW}📋 Next Steps:${NC}"
echo "1. Review the created files and understand their purpose"
echo "2. Follow the exercise guide step by step"
echo "3. Run your application: ${BLUE}dotnet run${NC}"
echo "4. Test your changes at: ${BLUE}https://localhost:5001${NC}"
echo ""
echo -e "${CYAN}Happy learning! 🚀${NC}"