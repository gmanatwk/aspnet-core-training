# Docker Best Practices for ASP.NET Core

## 🚀 Overview
This guide covers essential Docker best practices specifically for ASP.NET Core applications, focusing on security, performance, and maintainability.

## 📦 Image Optimization

### Use Multi-Stage Builds
Always use multi-stage builds to minimize final image size:

```dockerfile
# Build stage
FROM mcr.microsoft.com/dotnet/sdk:8.0-alpine AS build
WORKDIR /src
COPY ["MyApp.csproj", "."]
RUN dotnet restore
COPY . .
RUN dotnet publish -c Release -o /app/publish

# Runtime stage
FROM mcr.microsoft.com/dotnet/aspnet:8.0-alpine AS runtime
WORKDIR /app
COPY --from=build /app/publish .
ENTRYPOINT ["dotnet", "MyApp.dll"]
```

### Choose the Right Base Image
- **Alpine**: Smallest size (~45MB), good for production
- **Debian**: Larger but more compatible (~200MB)
- **Ubuntu**: Most compatible but largest (~250MB)

```dockerfile
# Recommended for production
FROM mcr.microsoft.com/dotnet/aspnet:8.0-alpine

# For compatibility issues
FROM mcr.microsoft.com/dotnet/aspnet:8.0
```

### Optimize Layer Caching
Copy dependency files first to leverage Docker layer caching:

```dockerfile
# Good - leverages caching
COPY ["MyApp.csproj", "."]
RUN dotnet restore
COPY . .

# Bad - invalidates cache on any file change
COPY . .
RUN dotnet restore
```

## 🔒 Security Best Practices

### Run as Non-Root User
```dockerfile
# Create and use non-root user
RUN addgroup -g 1000 appgroup && \
    adduser -u 1000 -G appgroup -s /bin/sh -D appuser
USER appuser
```

### Use Specific Image Tags
```dockerfile
# Good - specific version
FROM mcr.microsoft.com/dotnet/aspnet:8.0.1-alpine

# Bad - can change unexpectedly
FROM mcr.microsoft.com/dotnet/aspnet:latest
```

### Scan for Vulnerabilities
```bash
# Use Trivy for security scanning
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
    aquasec/trivy image myapp:latest
```

### Minimize Attack Surface
```dockerfile
# Remove unnecessary packages
RUN apk del .build-deps

# Use specific package versions
RUN apk add --no-cache curl=7.88.1-r1
```

## ⚡ Performance Optimization

### Use .dockerignore
Create comprehensive .dockerignore:

```
# Build artifacts
**/bin
**/obj
**/.vs
**/.vscode

# Source control
**/.git
**/.gitignore

# Documentation
**/README.md
**/LICENSE

# Local environment
**/.env
**/docker-compose*
**/Dockerfile*

# Node modules (if any)
**/node_modules
```

### Optimize .NET Runtime
```dockerfile
# Set runtime configuration
ENV DOTNET_RUNNING_IN_CONTAINER=true
ENV DOTNET_USE_POLLING_FILE_WATCHER=true
ENV ASPNETCORE_URLS=http://+:8080

# Optimize garbage collection
ENV DOTNET_gcServer=1
ENV DOTNET_GCRetainVM=1
```

### Use ReadyToRun Images
For faster startup times:

```dockerfile
# Use ReadyToRun images for better performance
FROM mcr.microsoft.com/dotnet/aspnet:8.0-alpine

# Or publish with ReadyToRun
RUN dotnet publish -c Release -o /app/publish \
    --runtime linux-musl-x64 \
    --self-contained false \
    -p:PublishReadyToRun=true
```

## 🏥 Health Checks

### Implement Container Health Checks
```dockerfile
# Add health check to Dockerfile
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl --fail http://localhost:8080/health || exit 1
```

### Application Health Checks
```csharp
// In Program.cs
builder.Services.AddHealthChecks()
    .AddCheck("self", () => HealthCheckResult.Healthy())
    .AddCheck("database", () => CheckDatabaseConnection())
    .AddCheck("external-service", () => CheckExternalService());

app.MapHealthChecks("/health");
app.MapHealthChecks("/healthz", new HealthCheckOptions
{
    ResponseWriter = UIResponseWriter.WriteHealthCheckUIResponse
});
```

## 🔧 Configuration Management

### Environment Variables
```dockerfile
# Set default environment variables
ENV ASPNETCORE_ENVIRONMENT=Production
ENV ASPNETCORE_URLS=http://+:8080

# Use ARG for build-time variables
ARG BUILD_VERSION=1.0.0
ENV APP_VERSION=$BUILD_VERSION
```

### Secrets Management
```csharp
// Never put secrets in Dockerfile or environment variables
// Use Azure Key Vault or similar services

// Good - from configuration provider
var connectionString = configuration.GetConnectionString("Database");

// Bad - hardcoded
var connectionString = "Server=prod;Database=mydb;User=admin;Password=secret123;";
```

## 📊 Logging Configuration

### Structured Logging
```csharp
// Configure logging for containers
builder.Logging.ClearProviders();
builder.Logging.AddConsole();
builder.Logging.AddApplicationInsights();

// Use structured logging
builder.Services.Configure<JsonConsoleFormatterOptions>(options =>
{
    options.IncludeScopes = true;
    options.TimestampFormat = "yyyy-MM-dd HH:mm:ss ";
});
```

### Log to Console
```dockerfile
# Ensure logs go to stdout/stderr for container orchestration
ENV DOTNET_CONSOLE_ANSI_COLOR=1
```

## 🐳 Development vs Production Images

### Development Dockerfile
```dockerfile
# Dockerfile.dev
FROM mcr.microsoft.com/dotnet/sdk:8.0
WORKDIR /app
EXPOSE 8080

# Install dev tools
RUN dotnet tool install --global dotnet-ef

COPY ["MyApp.csproj", "."]
RUN dotnet restore

COPY . .
CMD ["dotnet", "watch", "run", "--urls", "http://0.0.0.0:8080"]
```

### Production Dockerfile
```dockerfile
# Dockerfile
FROM mcr.microsoft.com/dotnet/sdk:8.0-alpine AS build
WORKDIR /src

# Restore dependencies
COPY ["MyApp.csproj", "."]
RUN dotnet restore --runtime linux-musl-x64

# Build and publish
COPY . .
RUN dotnet publish -c Release -o /app/publish \
    --runtime linux-musl-x64 \
    --self-contained false \
    --no-restore

# Runtime image
FROM mcr.microsoft.com/dotnet/aspnet:8.0-alpine
WORKDIR /app

# Security: Create non-root user
RUN addgroup -g 1000 appgroup && \
    adduser -u 1000 -G appgroup -s /bin/sh -D appuser
USER appuser

# Copy application
COPY --from=build /app/publish .

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl --fail http://localhost:8080/health || exit 1

ENTRYPOINT ["dotnet", "MyApp.dll"]
```

## 🔄 Build Optimization

### Build Script Example
```bash
#!/bin/bash
# build.sh

set -e

APP_NAME="myapp"
VERSION=${1:-latest}
REGISTRY=${REGISTRY:-myregistry.azurecr.io}

echo "Building $APP_NAME:$VERSION"

# Build with BuildKit for better performance
DOCKER_BUILDKIT=1 docker build \
    --tag $APP_NAME:$VERSION \
    --tag $APP_NAME:latest \
    --target runtime \
    --build-arg BUILD_VERSION=$VERSION \
    --platform linux/amd64 \
    .

# Tag for registry
docker tag $APP_NAME:$VERSION $REGISTRY/$APP_NAME:$VERSION
docker tag $APP_NAME:latest $REGISTRY/$APP_NAME:latest

echo "Build completed successfully"
```

### Multi-Platform Builds
```bash
# Build for multiple architectures
docker buildx build \
    --platform linux/amd64,linux/arm64 \
    --tag myapp:latest \
    --push \
    .
```

## 🧪 Testing Containers

### Container Tests
```csharp
// Integration test with TestContainers
[Test]
public async Task TestContainerApp()
{
    var container = new ContainerBuilder()
        .WithImage("myapp:latest")
        .WithPortBinding(8080, true)
        .WithWaitStrategy(Wait.ForUnixContainer()
            .UntilHttpRequestIsSucceeded(r => r.ForPort(8080).ForPath("/health")))
        .Build();

    await container.StartAsync();
    
    var httpClient = new HttpClient();
    var response = await httpClient.GetAsync($"http://localhost:{container.GetMappedPublicPort(8080)}/api/values");
    
    Assert.That(response.IsSuccessStatusCode, Is.True);
    
    await container.StopAsync();
}
```

## 📚 Useful Commands

### Development Commands
```bash
# Build development image
docker build -f Dockerfile.dev -t myapp:dev .

# Run with volume mounting for development
docker run -p 8080:8080 -v $(pwd):/app myapp:dev

# Debug container
docker exec -it container_name /bin/sh

# View container logs
docker logs -f container_name
```

### Production Commands
```bash
# Build production image
docker build -t myapp:prod .

# Run production container
docker run -d -p 8080:8080 --name myapp-prod myapp:prod

# Check container health
docker inspect --format='{{.State.Health.Status}}' myapp-prod

# Monitor resource usage
docker stats myapp-prod
```

### Cleanup Commands
```bash
# Remove unused images
docker image prune

# Remove unused containers
docker container prune

# Remove everything unused
docker system prune -a
```

## ⚠️ Common Pitfalls

### 1. Large Image Sizes
- Use Alpine base images
- Multi-stage builds
- Remove unnecessary files

### 2. Security Issues
- Run as non-root user
- Use specific image tags
- Regular security scanning

### 3. Poor Performance
- Optimize layer caching
- Use .dockerignore
- Proper resource limits

### 4. Configuration Problems
- Environment-specific configuration
- Proper secret management
- Health check implementation

## 🎯 Checklist for Production

- [ ] Multi-stage build implemented
- [ ] Alpine or minimal base image used
- [ ] Non-root user configured
- [ ] Health checks implemented
- [ ] Security scanning integrated
- [ ] .dockerignore file created
- [ ] Environment variables properly configured
- [ ] Logging configured for containers
- [ ] Resource limits defined
- [ ] Documentation updated

## 📖 Additional Resources

- [.NET Docker Best Practices](https://github.com/dotnet/dotnet-docker/blob/main/documentation/best-practices.md)
- [Docker Security Best Practices](https://docs.docker.com/develop/security-best-practices/)
- [Container Image Security](https://kubernetes.io/docs/concepts/security/pod-security-standards/)
- [ASP.NET Core Docker Documentation](https://docs.microsoft.com/en-us/aspnet/core/host-and-deploy/docker/)
