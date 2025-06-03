# Multi-stage build for ASP.NET Core
FROM mcr.microsoft.com/dotnet/aspnet:8.0-alpine AS base
WORKDIR /app
EXPOSE 8080

# Create non-root user for security
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
    CMD curl --fail http://localhost:8080/health || exit 1

ENTRYPOINT ["dotnet", "ProductApi.dll"]
