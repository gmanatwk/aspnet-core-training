# Module 04: Authentication and Authorization - Exercise Launcher (PowerShell)
# This script creates complete, working implementations for all exercises

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("exercise01", "exercise02", "exercise03")]
    [string]$Exercise
)

# Function to print colored output
function Write-Status {
    param([string]$Message)
    Write-Host "[OK] $Message" -ForegroundColor Green
}

function Write-Info {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Blue
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[WARN] $Message" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

function Write-Header {
    param([string]$Message)
    Write-Host $Message -ForegroundColor Cyan
}

# Function to create files
function New-ProjectFile {
    param(
        [string]$FilePath,
        [string]$Content,
        [string]$Description
    )
    
    Write-Host "[CREATE] Creating: $FilePath" -ForegroundColor Yellow
    if ($Description) {
        Write-Host "   Description: $Description" -ForegroundColor Blue
    }
    
    # Create directory if it doesn't exist
    $Directory = Split-Path $FilePath -Parent
    if ($Directory -and !(Test-Path $Directory)) {
        New-Item -ItemType Directory -Path $Directory -Force | Out-Null
    }
    
    # Write content to file
    Set-Content -Path $FilePath -Value $Content -Encoding UTF8
    
    Write-Status "Created $FilePath"
}

# Function to show exercise information
function Show-ExerciseInfo {
    param([string]$ExerciseNum)
    
    Write-Host ""
    Write-Header "Exercise Information"
    Write-Host ""
    
    switch ($ExerciseNum) {
        "exercise01" {
            Write-Host "In this exercise, you will learn:" -ForegroundColor Cyan
            Write-Host "  1. JWT token structure and validation"
            Write-Host "  2. Configuring JWT authentication in ASP.NET Core"
            Write-Host "  3. Implementing secure login endpoints"
            Write-Host "  4. Testing protected API endpoints"
            Write-Host "  5. Handling authentication errors properly"
            Write-Host ""
            Write-Host "Key concepts:" -ForegroundColor Yellow
            Write-Host "  • JWT token generation and validation"
            Write-Host "  • Claims-based authentication"
            Write-Host "  • Middleware configuration"
            Write-Host "  • Security best practices"
        }
        "exercise02" {
            Write-Host "Building on Exercise 1, you will add:" -ForegroundColor Cyan
            Write-Host "  1. Role-based authorization to your JWT API"
            Write-Host "  2. Multiple user roles (Admin, Manager, User)"
            Write-Host "  3. [Authorize(Roles = `"...`")] attributes"
            Write-Host "  4. Role-based endpoint protection"
            Write-Host "  5. Testing role-based access control"
            Write-Host ""
            Write-Host "New concepts:" -ForegroundColor Yellow
            Write-Host "  • Role claims in JWT tokens"
            Write-Host "  • Authorization vs Authentication"
            Write-Host "  • Role-based access control (RBAC)"
            Write-Host "  • Authorization policies"
        }
        "exercise03" {
            Write-Host "Advanced authorization with custom policies:" -ForegroundColor Cyan
            Write-Host "  1. Custom authorization requirements"
            Write-Host "  2. Authorization handlers implementation"
            Write-Host "  3. Complex policy-based authorization"
            Write-Host "  4. Resource-based authorization"
            Write-Host "  5. Advanced security scenarios"
            Write-Host ""
            Write-Host "Professional concepts:" -ForegroundColor Yellow
            Write-Host "  • Custom authorization policies"
            Write-Host "  • Authorization handlers"
            Write-Host "  • Resource-based authorization"
            Write-Host "  • Security best practices"
        }
    }
}

# Function to show project structure
function Show-ProjectStructure {
    param([string]$ExerciseNum)
    
    Write-Host ""
    Write-Header "Project Structure"
    Write-Host ""
    
    switch ($ExerciseNum) {
        "exercise01" {
            Write-Host "Exercise 01: Complete JWT Authentication API" -ForegroundColor Green
            Write-Host ""
            Write-Host "What you'll build:" -ForegroundColor Yellow
            Write-Host "  - Complete JWT authentication system"
            Write-Host "  - Secure login and registration endpoints"
            Write-Host "  - Protected API endpoints with JWT validation"
            Write-Host "  - User management with in-memory store"
            Write-Host "  - Interactive demo web interface"
            Write-Host "  - Comprehensive error handling"
            Write-Host "  - Swagger documentation with JWT support"
            Write-Host ""
            Write-Host "Complete Project Structure:" -ForegroundColor Green
            Write-Host "  JwtAuthenticationAPI/"
            Write-Host "  ├── Controllers/"
            Write-Host "  │   └── AuthController.cs       # Login and profile endpoints" -ForegroundColor Yellow
            Write-Host "  ├── Models/"
            Write-Host "  │   └── AuthModels.cs           # Authentication models" -ForegroundColor Yellow
            Write-Host "  ├── Services/"
            Write-Host "  │   ├── JwtTokenService.cs      # JWT token generation" -ForegroundColor Yellow
            Write-Host "  │   └── UserService.cs          # User authentication" -ForegroundColor Yellow
            Write-Host "  ├── wwwroot/"
            Write-Host "  │   └── index.html              # Interactive demo" -ForegroundColor Yellow
            Write-Host "  ├── Program.cs                  # JWT configuration" -ForegroundColor Yellow
            Write-Host "  └── appsettings.json            # JWT settings" -ForegroundColor Yellow
        }
        "exercise02" {
            Write-Host "Exercise 02: Role-Based Authorization" -ForegroundColor Green
            Write-Host ""
            Write-Host "Building on Exercise 1:" -ForegroundColor Yellow
            Write-Host "  - Multiple user roles (Admin, Editor, User)"
            Write-Host "  - Role-based endpoint protection"
            Write-Host "  - Enhanced JWT tokens with role claims"
            Write-Host "  - Authorization policies"
            Write-Host ""
            Write-Host "New Controllers:" -ForegroundColor Green
            Write-Host "  ├── AdminController.cs          # Admin-only endpoints" -ForegroundColor Yellow
            Write-Host "  ├── EditorController.cs         # Editor endpoints" -ForegroundColor Yellow
            Write-Host "  └── UsersController.cs          # User management" -ForegroundColor Yellow
        }
        "exercise03" {
            Write-Host "Exercise 03: Custom Authorization Policies" -ForegroundColor Green
            Write-Host ""
            Write-Host "Advanced Features:" -ForegroundColor Yellow
            Write-Host "  - Custom authorization requirements"
            Write-Host "  - Authorization handlers"
            Write-Host "  - Age and department-based policies"
            Write-Host "  - Time-based access control"
            Write-Host ""
            Write-Host "New Components:" -ForegroundColor Green
            Write-Host "  ├── Requirements/"
            Write-Host "  │   ├── MinimumAgeRequirement.cs" -ForegroundColor Yellow
            Write-Host "  │   ├── DepartmentRequirement.cs" -ForegroundColor Yellow
            Write-Host "  │   └── WorkingHoursRequirement.cs" -ForegroundColor Yellow
            Write-Host "  ├── Handlers/"
            Write-Host "  │   ├── MinimumAgeHandler.cs" -ForegroundColor Yellow
            Write-Host "  │   ├── DepartmentHandler.cs" -ForegroundColor Yellow
            Write-Host "  │   └── WorkingHoursHandler.cs" -ForegroundColor Yellow
            Write-Host "  └── Controllers/"
            Write-Host "      └── PolicyController.cs    # Policy testing" -ForegroundColor Yellow
        }
    }
}

# Main script logic
Clear-Host
Write-Header "Module 04: Authentication and Authorization - Exercise Launcher"
Write-Header "=================================================================="
Write-Host ""

Show-ExerciseInfo $Exercise
Show-ProjectStructure $Exercise

Write-Host ""
$response = Read-Host "Do you want to create this exercise? (y/N)"

if ($response -notmatch "^[Yy]$") {
    Write-Host "Exercise creation cancelled."
    exit 0
}

Write-Host ""
Write-Header "Creating Exercise: $Exercise"
Write-Host ""

# Create the project directory
if (!(Test-Path "JwtAuthenticationAPI")) {
    New-Item -ItemType Directory -Path "JwtAuthenticationAPI" | Out-Null
}
Set-Location "JwtAuthenticationAPI"

# Create .NET project only for exercise01
if ($Exercise -eq "exercise01") {
    Write-Info "Creating .NET 8.0 Web API project..."
    dotnet new webapi --framework net8.0 --no-https --force
    
    # Add required packages
    Write-Info "Adding required NuGet packages..."
    dotnet add package Microsoft.AspNetCore.Authentication.JwtBearer --version 8.0.11
    dotnet add package System.IdentityModel.Tokens.Jwt --version 8.0.8
    dotnet add package Microsoft.IdentityModel.Tokens --version 8.0.8
    dotnet add package Swashbuckle.AspNetCore --version 6.8.1
    
    # Remove default files
    Remove-Item -Force WeatherForecast.cs, Controllers/WeatherForecastController.cs -ErrorAction SilentlyContinue
}

# Create directories
$directories = @("Models", "Services", "Controllers", "wwwroot")
if ($Exercise -eq "exercise03") {
    $directories += @("Requirements", "Handlers")
}
foreach ($dir in $directories) {
    if (!(Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir | Out-Null
    }
}

# Create appsettings.json
$appsettingsContent = @'
{
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "AllowedHosts": "*",
  "Jwt": {
    "Key": "ThisIsMySecureKey12345678901234567890",
    "Issuer": "JwtAuthenticationAPI",
    "Audience": "JwtAuthenticationAPI",
    "ExpiryMinutes": 60
  }
}
'@
New-ProjectFile -FilePath "appsettings.json" -Content $appsettingsContent -Description "Application settings with JWT configuration"

# Create Models/AuthModels.cs
$authModelsContent = @'
using System.ComponentModel.DataAnnotations;

namespace JwtAuthenticationAPI.Models;

public class LoginRequest
{
    [Required(ErrorMessage = "Username is required")]
    public string Username { get; set; } = string.Empty;

    [Required(ErrorMessage = "Password is required")]
    public string Password { get; set; } = string.Empty;
}

public class LoginResponse
{
    public string Token { get; set; } = string.Empty;
    public DateTime Expiration { get; set; }
    public string Username { get; set; } = string.Empty;
    public List<string> Roles { get; set; } = new();
}

public class RegisterRequest
{
    [Required(ErrorMessage = "Username is required")]
    [StringLength(50, MinimumLength = 3)]
    public string Username { get; set; } = string.Empty;

    [Required(ErrorMessage = "Email is required")]
    [EmailAddress(ErrorMessage = "Invalid email format")]
    public string Email { get; set; } = string.Empty;

    [Required(ErrorMessage = "Password is required")]
    [StringLength(100, MinimumLength = 6)]
    public string Password { get; set; } = string.Empty;

    [Required(ErrorMessage = "Password confirmation is required")]
    [Compare("Password")]
    public string ConfirmPassword { get; set; } = string.Empty;
}

public class User
{
    public int Id { get; set; }
    public string Username { get; set; } = string.Empty;
    public string Password { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public List<string> Roles { get; set; } = new();
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}

public class ApiResponse<T>
{
    public bool Success { get; set; }
    public string Message { get; set; } = string.Empty;
    public T? Data { get; set; }
    public List<string> Errors { get; set; } = new();
}

public class UserProfile
{
    public int Id { get; set; }
    public string Username { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public List<string> Roles { get; set; } = new();
    public DateTime CreatedAt { get; set; }
}
'@
New-ProjectFile -FilePath "Models/AuthModels.cs" -Content $authModelsContent -Description "Authentication and authorization models"

# Create Services/JwtTokenService.cs
$jwtTokenServiceContent = @'
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using JwtAuthenticationAPI.Models;

namespace JwtAuthenticationAPI.Services;

public interface IJwtTokenService
{
    string GenerateToken(User user);
    ClaimsPrincipal? ValidateToken(string token);
}

public class JwtTokenService : IJwtTokenService
{
    private readonly IConfiguration _configuration;
    private readonly ILogger<JwtTokenService> _logger;

    public JwtTokenService(IConfiguration configuration, ILogger<JwtTokenService> logger)
    {
        _configuration = configuration;
        _logger = logger;
    }

    public string GenerateToken(User user)
    {
        try
        {
            var jwtSettings = _configuration.GetSection("Jwt");
            var key = Encoding.UTF8.GetBytes(jwtSettings["Key"]!);
            var issuer = jwtSettings["Issuer"];
            var audience = jwtSettings["Audience"];
            var expiryMinutes = int.Parse(jwtSettings["ExpiryMinutes"]!);

            var tokenDescriptor = new SecurityTokenDescriptor
            {
                Subject = new ClaimsIdentity(new[]
                {
                    new Claim(ClaimTypes.NameIdentifier, user.Id.ToString()),
                    new Claim(ClaimTypes.Name, user.Username),
                    new Claim(ClaimTypes.Email, user.Email),
                    new Claim("username", user.Username),
                    new Claim("userId", user.Id.ToString())
                }),
                Expires = DateTime.UtcNow.AddMinutes(expiryMinutes),
                Issuer = issuer,
                Audience = audience,
                SigningCredentials = new SigningCredentials(
                    new SymmetricSecurityKey(key),
                    SecurityAlgorithms.HmacSha256Signature)
            };

            // Add role claims
            foreach (var role in user.Roles)
            {
                tokenDescriptor.Subject.AddClaim(new Claim(ClaimTypes.Role, role));
            }

            // Add custom claims for Exercise 03 demonstrations
            if (user.Username == "admin" || user.Username == "senior_dev")
            {
                tokenDescriptor.Subject.AddClaim(new Claim("birthdate", "1985-05-15"));
            }
            else if (user.Username == "junior_dev")
            {
                tokenDescriptor.Subject.AddClaim(new Claim("birthdate", "2002-08-20"));
            }

            // Add department claim
            if (user.Username == "admin" || user.Username.Contains("dev"))
            {
                tokenDescriptor.Subject.AddClaim(new Claim("department", "IT"));
            }
            else if (user.Username == "editor")
            {
                tokenDescriptor.Subject.AddClaim(new Claim("department", "Content"));
            }
            else
            {
                tokenDescriptor.Subject.AddClaim(new Claim("department", "General"));
            }

            var tokenHandler = new JwtSecurityTokenHandler();
            var token = tokenHandler.CreateToken(tokenDescriptor);

            _logger.LogInformation("JWT token generated successfully for user: {Username}", user.Username);

            return tokenHandler.WriteToken(token);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error generating JWT token for user: {Username}", user.Username);
            throw;
        }
    }

    public ClaimsPrincipal? ValidateToken(string token)
    {
        try
        {
            var jwtSettings = _configuration.GetSection("Jwt");
            var key = Encoding.UTF8.GetBytes(jwtSettings["Key"]!);

            var tokenHandler = new JwtSecurityTokenHandler();
            var validationParameters = new TokenValidationParameters
            {
                ValidateIssuer = true,
                ValidateAudience = true,
                ValidateLifetime = true,
                ValidateIssuerSigningKey = true,
                ValidIssuer = jwtSettings["Issuer"],
                ValidAudience = jwtSettings["Audience"],
                IssuerSigningKey = new SymmetricSecurityKey(key),
                ClockSkew = TimeSpan.Zero
            };

            var principal = tokenHandler.ValidateToken(token, validationParameters, out SecurityToken validatedToken);

            _logger.LogInformation("JWT token validated successfully");

            return principal;
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex, "JWT token validation failed");
            return null;
        }
    }
}
'@
New-ProjectFile -FilePath "Services/JwtTokenService.cs" -Content $jwtTokenServiceContent -Description "JWT token generation and validation service"

# Create Services/UserService.cs
$userServiceContent = @'
using JwtAuthenticationAPI.Models;

namespace JwtAuthenticationAPI.Services;

public interface IUserService
{
    Task<User?> AuthenticateAsync(string username, string password);
    Task<User?> GetUserByIdAsync(int id);
    Task<List<User>> GetAllUsersAsync();
}

public class UserService : IUserService
{
    private readonly List<User> _users;
    private readonly ILogger<UserService> _logger;

    public UserService(ILogger<UserService> logger)
    {
        _logger = logger;

        // In a real application, this would be replaced with a database
        _users = new List<User>
        {
            new User
            {
                Id = 1,
                Username = "admin",
                Password = HashPassword("admin123"),
                Email = "admin@example.com",
                Roles = new List<string> { "Admin", "Editor", "User", "Employee" }
            },
            new User
            {
                Id = 2,
                Username = "user",
                Password = HashPassword("user123"),
                Email = "user@example.com",
                Roles = new List<string> { "User" }
            },
            new User
            {
                Id = 3,
                Username = "editor",
                Password = HashPassword("editor123"),
                Email = "editor@example.com",
                Roles = new List<string> { "Editor", "User" }
            },
            new User
            {
                Id = 4,
                Username = "senior_dev",
                Password = HashPassword("senior123"),
                Email = "senior.dev@example.com",
                Roles = new List<string> { "Employee", "Developer" }
            },
            new User
            {
                Id = 5,
                Username = "junior_dev",
                Password = HashPassword("junior123"),
                Email = "junior.dev@example.com",
                Roles = new List<string> { "Employee", "Developer" }
            }
        };
    }

    public async Task<User?> AuthenticateAsync(string username, string password)
    {
        try
        {
            _logger.LogInformation("Attempting to authenticate user: {Username}", username);

            await Task.Delay(100); // Simulate async database call

            var user = _users.FirstOrDefault(x =>
                x.Username.Equals(username, StringComparison.OrdinalIgnoreCase));

            if (user != null && ValidatePassword(password, user.Password))
            {
                _logger.LogInformation("User authenticated successfully: {Username}", username);
                return user;
            }

            _logger.LogWarning("Authentication failed for user: {Username}", username);
            return null;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error during authentication for user: {Username}", username);
            return null;
        }
    }

    public async Task<User?> GetUserByIdAsync(int id)
    {
        try
        {
            await Task.Delay(50); // Simulate async database call

            var user = _users.FirstOrDefault(x => x.Id == id);

            return user;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving user by ID: {UserId}", id);
            return null;
        }
    }

    public async Task<List<User>> GetAllUsersAsync()
    {
        try
        {
            await Task.Delay(50); // Simulate async database call

            return _users.ToList();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving all users");
            return new List<User>();
        }
    }

    private bool ValidatePassword(string password, string hashedPassword)
    {
        // In a real application, use proper password hashing like BCrypt
        return HashPassword(password) == hashedPassword;
    }

    private string HashPassword(string password)
    {
        // In a real application, use BCrypt, Argon2, or ASP.NET Core Identity
        // For demo purposes, using simple hash
        using var sha256 = System.Security.Cryptography.SHA256.Create();
        var hashedBytes = sha256.ComputeHash(System.Text.Encoding.UTF8.GetBytes(password + "salt"));
        return Convert.ToBase64String(hashedBytes);
    }
}
'@
New-ProjectFile -FilePath "Services/UserService.cs" -Content $userServiceContent -Description "User authentication and management service"

# Create Controllers/AuthController.cs
$authControllerContent = @'
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using JwtAuthenticationAPI.Models;
using JwtAuthenticationAPI.Services;
using System.Security.Claims;

namespace JwtAuthenticationAPI.Controllers;

[ApiController]
[Route("api/[controller]")]
public class AuthController : ControllerBase
{
    private readonly IJwtTokenService _jwtTokenService;
    private readonly IUserService _userService;
    private readonly ILogger<AuthController> _logger;

    public AuthController(
        IJwtTokenService jwtTokenService,
        IUserService userService,
        ILogger<AuthController> logger)
    {
        _jwtTokenService = jwtTokenService;
        _userService = userService;
        _logger = logger;
    }

    /// <summary>
    /// Authenticate user and return JWT token
    /// </summary>
    /// <param name="request">Login credentials</param>
    /// <returns>JWT token if authentication successful</returns>
    [HttpPost("login")]
    public async Task<IActionResult> Login([FromBody] LoginRequest request)
    {
        try
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(new ApiResponse<object>
                {
                    Success = false,
                    Message = "Invalid request data",
                    Errors = ModelState.Values.SelectMany(v => v.Errors.Select(e => e.ErrorMessage)).ToList()
                });
            }

            var user = await _userService.AuthenticateAsync(request.Username, request.Password);

            if (user == null)
            {
                _logger.LogWarning("Login attempt failed for username: {Username}", request.Username);
                return Unauthorized(new ApiResponse<object>
                {
                    Success = false,
                    Message = "Invalid username or password"
                });
            }

            var token = _jwtTokenService.GenerateToken(user);
            var response = new LoginResponse
            {
                Token = token,
                Expiration = DateTime.UtcNow.AddMinutes(60),
                Username = user.Username,
                Roles = user.Roles
            };

            _logger.LogInformation("User logged in successfully: {Username}", request.Username);

            return Ok(new ApiResponse<LoginResponse>
            {
                Success = true,
                Message = "Login successful",
                Data = response
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error during login for username: {Username}", request.Username);
            return StatusCode(500, new ApiResponse<object>
            {
                Success = false,
                Message = "An error occurred during login"
            });
        }
    }

    /// <summary>
    /// Test endpoint to verify JWT authentication
    /// </summary>
    /// <returns>Success message if authenticated</returns>
    [HttpGet("protected")]
    [Authorize]
    public IActionResult Protected()
    {
        var username = User.FindFirst(ClaimTypes.Name)?.Value;
        var roles = User.FindAll(ClaimTypes.Role).Select(c => c.Value).ToList();

        return Ok(new ApiResponse<object>
        {
            Success = true,
            Message = $"Hello {username}! You have successfully accessed a protected endpoint.",
            Data = new { Username = username, Roles = roles }
        });
    }

    /// <summary>
    /// Get current user profile (requires authentication)
    /// </summary>
    /// <returns>Current user's profile information</returns>
    [HttpGet("profile")]
    [Authorize]
    public async Task<IActionResult> GetProfile()
    {
        try
        {
            var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            if (string.IsNullOrEmpty(userId) || !int.TryParse(userId, out int id))
            {
                return Unauthorized(new ApiResponse<object>
                {
                    Success = false,
                    Message = "Invalid user token"
                });
            }

            var user = await _userService.GetUserByIdAsync(id);

            if (user == null)
            {
                return NotFound(new ApiResponse<object>
                {
                    Success = false,
                    Message = "User not found"
                });
            }

            return Ok(new ApiResponse<object>
            {
                Success = true,
                Message = "Profile retrieved successfully",
                Data = new {
                    Id = user.Id,
                    Username = user.Username,
                    Email = user.Email,
                    Roles = user.Roles,
                    CreatedAt = user.CreatedAt
                }
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving user profile");
            return StatusCode(500, new ApiResponse<object>
            {
                Success = false,
                Message = "An error occurred while retrieving profile"
            });
        }
    }
}
'@
New-ProjectFile -FilePath "Controllers/AuthController.cs" -Content $authControllerContent -Description "Authentication controller with login and profile endpoints"

# Exercise 02 specific files
if ($Exercise -eq "exercise02" -or $Exercise -eq "exercise03") {
    # Create AdminController.cs
    $adminControllerContent = @'
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using JwtAuthenticationAPI.Models;

namespace JwtAuthenticationAPI.Controllers;

/// <summary>
/// Admin-only endpoints from Exercise 02
/// </summary>
[ApiController]
[Route("api/[controller]")]
public class AdminController : ControllerBase
{
    /// <summary>
    /// Admin dashboard - requires Admin role
    /// </summary>
    [HttpGet("dashboard")]
    [Authorize(Roles = "Admin")]
    public IActionResult GetDashboard()
    {
        return Ok(new ApiResponse<object>
        {
            Success = true,
            Message = "Admin Dashboard Data",
            Data = new
            {
                TotalUsers = 150,
                ActiveSessions = 45,
                SystemHealth = "Good",
                LastBackup = DateTime.UtcNow.AddHours(-2)
            }
        });
    }

    /// <summary>
    /// Get all users - Admin only policy
    /// </summary>
    [HttpGet("users")]
    [Authorize(Policy = "AdminOnly")]
    public IActionResult GetAllUsers()
    {
        return Ok(new ApiResponse<object>
        {
            Success = true,
            Message = "List of all users",
            Data = new[]
            {
                new { Id = 1, Username = "admin", Role = "Admin", LastLogin = DateTime.UtcNow.AddMinutes(-30) },
                new { Id = 2, Username = "editor", Role = "Editor", LastLogin = DateTime.UtcNow.AddHours(-1) },
                new { Id = 3, Username = "user", Role = "User", LastLogin = DateTime.UtcNow.AddDays(-1) }
            }
        });
    }
}
'@
    New-ProjectFile -FilePath "Controllers/AdminController.cs" -Content $adminControllerContent -Description "Admin-only controller for Exercise 02"

    # Create EditorController.cs
    $editorControllerContent = @'
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using JwtAuthenticationAPI.Models;

namespace JwtAuthenticationAPI.Controllers;

/// <summary>
/// Editor endpoints from Exercise 02
/// </summary>
[ApiController]
[Route("api/[controller]")]
public class EditorController : ControllerBase
{
    /// <summary>
    /// Content management - Editor or Admin access
    /// </summary>
    [HttpGet("content")]
    [Authorize(Policy = "EditorOrAdmin")]
    public IActionResult GetContent()
    {
        return Ok(new ApiResponse<object>
        {
            Success = true,
            Message = "Content Management Data",
            Data = new
            {
                Articles = new[]
                {
                    new { Id = 1, Title = "Getting Started with JWT", Status = "Published" },
                    new { Id = 2, Title = "Role-Based Authorization", Status = "Draft" },
                    new { Id = 3, Title = "Custom Policies", Status = "Review" }
                },
                CanPublish = User.IsInRole("Editor") || User.IsInRole("Admin"),
                CanDelete = User.IsInRole("Admin")
            }
        });
    }

    /// <summary>
    /// Create content - requires Editor role
    /// </summary>
    [HttpPost("content")]
    [Authorize(Roles = "Editor,Admin")]
    public IActionResult CreateContent([FromBody] object content)
    {
        return Ok(new ApiResponse<object>
        {
            Success = true,
            Message = "Content created successfully",
            Data = new { Id = 4, CreatedAt = DateTime.UtcNow }
        });
    }
}
'@
    New-ProjectFile -FilePath "Controllers/EditorController.cs" -Content $editorControllerContent -Description "Editor controller for Exercise 02"

    # Create UsersController.cs
    $usersControllerContent = @'
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using JwtAuthenticationAPI.Models;
using JwtAuthenticationAPI.Services;
using System.Security.Claims;

namespace JwtAuthenticationAPI.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize] // All endpoints in this controller require authentication
public class UsersController : ControllerBase
{
    private readonly IUserService _userService;
    private readonly ILogger<UsersController> _logger;

    public UsersController(IUserService userService, ILogger<UsersController> logger)
    {
        _userService = userService;
        _logger = logger;
    }

    /// <summary>
    /// Get all users (Admin only)
    /// </summary>
    /// <returns>List of all users</returns>
    [HttpGet]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> GetAllUsers()
    {
        try
        {
            var users = await _userService.GetAllUsersAsync();

            var userProfiles = users.Select(u => new UserProfile
            {
                Id = u.Id,
                Username = u.Username,
                Email = u.Email,
                Roles = u.Roles,
                CreatedAt = u.CreatedAt
            }).ToList();

            return Ok(new ApiResponse<List<UserProfile>>
            {
                Success = true,
                Message = "Users retrieved successfully",
                Data = userProfiles
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving all users");
            return StatusCode(500, new ApiResponse<object>
            {
                Success = false,
                Message = "An error occurred while retrieving users"
            });
        }
    }

    /// <summary>
    /// Get current user's information
    /// </summary>
    /// <returns>Current user profile</returns>
    [HttpGet("me")]
    public async Task<IActionResult> GetCurrentUser()
    {
        try
        {
            var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            if (string.IsNullOrEmpty(userId) || !int.TryParse(userId, out int id))
            {
                return Unauthorized(new ApiResponse<object>
                {
                    Success = false,
                    Message = "Invalid user token"
                });
            }

            var user = await _userService.GetUserByIdAsync(id);

            if (user == null)
            {
                return NotFound(new ApiResponse<object>
                {
                    Success = false,
                    Message = "User not found"
                });
            }

            var profile = new UserProfile
            {
                Id = user.Id,
                Username = user.Username,
                Email = user.Email,
                Roles = user.Roles,
                CreatedAt = user.CreatedAt
            };

            return Ok(new ApiResponse<UserProfile>
            {
                Success = true,
                Message = "Current user retrieved successfully",
                Data = profile
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving current user");
            return StatusCode(500, new ApiResponse<object>
            {
                Success = false,
                Message = "An error occurred while retrieving current user"
            });
        }
    }
}
'@
    New-ProjectFile -FilePath "Controllers/UsersController.cs" -Content $usersControllerContent -Description "Users management controller for Exercise 02"
}

# Exercise 03 specific files
if ($Exercise -eq "exercise03") {
    # Create Requirements
    $minimumAgeRequirementContent = @'
using Microsoft.AspNetCore.Authorization;

namespace JwtAuthenticationAPI.Requirements;

public class MinimumAgeRequirement : IAuthorizationRequirement
{
    public int MinimumAge { get; }

    public MinimumAgeRequirement(int minimumAge)
    {
        MinimumAge = minimumAge;
    }
}
'@
    New-ProjectFile -FilePath "Requirements/MinimumAgeRequirement.cs" -Content $minimumAgeRequirementContent -Description "Minimum age requirement for Exercise 03"

    $departmentRequirementContent = @'
using Microsoft.AspNetCore.Authorization;

namespace JwtAuthenticationAPI.Requirements;

public class DepartmentRequirement : IAuthorizationRequirement
{
    public string[] AllowedDepartments { get; }

    public DepartmentRequirement(params string[] departments)
    {
        AllowedDepartments = departments;
    }
}
'@
    New-ProjectFile -FilePath "Requirements/DepartmentRequirement.cs" -Content $departmentRequirementContent -Description "Department requirement for Exercise 03"

    $workingHoursRequirementContent = @'
using Microsoft.AspNetCore.Authorization;

namespace JwtAuthenticationAPI.Requirements;

public class WorkingHoursRequirement : IAuthorizationRequirement
{
    public TimeSpan StartTime { get; }
    public TimeSpan EndTime { get; }

    public WorkingHoursRequirement(TimeSpan startTime, TimeSpan endTime)
    {
        StartTime = startTime;
        EndTime = endTime;
    }
}
'@
    New-ProjectFile -FilePath "Requirements/WorkingHoursRequirement.cs" -Content $workingHoursRequirementContent -Description "Working hours requirement for Exercise 03"

    # Create Handlers
    $minimumAgeHandlerContent = @'
using Microsoft.AspNetCore.Authorization;
using JwtAuthenticationAPI.Requirements;

namespace JwtAuthenticationAPI.Handlers;

public class MinimumAgeHandler : AuthorizationHandler<MinimumAgeRequirement>
{
    protected override Task HandleRequirementAsync(
        AuthorizationHandlerContext context,
        MinimumAgeRequirement requirement)
    {
        var birthDateClaim = context.User.FindFirst("birthdate");

        if (birthDateClaim != null && DateTime.TryParse(birthDateClaim.Value, out var birthDate))
        {
            var age = DateTime.Today.Year - birthDate.Year;
            if (birthDate > DateTime.Today.AddYears(-age)) age--;

            if (age >= requirement.MinimumAge)
            {
                context.Succeed(requirement);
            }
        }

        return Task.CompletedTask;
    }
}
'@
    New-ProjectFile -FilePath "Handlers/MinimumAgeHandler.cs" -Content $minimumAgeHandlerContent -Description "Minimum age authorization handler for Exercise 03"

    $departmentHandlerContent = @'
using Microsoft.AspNetCore.Authorization;
using JwtAuthenticationAPI.Requirements;

namespace JwtAuthenticationAPI.Handlers;

public class DepartmentHandler : AuthorizationHandler<DepartmentRequirement>
{
    protected override Task HandleRequirementAsync(
        AuthorizationHandlerContext context,
        DepartmentRequirement requirement)
    {
        var departmentClaim = context.User.FindFirst("department");

        if (departmentClaim != null)
        {
            var userDepartment = departmentClaim.Value;

            if (requirement.AllowedDepartments.Contains(userDepartment, StringComparer.OrdinalIgnoreCase))
            {
                context.Succeed(requirement);
            }
        }

        return Task.CompletedTask;
    }
}
'@
    New-ProjectFile -FilePath "Handlers/DepartmentHandler.cs" -Content $departmentHandlerContent -Description "Department authorization handler for Exercise 03"

    $workingHoursHandlerContent = @'
using Microsoft.AspNetCore.Authorization;
using JwtAuthenticationAPI.Requirements;

namespace JwtAuthenticationAPI.Handlers;

public class WorkingHoursHandler : AuthorizationHandler<WorkingHoursRequirement>
{
    protected override Task HandleRequirementAsync(
        AuthorizationHandlerContext context,
        WorkingHoursRequirement requirement)
    {
        var currentTime = DateTime.Now.TimeOfDay;

        // Check if current time is within working hours
        if (currentTime >= requirement.StartTime && currentTime <= requirement.EndTime)
        {
            context.Succeed(requirement);
        }

        return Task.CompletedTask;
    }
}
'@
    New-ProjectFile -FilePath "Handlers/WorkingHoursHandler.cs" -Content $workingHoursHandlerContent -Description "Working hours authorization handler for Exercise 03"

    # Create PolicyController.cs
    $policyControllerContent = @'
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using JwtAuthenticationAPI.Models;
using System.Security.Claims;

namespace JwtAuthenticationAPI.Controllers;

/// <summary>
/// Custom policy endpoints from Exercise 03
/// </summary>
[ApiController]
[Route("api/[controller]")]
public class PolicyController : ControllerBase
{
    /// <summary>
    /// Adult content - requires minimum age of 18
    /// </summary>
    [HttpGet("adult-content")]
    [Authorize(Policy = "Adult")]
    public IActionResult GetAdultContent()
    {
        return Ok(new ApiResponse<object>
        {
            Success = true,
            Message = "Adult content accessed",
            Data = new { Content = "This content is restricted to users 18 and older" }
        });
    }

    /// <summary>
    /// IT Department resources - requires IT or Development department
    /// </summary>
    [HttpGet("it-resources")]
    [Authorize(Policy = "ITDepartment")]
    public IActionResult GetITResources()
    {
        var department = User.FindFirst("department")?.Value;

        return Ok(new ApiResponse<object>
        {
            Success = true,
            Message = "IT Department Resources",
            Data = new
            {
                Department = department,
                Resources = new[]
                {
                    "Source Code Repository",
                    "Development Servers",
                    "CI/CD Pipeline",
                    "Technical Documentation"
                }
            }
        });
    }

    /// <summary>
    /// Business hours only endpoint - accessible 9 AM to 5 PM
    /// </summary>
    [HttpGet("business-hours")]
    [Authorize(Policy = "BusinessHours")]
    public IActionResult GetBusinessHoursData()
    {
        return Ok(new ApiResponse<object>
        {
            Success = true,
            Message = "Business hours data accessed",
            Data = new
            {
                CurrentTime = DateTime.Now.ToString("HH:mm"),
                BusinessData = "This data is only available during business hours (9:00 - 17:00)"
            }
        });
    }

    /// <summary>
    /// Senior IT Staff endpoint - combined requirements
    /// </summary>
    [HttpGet("senior-it-data")]
    [Authorize(Policy = "SeniorITStaff")]
    public IActionResult GetSeniorITData()
    {
        var username = User.FindFirst(ClaimTypes.Name)?.Value;
        var department = User.FindFirst("department")?.Value;

        return Ok(new ApiResponse<object>
        {
            Success = true,
            Message = "Senior IT Staff Data",
            Data = new
            {
                User = username,
                Department = department,
                AccessLevel = "Senior",
                SensitiveData = new
                {
                    ServerPasswords = "********",
                    DatabaseConnections = "Encrypted",
                    APIKeys = "Secured"
                }
            }
        });
    }

    /// <summary>
    /// Public info - no authentication required
    /// </summary>
    [HttpGet("public-info")]
    public IActionResult GetPublicInfo()
    {
        return Ok(new ApiResponse<object>
        {
            Success = true,
            Message = "Public information",
            Data = new
            {
                CompanyName = "Tech Corp",
                Address = "123 Tech Street",
                Phone = "555-0123",
                OpenHours = "Mon-Fri 9:00-17:00"
            }
        });
    }
}
'@
    New-ProjectFile -FilePath "Controllers/PolicyController.cs" -Content $policyControllerContent -Description "Policy controller for Exercise 03"
}

# Create Program.cs based on exercise
$programContent = if ($Exercise -eq "exercise01") {
@'
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using System.Text;
using JwtAuthenticationAPI.Services;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();

// Configure Swagger with JWT support
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo
    {
        Title = "JWT Authentication API",
        Version = "v1",
        Description = "A secure API demonstrating JWT authentication and authorization"
    });

    // Add JWT Authentication to Swagger
    c.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Description = @"JWT Authorization header using the Bearer scheme.
                      Enter 'Bearer' [space] and then your token in the text input below.
                      Example: 'Bearer 12345abcdef'",
        Name = "Authorization",
        In = ParameterLocation.Header,
        Type = SecuritySchemeType.ApiKey,
        Scheme = "Bearer"
    });

    c.AddSecurityRequirement(new OpenApiSecurityRequirement()
    {
        {
            new OpenApiSecurityScheme
            {
                Reference = new OpenApiReference
                {
                    Type = ReferenceType.SecurityScheme,
                    Id = "Bearer"
                },
                Scheme = "oauth2",
                Name = "Bearer",
                In = ParameterLocation.Header,
            },
            new List<string>()
        }
    });
});

// Register services
builder.Services.AddScoped<IJwtTokenService, JwtTokenService>();
builder.Services.AddScoped<IUserService, UserService>();

// Configure JWT Authentication
var jwtSettings = builder.Configuration.GetSection("Jwt");
var key = Encoding.UTF8.GetBytes(jwtSettings["Key"]!);

builder.Services.AddAuthentication(options =>
{
    options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
})
.AddJwtBearer(options =>
{
    options.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuer = true,
        ValidateAudience = true,
        ValidateLifetime = true,
        ValidateIssuerSigningKey = true,
        ValidIssuer = jwtSettings["Issuer"],
        ValidAudience = jwtSettings["Audience"],
        IssuerSigningKey = new SymmetricSecurityKey(key),
        ClockSkew = TimeSpan.Zero
    };

    options.Events = new JwtBearerEvents
    {
        OnAuthenticationFailed = context =>
        {
            if (context.Exception.GetType() == typeof(SecurityTokenExpiredException))
            {
                context.Response.Headers.Add("Token-Expired", "true");
            }
            return Task.CompletedTask;
        }
    };
});

builder.Services.AddAuthorization();

// Add CORS for development
builder.Services.AddCors(options =>
{
    options.AddDefaultPolicy(policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyHeader()
              .AllowAnyMethod();
    });
});

var app = builder.Build();

// Configure the HTTP request pipeline
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI(c =>
    {
        c.SwaggerEndpoint("/swagger/v1/swagger.json", "JWT Authentication API V1");
    });
}

// Serve static files for demo interface
app.UseStaticFiles();

app.UseRouting();
app.UseCors();

// Authentication & Authorization middleware (ORDER MATTERS!)
app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();

// Default route to demo page
app.MapFallbackToFile("index.html");

app.Run();
'@
} elseif ($Exercise -eq "exercise02") {
@'
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using System.Text;
using JwtAuthenticationAPI.Services;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();

// Configure Swagger with JWT support
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo
    {
        Title = "JWT Authentication API - Exercise 02",
        Version = "v1",
        Description = "JWT authentication with role-based authorization"
    });

    // Add JWT Authentication to Swagger
    c.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Description = @"JWT Authorization header using the Bearer scheme.
                      Enter 'Bearer' [space] and then your token in the text input below.
                      Example: 'Bearer 12345abcdef'",
        Name = "Authorization",
        In = ParameterLocation.Header,
        Type = SecuritySchemeType.ApiKey,
        Scheme = "Bearer"
    });

    c.AddSecurityRequirement(new OpenApiSecurityRequirement()
    {
        {
            new OpenApiSecurityScheme
            {
                Reference = new OpenApiReference
                {
                    Type = ReferenceType.SecurityScheme,
                    Id = "Bearer"
                },
                Scheme = "oauth2",
                Name = "Bearer",
                In = ParameterLocation.Header,
            },
            new List<string>()
        }
    });
});

// Register services
builder.Services.AddScoped<IJwtTokenService, JwtTokenService>();
builder.Services.AddScoped<IUserService, UserService>();

// Configure JWT Authentication
var jwtSettings = builder.Configuration.GetSection("Jwt");
var key = Encoding.UTF8.GetBytes(jwtSettings["Key"]!);

builder.Services.AddAuthentication(options =>
{
    options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
})
.AddJwtBearer(options =>
{
    options.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuer = true,
        ValidateAudience = true,
        ValidateLifetime = true,
        ValidateIssuerSigningKey = true,
        ValidIssuer = jwtSettings["Issuer"],
        ValidAudience = jwtSettings["Audience"],
        IssuerSigningKey = new SymmetricSecurityKey(key),
        ClockSkew = TimeSpan.Zero
    };

    options.Events = new JwtBearerEvents
    {
        OnAuthenticationFailed = context =>
        {
            if (context.Exception.GetType() == typeof(SecurityTokenExpiredException))
            {
                context.Response.Headers.Add("Token-Expired", "true");
            }
            return Task.CompletedTask;
        }
    };
});

// Configure Authorization with role-based policies
builder.Services.AddAuthorization(options =>
{
    // Exercise 02 - Role-Based Policies
    options.AddPolicy("AdminOnly", policy => policy.RequireRole("Admin"));
    options.AddPolicy("UserOrAdmin", policy => policy.RequireRole("User", "Admin"));
    options.AddPolicy("EditorOrAdmin", policy => policy.RequireRole("Editor", "Admin"));
    options.AddPolicy("UserOrAbove", policy => policy.RequireRole("User", "Editor", "Admin"));
});

// Add CORS for development
builder.Services.AddCors(options =>
{
    options.AddDefaultPolicy(policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyHeader()
              .AllowAnyMethod();
    });
});

var app = builder.Build();

// Configure the HTTP request pipeline
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI(c =>
    {
        c.SwaggerEndpoint("/swagger/v1/swagger.json", "JWT Authentication API V1");
    });
}

// Serve static files for demo interface
app.UseStaticFiles();

app.UseRouting();
app.UseCors();

// Authentication & Authorization middleware (ORDER MATTERS!)
app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();

// Default route to demo page
app.MapFallbackToFile("index.html");

app.Run();
'@
} else {
@'
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using System.Text;
using JwtAuthenticationAPI.Services;
using JwtAuthenticationAPI.Requirements;
using JwtAuthenticationAPI.Handlers;
using Microsoft.AspNetCore.Authorization;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();

// Configure Swagger with JWT support
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo
    {
        Title = "JWT Authentication API - Exercise 03",
        Version = "v1",
        Description = "JWT authentication with custom authorization policies"
    });

    // Add JWT Authentication to Swagger
    c.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Description = @"JWT Authorization header using the Bearer scheme.
                      Enter 'Bearer' [space] and then your token in the text input below.
                      Example: 'Bearer 12345abcdef'",
        Name = "Authorization",
        In = ParameterLocation.Header,
        Type = SecuritySchemeType.ApiKey,
        Scheme = "Bearer"
    });

    c.AddSecurityRequirement(new OpenApiSecurityRequirement()
    {
        {
            new OpenApiSecurityScheme
            {
                Reference = new OpenApiReference
                {
                    Type = ReferenceType.SecurityScheme,
                    Id = "Bearer"
                },
                Scheme = "oauth2",
                Name = "Bearer",
                In = ParameterLocation.Header,
            },
            new List<string>()
        }
    });
});

// Register services
builder.Services.AddScoped<IJwtTokenService, JwtTokenService>();
builder.Services.AddScoped<IUserService, UserService>();

// Register authorization handlers from Exercise 03
builder.Services.AddScoped<IAuthorizationHandler, MinimumAgeHandler>();
builder.Services.AddScoped<IAuthorizationHandler, DepartmentHandler>();
builder.Services.AddScoped<IAuthorizationHandler, WorkingHoursHandler>();

// Configure JWT Authentication
var jwtSettings = builder.Configuration.GetSection("Jwt");
var key = Encoding.UTF8.GetBytes(jwtSettings["Key"]!);

builder.Services.AddAuthentication(options =>
{
    options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
})
.AddJwtBearer(options =>
{
    options.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuer = true,
        ValidateAudience = true,
        ValidateLifetime = true,
        ValidateIssuerSigningKey = true,
        ValidIssuer = jwtSettings["Issuer"],
        ValidAudience = jwtSettings["Audience"],
        IssuerSigningKey = new SymmetricSecurityKey(key),
        ClockSkew = TimeSpan.Zero
    };

    options.Events = new JwtBearerEvents
    {
        OnAuthenticationFailed = context =>
        {
            if (context.Exception.GetType() == typeof(SecurityTokenExpiredException))
            {
                context.Response.Headers.Add("Token-Expired", "true");
            }
            return Task.CompletedTask;
        }
    };
});

// Configure Authorization with custom policies
builder.Services.AddAuthorization(options =>
{
    // Exercise 02 - Role-Based Policies
    options.AddPolicy("AdminOnly", policy => policy.RequireRole("Admin"));
    options.AddPolicy("UserOrAdmin", policy => policy.RequireRole("User", "Admin"));
    options.AddPolicy("EditorOrAdmin", policy => policy.RequireRole("Editor", "Admin"));
    options.AddPolicy("UserOrAbove", policy => policy.RequireRole("User", "Editor", "Admin"));

    // Exercise 03 - Custom Authorization Policies
    // Age-based policy
    options.AddPolicy("Adult", policy =>
        policy.Requirements.Add(new MinimumAgeRequirement(18)));

    // Department-based policy
    options.AddPolicy("ITDepartment", policy =>
        policy.Requirements.Add(new DepartmentRequirement("IT", "Development")));

    // Working hours policy
    options.AddPolicy("BusinessHours", policy =>
        policy.Requirements.Add(new WorkingHoursRequirement(
            new TimeSpan(9, 0, 0),
            new TimeSpan(17, 0, 0))));

    // Complex combined policy
    options.AddPolicy("SeniorITStaff", policy =>
    {
        policy.RequireRole("Employee");
        policy.Requirements.Add(new MinimumAgeRequirement(25));
        policy.Requirements.Add(new DepartmentRequirement("IT"));
    });
});

// Add CORS for development
builder.Services.AddCors(options =>
{
    options.AddDefaultPolicy(policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyHeader()
              .AllowAnyMethod();
    });
});

var app = builder.Build();

// Configure the HTTP request pipeline
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI(c =>
    {
        c.SwaggerEndpoint("/swagger/v1/swagger.json", "JWT Authentication API V1");
    });
}

// Serve static files for demo interface
app.UseStaticFiles();

app.UseRouting();
app.UseCors();

// Authentication & Authorization middleware (ORDER MATTERS!)
app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();

// Default route to demo page
app.MapFallbackToFile("index.html");

app.Run();
'@
}

New-ProjectFile -FilePath "Program.cs" -Content $programContent -Description "Main program configuration with JWT authentication"

# Create wwwroot/index.html (demo interface)
$indexHtmlContent = @'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>JWT Authentication Demo</title>
    <style>
        body { font-family: Arial, sans-serif; max-width: 1200px; margin: 0 auto; padding: 20px; }
        .container { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; }
        .section { border: 1px solid #ddd; padding: 20px; border-radius: 8px; }
        .form-group { margin-bottom: 15px; }
        label { display: block; margin-bottom: 5px; font-weight: bold; }
        input, button { padding: 10px; width: 100%; box-sizing: border-box; }
        button { background: #007bff; color: white; border: none; cursor: pointer; border-radius: 4px; }
        button:hover { background: #0056b3; }
        .token-display { background: #f8f9fa; padding: 15px; border-radius: 4px; word-break: break-all; }
        .response { margin-top: 15px; padding: 15px; border-radius: 4px; }
        .success { background: #d4edda; border: 1px solid #c3e6cb; color: #155724; }
        .error { background: #f8d7da; border: 1px solid #f5c6cb; color: #721c24; }
        .endpoint-btn { margin: 5px; padding: 8px 15px; width: auto; }
        h1 { text-align: center; color: #333; }
        h2 { color: #007bff; border-bottom: 2px solid #007bff; padding-bottom: 10px; }
    </style>
</head>
<body>
    <h1>JWT Authentication Demo</h1>

    <div class="container">
        <div class="section">
            <h2>Authentication</h2>

            <div class="form-group">
                <label>Test Users:</label>
                <p><strong>admin/admin123</strong> (Admin, Editor, User roles)</p>
                <p><strong>editor/editor123</strong> (Editor, User roles)</p>
                <p><strong>user/user123</strong> (User role)</p>
                <p><strong>senior_dev/senior123</strong> (Employee, Developer)</p>
                <p><strong>junior_dev/junior123</strong> (Employee, Developer)</p>
            </div>

            <div class="form-group">
                <label for="username">Username:</label>
                <input type="text" id="username" value="admin">
            </div>

            <div class="form-group">
                <label for="password">Password:</label>
                <input type="password" id="password" value="admin123">
            </div>

            <button onclick="login()">Login</button>

            <div id="loginResponse" class="response" style="display: none;"></div>

            <div id="tokenSection" style="display: none;">
                <h3>JWT Token:</h3>
                <div id="tokenDisplay" class="token-display"></div>
            </div>
        </div>

        <div class="section">
            <h2>API Testing</h2>

            <div class="form-group">
                <label>Basic Endpoints:</label>
                <button class="endpoint-btn" onclick="testEndpoint('/api/auth/profile')">Get Profile</button>
                <button class="endpoint-btn" onclick="testEndpoint('/api/auth/protected')">Protected</button>
            </div>

            <div class="form-group">
                <label>Role-Based Endpoints (Exercise 02):</label>
                <button class="endpoint-btn" onclick="testEndpoint('/api/admin/dashboard')">Admin Dashboard</button>
                <button class="endpoint-btn" onclick="testEndpoint('/api/admin/users')">Admin Users</button>
                <button class="endpoint-btn" onclick="testEndpoint('/api/editor/content')">Editor Content</button>
                <button class="endpoint-btn" onclick="testEndpoint('/api/users/me')">My Profile</button>
            </div>

            <div class="form-group">
                <label>Policy-Based Endpoints (Exercise 03):</label>
                <button class="endpoint-btn" onclick="testEndpoint('/api/policy/adult-content')">Adult Content</button>
                <button class="endpoint-btn" onclick="testEndpoint('/api/policy/it-resources')">IT Resources</button>
                <button class="endpoint-btn" onclick="testEndpoint('/api/policy/business-hours')">Business Hours</button>
                <button class="endpoint-btn" onclick="testEndpoint('/api/policy/senior-it-data')">Senior IT Data</button>
                <button class="endpoint-btn" onclick="testEndpoint('/api/policy/public-info')">Public Info</button>
            </div>

            <div id="apiResponse" class="response" style="display: none;"></div>
        </div>
    </div>

    <script>
        let currentToken = '';

        async function login() {
            const username = document.getElementById('username').value;
            const password = document.getElementById('password').value;

            try {
                const response = await fetch('/api/auth/login', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                    },
                    body: JSON.stringify({ username, password })
                });

                const data = await response.json();

                if (data.success) {
                    currentToken = data.data.token;
                    document.getElementById('loginResponse').className = 'response success';
                    document.getElementById('loginResponse').innerHTML = `
                        <strong>Login Successful!</strong><br>
                        Username: ${data.data.username}<br>
                        Roles: ${data.data.roles.join(', ')}<br>
                        Expires: ${new Date(data.data.expiration).toLocaleString()}
                    `;
                    document.getElementById('tokenDisplay').textContent = currentToken;
                    document.getElementById('tokenSection').style.display = 'block';
                } else {
                    document.getElementById('loginResponse').className = 'response error';
                    document.getElementById('loginResponse').innerHTML = `<strong>Error:</strong> ${data.message}`;
                }
                document.getElementById('loginResponse').style.display = 'block';
            } catch (error) {
                document.getElementById('loginResponse').className = 'response error';
                document.getElementById('loginResponse').innerHTML = `<strong>Error:</strong> ${error.message}`;
                document.getElementById('loginResponse').style.display = 'block';
            }
        }

        async function testEndpoint(endpoint) {
            if (!currentToken && !endpoint.includes('public')) {
                document.getElementById('apiResponse').className = 'response error';
                document.getElementById('apiResponse').innerHTML = '<strong>Error:</strong> Please login first!';
                document.getElementById('apiResponse').style.display = 'block';
                return;
            }

            try {
                const headers = {
                    'Content-Type': 'application/json'
                };

                if (currentToken) {
                    headers['Authorization'] = `Bearer ${currentToken}`;
                }

                const response = await fetch(endpoint, { headers });
                const data = await response.json();

                if (response.ok) {
                    document.getElementById('apiResponse').className = 'response success';
                    document.getElementById('apiResponse').innerHTML = `
                        <strong>Success!</strong><br>
                        <pre>${JSON.stringify(data, null, 2)}</pre>
                    `;
                } else {
                    document.getElementById('apiResponse').className = 'response error';
                    document.getElementById('apiResponse').innerHTML = `
                        <strong>Error ${response.status}:</strong><br>
                        <pre>${JSON.stringify(data, null, 2)}</pre>
                    `;
                }
                document.getElementById('apiResponse').style.display = 'block';
            } catch (error) {
                document.getElementById('apiResponse').className = 'response error';
                document.getElementById('apiResponse').innerHTML = `<strong>Error:</strong> ${error.message}`;
                document.getElementById('apiResponse').style.display = 'block';
            }
        }
    </script>
</body>
</html>
'@
New-ProjectFile -FilePath "wwwroot/index.html" -Content $indexHtmlContent -Description "Interactive demo interface for testing JWT authentication"

Write-Host ""
Write-Header "Exercise Created Successfully!"
Write-Host ""
Write-Info "Next steps:"
Write-Host "  1. dotnet run"
Write-Host "  2. Visit http://localhost:5000 for interactive demo"
Write-Host "  3. Visit http://localhost:5000/swagger for API documentation"
Write-Host ""
Write-Info "Test users available:"
Write-Host "  - admin/admin123 (Admin, Editor, User roles)"
Write-Host "  - editor/editor123 (Editor, User roles)"
Write-Host "  - user/user123 (User role)"
Write-Host "  - senior_dev/senior123 (Employee, Developer - for Exercise 03)"
Write-Host "  - junior_dev/junior123 (Employee, Developer - for Exercise 03)"
Write-Host ""

if ($Exercise -eq "exercise02") {
    Write-Info "Exercise 02 Features:"
    Write-Host "  - Role-based authorization policies"
    Write-Host "  - Admin, Editor, and User controllers"
    Write-Host "  - Different access levels for each role"
}

if ($Exercise -eq "exercise03") {
    Write-Info "Exercise 03 Features:"
    Write-Host "  - Custom authorization requirements and handlers"
    Write-Host "  - Age-based policies (18+ for adult content)"
    Write-Host "  - Department-based access (IT department)"
    Write-Host "  - Time-based access (business hours 9-5)"
    Write-Host "  - Combined policies (Senior IT Staff)"
}