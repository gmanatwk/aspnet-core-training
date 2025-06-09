# Security Demo API

This is the demonstration project for Module 10 - Security Fundamentals.

## Running the Application

The application runs on the following ports:
- HTTP: `http://localhost:5050`
- HTTPS: `https://localhost:5051`

To run the application:
```bash
dotnet run
```

The application will automatically open the Swagger UI at `https://localhost:5051/swagger`.

## Port Configuration

The default ports (5000/5001) were changed to 5050/5051 to avoid conflicts with other common development tools like:
- Control Center on macOS
- Other ASP.NET Core applications
- Docker Desktop

If you need to change the ports, update:
1. `Properties/launchSettings.json` - Application URLs
2. `Program.cs` - HTTPS redirection port
3. `SecurityDemo.http` - Test file base URL

## Testing Security Headers

1. Use the included `SecurityDemo.http` file with the REST Client extension in VS Code
2. Or use curl:
   ```bash
   curl -k https://localhost:5051/api/SecurityTest/headers -I
   ```

## Features Demonstrated

- Security Headers Middleware
- Content Security Policy (CSP)
- HTTPS Enforcement
- XSS Prevention
- Secure Cookie Configuration