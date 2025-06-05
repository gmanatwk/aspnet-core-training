# Module 04 - JWT Authentication Fixes

## Issues Fixed

### 1. HTTPS Redirection Error
- **Problem**: Application was trying to use HTTPS redirection without proper configuration
- **Solution**: Only use HTTPS redirection in Development environment

### 2. 404 Error on Root URL  
- **Problem**: No default page when accessing http://localhost:5000/
- **Solution**: Added simple JSON endpoint at root that returns API information

### 3. Missing Launch Settings
- **Problem**: No Properties/launchSettings.json file
- **Solution**: Created launchSettings.json with proper development URLs

### 4. Missing wwwroot Directory
- **Problem**: ASP.NET Core expects wwwroot folder to exist even if empty
- **Solution**: Created empty wwwroot folder with .gitkeep file

## Files Changed

1. **Program.cs**
   - Added static files middleware
   - Conditional HTTPS redirection
   - Added root endpoint redirect
   - Enabled Swagger in all environments

2. **Properties/launchSettings.json** (new file)
   - Configured development URLs
   - Set environment to Development
   - Launch browser to Swagger

3. **wwwroot/index.html** (new file)
   - Welcome page with API documentation
   - Test credentials displayed
   - cURL examples
   - Links to Swagger

## How to Run

```bash
# Development mode (with proper URLs)
dotnet run

# Or specify URLs manually
dotnet run --urls="http://localhost:5219"
```

## Available Endpoints

- **GET /** - Welcome page with documentation
- **GET /swagger** - Swagger UI
- **POST /api/auth/login** - Login endpoint
- **POST /api/auth/register** - Registration endpoint
- **GET /api/users/profile** - Get user profile (requires auth)
- **GET /api/users** - Get all users (requires Admin role)

## Test Credentials

- **Admin**: username: `admin`, password: `admin123`
- **User**: username: `user`, password: `user123`

## Testing

```bash
# Login
curl -X POST http://localhost:5219/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin123"}'

# Use token from response
curl -X GET http://localhost:5219/api/users/profile \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```