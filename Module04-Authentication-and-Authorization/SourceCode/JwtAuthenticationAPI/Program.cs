using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Authorization;
using Microsoft.IdentityModel.Tokens;
using System.Text;
using JwtAuthenticationAPI.Services;
using JwtAuthenticationAPI.Models;
using JwtAuthenticationAPI.Requirements;
using JwtAuthenticationAPI.Handlers;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new() { Title = "JWT Authentication API", Version = "v1" });
    
    // Add JWT authentication to Swagger
    c.AddSecurityDefinition("Bearer", new Microsoft.OpenApi.Models.OpenApiSecurityScheme
    {
        Description = "JWT Authorization header using the Bearer scheme. Example: \"Authorization: Bearer {token}\"",
        Name = "Authorization",
        In = Microsoft.OpenApi.Models.ParameterLocation.Header,
        Type = Microsoft.OpenApi.Models.SecuritySchemeType.ApiKey,
        Scheme = "Bearer"
    });
    
    c.AddSecurityRequirement(new Microsoft.OpenApi.Models.OpenApiSecurityRequirement()
    {
        {
            new Microsoft.OpenApi.Models.OpenApiSecurityScheme
            {
                Reference = new Microsoft.OpenApi.Models.OpenApiReference
                {
                    Type = Microsoft.OpenApi.Models.ReferenceType.SecurityScheme,
                    Id = "Bearer"
                },
                Scheme = "oauth2",
                Name = "Bearer",
                In = Microsoft.OpenApi.Models.ParameterLocation.Header,
            },
            new List<string>()
        }
    });
});

// Configure JWT Authentication
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
                Encoding.UTF8.GetBytes(builder.Configuration["Jwt:Key"]!))
        };
    });

// Configure Authorization with policies from all exercises
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

// Register services
builder.Services.AddScoped<IJwtTokenService, JwtTokenService>();
builder.Services.AddScoped<IUserService, UserService>();

// Register authorization handlers from Exercise 03
builder.Services.AddScoped<IAuthorizationHandler, MinimumAgeHandler>();
builder.Services.AddScoped<IAuthorizationHandler, DepartmentHandler>();
builder.Services.AddScoped<IAuthorizationHandler, WorkingHoursHandler>();

// Configure CORS
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", builder =>
    {
        builder.AllowAnyOrigin()
               .AllowAnyMethod()
               .AllowAnyHeader();
    });
});

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

// Only use HTTPS redirection in development where we have HTTPS configured
if (app.Environment.IsDevelopment())
{
    app.UseHttpsRedirection();
}

app.UseCors("AllowAll");

// Authentication & Authorization middleware order is important!
app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();

// Add a simple root endpoint that returns API info
app.MapGet("/", () => new 
{
    message = "JWT Authentication & Authorization API - Complete Module 04",
    version = "1.0",
    documentation = "/swagger",
    exercises = new
    {
        exercise01_jwt = new[]
        {
            "POST /api/auth/login - Basic JWT authentication",
            "GET /api/auth/protected - Protected endpoint test"
        },
        exercise02_roles = new[]
        {
            "GET /api/admin/dashboard - Admin only (Role-based)",
            "GET /api/editor/content - Editor or Admin (Policy-based)",
            "GET /api/auth/admin-only - Admin role required",
            "GET /api/auth/user-area - User or Admin policy"
        },
        exercise03_policies = new[]
        {
            "GET /api/policy/adult-content - Age-based policy (18+)",
            "GET /api/policy/it-resources - Department-based policy",
            "GET /api/policy/business-hours - Time-based policy (9-5)",
            "GET /api/policy/senior-it-data - Complex combined policy"
        }
    },
    testUsers = new[]
    {
        "admin/admin123 - Full access + IT dept + age 38",
        "user/user123 - Basic user role",
        "editor/editor123 - Editor role + Content dept",
        "senior_dev/senior123 - Employee + IT dept + age 38",
        "junior_dev/junior123 - Employee + IT dept + age 22"
    }
});

app.Run();