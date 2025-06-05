# Multi-stage build for ASP.NET Core API
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

# Create non-root user for security
RUN addgroup --system --gid 1000 appgroup \
    && adduser --system --uid 1000 --ingroup appgroup --shell /bin/false appuser

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copy project file and restore dependencies
COPY ["RestfulAPI.csproj", "."]
RUN dotnet restore "./RestfulAPI.csproj"

# Copy source code
COPY . .
RUN dotnet build "RestfulAPI.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "RestfulAPI.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app

# Install curl for health checks
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

# Switch to non-root user
USER appuser

# Copy published files
COPY --from=publish --chown=appuser:appgroup /app/publish .

ENTRYPOINT ["dotnet", "RestfulAPI.dll"]