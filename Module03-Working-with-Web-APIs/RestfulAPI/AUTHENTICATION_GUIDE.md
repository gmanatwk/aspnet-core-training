# Adding Authentication to Your API

## Update Program.cs
Add these lines after existing service configuration:

```csharp
// Add JWT Service
builder.Services.AddScoped<JwtService>();

// Add Authentication
builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            ValidIssuer = builder.Configuration["Jwt:Issuer"],
            ValidAudience = builder.Configuration["Jwt:Audience"],
            IssuerSigningKey = new SymmetricSecurityKey(
                Encoding.UTF8.GetBytes(builder.Configuration["Jwt:Key"]))
        };
    });

// In the pipeline, add BEFORE app.UseAuthorization():
app.UseAuthentication();
```

## Update appsettings.json
Add JWT configuration:

```json
{
  "Jwt": {
    "Key": "ThisIsMySecretKeyForJwtAuthentication",
    "Issuer": "YourAppName",
    "Audience": "YourAppUsers",
    "ExpiryMinutes": 60
  }
}
```

## Update ProductsController
Add authentication to protect certain endpoints:

```csharp
using Microsoft.AspNetCore.Authorization;

// Add to the top of your ProductsController class
[ApiController]
[Route("api/[controller]")]
[Produces("application/json")]
public class ProductsController : ControllerBase
{
    // Keep GET endpoints public for browsing:
    [HttpGet]
    [AllowAnonymous]
    public async Task<ActionResult<IEnumerable<ProductDto>>> GetProducts(...)
    {
        // Existing implementation
    }

    // Protect create/update/delete operations:
    [HttpPost]
    [Authorize] // Require authentication for creating products
    public async Task<ActionResult<ProductDto>> CreateProduct(...)
    {
        // Existing implementation
    }

    [HttpPut("{id:int}")]
    [Authorize(Roles = "Admin")] // Only admins can update
    public async Task<IActionResult> UpdateProduct(...)
    {
        // Existing implementation
    }

    [HttpDelete("{id:int}")]
    [Authorize(Roles = "Admin")] // Only admins can delete
    public async Task<IActionResult> DeleteProduct(...)
    {
        // Existing implementation
    }
}
```

## Testing Authentication:
1. Call POST /api/auth/login with username and password
2. Copy the token from the response
3. In Swagger, click "Authorize" button
4. Enter: Bearer YOUR_TOKEN_HERE
5. Now you can access protected endpoints!
