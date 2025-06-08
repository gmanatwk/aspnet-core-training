# Multi-stage Dockerfile for ASP.NET Core
# Build stage
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copy project file and restore dependencies
COPY ["ContainerAppsDemo.csproj", "./"]
RUN dotnet restore "ContainerAppsDemo.csproj"

# Copy source code and build
COPY . .
RUN dotnet build "ContainerAppsDemo.csproj" -c Release -o /app/build

# Publish stage
FROM build AS publish
RUN dotnet publish "ContainerAppsDemo.csproj" -c Release -o /app/publish /p:UseAppHost=false

# Runtime stage
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app

# Create non-root user for security
RUN groupadd -r appgroup && useradd -r -g appgroup appuser
RUN chown -R appuser:appgroup /app
USER appuser

# Copy published application
COPY --from=publish /app/publish .

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl --fail http://localhost:8080/health || exit 1

# Entry point
ENTRYPOINT ["dotnet", "ContainerAppsDemo.dll"]
