# Exercise 2: Add Authentication and Security to Your API

## 🎯 Objective
Secure your Library API with JWT authentication, implement role-based authorization, and add security best practices.

## ⏱️ Estimated Time
40 minutes

## 📋 Prerequisites
- Completed Exercise 1
- Basic understanding of JWT tokens
- Knowledge of authentication vs authorization

## 📝 Instructions

### Part 0: Project Setup (2 minutes)

**Run the setup script:**
```bash
# From the aspnet-core-training directory
./setup-exercise.sh exercise02-authentication
cd LibraryAPI
```

**Verify setup:**
```bash
../verify-packages.sh
dotnet build
```

### Part 1: Add Authentication Models and Services (10 minutes)

2. **Create authentication models** in `Models/Auth/`:

   **User.cs**:
   ```csharp
   using Microsoft.AspNetCore.Identity;

   namespace LibraryAPI.Models.Auth
   {
       public class User : IdentityUser
       {
           public string FirstName { get; set; } = string.Empty;
           public string LastName { get; set; } = string.Empty;
           public DateTime CreatedAt { get; set; }
           public DateTime? LastLoginAt { get; set; }
           public bool IsActive { get; set; } = true;
       }
   }
   ```

   **AuthModels.cs**:
   ```csharp
   using System.ComponentModel.DataAnnotations;

   namespace LibraryAPI.Models.Auth
   {
       public class RegisterModel
       {
           [Required]
           [EmailAddress]
           public string Email { get; set; } = string.Empty;

           [Required]
           [StringLength(100, MinimumLength = 6)]
           public string Password { get; set; } = string.Empty;

           [Required]
           [Compare("Password")]
           public string ConfirmPassword { get; set; } = string.Empty;

           [Required]
           [StringLength(100)]
           public string FirstName { get; set; } = string.Empty;

           [Required]
           [StringLength(100)]
           public string LastName { get; set; } = string.Empty;
       }

       public class LoginModel
       {
           [Required]
           [EmailAddress]
           public string Email { get; set; } = string.Empty;

           [Required]
           public string Password { get; set; } = string.Empty;

           public bool RememberMe { get; set; }
       }

       public class TokenResponse
       {
           public string Token { get; set; } = string.Empty;
           public DateTime Expiration { get; set; }
           public string RefreshToken { get; set; } = string.Empty;
           public UserInfo User { get; set; } = new();
       }

       public class UserInfo
       {
           public string Id { get; set; } = string.Empty;
           public string Email { get; set; } = string.Empty;
           public string FullName { get; set; } = string.Empty;
           public List<string> Roles { get; set; } = new();
       }

       public class RefreshTokenModel
       {
           [Required]
           public string Token { get; set; } = string.Empty;

           [Required]
           public string RefreshToken { get; set; } = string.Empty;
       }

       public class ChangePasswordModel
       {
           [Required]
           public string CurrentPassword { get; set; } = string.Empty;

           [Required]
           [StringLength(100, MinimumLength = 6)]
           public string NewPassword { get; set; } = string.Empty;

           [Required]
           [Compare("NewPassword")]
           public string ConfirmNewPassword { get; set; } = string.Empty;
       }
   }
   ```

3. **Create JWT service** in `Services/`:

   **JwtService.cs**:
   ```csharp
   using System.IdentityModel.Tokens.Jwt;
   using System.Security.Claims;
   using System.Security.Cryptography;
   using System.Text;
   using LibraryAPI.Models.Auth;
   using Microsoft.AspNetCore.Identity;
   using Microsoft.IdentityModel.Tokens;

   namespace LibraryAPI.Services
   {
       public interface IJwtService
       {
           Task<TokenResponse> GenerateTokenAsync(User user);
           ClaimsPrincipal? ValidateToken(string token);
           string GenerateRefreshToken();
       }

       public class JwtService : IJwtService
       {
           private readonly IConfiguration _configuration;
           private readonly UserManager<User> _userManager;

           public JwtService(IConfiguration configuration, UserManager<User> userManager)
           {
               _configuration = configuration;
               _userManager = userManager;
           }

           public async Task<TokenResponse> GenerateTokenAsync(User user)
           {
               var tokenHandler = new JwtSecurityTokenHandler();
               var key = Encoding.ASCII.GetBytes(_configuration["Jwt:Key"]!);
               var roles = await _userManager.GetRolesAsync(user);

               var claims = new List<Claim>
               {
                   new Claim(ClaimTypes.NameIdentifier, user.Id),
                   new Claim(ClaimTypes.Email, user.Email!),
                   new Claim(ClaimTypes.Name, $"{user.FirstName} {user.LastName}"),
                   new Claim(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString()),
               };

               // Add role claims
               foreach (var role in roles)
               {
                   claims.Add(new Claim(ClaimTypes.Role, role));
               }

               var tokenDescriptor = new SecurityTokenDescriptor
               {
                   Subject = new ClaimsIdentity(claims),
                   Expires = DateTime.UtcNow.AddHours(1),
                   Issuer = _configuration["Jwt:Issuer"],
                   Audience = _configuration["Jwt:Audience"],
                   SigningCredentials = new SigningCredentials(
                       new SymmetricSecurityKey(key),
                       SecurityAlgorithms.HmacSha256Signature)
               };

               var token = tokenHandler.CreateToken(tokenDescriptor);
               var tokenString = tokenHandler.WriteToken(token);

               return new TokenResponse
               {
                   Token = tokenString,
                   Expiration = tokenDescriptor.Expires.Value,
                   RefreshToken = GenerateRefreshToken(),
                   User = new UserInfo
                   {
                       Id = user.Id,
                       Email = user.Email!,
                       FullName = $"{user.FirstName} {user.LastName}",
                       Roles = roles.ToList()
                   }
               };
           }

           public ClaimsPrincipal? ValidateToken(string token)
           {
               var tokenHandler = new JwtSecurityTokenHandler();
               var key = Encoding.ASCII.GetBytes(_configuration["Jwt:Key"]!);

               try
               {
                   var validationParameters = new TokenValidationParameters
                   {
                       ValidateIssuerSigningKey = true,
                       IssuerSigningKey = new SymmetricSecurityKey(key),
                       ValidateIssuer = true,
                       ValidIssuer = _configuration["Jwt:Issuer"],
                       ValidateAudience = true,
                       ValidAudience = _configuration["Jwt:Audience"],
                       ValidateLifetime = true,
                       ClockSkew = TimeSpan.Zero
                   };

                   var principal = tokenHandler.ValidateToken(token, validationParameters, out _);
                   return principal;
               }
               catch
               {
                   return null;
               }
           }

           public string GenerateRefreshToken()
           {
               var randomNumber = new byte[32];
               using var rng = RandomNumberGenerator.Create();
               rng.GetBytes(randomNumber);
               return Convert.ToBase64String(randomNumber);
           }
       }
   }
   ```

### Part 2: Update Data Context and Create Auth Controller (10 minutes)

1. **Update LibraryContext.cs** to inherit from IdentityDbContext:
   ```csharp
   using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
   using Microsoft.EntityFrameworkCore;
   using LibraryAPI.Models;
   using LibraryAPI.Models.Auth;

   namespace LibraryAPI.Data
   {
       public class LibraryContext : IdentityDbContext<User>
       {
           public LibraryContext(DbContextOptions<LibraryContext> options)
               : base(options)
           {
           }

           public DbSet<Book> Books => Set<Book>();
           public DbSet<Author> Authors => Set<Author>();
           public DbSet<Category> Categories => Set<Category>();
           public DbSet<RefreshToken> RefreshTokens => Set<RefreshToken>();

           protected override void OnModelCreating(ModelBuilder modelBuilder)
           {
               base.OnModelCreating(modelBuilder);

               // Previous configurations...
               
               // Configure RefreshToken
               modelBuilder.Entity<RefreshToken>(entity =>
               {
                   entity.HasKey(e => e.Id);
                   entity.Property(e => e.Token).IsRequired();
                   entity.HasIndex(e => e.Token).IsUnique();
                   entity.HasOne(e => e.User)
                       .WithMany()
                       .HasForeignKey(e => e.UserId)
                       .OnDelete(DeleteBehavior.Cascade);
               });
           }
       }

       public class RefreshToken
       {
           public int Id { get; set; }
           public string Token { get; set; } = string.Empty;
           public string UserId { get; set; } = string.Empty;
           public User User { get; set; } = null!;
           public DateTime Created { get; set; }
           public DateTime Expires { get; set; }
           public bool IsRevoked { get; set; }
       }
   }
   ```

2. **Create AuthController.cs**:
   ```csharp
   using Microsoft.AspNetCore.Authorization;
   using Microsoft.AspNetCore.Identity;
   using Microsoft.AspNetCore.Mvc;
   using Microsoft.EntityFrameworkCore;
   using LibraryAPI.Data;
   using LibraryAPI.Models.Auth;
   using LibraryAPI.Services;

   namespace LibraryAPI.Controllers
   {
       [ApiController]
       [Route("api/[controller]")]
       [Produces("application/json")]
       public class AuthController : ControllerBase
       {
           private readonly UserManager<User> _userManager;
           private readonly SignInManager<User> _signInManager;
           private readonly IJwtService _jwtService;
           private readonly LibraryContext _context;
           private readonly ILogger<AuthController> _logger;

           public AuthController(
               UserManager<User> userManager,
               SignInManager<User> signInManager,
               IJwtService jwtService,
               LibraryContext context,
               ILogger<AuthController> logger)
           {
               _userManager = userManager;
               _signInManager = signInManager;
               _jwtService = jwtService;
               _context = context;
               _logger = logger;
           }

           /// <summary>
           /// Register a new user
           /// </summary>
           [HttpPost("register")]
           [ProducesResponseType(typeof(TokenResponse), StatusCodes.Status200OK)]
           [ProducesResponseType(typeof(ValidationProblemDetails), StatusCodes.Status400BadRequest)]
           public async Task<ActionResult<TokenResponse>> Register([FromBody] RegisterModel model)
           {
               _logger.LogInformation("New user registration attempt for {Email}", model.Email);

               var user = new User
               {
                   UserName = model.Email,
                   Email = model.Email,
                   FirstName = model.FirstName,
                   LastName = model.LastName,
                   CreatedAt = DateTime.UtcNow
               };

               var result = await _userManager.CreateAsync(user, model.Password);

               if (!result.Succeeded)
               {
                   _logger.LogWarning("Registration failed for {Email}: {Errors}", 
                       model.Email, string.Join(", ", result.Errors.Select(e => e.Description)));
                   
                   return BadRequest(new ValidationProblemDetails
                   {
                       Errors = result.Errors.ToDictionary(
                           e => e.Code,
                           e => new[] { e.Description })
                   });
               }

               // Assign default role
               await _userManager.AddToRoleAsync(user, "User");

               // Generate token
               var tokenResponse = await _jwtService.GenerateTokenAsync(user);

               // Save refresh token
               var refreshToken = new RefreshToken
               {
                   Token = tokenResponse.RefreshToken,
                   UserId = user.Id,
                   Created = DateTime.UtcNow,
                   Expires = DateTime.UtcNow.AddDays(7)
               };

               _context.RefreshTokens.Add(refreshToken);
               await _context.SaveChangesAsync();

               _logger.LogInformation("User {Email} registered successfully", model.Email);

               return Ok(tokenResponse);
           }

           /// <summary>
           /// Login with email and password
           /// </summary>
           [HttpPost("login")]
           [ProducesResponseType(typeof(TokenResponse), StatusCodes.Status200OK)]
           [ProducesResponseType(StatusCodes.Status401Unauthorized)]
           public async Task<ActionResult<TokenResponse>> Login([FromBody] LoginModel model)
           {
               _logger.LogInformation("Login attempt for {Email}", model.Email);

               var user = await _userManager.FindByEmailAsync(model.Email);
               if (user == null || !user.IsActive)
               {
                   _logger.LogWarning("Login failed - user not found or inactive: {Email}", model.Email);
                   return Unauthorized(new { message = "Invalid email or password" });
               }

               var result = await _signInManager.CheckPasswordSignInAsync(user, model.Password, false);
               if (!result.Succeeded)
               {
                   _logger.LogWarning("Login failed - invalid password for: {Email}", model.Email);
                   return Unauthorized(new { message = "Invalid email or password" });
               }

               // Update last login
               user.LastLoginAt = DateTime.UtcNow;
               await _userManager.UpdateAsync(user);

               // Generate token
               var tokenResponse = await _jwtService.GenerateTokenAsync(user);

               // Save refresh token
               var refreshToken = new RefreshToken
               {
                   Token = tokenResponse.RefreshToken,
                   UserId = user.Id,
                   Created = DateTime.UtcNow,
                   Expires = DateTime.UtcNow.AddDays(7)
               };

               _context.RefreshTokens.Add(refreshToken);
               await _context.SaveChangesAsync();

               _logger.LogInformation("User {Email} logged in successfully", model.Email);

               return Ok(tokenResponse);
           }

           /// <summary>
           /// Refresh access token
           /// </summary>
           [HttpPost("refresh")]
           [ProducesResponseType(typeof(TokenResponse), StatusCodes.Status200OK)]
           [ProducesResponseType(StatusCodes.Status401Unauthorized)]
           public async Task<ActionResult<TokenResponse>> Refresh([FromBody] RefreshTokenModel model)
           {
               var principal = _jwtService.ValidateToken(model.Token);
               if (principal == null)
               {
                   return Unauthorized(new { message = "Invalid token" });
               }

               var userId = principal.FindFirst(ClaimTypes.NameIdentifier)?.Value;
               if (string.IsNullOrEmpty(userId))
               {
                   return Unauthorized(new { message = "Invalid token" });
               }

               // Validate refresh token
               var storedToken = await _context.RefreshTokens
                   .Include(rt => rt.User)
                   .FirstOrDefaultAsync(rt => 
                       rt.Token == model.RefreshToken && 
                       rt.UserId == userId &&
                       !rt.IsRevoked);

               if (storedToken == null || storedToken.Expires < DateTime.UtcNow)
               {
                   return Unauthorized(new { message = "Invalid or expired refresh token" });
               }

               // Revoke old refresh token
               storedToken.IsRevoked = true;

               // Generate new tokens
               var tokenResponse = await _jwtService.GenerateTokenAsync(storedToken.User);

               // Save new refresh token
               var newRefreshToken = new RefreshToken
               {
                   Token = tokenResponse.RefreshToken,
                   UserId = userId,
                   Created = DateTime.UtcNow,
                   Expires = DateTime.UtcNow.AddDays(7)
               };

               _context.RefreshTokens.Add(newRefreshToken);
               await _context.SaveChangesAsync();

               return Ok(tokenResponse);
           }

           /// <summary>
           /// Get current user profile
           /// </summary>
           [HttpGet("profile")]
           [Authorize]
           [ProducesResponseType(typeof(UserInfo), StatusCodes.Status200OK)]
           public async Task<ActionResult<UserInfo>> GetProfile()
           {
               var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
               var user = await _userManager.FindByIdAsync(userId!);
               
               if (user == null)
               {
                   return NotFound();
               }

               var roles = await _userManager.GetRolesAsync(user);

               return Ok(new UserInfo
               {
                   Id = user.Id,
                   Email = user.Email!,
                   FullName = $"{user.FirstName} {user.LastName}",
                   Roles = roles.ToList()
               });
           }

           /// <summary>
           /// Change password
           /// </summary>
           [HttpPost("change-password")]
           [Authorize]
           [ProducesResponseType(StatusCodes.Status200OK)]
           [ProducesResponseType(typeof(ValidationProblemDetails), StatusCodes.Status400BadRequest)]
           public async Task<IActionResult> ChangePassword([FromBody] ChangePasswordModel model)
           {
               var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
               var user = await _userManager.FindByIdAsync(userId!);

               if (user == null)
               {
                   return NotFound();
               }

               var result = await _userManager.ChangePasswordAsync(user, model.CurrentPassword, model.NewPassword);

               if (!result.Succeeded)
               {
                   return BadRequest(new ValidationProblemDetails
                   {
                       Errors = result.Errors.ToDictionary(
                           e => e.Code,
                           e => new[] { e.Description })
                   });
               }

               return Ok(new { message = "Password changed successfully" });
           }

           /// <summary>
           /// Logout (revoke refresh tokens)
           /// </summary>
           [HttpPost("logout")]
           [Authorize]
           [ProducesResponseType(StatusCodes.Status200OK)]
           public async Task<IActionResult> Logout()
           {
               var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
               
               // Revoke all user's refresh tokens
               var tokens = await _context.RefreshTokens
                   .Where(rt => rt.UserId == userId && !rt.IsRevoked)
                   .ToListAsync();

               foreach (var token in tokens)
               {
                   token.IsRevoked = true;
               }

               await _context.SaveChangesAsync();

               return Ok(new { message = "Logged out successfully" });
           }
       }
   }
   ```

### Part 3: Configure Authentication in Program.cs (10 minutes)

Update **Program.cs** with authentication configuration:

```csharp
using System.Text;
using LibraryAPI.Data;
using LibraryAPI.Models.Auth;
using LibraryAPI.Services;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();

// Configure Swagger with JWT support
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo
    {
        Title = "Library API",
        Version = "v1",
        Description = "A secure API for managing a library system"
    });

    // Add JWT Authentication
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

// Add Entity Framework
builder.Services.AddDbContext<LibraryContext>(options =>
    options.UseInMemoryDatabase("LibraryDb"));

// Add Identity
builder.Services.AddIdentity<User, IdentityRole>(options =>
{
    // Password settings
    options.Password.RequireDigit = true;
    options.Password.RequireLowercase = true;
    options.Password.RequireNonAlphanumeric = false;
    options.Password.RequireUppercase = true;
    options.Password.RequiredLength = 6;
    options.Password.RequiredUniqueChars = 1;

    // Lockout settings
    options.Lockout.DefaultLockoutTimeSpan = TimeSpan.FromMinutes(5);
    options.Lockout.MaxFailedAccessAttempts = 5;
    options.Lockout.AllowedForNewUsers = true;

    // User settings
    options.User.AllowedUserNameCharacters =
        "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._@+";
    options.User.RequireUniqueEmail = true;
})
.AddEntityFrameworkStores<LibraryContext>()
.AddDefaultTokenProviders();

// Add JWT Authentication
var jwtKey = builder.Configuration["Jwt:Key"];
var jwtIssuer = builder.Configuration["Jwt:Issuer"];
var jwtAudience = builder.Configuration["Jwt:Audience"];

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
        ValidIssuer = jwtIssuer,
        ValidAudience = jwtAudience,
        IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtKey!)),
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

// Add Authorization with policies
builder.Services.AddAuthorization(options =>
{
    options.AddPolicy("RequireAdminRole", policy => policy.RequireRole("Admin"));
    options.AddPolicy("RequireLibrarianRole", policy => policy.RequireRole("Admin", "Librarian"));
    options.AddPolicy("RequireAuthenticatedUser", policy => policy.RequireAuthenticatedUser());
});

// Register services
builder.Services.AddScoped<IJwtService, JwtService>();

// Add CORS
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowSpecificOrigin",
        policy =>
        {
            policy.WithOrigins("http://localhost:3000", "https://localhost:3000")
                   .AllowAnyHeader()
                   .AllowAnyMethod()
                   .AllowCredentials();
        });
});

var app = builder.Build();

// Seed the database with roles and admin user
using (var scope = app.Services.CreateScope())
{
    var services = scope.ServiceProvider;
    var context = services.GetRequiredService<LibraryContext>();
    var userManager = services.GetRequiredService<UserManager<User>>();
    var roleManager = services.GetRequiredService<RoleManager<IdentityRole>>();

    // Ensure database is created
    context.Database.EnsureCreated();

    // Create roles
    string[] roles = { "Admin", "Librarian", "User" };
    foreach (var role in roles)
    {
        if (!await roleManager.RoleExistsAsync(role))
        {
            await roleManager.CreateAsync(new IdentityRole(role));
        }
    }

    // Create admin user
    var adminEmail = "admin@library.com";
    var adminUser = await userManager.FindByEmailAsync(adminEmail);
    if (adminUser == null)
    {
        adminUser = new User
        {
            UserName = adminEmail,
            Email = adminEmail,
            FirstName = "Admin",
            LastName = "User",
            CreatedAt = DateTime.UtcNow,
            IsActive = true
        };

        await userManager.CreateAsync(adminUser, "Admin123!");
        await userManager.AddToRoleAsync(adminUser, "Admin");
    }
}

// Configure the HTTP request pipeline
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI(c =>
    {
        c.SwaggerEndpoint("/swagger/v1/swagger.json", "Library API V1");
    });
}

// Security headers
app.Use(async (context, next) =>
{
    context.Response.Headers["X-Content-Type-Options"] = "nosniff";
    context.Response.Headers["X-Frame-Options"] = "DENY";
    context.Response.Headers["X-XSS-Protection"] = "1; mode=block";
    context.Response.Headers.Remove("Server");
    await next();
});

app.UseHttpsRedirection();
app.UseCors("AllowSpecificOrigin");
app.UseAuthentication();
app.UseAuthorization();
app.MapControllers();

app.Run();
```

### Part 4: Secure Your API Endpoints (5 minutes)

1. **Update BooksController** to add authorization:

```csharp
[ApiController]
[Route("api/[controller]")]
[Produces("application/json")]
[Authorize] // Require authentication for all endpoints
public class BooksController : ControllerBase
{
    // ... existing code ...

    /// <summary>
    /// Create a new book (Librarian or Admin only)
    /// </summary>
    [HttpPost]
    [Authorize(Policy = "RequireLibrarianRole")]
    [ProducesResponseType(typeof(BookDto), StatusCodes.Status201Created)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    public async Task<ActionResult<BookDto>> CreateBook([FromBody] CreateBookDto createBookDto)
    {
        // ... existing code ...
    }

    /// <summary>
    /// Update an existing book (Librarian or Admin only)
    /// </summary>
    [HttpPut("{id:int}")]
    [Authorize(Policy = "RequireLibrarianRole")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    public async Task<IActionResult> UpdateBook(int id, [FromBody] UpdateBookDto updateBookDto)
    {
        // ... existing code ...
    }

    /// <summary>
    /// Delete a book (Admin only)
    /// </summary>
    [HttpDelete("{id:int}")]
    [Authorize(Roles = "Admin")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    public async Task<IActionResult> DeleteBook(int id)
    {
        _logger.LogInformation("Admin {UserId} deleting book with ID: {BookId}", 
            User.FindFirst(ClaimTypes.NameIdentifier)?.Value, id);
        
        // ... existing code ...
    }

    /// <summary>
    /// Get all books (public endpoint)
    /// </summary>
    [HttpGet]
    [AllowAnonymous] // Override controller-level authorization
    [ProducesResponseType(typeof(IEnumerable<BookDto>), StatusCodes.Status200OK)]
    public async Task<ActionResult<IEnumerable<BookDto>>> GetBooks(
        [FromQuery] string? category = null,
        [FromQuery] string? author = null,
        [FromQuery] int? year = null)
    {
        // ... existing code ...
    }
}
```

2. **Add appsettings.json configuration**:

```json
{
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "AllowedHosts": "*",
  "Jwt": {
    "Key": "ThisIsAVerySecretKeyForJWTTokensThatShouldBeAtLeast32CharactersLong!",
    "Issuer": "LibraryAPI",
    "Audience": "LibraryAPIUsers"
  }
}
```

### Part 5: Test Your Secured API (5 minutes)

1. **Run the application**:
   ```bash
   dotnet run
   ```

2. **Test authentication flow**:

   a. **Register a new user**:
   ```bash
   curl -X POST https://localhost:5001/api/auth/register \
     -H "Content-Type: application/json" \
     -d '{
       "email": "user@yourdomain.com",
       "password": "Test123!",
       "confirmPassword": "Test123!",
       "firstName": "Test",
       "lastName": "User"
     }'
   ```

   b. **Login**:
   ```bash
   curl -X POST https://localhost:5001/api/auth/login \
     -H "Content-Type: application/json" \
     -d '{
       "email": "admin@library.com",
       "password": "Admin123!"
     }'
   ```

   c. **Use the token** (copy from login response):
   ```bash
   curl -X GET https://localhost:5001/api/books \
     -H "Authorization: Bearer YOUR_TOKEN_HERE"
   ```

3. **Test in Swagger UI**:
   - Navigate to `https://localhost:[port]/swagger`
   - Click "Authorize" button
   - Enter: `Bearer YOUR_TOKEN_HERE`
   - Test protected endpoints

## ✅ Success Criteria

- [ ] Authentication endpoints working (register, login)
- [ ] JWT tokens generated successfully
- [ ] Protected endpoints require authentication
- [ ] Role-based authorization working
- [ ] Refresh token functionality working
- [ ] Security headers added
- [ ] Admin user seeded in database

## 🚀 Bonus Challenges

1. **Add Rate Limiting**:
   - Implement rate limiting for authentication endpoints
   - Prevent brute force attacks
   - Use IP-based or user-based limits

2. **Add Two-Factor Authentication**:
   - Implement TOTP-based 2FA
   - Add QR code generation
   - Verify TOTP codes on login

3. **Add API Key Authentication**:
   - Support both JWT and API key authentication
   - Create API key management endpoints
   - Track API key usage

4. **Implement Audit Logging**:
   - Log all authentication attempts
   - Track sensitive operations
   - Store audit logs securely

## 🤔 Reflection Questions

1. What's the difference between authentication and authorization?
2. Why use refresh tokens in addition to access tokens?
3. What are the security implications of storing JWTs client-side?
4. How would you implement logout with JWTs?

## 🆘 Troubleshooting

**Issue**: 'AuthorizeAttribute' could not be found
**Solution**: Add `using Microsoft.AspNetCore.Authorization;` to the top of your controller file. Ensure you have the correct package references for ASP.NET Core 8.0.

**Issue**: 401 Unauthorized on all requests
**Solution**: Ensure you're including the "Bearer " prefix in the Authorization header.

**Issue**: Token validation fails
**Solution**: Check that the JWT key in appsettings.json matches between token generation and validation.

**Issue**: CORS errors with authentication
**Solution**: Ensure AllowCredentials() is set in CORS policy when using authentication.

**Issue**: ASP0019 warnings about Headers.Add
**Solution**: Use `context.Response.Headers["HeaderName"] = "value"` instead of `Headers.Add()`.

**Issue**: Package version conflicts
**Solution**: Ensure all authentication packages are using .NET 8.0 compatible versions:
```bash
dotnet add package Microsoft.AspNetCore.Authentication.JwtBearer --version 8.0.11
dotnet add package Microsoft.AspNetCore.Identity.EntityFrameworkCore --version 8.0.11
dotnet add package System.IdentityModel.Tokens.Jwt --version 8.0.2
```

---

**Next Exercise**: [Exercise 3 - API Documentation and Versioning →](Exercise03-API-Documentation-Versioning.md)