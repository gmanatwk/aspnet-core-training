# Docker Setup Summary for ASP.NET Core Training Modules

This document summarizes the Docker configurations available across key training modules, making it easy for students to run examples regardless of their operating system.

## 🐳 Modules with Docker Support

### ✅ Module 02 - ASP.NET Core with React
**Status**: Already has comprehensive Docker setup  
**Location**: `Module02-ASP.NET-Core-with-React/SourceCode/ReactTodoApp`  
**Port**: 8000 (prod), 5001 (dev), 3000 (React dev)  
**Features**:
- Multiple deployment profiles (production, development, API-only)
- Hot reload for both .NET and React
- Integrated Todo application example

**Quick Start**:
```bash
cd Module02-ASP.NET-Core-with-React/SourceCode/ReactTodoApp
docker-compose --profile development up
```

### ✅ Module 03 - Working with Web APIs
**Status**: Docker setup with fixes applied  
**Location**: `Module03-Working-with-Web-APIs/SourceCode`  
**Port**: 5001 (API), 3000 (React frontend), 1433 (SQL Server)  
**Features**:
- Full stack setup with React frontend
- SQL Server database with automatic seeding
- API documentation with Swagger

**Quick Start**:
```bash
cd Module03-Working-with-Web-APIs/SourceCode
docker-compose up
```

### ✅ Module 04 - Authentication and Authorization
**Status**: New Docker setup created  
**Location**: `Module04-Authentication-and-Authorization/SourceCode`  
**Port**: 5002  
**Features**:
- JWT authentication implementation
- No database required (in-memory users)
- Role-based and policy-based authorization examples
- Swagger UI with JWT support

**Quick Start**:
```bash
cd Module04-Authentication-and-Authorization/SourceCode
docker-compose up
```

### ✅ Module 05 - Entity Framework Core
**Status**: New Docker setup created  
**Location**: `Module05-Entity-Framework-Core/SourceCode`  
**Port**: 5003 (API), 1434 (SQL Server)  
**Features**:
- SQL Server with persistent volumes
- Multiple DbContext examples
- Repository and Unit of Work patterns
- EF Core migrations support

**Quick Start**:
```bash
cd Module05-Entity-Framework-Core/SourceCode
docker-compose up -d
./docker-init.sh  # Run migrations
```

## 🚀 General Docker Commands

### Start Services
```bash
docker-compose up        # Run with logs
docker-compose up -d     # Run in background
```

### Stop Services
```bash
docker-compose down      # Stop and remove containers
docker-compose down -v   # Also remove volumes (data)
```

### View Logs
```bash
docker-compose logs -f [service-name]
```

### Rebuild After Changes
```bash
docker-compose build
docker-compose up --build
```

## 📋 Port Allocation Summary

To avoid conflicts when running multiple modules:

| Module | Service | Port |
|--------|---------|------|
| Module 02 | React Todo App | 8000/5001/3000 |
| Module 03 | RestfulAPI | 5001 |
| Module 03 | React Frontend | 3000 |
| Module 03 | SQL Server | 1433 |
| Module 04 | JWT Auth API | 5002 |
| Module 05 | EF Core API | 5003 |
| Module 05 | SQL Server | 1434 |

## 🎯 Benefits for Students

1. **Cross-Platform**: Works identically on Windows, macOS, and Linux
2. **No Local Setup**: No need to install .NET SDK, Node.js, or SQL Server
3. **Consistent Environment**: Everyone has the same versions and configurations
4. **Easy Cleanup**: Simple to remove everything after training
5. **Real-World Practice**: Learn containerization alongside ASP.NET Core

## 🔧 Prerequisites

Students only need:
- Docker Desktop installed
- A code editor (VS Code recommended)
- A web browser
- Basic command line knowledge

## 📚 Additional Modules

The following modules might benefit from Docker but are simpler setups:

- **Module 01**: Basic introduction (minimal setup needed)
- **Module 06**: Debugging (requires local debugging tools)
- **Module 07**: Testing (can use Docker for test databases)
- **Module 08**: Performance (benefits from controlled environment)
- **Module 09**: Azure Container Apps (already container-focused)
- **Module 10-13**: Various topics (can add Docker as needed)

## 🏁 Getting Started

1. Install Docker Desktop from https://www.docker.com/products/docker-desktop
2. Clone the training repository
3. Navigate to any module with Docker support
4. Run `docker-compose up`
5. Follow the module-specific README for endpoints and features

## ⚠️ Important Notes

- **First Run**: Initial Docker image downloads may take several minutes
- **Disk Space**: Ensure at least 10GB free space for Docker images
- **Memory**: Allocate at least 4GB RAM to Docker Desktop
- **Cleanup**: Run `docker system prune -a` periodically to free space

---

This standardized Docker approach ensures all students have a consistent, reliable development environment regardless of their operating system or local setup.