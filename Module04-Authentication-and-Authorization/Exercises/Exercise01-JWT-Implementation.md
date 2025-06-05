# Exercise 1: JWT Implementation

## 🎯 Objective
Create a secure JWT authentication system from scratch and test all endpoints.

## 🌐 **Demo Application**
After completing this exercise, your application will have a comprehensive demo interface available at `http://localhost:5000` (or your configured port). The demo page includes:
- Interactive login form with test users
- JWT token display and testing
- Links to all authentication endpoints
- Real-time API testing capabilities

**Preview the final result:** Check the `wwwroot/index.html` in the source code to see what you're building toward!

## ⏱️ Time Allocation: 45 minutes

## 📋 Prerequisites
- .NET 8.0 SDK installed
- Visual Studio or VS Code
- Postman or similar API testing tool

## 🎯 Learning Goals
By completing this exercise, you will:
- ✅ Understand JWT token structure and validation
- ✅ Configure JWT authentication in ASP.NET Core
- ✅ Implement secure login endpoints
- ✅ Test protected API endpoints
- ✅ Handle authentication errors properly

## 📝 Tasks

### Task 1: Project Setup (2 minutes)

**Run the setup script:**
```bash
# From the aspnet-core-training directory
./setup-exercise.sh module04-exercise01-jwt
cd JwtAuthenticationAPI
```

**Verify setup:**
```bash
../verify-packages.sh
dotnet build
```

**Note**: All required packages are pre-installed with correct versions:
- `Microsoft.AspNetCore.Authentication.JwtBearer`
- `System.IdentityModel.Tokens.Jwt`
- `Microsoft.IdentityModel.Tokens`
- JWT configuration is pre-configured in appsettings.json

### Task 2: JWT Service Implementation (15 minutes)

1. **Create Models folder** and add authentication models:

   **Models/AuthModels.cs**:
   ```csharp
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
       public string Password { get; set; } = string.Empty; // In real app, this would be hashed
       public string Email { get; set; } = string.Empty;
       public List<string> Roles { get; set; } = new();
       public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
   }

   public class RegisterRequest
   {
       [Required(ErrorMessage = "Username is required")]
       [StringLength(50, MinimumLength = 3, ErrorMessage = "Username must be between 3 and 50 characters")]
       public string Username { get; set; } = string.Empty;

       [Required(ErrorMessage = "Email is required")]
       [EmailAddress(ErrorMessage = "Invalid email format")]
       public string Email { get; set; } = string.Empty;

       [Required(ErrorMessage = "Password is required")]
       [StringLength(100, MinimumLength = 6, ErrorMessage = "Password must be at least 6 characters")]
       public string Password { get; set; } = string.Empty;

       [Required(ErrorMessage = "Password confirmation is required")]
       [Compare("Password", ErrorMessage = "Password and confirmation password do not match")]
       public string ConfirmPassword { get; set; } = string.Empty;
   }

   public class ApiResponse<T>
   {
       public bool Success { get; set; }
       public string Message { get; set; } = string.Empty;
       public T? Data { get; set; }
       public List<string> Errors { get; set; } = new();
   }
   ```

2. **Create Services folder** and implement JWT token service:

   **Services/JwtTokenService.cs**:
   ```csharp
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
   ```

### Task 3: Authentication Configuration (10 minutes)

1. **Configure JWT in Program.cs**:

   **Program.cs**:
   ```csharp
   using Microsoft.AspNetCore.Authentication.JwtBearer;
   using Microsoft.IdentityModel.Tokens;
   using System.Text;
   using JwtAuthenticationAPI.Services;

   var builder = WebApplication.CreateBuilder(args);

   // Add services to the container
   builder.Services.AddControllers();
   builder.Services.AddEndpointsApiExplorer();
   builder.Services.AddSwaggerGen();

   // Register JWT Token Service
   builder.Services.AddScoped<IJwtTokenService, JwtTokenService>();

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
   ```

### Task 4: User Service Implementation (8 minutes)

1. **Add User Service for authentication**:

   **Services/UserService.cs**:
   ```csharp
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

               var user = _users.FirstOrDefault(x => x.Id == id);

               return user;
           }
           catch (Exception ex)
           {
               _logger.LogError(ex, "Error retrieving user by ID: {UserId}", id);
               return null;
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
   ```

2. **Register UserService in Program.cs** (add this line after the JWT service registration):
   ```csharp
   // Register services
   builder.Services.AddScoped<IJwtTokenService, JwtTokenService>();
   builder.Services.AddScoped<IUserService, UserService>();
   ```

### Task 5: Controller Implementation (7 minutes)

1. **Create AuthController** with authentication endpoints:

   **Controllers/AuthController.cs**:
   ```csharp
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
   ```

## 🧪 Testing Checklist

### Authentication Tests:
- [ ] **Valid Login**: Test with correct credentials
- [ ] **Invalid Login**: Test with wrong credentials
- [ ] **Missing Credentials**: Test with empty request
- [ ] **Token Format**: Verify JWT token structure

### Authorization Tests:
- [ ] **Protected Endpoint Without Token**: Should return 401
- [ ] **Protected Endpoint With Valid Token**: Should return 200
- [ ] **Protected Endpoint With Expired Token**: Should return 401
- [ ] **Protected Endpoint With Invalid Token**: Should return 401

## 📊 Sample Test Data

### Valid Users:
```json
{
  "username": "admin",
  "password": "admin123"
}
```

```json
{
  "username": "user",
  "password": "user123"
}
```

## 🔧 Postman Test Collection

### 1. Login Request
```
POST {{baseUrl}}/api/auth/login
Content-Type: application/json

{
  "username": "admin",
  "password": "admin123"
}
```

### 2. Protected Endpoint
```
GET {{baseUrl}}/api/auth/protected
Authorization: Bearer {{token}}
```

## ❓ Verification Questions

After completing the exercise, answer these questions:

1. **What are the three parts of a JWT token?**
2. **Why is the signing key important in JWT?**
3. **What happens if you don't include the Authorization middleware?**
4. **How would you extend the token expiration time?**
5. **What's the difference between authentication and authorization?**

## 💡 Challenge Tasks (Bonus)

If you finish early, try these additional challenges:

### Challenge 1: User Registration
- Add a registration endpoint
- Implement proper password hashing
- Validate user input

### Challenge 2: Role-Based Authorization
- Add roles to your user model
- Implement role-based access control
- Create admin-only endpoints

### Challenge 3: Token Refresh
- Implement token refresh mechanism
- Handle token expiration gracefully
- Add refresh token storage

## 🆘 Troubleshooting Guide

### Common Issues:

**Token Not Working:**
- Check if authentication middleware is added
- Verify token is properly formatted in Authorization header
- Ensure JWT configuration matches between generation and validation

**401 Unauthorized:**
- Verify [Authorize] attribute is applied
- Check if token is expired
- Ensure proper Bearer format: `Bearer {your-token}`

**Configuration Errors:**
- Verify JWT key is long enough (minimum 256 bits)
- Check issuer and audience settings
- Ensure middleware order is correct

## ✅ Completion Criteria

You have successfully completed this exercise when:
- ✅ Login endpoint returns valid JWT tokens
- ✅ Protected endpoints require authentication
- ✅ Invalid credentials are properly rejected
- ✅ Token validation works correctly
- ✅ All Postman tests pass

## 📚 Additional Resources

- [JWT.io Token Debugger](https://jwt.io/)
- [ASP.NET Core JWT Documentation](https://docs.microsoft.com/en-us/aspnet/core/security/authentication/jwt-authn)
- [JWT Best Practices](https://tools.ietf.org/html/rfc8725)

---

## 🌐 **Testing Your Implementation with the Demo Page**

After completing the exercise, you can test your JWT authentication system using the built-in demo page:

1. **Start your application:**
   ```bash
   dotnet run
   ```

2. **Open the demo page:**
   Navigate to `http://localhost:5000` (or your configured port)

3. **Test the features:**
   - Use the interactive login form with test users
   - Copy JWT tokens for API testing
   - Test protected endpoints directly from the page
   - Explore all authentication and authorization features

4. **Available test users:**
   - `admin/admin123` - Full access (Admin, User roles)
   - `user/user123` - Basic user access

The demo page provides a comprehensive interface to test all the JWT authentication features you've implemented!

---

**Remember**: Always use strong, unique signing keys in production and never expose them in your code or version control!