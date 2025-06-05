# Docker Integration Guide for Module 03

This guide explains how to use Docker to run the RestfulAPI backend and React TypeScript frontend together for development and training purposes.

## Overview

The Module 03 source code includes:
- **RestfulAPI**: ASP.NET Core Web API backend
- **ReactFrontend**: React TypeScript SPA frontend
- **SQL Server**: Database for the API
- **Docker Compose**: Orchestration for all services

## Architecture

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│  React Frontend │────▶│   RestfulAPI    │────▶│   SQL Server    │
│   (Port 3000)   │     │   (Port 5001)   │     │   (Port 1433)   │
└─────────────────┘     └─────────────────┘     └─────────────────┘
        Vite Dev            ASP.NET Core           MSSQL Express
```

## Quick Start

### Prerequisites
- Docker Desktop installed and running
- No other services running on ports 3000, 5001, or 1433

### Start All Services

```bash
cd Module03-Working-with-Web-APIs/SourceCode

# Start all containers
docker-compose up --build

# Or run in background
docker-compose up -d --build
```

### Access the Applications

- **React Frontend**: http://localhost:3000
- **API Documentation**: http://localhost:5001/swagger
- **API Endpoints**: http://localhost:5001/api/*
- **Health Check**: http://localhost:5001/health

### Stop All Services

```bash
# Stop containers
docker-compose down

# Stop and remove volumes (database data)
docker-compose down -v
```

## Service Details

### RestfulAPI (Backend)
- **Port**: 5001 (mapped to container port 80)
- **Features**:
  - Hot reload enabled with `dotnet watch`
  - Development environment configuration
  - EF Core with SQL Server
  - Swagger UI for API documentation

### React Frontend
- **Port**: 3000
- **Features**:
  - Vite dev server with hot module replacement
  - TypeScript support
  - React Query for data fetching
  - Proxy configuration for API calls

### SQL Server Database (Optional)
- **Port**: 1433
- **Credentials**: 
  - Username: `sa`
  - Password: `YourStrong@Passw0rd123`
- **Database**: `RestfulAPIDb` (created automatically)
- **Note**: If SQL Server fails to start (common on Apple Silicon Macs), the API automatically uses an in-memory database instead

## Development Workflow

### Making Backend Changes
1. Edit files in `RestfulAPI/` directory
2. Changes auto-reload thanks to `dotnet watch`
3. Check logs: `docker-compose logs -f restfulapi`

### Making Frontend Changes
1. Edit files in `ReactFrontend/` directory
2. Vite hot-reloads changes instantly
3. Check logs: `docker-compose logs -f react-frontend`

### Database Access
```bash
# Connect to SQL Server from host
sqlcmd -S localhost,1433 -U sa -P Training123!

# Or use a GUI tool like Azure Data Studio
# Server: localhost,1433
# Username: sa
# Password: Training123!
```

## Troubleshooting

### Port Already in Use
```bash
# Find process using port
lsof -i :3000  # or :5001, :1433

# Kill the process or change ports in docker-compose.yml
```

### Database Connection Issues
1. Wait for SQL Server to fully start (check health status)
2. Verify connection string in docker-compose.yml
3. Check SQL Server logs: `docker-compose logs db`

### Frontend Can't Connect to API
1. Ensure the API container is running: `docker ps`
2. Check API logs: `docker-compose logs restfulapi`
3. Verify API is healthy: `curl http://localhost:5001/health`

### Container Build Failures
```bash
# Clean rebuild
docker-compose down -v
docker system prune -f
docker-compose up --build
```

## Useful Commands

```bash
# View all running containers
docker ps

# View logs for specific service
docker-compose logs -f [service-name]

# Execute commands in container
docker exec -it restfulapi bash
docker exec -it react-frontend sh

# Rebuild specific service
docker-compose build [service-name]

# Remove all containers and volumes
docker-compose down -v

# Check container health
docker inspect restfulapi | grep -A 10 Health
```

## Common Tasks

### Run EF Core Migrations
```bash
# Connect to the API container
docker exec -it restfulapi bash

# Run migrations
dotnet ef database update

# Or create a new migration
dotnet ef migrations add YourMigrationName
```

### Install New npm Packages
```bash
# Connect to frontend container
docker exec -it react-frontend sh

# Install package
npm install package-name

# Or from host (will sync to container)
cd ReactFrontend
npm install package-name
```

### Reset Everything
```bash
# Stop containers and remove volumes
docker-compose down -v

# Start fresh
docker-compose up --build
```

## Tips for Training

1. **Watch the logs** - Keep a terminal open with `docker-compose logs -f` to see all activity
2. **Use volumes** - Your code changes are automatically synced, no rebuild needed
3. **Database persists** - Data survives container restarts (unless you use `-v` flag)
4. **Network isolation** - Services can only talk to each other through the defined network

## Next Steps

1. Explore the API endpoints using Swagger UI
2. Modify the React components to add new features
3. Add authentication to secure the API
4. Practice debugging containerized applications
5. Learn about Docker networking and volumes

## Additional Resources

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Reference](https://docs.docker.com/compose/)
- [ASP.NET Core Docker Guide](https://docs.microsoft.com/en-us/aspnet/core/host-and-deploy/docker/)
- [Vite Docker Setup](https://vitejs.dev/guide/)