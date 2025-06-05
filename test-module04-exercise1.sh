#!/bin/bash

# Test Module 04 Exercise 1 implementation

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

ERRORS=0

echo -e "${BLUE}🧪 Testing Module 04 Exercise 1 Implementation${NC}"
echo "=============================================="

# Clean up any existing project
rm -rf JwtAuthenticationAPI

# Test 1: Setup script
echo -e "${BLUE}1. Testing setup script...${NC}"
if ./setup-exercise.sh module04-exercise01-jwt > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Setup script works${NC}"
else
    echo -e "${RED}❌ Setup script failed${NC}"
    ((ERRORS++))
    exit 1
fi

cd JwtAuthenticationAPI

# Test 2: Build after setup
echo -e "${BLUE}2. Testing initial build...${NC}"
if dotnet build > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Project builds after setup${NC}"
else
    echo -e "${RED}❌ Project fails to build after setup${NC}"
    ((ERRORS++))
fi

# Test 3: Add code from exercise and test build
echo -e "${BLUE}3. Adding code from Exercise 1...${NC}"

# Create Models directory and add AuthModels.cs
mkdir -p Models
cat > Models/AuthModels.cs << 'EOF'
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
EOF

# Create Services directory and add services
mkdir -p Services
cat > Services/JwtTokenService.cs << 'EOF'
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

        foreach (var role in user.Roles)
        {
            tokenDescriptor.Subject.AddClaim(new Claim(ClaimTypes.Role, role));
        }

        var tokenHandler = new JwtSecurityTokenHandler();
        var token = tokenHandler.CreateToken(tokenDescriptor);
        
        return tokenHandler.WriteToken(token);
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
            return principal;
        }
        catch
        {
            return null;
        }
    }
}
EOF

cat > Services/UserService.cs << 'EOF'
using JwtAuthenticationAPI.Models;

namespace JwtAuthenticationAPI.Services;

public interface IUserService
{
    Task<User?> AuthenticateAsync(string username, string password);
    Task<User?> GetUserByIdAsync(int id);
}

public class UserService : IUserService
{
    private readonly List<User> _users;
    private readonly ILogger<UserService> _logger;

    public UserService(ILogger<UserService> logger)
    {
        _logger = logger;
        
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
                Username = "user",
                Password = HashPassword("user123"),
                Email = "user@example.com",
                Roles = new List<string> { "User" }
            }
        };
    }

    public async Task<User?> AuthenticateAsync(string username, string password)
    {
        await Task.Delay(100);
        
        var user = _users.FirstOrDefault(x => 
            x.Username.Equals(username, StringComparison.OrdinalIgnoreCase));
        
        if (user != null && ValidatePassword(password, user.Password))
        {
            return user;
        }
        
        return null;
    }

    public async Task<User?> GetUserByIdAsync(int id)
    {
        await Task.Delay(50);
        return _users.FirstOrDefault(x => x.Id == id);
    }

    private bool ValidatePassword(string password, string hashedPassword)
    {
        return HashPassword(password) == hashedPassword;
    }

    private string HashPassword(string password)
    {
        using var sha256 = System.Security.Cryptography.SHA256.Create();
        var hashedBytes = sha256.ComputeHash(System.Text.Encoding.UTF8.GetBytes(password + "salt"));
        return Convert.ToBase64String(hashedBytes);
    }
}
EOF

# Update Program.cs
cat > Program.cs << 'EOF'
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using System.Text;
using JwtAuthenticationAPI.Services;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

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
});

builder.Services.AddAuthorization();

var app = builder.Build();

// Configure the HTTP request pipeline
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

// Authentication & Authorization middleware (ORDER MATTERS!)
app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();

app.Run();
EOF

# Create Controllers directory and add AuthController
mkdir -p Controllers
cat > Controllers/AuthController.cs << 'EOF'
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

    [HttpPost("login")]
    public async Task<IActionResult> Login([FromBody] LoginRequest request)
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

        return Ok(new ApiResponse<LoginResponse>
        {
            Success = true,
            Message = "Login successful",
            Data = response
        });
    }

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
}
EOF

echo -e "${GREEN}✅ Code added from exercise${NC}"

# Test 4: Build with exercise code
echo -e "${BLUE}4. Testing build with exercise code...${NC}"
if dotnet build > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Project builds with exercise code${NC}"
else
    echo -e "${RED}❌ Project fails to build with exercise code${NC}"
    ((ERRORS++))
fi

# Test 5: Test application startup
echo -e "${BLUE}5. Testing application startup...${NC}"
timeout 10s dotnet run --urls="http://localhost:5002" > /dev/null 2>&1 &
APP_PID=$!
sleep 5

# Test endpoints
if curl -s http://localhost:5002/swagger/index.html > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Application starts and Swagger accessible${NC}"
else
    echo -e "${RED}❌ Application failed to start${NC}"
    ((ERRORS++))
fi

# Clean up
kill $APP_PID 2>/dev/null || true
cd ..
rm -rf JwtAuthenticationAPI

echo ""
echo "=============================================="
if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}🎉 Module 04 Exercise 1 test PASSED!${NC}"
    echo -e "${GREEN}✅ Students can successfully complete Exercise 1${NC}"
else
    echo -e "${RED}❌ Module 04 Exercise 1 test FAILED with $ERRORS errors${NC}"
    echo -e "${YELLOW}⚠️  Exercise needs more work${NC}"
fi

exit $ERRORS
