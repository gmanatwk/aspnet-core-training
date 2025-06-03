# Exercise 1: Basic Containerization

## 🎯 Objective
Learn to containerize an ASP.NET Core application and run it locally using Docker. This exercise covers Docker fundamentals, Dockerfile creation, and container optimization techniques.

## ⏱️ Estimated Time: 30 minutes

## 📋 Prerequisites
- Docker Desktop installed and running
- .NET 8 SDK installed
- Visual Studio Code with Docker extension

## 🎓 Learning Goals
- Create an optimized Dockerfile for ASP.NET Core
- Understand multi-stage Docker builds
- Implement container health checks
- Optimize container image size
- Test containerized applications locally

---

## 📚 Background Information

### Docker Fundamentals for .NET Developers
Docker containers package applications with their dependencies, ensuring consistent behavior across environments. For .NET applications, this means:

- **Isolation**: Applications run in isolated environments
- **Portability**: Containers run consistently across different machines
- **Scalability**: Easy to scale horizontally
- **Efficiency**: Lightweight compared to virtual machines

### Multi-Stage Build Benefits
- **Smaller Images**: Runtime images don't include SDK tools
- **Security**: Reduced attack surface
- **Performance**: Faster deployment and startup times
- **Build Caching**: Improved build performance

---

## 🛠️ Setup Instructions

### Step 1: Prepare the Application
We'll start with a simple ASP.NET Core Web API that you'll containerize.

1. **Create a new ASP.NET Core Web API**:
```bash
mkdir ContainerDemo
cd ContainerDemo
dotnet new webapi -n ProductApi
cd ProductApi
```

2. **Add required packages** (if not already present):
```bash
dotnet add package Microsoft.AspNetCore.HealthChecks
```

3. **Update Program.cs** to include health checks:
```csharp
var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Add health checks
builder.Services.AddHealthChecks();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

// Add health check endpoint
app.MapHealthChecks("/healthz");

app.UseHttpsRedirection();
app.UseAuthorization();
app.MapControllers();

app.Run();
```

---

## 📝 Tasks

### Task 1: Create a Basic Dockerfile (10 minutes)

Create a `Dockerfile` in the root of your ProductApi project:

```dockerfile
# This is a basic Dockerfile - we'll optimize it in the next tasks
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 8080

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY ["ProductApi.csproj", "."]
RUN dotnet restore "./ProductApi.csproj"
COPY . .
WORKDIR "/src/."
RUN dotnet build "ProductApi.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "ProductApi.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "ProductApi.dll"]
```

**Questions to Consider:**
- Why do we use multiple FROM statements?
- What's the purpose of each stage?
- Why do we copy the .csproj file first?

### Task 2: Build and Test Your Container (5 minutes)

1. **Build the Docker image**:
```bash
docker build -t productapi:v1 .
```

2. **Run the container**:
```bash
docker run -d -p 8080:8080 --name productapi-container productapi:v1
```

3. **Test the application**:
```bash
# Test the API
curl http://localhost:8080/WeatherForecast

# Test health check
curl http://localhost:8080/healthz
```

4. **View container logs**:
```bash
docker logs productapi-container
```

5. **Stop and remove the container**:
```bash
docker stop productapi-container
docker rm productapi-container
```

### Task 3: Optimize the Dockerfile (10 minutes)

Create an optimized version of your Dockerfile:

```dockerfile
# Optimized Dockerfile
FROM mcr.microsoft.com/dotnet/aspnet:8.0-alpine AS base
WORKDIR /app
EXPOSE 8080

# Create a non-root user for security
RUN addgroup -g 1000 appgroup && adduser -u 1000 -G appgroup -s /bin/sh -D appuser
USER appuser

FROM mcr.microsoft.com/dotnet/sdk:8.0-alpine AS build
WORKDIR /src

# Copy project file and restore dependencies (better layer caching)
COPY ["ProductApi.csproj", "."]
RUN dotnet restore "./ProductApi.csproj" --runtime linux-musl-x64

# Copy source code
COPY . .

# Build the application
RUN dotnet build "ProductApi.csproj" -c Release -o /app/build --runtime linux-musl-x64 --no-restore

FROM build AS publish
RUN dotnet publish "ProductApi.csproj" -c Release -o /app/publish \
    --runtime linux-musl-x64 \
    --self-contained false \
    --no-restore

FROM base AS final
WORKDIR /app

# Copy the published application
COPY --from=publish /app/publish .

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl --fail http://localhost:8080/healthz || exit 1

ENTRYPOINT ["dotnet", "ProductApi.dll"]
```

**Optimizations Explained:**
- **Alpine images**: Smaller base images (~5MB vs ~200MB)
- **Layer caching**: Copy .csproj first for better Docker layer caching
- **Security**: Run as non-root user
- **Health checks**: Built-in container health monitoring
- **Runtime optimization**: Target specific runtime

### Task 4: Add .dockerignore File (2 minutes)

Create a `.dockerignore` file to exclude unnecessary files:

```
# .dockerignore
**/.classpath
**/.dockerignore
**/.env
**/.git
**/.gitignore
**/.project
**/.settings
**/.toolstarget
**/.vs
**/.vscode
**/*.*proj.user
**/*.dbmdl
**/*.jfm
**/azds.yaml
**/bin
**/charts
**/docker-compose*
**/Dockerfile*
**/node_modules
**/npm-debug.log
**/obj
**/secrets.dev.yaml
**/values.dev.yaml
LICENSE
README.md
```

### Task 5: Build and Compare Images (3 minutes)

1. **Build the optimized image**:
```bash
docker build -t productapi:v2-optimized .
```

2. **Compare image sizes**:
```bash
docker images | grep productapi
```

3. **Run the optimized container**:
```bash
docker run -d -p 8080:8080 --name productapi-optimized productapi:v2-optimized
```

4. **Test health check**:
```bash
# Check container health
docker inspect --format='{{.State.Health.Status}}' productapi-optimized

# Wait a moment for health check to run, then check again
sleep 35
docker inspect --format='{{.State.Health.Status}}' productapi-optimized
```

---

## ✅ Verification Checklist

Mark each item as complete:

- [ ] Created a multi-stage Dockerfile
- [ ] Successfully built a Docker image
- [ ] Ran the containerized application locally
- [ ] Accessed the API endpoints (WeatherForecast and /healthz)
- [ ] Created an optimized Dockerfile with Alpine images
- [ ] Implemented health checks in the container
- [ ] Added .dockerignore file to exclude unnecessary files
- [ ] Compared image sizes between basic and optimized versions
- [ ] Verified health check functionality

---

## 🎯 Expected Outcomes

After completing this exercise, you should have:

1. **Working Container**: A containerized ASP.NET Core application running locally
2. **Optimized Image**: Reduced image size by 60-80% using Alpine base images
3. **Health Monitoring**: Container with built-in health checks
4. **Security**: Application running as non-root user
5. **Performance**: Optimized Docker layers for better build caching

### Image Size Comparison
- **Basic image**: ~210MB
- **Optimized image**: ~45MB
- **Size reduction**: ~78%

---

## 🔍 Troubleshooting Guide

### Common Issues and Solutions

**1. Port Already in Use**
```bash
# Error: Port 8080 is already in use
# Solution: Use a different port or stop existing containers
docker ps
docker stop <container-name>
```

**2. Health Check Failing**
```bash
# Check health status
docker inspect --format='{{.State.Health}}' <container-name>

# View health check logs
docker logs <container-name>
```

**3. Application Not Accessible**
```bash
# Verify port mapping
docker port <container-name>

# Check if container is running
docker ps
```

**4. Build Errors**
```bash
# Clear Docker cache if needed
docker builder prune

# Rebuild without cache
docker build --no-cache -t productapi:v1 .
```

---

## 🏆 Bonus Challenges

If you complete the main tasks early, try these additional challenges:

### Challenge 1: Environment Variables
Modify your application to use environment variables for configuration:

```csharp
// In Program.cs
var message = Environment.GetEnvironmentVariable("WELCOME_MESSAGE") ?? "Hello from Container!";

app.MapGet("/info", () => new { Message = message, Environment = app.Environment.EnvironmentName });
```

Run with custom environment variables:
```bash
docker run -d -p 8080:8080 -e WELCOME_MESSAGE="Hello from Docker!" --name productapi-env productapi:v2-optimized
```

### Challenge 2: Multi-Architecture Build
Build your image for multiple architectures:

```bash
# Create and use a new builder
docker buildx create --use --name multiarch-builder

# Build for multiple platforms
docker buildx build --platform linux/amd64,linux/arm64 -t productapi:multiarch .
```

### Challenge 3: Development Dockerfile
Create a separate Dockerfile for development that includes hot reload:

```dockerfile
# Dockerfile.dev
FROM mcr.microsoft.com/dotnet/sdk:8.0
WORKDIR /app
EXPOSE 8080

COPY ["ProductApi.csproj", "."]
RUN dotnet restore

COPY . .

CMD ["dotnet", "watch", "run", "--urls", "http://0.0.0.0:8080"]
```

---

## 📖 Additional Reading

### Docker Best Practices for .NET
- [Official .NET Docker Guidelines](https://github.com/dotnet/dotnet-docker/blob/main/documentation/best-practices.md)
- [Docker Multi-stage Builds](https://docs.docker.com/develop/dev-best-practices/)
- [Security Best Practices](https://docs.docker.com/develop/security-best-practices/)

### Performance Optimization
- [Optimizing .NET Container Images](https://devblogs.microsoft.com/dotnet/optimizing-container-images/)
- [Docker Layer Caching Strategies](https://docs.docker.com/develop/dev-best-practices/#how-to-keep-your-images-small)

---

## 🚀 Next Steps

Once you've completed this exercise:

1. **Review your Dockerfile** - Ensure you understand each instruction
2. **Experiment with configurations** - Try different base images and settings
3. **Document your learnings** - Note the optimization techniques that worked best
4. **Prepare for Exercise 2** - We'll deploy this container to Azure Container Apps

**Key takeaways to remember**:
- Multi-stage builds significantly reduce image size
- Alpine images provide better security and performance
- Health checks are essential for production deployments
- Layer optimization improves build performance
- Security best practices include running as non-root

---

**🎉 Congratulations!** You've successfully containerized your first ASP.NET Core application and learned optimization techniques that will serve you well in production deployments.
