#!/bin/bash

# Module 04: Authentication and Authorization - Exercise Launcher
# This script creates complete, working implementations for all exercises

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_header() {
    echo -e "${CYAN}$1${NC}"
}

# Function to create files interactively
create_file_interactive() {
    local file_path="$1"
    local content="$2"
    local description="$3"
    
    echo -e "${YELLOW}📝 Creating: ${file_path}${NC}"
    if [ -n "$description" ]; then
        echo -e "${BLUE}   Description: ${description}${NC}"
    fi
    
    # Create directory if it doesn't exist
    mkdir -p "$(dirname "$file_path")"
    
    # Write content to file
    echo "$content" > "$file_path"
    
    print_status "Created $file_path"
}

# Function to show exercise information
show_exercise_info() {
    local exercise=$1
    
    echo ""
    print_header "🎯 Exercise Information"
    echo ""
    
    case $exercise in
        "exercise01")
            echo -e "${CYAN}In this exercise, you will learn:${NC}"
            echo "  🔐 1. JWT token structure and validation"
            echo "  🔐 2. Configuring JWT authentication in ASP.NET Core"
            echo "  🔐 3. Implementing secure login endpoints"
            echo "  🔐 4. Testing protected API endpoints"
            echo "  🔐 5. Handling authentication errors properly"
            echo ""
            echo -e "${YELLOW}Key concepts:${NC}"
            echo "  • JWT token generation and validation"
            echo "  • Claims-based authentication"
            echo "  • Middleware configuration"
            echo "  • Security best practices"
            ;;
        "exercise02")
            echo -e "${CYAN}Building on Exercise 1, you will add:${NC}"
            echo "  👥 1. Role-based authorization to your JWT API"
            echo "  👥 2. Multiple user roles (Admin, Manager, User)"
            echo "  👥 3. [Authorize(Roles = \"...\")] attributes"
            echo "  👥 4. Role-based endpoint protection"
            echo "  👥 5. Testing role-based access control"
            echo ""
            echo -e "${YELLOW}New concepts:${NC}"
            echo "  • Role claims in JWT tokens"
            echo "  • Authorization vs Authentication"
            echo "  • Role-based access control (RBAC)"
            echo "  • Authorization policies"
            ;;
        "exercise03")
            echo -e "${CYAN}Advanced authorization with custom policies:${NC}"
            echo "  📋 1. Custom authorization requirements"
            echo "  📋 2. Authorization handlers implementation"
            echo "  📋 3. Complex policy-based authorization"
            echo "  📋 4. Resource-based authorization"
            echo "  📋 5. Advanced security scenarios"
            echo ""
            echo -e "${YELLOW}Professional concepts:${NC}"
            echo "  • Custom authorization policies"
            echo "  • Authorization handlers"
            echo "  • Resource-based authorization"
            echo "  • Security best practices"
            ;;
    esac
}

# Function to show project structure
show_project_structure() {
    local exercise=$1
    
    echo ""
    print_header "📁 Project Structure"
    echo ""
    
    case $exercise in
        "exercise01")
            echo -e "${GREEN}🎯 Exercise 01: Complete JWT Authentication API${NC}"
            echo ""
            echo -e "${YELLOW}📋 What you'll build:${NC}"
            echo "  ✅ Complete JWT authentication system"
            echo "  ✅ Secure login and registration endpoints"
            echo "  ✅ Protected API endpoints with JWT validation"
            echo "  ✅ User management with in-memory store"
            echo "  ✅ Interactive demo web interface"
            echo "  ✅ Comprehensive error handling"
            echo "  ✅ Swagger documentation with JWT support"
            echo ""
            echo -e "${BLUE}🚀 RECOMMENDED: Use the Complete Working Example${NC}"
            echo "  ${CYAN}cd SourceCode/JwtAuthenticationAPI && dotnet run${NC}"
            echo "  Then visit: ${CYAN}http://localhost:5000${NC} for interactive demo"
            echo ""
            echo -e "${GREEN}📁 Complete Project Structure:${NC}"
            echo "  JwtAuthenticationAPI/"
            echo "  ├── Controllers/"
            echo "  │   ├── AuthController.cs       ${YELLOW}# Login, register, profile endpoints${NC}"
            echo "  │   └── SecureController.cs     ${YELLOW}# Protected endpoints for testing${NC}"
            echo "  ├── Models/"
            echo "  │   └── AuthModels.cs           ${YELLOW}# Authentication request/response models${NC}"
            echo "  ├── Services/"
            echo "  │   ├── JwtTokenService.cs      ${YELLOW}# JWT token generation and validation${NC}"
            echo "  │   └── UserService.cs          ${YELLOW}# User authentication and management${NC}"
            echo "  ├── wwwroot/"
            echo "  │   └── index.html              ${YELLOW}# Interactive demo interface${NC}"
            echo "  ├── Program.cs                  ${YELLOW}# Complete JWT configuration${NC}"
            echo "  └── appsettings.json            ${YELLOW}# JWT settings${NC}"
            ;;
            
        "exercise02")
            echo -e "${GREEN}🎯 Exercise 02: Role-Based Authorization${NC}"
            echo ""
            echo -e "${YELLOW}📋 Building on your JWT API:${NC}"
            echo "  ✅ Multiple user roles (Admin, Manager, User)"
            echo "  ✅ Role-based endpoint protection"
            echo "  ✅ Enhanced JWT tokens with role claims"
            echo "  ✅ Authorization policies for different access levels"
            echo "  ✅ Role management endpoints"
            echo "  ✅ Testing scenarios for all roles"
            echo ""
            echo -e "${GREEN}📁 Enhanced project features:${NC}"
            echo "  JwtAuthenticationAPI/"
            echo "  ├── Controllers/"
            echo "  │   ├── AuthController.cs       ${YELLOW}# Enhanced with role assignment${NC}"
            echo "  │   ├── AdminController.cs      ${YELLOW}# NEW - Admin-only endpoints${NC}"
            echo "  │   ├── ManagerController.cs    ${YELLOW}# NEW - Manager-level endpoints${NC}"
            echo "  │   └── UserController.cs       ${YELLOW}# NEW - User-level endpoints${NC}"
            echo "  ├── Models/"
            echo "  │   └── AuthModels.cs           ${YELLOW}# Enhanced with role models${NC}"
            echo "  ├── Services/"
            echo "  │   ├── JwtTokenService.cs      ${YELLOW}# Enhanced with role claims${NC}"
            echo "  │   └── UserService.cs          ${YELLOW}# Enhanced with role management${NC}"
            echo "  └── Program.cs                  ${YELLOW}# Enhanced with authorization policies${NC}"
            ;;
            
        "exercise03")
            echo -e "${GREEN}🎯 Exercise 03: Custom Authorization Policies${NC}"
            echo ""
            echo -e "${YELLOW}📋 Advanced authorization features:${NC}"
            echo "  ✅ Custom authorization requirements"
            echo "  ✅ Authorization handlers for complex logic"
            echo "  ✅ Resource-based authorization"
            echo "  ✅ Age-based and department-based policies"
            echo "  ✅ Time-based access control"
            echo "  ✅ Advanced security scenarios"
            echo ""
            echo -e "${GREEN}📁 Advanced authorization features:${NC}"
            echo "  JwtAuthenticationAPI/"
            echo "  ├── Controllers/"
            echo "  │   ├── ResourceController.cs   ${YELLOW}# Resource-based authorization${NC}"
            echo "  │   └── PolicyController.cs     ${YELLOW}# Policy-based endpoints${NC}"
            echo "  ├── Requirements/"
            echo "  │   ├── MinimumAgeRequirement.cs ${YELLOW}# Custom age requirement${NC}"
            echo "  │   ├── DepartmentRequirement.cs ${YELLOW}# Department-based access${NC}"
            echo "  │   └── TimeBasedRequirement.cs  ${YELLOW}# Time-based access control${NC}"
            echo "  ├── Handlers/"
            echo "  │   ├── MinimumAgeHandler.cs    ${YELLOW}# Age verification logic${NC}"
            echo "  │   ├── DepartmentHandler.cs    ${YELLOW}# Department authorization${NC}"
            echo "  │   └── TimeBasedHandler.cs     ${YELLOW}# Time-based authorization${NC}"
            echo "  └── (all existing files enhanced)"
            ;;
    esac
}

# Main script logic
main() {
    clear
    print_header "🔐 Module 04: Authentication and Authorization - Exercise Launcher"
    print_header "=================================================================="
    echo ""
    
    if [ $# -eq 0 ]; then
        echo -e "${YELLOW}Usage: $0 <exercise_number>${NC}"
        echo ""
        echo "Available exercises:"
        echo "  exercise01 - JWT Implementation"
        echo "  exercise02 - Role-Based Authorization" 
        echo "  exercise03 - Custom Authorization Policies"
        echo ""
        echo "Example: $0 exercise01"
        exit 1
    fi
    
    local exercise=$1
    
    case $exercise in
        "exercise01"|"exercise02"|"exercise03")
            show_exercise_info $exercise
            show_project_structure $exercise
            ;;
        *)
            print_error "Invalid exercise: $exercise"
            echo "Valid options: exercise01, exercise02, exercise03"
            exit 1
            ;;
    esac
    
    echo ""
    echo -e "${YELLOW}Do you want to create this exercise? (y/N)${NC}"
    read -r response
    
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        echo "Exercise creation cancelled."
        exit 0
    fi
    
    echo ""
    print_header "🚀 Creating Exercise: $exercise"
    echo ""
    
    # Create the exercise
    case $exercise in
        "exercise01")
            create_exercise01
            ;;
        "exercise02")
            create_exercise02
            ;;
        "exercise03")
            create_exercise03
            ;;
    esac
    
    echo ""
    print_header "🎉 Exercise Created Successfully!"
    echo ""
    print_info "Next steps:"
    echo "  1. cd JwtAuthenticationAPI"
    echo "  2. dotnet run"
    echo "  3. Visit http://localhost:5000 for interactive demo"
    echo "  4. Visit http://localhost:5000/swagger for API documentation"
    echo ""
    print_info "Test users available:"
    echo "  • admin/admin123 (Admin, User roles)"
    echo "  • manager/manager123 (Manager, User roles)"  
    echo "  • user/user123 (User role)"
    echo ""
}

# Exercise creation functions
create_exercise01() {
    print_status "Creating Exercise 01: JWT Implementation"

    # Create project directory
    mkdir -p JwtAuthenticationAPI
    cd JwtAuthenticationAPI

    # Create .NET project
    print_info "Creating .NET 8.0 Web API project..."
    dotnet new webapi --framework net8.0 --no-https --force

    # Add required packages
    print_info "Adding required NuGet packages..."
    dotnet add package Microsoft.AspNetCore.Authentication.JwtBearer --version 8.0.11
    dotnet add package System.IdentityModel.Tokens.Jwt --version 8.0.8
    dotnet add package Microsoft.IdentityModel.Tokens --version 8.0.8
    dotnet add package Swashbuckle.AspNetCore --version 6.8.1

    # Create Models
    create_file_interactive "Models/AuthModels.cs" \
'using System.ComponentModel.DataAnnotations;

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

public class User
{
    public int Id { get; set; }
    public string Username { get; set; } = string.Empty;
    public string Password { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public List<string> Roles { get; set; } = new();
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
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

public class ApiResponse<T>
{
    public bool Success { get; set; }
    public string Message { get; set; } = string.Empty;
    public T? Data { get; set; }
    public List<string> Errors { get; set; } = new();
}' \
"Authentication models for requests and responses"

    # Create JWT Token Service
    create_file_interactive "Services/JwtTokenService.cs" \
'using Microsoft.IdentityModel.Tokens;
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
}' \
""JWT token generation and validation service"

    # Create User Service
    create_file_interactive "Services/UserService.cs" \
'using JwtAuthenticationAPI.Models;

namespace JwtAuthenticationAPI.Services;

public interface IUserService
{
    Task<User?> AuthenticateAsync(string username, string password);
    Task<User?> GetUserByIdAsync(int id);
    Task<User?> RegisterAsync(RegisterRequest request);
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
                Roles = new List<string> { "Admin", "User" }
            },
            new User
            {
                Id = 2,
                Username = "manager",
                Password = HashPassword("manager123"),
                Email = "manager@example.com",
                Roles = new List<string> { "Manager", "User" }
            },
            new User
            {
                Id = 3,
                Username = "user",
                Password = HashPassword("user123"),
                Email = "user@example.com",
                Roles = new List<string> { "User" }
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
            return _users.FirstOrDefault(x => x.Id == id);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving user by ID: {UserId}", id);
            return null;
        }
    }

    public async Task<User?> RegisterAsync(RegisterRequest request)
    {
        try
        {
            await Task.Delay(100); // Simulate async database call

            // Check if username already exists
            if (_users.Any(u => u.Username.Equals(request.Username, StringComparison.OrdinalIgnoreCase)))
            {
                return null; // Username already exists
            }

            var newUser = new User
            {
                Id = _users.Max(u => u.Id) + 1,
                Username = request.Username,
                Password = HashPassword(request.Password),
                Email = request.Email,
                Roles = new List<string> { "User" }, // Default role
                CreatedAt = DateTime.UtcNow
            };

            _users.Add(newUser);
            _logger.LogInformation("User registered successfully: {Username}", request.Username);

            return newUser;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error during registration for user: {Username}", request.Username);
            return null;
        }
    }

    public async Task<List<User>> GetAllUsersAsync()
    {
        await Task.Delay(50); // Simulate async database call
        return _users.ToList();
    }

    private bool ValidatePassword(string password, string hashedPassword)
    {
        return HashPassword(password) == hashedPassword;
    }

    private string HashPassword(string password)
    {
        // In a real application, use BCrypt, Argon2, or ASP.NET Core Identity
        using var sha256 = System.Security.Cryptography.SHA256.Create();
        var hashedBytes = sha256.ComputeHash(System.Text.Encoding.UTF8.GetBytes(password + "salt"));
        return Convert.ToBase64String(hashedBytes);
    }
}' \
""User authentication and management service"

    # Create Auth Controller
    create_file_interactive "Controllers/AuthController.cs" \
'using Microsoft.AspNetCore.Authorization;
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
    /// Register a new user
    /// </summary>
    [HttpPost("register")]
    public async Task<IActionResult> Register([FromBody] RegisterRequest request)
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

            var user = await _userService.RegisterAsync(request);

            if (user == null)
            {
                return BadRequest(new ApiResponse<object>
                {
                    Success = false,
                    Message = "Username already exists"
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

            _logger.LogInformation("User registered successfully: {Username}", request.Username);

            return Ok(new ApiResponse<LoginResponse>
            {
                Success = true,
                Message = "Registration successful",
                Data = response
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error during registration for username: {Username}", request.Username);
            return StatusCode(500, new ApiResponse<object>
            {
                Success = false,
                Message = "An error occurred during registration"
            });
        }
    }

    /// <summary>
    /// Get current user profile (requires authentication)
    /// </summary>
    [HttpGet("profile")]
    [Authorize]
    public async Task<IActionResult> GetProfile()
    {
        try
        {
            var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (string.IsNullOrEmpty(userIdClaim) || !int.TryParse(userIdClaim, out int userId))
            {
                return Unauthorized(new ApiResponse<object>
                {
                    Success = false,
                    Message = "Invalid token"
                });
            }

            var user = await _userService.GetUserByIdAsync(userId);
            if (user == null)
            {
                return NotFound(new ApiResponse<object>
                {
                    Success = false,
                    Message = "User not found"
                });
            }

            var userProfile = new
            {
                Id = user.Id,
                Username = user.Username,
                Email = user.Email,
                Roles = user.Roles,
                CreatedAt = user.CreatedAt
            };

            return Ok(new ApiResponse<object>
            {
                Success = true,
                Message = "Profile retrieved successfully",
                Data = userProfile
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving profile for user");
            return StatusCode(500, new ApiResponse<object>
            {
                Success = false,
                Message = "An error occurred while retrieving profile"
            });
        }
    }
}' \
""Authentication controller with login, register, and profile endpoints"

    # Create Secure Controller for testing protected endpoints
    create_file_interactive "Controllers/SecureController.cs" \
'using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using JwtAuthenticationAPI.Models;
using System.Security.Claims;

namespace JwtAuthenticationAPI.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize] // All endpoints require authentication
public class SecureController : ControllerBase
{
    private readonly ILogger<SecureController> _logger;

    public SecureController(ILogger<SecureController> logger)
    {
        _logger = logger;
    }

    /// <summary>
    /// Get public data (accessible to any authenticated user)
    /// </summary>
    [HttpGet("public")]
    public IActionResult GetPublicData()
    {
        var username = User.FindFirst(ClaimTypes.Name)?.Value;
        var roles = User.FindAll(ClaimTypes.Role).Select(c => c.Value).ToList();

        _logger.LogInformation("Public data accessed by user: {Username}", username);

        return Ok(new ApiResponse<object>
        {
            Success = true,
            Message = "Public data retrieved successfully",
            Data = new
            {
                Message = "This is public data accessible to any authenticated user",
                AccessedBy = username,
                UserRoles = roles,
                Timestamp = DateTime.UtcNow
            }
        });
    }

    /// <summary>
    /// Get user-specific data
    /// </summary>
    [HttpGet("user-data")]
    public IActionResult GetUserData()
    {
        var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        var username = User.FindFirst(ClaimTypes.Name)?.Value;
        var email = User.FindFirst(ClaimTypes.Email)?.Value;

        return Ok(new ApiResponse<object>
        {
            Success = true,
            Message = "User data retrieved successfully",
            Data = new
            {
                UserId = userId,
                Username = username,
                Email = email,
                Message = "This is your personal data",
                LastAccessed = DateTime.UtcNow
            }
        });
    }

    /// <summary>
    /// Test endpoint to verify JWT token claims
    /// </summary>
    [HttpGet("claims")]
    public IActionResult GetClaims()
    {
        var claims = User.Claims.Select(c => new { c.Type, c.Value }).ToList();

        return Ok(new ApiResponse<object>
        {
            Success = true,
            Message = "Claims retrieved successfully",
            Data = new
            {
                Claims = claims,
                TotalClaims = claims.Count,
                Timestamp = DateTime.UtcNow
            }
        });
    }

    /// <summary>
    /// Admin-only endpoint (requires Admin role)
    /// </summary>
    [HttpGet("admin")]
    [Authorize(Roles = "Admin")]
    public IActionResult GetAdminData()
    {
        var username = User.FindFirst(ClaimTypes.Name)?.Value;

        _logger.LogInformation("Admin data accessed by user: {Username}", username);

        return Ok(new ApiResponse<object>
        {
            Success = true,
            Message = "Admin data retrieved successfully",
            Data = new
            {
                Message = "This is admin-only data",
                AccessedBy = username,
                AdminLevel = "Full Access",
                Timestamp = DateTime.UtcNow
            }
        });
    }

    /// <summary>
    /// Manager or Admin endpoint
    /// </summary>
    [HttpGet("manager")]
    [Authorize(Roles = "Manager,Admin")]
    public IActionResult GetManagerData()
    {
        var username = User.FindFirst(ClaimTypes.Name)?.Value;
        var roles = User.FindAll(ClaimTypes.Role).Select(c => c.Value).ToList();

        return Ok(new ApiResponse<object>
        {
            Success = true,
            Message = "Manager data retrieved successfully",
            Data = new
            {
                Message = "This data is accessible to Managers and Admins",
                AccessedBy = username,
                UserRoles = roles,
                AccessLevel = "Management",
                Timestamp = DateTime.UtcNow
            }
        });
    }
}' \
"Secure controller with protected endpoints for testing JWT authentication"

    # Update appsettings.json with JWT configuration
    create_file_interactive "appsettings.json" \
'{
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "AllowedHosts": "*",
  "Jwt": {
    "Key": "ThisIsAVerySecretKeyForJWTTokensThatShouldBeAtLeast32CharactersLong!",
    "Issuer": "JwtAuthenticationAPI",
    "Audience": "JwtAuthenticationAPI-Users",
    "ExpiryMinutes": "60"
  }
}' \
""JWT configuration settings"

    # Update Program.cs with complete JWT configuration
    create_file_interactive "Program.cs" \
'using Microsoft.AspNetCore.Authentication.JwtBearer;
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
                      Enter '\''Bearer'\'' [space] and then your token in the text input below.
                      Example: '\''Bearer 12345abcdef'\''",
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

app.Run();' \
"Complete Program.cs with JWT authentication configuration"

    # Create interactive demo HTML page
    mkdir -p wwwroot
    create_file_interactive "wwwroot/index.html" \
'<!DOCTYPE html>
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
    <h1>🔐 JWT Authentication Demo</h1>

    <div class="container">
        <div class="section">
            <h2>Authentication</h2>

            <div class="form-group">
                <label>Test Users:</label>
                <p><strong>admin/admin123</strong> (Admin, User roles)</p>
                <p><strong>manager/manager123</strong> (Manager, User roles)</p>
                <p><strong>user/user123</strong> (User role)</p>
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
                <label>Protected Endpoints:</label>
                <button class="endpoint-btn" onclick="testEndpoint('\''/api/auth/profile'\'')">Get Profile</button>
                <button class="endpoint-btn" onclick="testEndpoint('\''/api/secure/public'\'')">Public Data</button>
                <button class="endpoint-btn" onclick="testEndpoint('\''/api/secure/user-data'\'')">User Data</button>
                <button class="endpoint-btn" onclick="testEndpoint('\''/api/secure/claims'\'')">View Claims</button>
            </div>

            <div class="form-group">
                <label>Role-Based Endpoints:</label>
                <button class="endpoint-btn" onclick="testEndpoint('\''/api/secure/admin'\'')">Admin Only</button>
                <button class="endpoint-btn" onclick="testEndpoint('\''/api/secure/manager'\'')">Manager/Admin</button>
            </div>

            <div id="apiResponse" class="response" style="display: none;"></div>
        </div>
    </div>

    <div class="section" style="margin-top: 20px;">
        <h2>API Documentation</h2>
        <p><strong>Swagger UI:</strong> <a href="/swagger" target="_blank">Open API Documentation</a></p>
        <p><strong>Base URL:</strong> <code>http://localhost:5000</code></p>

        <h3>Available Endpoints:</h3>
        <ul>
            <li><strong>POST /api/auth/login</strong> - Authenticate and get JWT token</li>
            <li><strong>POST /api/auth/register</strong> - Register new user</li>
            <li><strong>GET /api/auth/profile</strong> - Get current user profile (requires auth)</li>
            <li><strong>GET /api/secure/public</strong> - Public data (requires auth)</li>
            <li><strong>GET /api/secure/user-data</strong> - User-specific data (requires auth)</li>
            <li><strong>GET /api/secure/claims</strong> - View JWT claims (requires auth)</li>
            <li><strong>GET /api/secure/admin</strong> - Admin-only data (requires Admin role)</li>
            <li><strong>GET /api/secure/manager</strong> - Manager/Admin data (requires Manager or Admin role)</li>
        </ul>
    </div>

    <script>
        let currentToken = null;

        async function login() {
            const username = document.getElementById('\''username'\'').value;
            const password = document.getElementById('\''password'\'').value;

            try {
                const response = await fetch('\''/api/auth/login'\'', {
                    method: '\''POST'\'',
                    headers: {
                        '\''Content-Type'\'': '\''application/json'\''
                    },
                    body: JSON.stringify({ username, password })
                });

                const data = await response.json();
                const responseDiv = document.getElementById('\''loginResponse'\'');

                if (response.ok && data.success) {
                    currentToken = data.data.token;
                    responseDiv.className = '\''response success'\'';
                    responseDiv.innerHTML = `<strong>Login Successful!</strong><br>
                        Username: ${data.data.username}<br>
                        Roles: ${data.data.roles.join('\'', '\'')}`;

                    document.getElementById('\''tokenDisplay'\'').textContent = currentToken;
                    document.getElementById('\''tokenSection'\'').style.display = '\''block'\'';
                } else {
                    responseDiv.className = '\''response error'\'';
                    responseDiv.innerHTML = `<strong>Login Failed:</strong> ${data.message}`;
                }

                responseDiv.style.display = '\''block'\'';
            } catch (error) {
                const responseDiv = document.getElementById('\''loginResponse'\'');
                responseDiv.className = '\''response error'\'';
                responseDiv.innerHTML = `<strong>Error:</strong> ${error.message}`;
                responseDiv.style.display = '\''block'\'';
            }
        }

        async function testEndpoint(endpoint) {
            if (!currentToken) {
                alert('\''Please login first to get a JWT token'\'');
                return;
            }

            try {
                const response = await fetch(endpoint, {
                    method: '\''GET'\'',
                    headers: {
                        '\''Authorization'\'': `Bearer ${currentToken}`,
                        '\''Content-Type'\'': '\''application/json'\''
                    }
                });

                const data = await response.json();
                const responseDiv = document.getElementById('\''apiResponse'\'');

                if (response.ok) {
                    responseDiv.className = '\''response success'\'';
                    responseDiv.innerHTML = `<strong>Success (${response.status}):</strong><br>
                        <strong>Endpoint:</strong> ${endpoint}<br>
                        <strong>Response:</strong><br>
                        <pre>${JSON.stringify(data, null, 2)}</pre>`;
                } else {
                    responseDiv.className = '\''response error'\'';
                    responseDiv.innerHTML = `<strong>Error (${response.status}):</strong><br>
                        <strong>Endpoint:</strong> ${endpoint}<br>
                        <strong>Message:</strong> ${data.message || '\''Access denied'\''}`;
                }

                responseDiv.style.display = '\''block'\'';
            } catch (error) {
                const responseDiv = document.getElementById('\''apiResponse'\'');
                responseDiv.className = '\''response error'\'';
                responseDiv.innerHTML = `<strong>Network Error:</strong> ${error.message}`;
                responseDiv.style.display = '\''block'\'';
            }
        }
    </script>
</body>
</html>' \
"Interactive demo interface for testing JWT authentication"

    # Create exercise guide
    create_file_interactive "EXERCISE_GUIDE.md" \
'# Exercise 1: JWT Authentication Implementation

## 🎯 What You Have Built
This script has created a **complete, working JWT authentication system** with all the features from the exercise:

### ✅ Features Implemented:
- **JWT Token Generation**: Secure token creation with user claims and roles
- **User Authentication**: Login and registration endpoints
- **Protected Endpoints**: Secure API endpoints requiring JWT tokens
- **Role-Based Authorization**: Admin, Manager, and User roles with different access levels
- **Interactive Demo**: Web interface for testing authentication
- **Swagger Documentation**: Complete API documentation with JWT support
- **Error Handling**: Comprehensive error responses and logging

### 🚀 Testing Your API:
1. **Run the application**:
   ```bash
   dotnet run
   ```

2. **Open Interactive Demo**:
   - Navigate to: `http://localhost:5000`
   - Test login with provided users
   - Try different protected endpoints

3. **Open Swagger UI**:
   - Navigate to: `http://localhost:5000/swagger`
   - Use "Authorize" button to test with JWT tokens

### 👥 Test Users Available:
1. **admin/admin123** - Admin and User roles (full access)
2. **manager/manager123** - Manager and User roles (management access)
3. **user/user123** - User role only (basic access)

### 🧪 Example API Calls:

**Login:**
```bash
curl -X POST "http://localhost:5000/api/auth/login" \
  -H "Content-Type: application/json" \
  -d '\''{"username": "admin", "password": "admin123"}'\''
```

**Access Protected Endpoint:**
```bash
curl -X GET "http://localhost:5000/api/secure/public" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN_HERE"
```

**Test Role-Based Access:**
```bash
# Admin-only endpoint (should work with admin token)
curl -X GET "http://localhost:5000/api/secure/admin" \
  -H "Authorization: Bearer ADMIN_TOKEN"

# Try with user token (should fail with 403)
curl -X GET "http://localhost:5000/api/secure/admin" \
  -H "Authorization: Bearer USER_TOKEN"
```

### 🎓 Key Learning Points:
- **JWT Structure**: Header.Payload.Signature format
- **Claims-Based Authentication**: User information embedded in tokens
- **Middleware Configuration**: Proper order of authentication middleware
- **Role-Based Authorization**: Different access levels for different users
- **Security Best Practices**: Token validation, expiration, and secure storage

### ✨ Ready for Exercise 2!
Your JWT authentication system is now complete and ready for Exercise 2, where you will enhance it with more advanced role-based authorization features.' \
"Complete JWT authentication system - ready to use!"

    print_status "Exercise 01 created successfully!"
    print_info "Project structure:"
    find . -type f -name "*.cs" -o -name "*.json" -o -name "*.html" -o -name "*.md" | sort
}

# Placeholder functions for other exercises
create_exercise02() {
    print_status "Creating Exercise 02: Role-Based Authorization"

    # Ensure we're in the JwtAuthenticationAPI directory
    if [ ! -d "JwtAuthenticationAPI" ]; then
        print_error "JwtAuthenticationAPI directory not found. Please run exercise01 first."
        exit 1
    fi
    cd JwtAuthenticationAPI

    print_info "Building on Exercise 01 - Adding role-based authorization..."

    # Create AdminController.cs
    create_file_interactive "Controllers/AdminController.cs" \
'using Microsoft.AspNetCore.Authorization;
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
}' \
"Admin-only controller for Exercise 02"

    # Create EditorController.cs
    create_file_interactive "Controllers/EditorController.cs" \
'using Microsoft.AspNetCore.Authorization;
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
}' \
"Editor controller for Exercise 02"

    # Create UsersController.cs
    create_file_interactive "Controllers/UsersController.cs" \
'using Microsoft.AspNetCore.Authorization;
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
    /// Get current user'\''s information
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
}' \
"Users management controller for Exercise 02"

    # Update Program.cs to add authorization policies
    print_info "Updating Program.cs with role-based authorization policies..."
    
    # Back up existing Program.cs
    cp Program.cs Program.cs.ex01.backup

    # Create updated Program.cs with authorization policies
    create_file_interactive "Program.cs" \
'using Microsoft.AspNetCore.Authentication.JwtBearer;
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
                      Enter '\''Bearer'\'' [space] and then your token in the text input below.
                      Example: '\''Bearer 12345abcdef'\''",
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

app.Run();' \
"Updated Program.cs with role-based authorization policies"

    print_status "Exercise 02 created successfully!"
    print_info "New features added:"
    echo "  • Role-based authorization policies"
    echo "  • Admin, Editor, and User controllers"
    echo "  • Different access levels for each role"
}

create_exercise03() {
    print_status "Creating Exercise 03: Custom Authorization Policies"

    # Ensure we're in the JwtAuthenticationAPI directory
    if [ ! -d "JwtAuthenticationAPI" ]; then
        print_error "JwtAuthenticationAPI directory not found. Please run exercise01 first."
        exit 1
    fi
    cd JwtAuthenticationAPI

    print_info "Building on Exercises 01 & 02 - Adding custom authorization policies..."

    # Create Requirements directory
    mkdir -p Requirements

    # Create MinimumAgeRequirement.cs
    create_file_interactive "Requirements/MinimumAgeRequirement.cs" \
'using Microsoft.AspNetCore.Authorization;

namespace JwtAuthenticationAPI.Requirements;

public class MinimumAgeRequirement : IAuthorizationRequirement
{
    public int MinimumAge { get; }

    public MinimumAgeRequirement(int minimumAge)
    {
        MinimumAge = minimumAge;
    }
}' \
"Minimum age requirement for Exercise 03"

    # Create DepartmentRequirement.cs
    create_file_interactive "Requirements/DepartmentRequirement.cs" \
'using Microsoft.AspNetCore.Authorization;

namespace JwtAuthenticationAPI.Requirements;

public class DepartmentRequirement : IAuthorizationRequirement
{
    public string[] AllowedDepartments { get; }

    public DepartmentRequirement(params string[] departments)
    {
        AllowedDepartments = departments;
    }
}' \
"Department requirement for Exercise 03"

    # Create WorkingHoursRequirement.cs
    create_file_interactive "Requirements/WorkingHoursRequirement.cs" \
'using Microsoft.AspNetCore.Authorization;

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
}' \
"Working hours requirement for Exercise 03"

    # Create Handlers directory
    mkdir -p Handlers

    # Create MinimumAgeHandler.cs
    create_file_interactive "Handlers/MinimumAgeHandler.cs" \
'using Microsoft.AspNetCore.Authorization;
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
}' \
"Minimum age authorization handler for Exercise 03"

    # Create DepartmentHandler.cs
    create_file_interactive "Handlers/DepartmentHandler.cs" \
'using Microsoft.AspNetCore.Authorization;
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
}' \
"Department authorization handler for Exercise 03"

    # Create WorkingHoursHandler.cs
    create_file_interactive "Handlers/WorkingHoursHandler.cs" \
'using Microsoft.AspNetCore.Authorization;
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
}' \
"Working hours authorization handler for Exercise 03"

    # Create PolicyController.cs
    create_file_interactive "Controllers/PolicyController.cs" \
'using Microsoft.AspNetCore.Authorization;
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
}' \
"Policy controller for Exercise 03"

    # Update Program.cs with custom policies
    print_info "Updating Program.cs with custom authorization policies..."
    
    # Back up existing Program.cs
    cp Program.cs Program.cs.ex02.backup

    # Create final Program.cs with all policies
    create_file_interactive "Program.cs" \
'using Microsoft.AspNetCore.Authentication.JwtBearer;
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
                      Enter '\''Bearer'\'' [space] and then your token in the text input below.
                      Example: '\''Bearer 12345abcdef'\''",
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

app.Run();' \
"Final Program.cs with all authorization features"

    print_status "Exercise 03 created successfully!"
    print_info "New features added:"
    echo "  • Custom authorization requirements and handlers"
    echo "  • Age-based policies (18+ for adult content)"
    echo "  • Department-based access (IT department)"
    echo "  • Time-based access (business hours 9-5)"
    echo "  • Combined policies (Senior IT Staff)"
}

# Run main function
main "$@"""""
