# Setup Guide for Windows, Mac, and Linux Users

This guide helps you set up the Module 03 project with consistent dependencies across all platforms.

## Prerequisites

### Required Software
1. **Node.js** (v18 or higher)
   - Download from: https://nodejs.org/
   - Verify: `node --version` and `npm --version`

2. **.NET 8.0 SDK**
   - Download from: https://dotnet.microsoft.com/download/dotnet/8.0
   - Verify: `dotnet --version`

3. **Docker Desktop**
   - Windows/Mac: https://www.docker.com/products/docker-desktop
   - Linux: Follow distribution-specific instructions
   - Verify: `docker --version` and `docker-compose --version`

4. **Git** (for cloning the repository)
   - Download from: https://git-scm.com/
   - Verify: `git --version`

## Initial Setup

### Step 1: Clone or Extract the Project
```bash
# If cloning from a repository
git clone <repository-url>
cd aspnet-core-training/Module03-Working-with-Web-APIs/SourceCode

# If extracted from a zip file
cd path/to/Module03-Working-with-Web-APIs/SourceCode
```

### Step 2: Install Dependencies

#### Option A: Using npm scripts (Recommended)
```bash
# Install root dependencies
npm install

# Install all project dependencies (backend + frontend)
npm run setup
```

#### Option B: Manual Installation
```bash
# Backend dependencies
cd RestfulAPI
dotnet restore
cd ..

# Frontend dependencies
cd ReactFrontend
npm install
cd ..
```

## Running the Application

### Using Docker (Recommended - Consistent across all platforms)

```bash
# Start all services
npm run dev

# Or directly with docker-compose
docker-compose up --build

# Stop all services
npm run stop
# or
docker-compose down
```

### Running Locally (Without Docker)

Open two terminal windows:

**Terminal 1 - Backend:**
```bash
npm run dev:backend
# or
cd RestfulAPI
dotnet run
```

**Terminal 2 - Frontend:**
```bash
npm run dev:frontend
# or
cd ReactFrontend
npm run dev
```

## Accessing the Application

- **React Frontend**: http://localhost:3000
- **API Swagger UI**: http://localhost:5001/swagger
- **API Endpoints**: http://localhost:5001/api/*
- **Database**: localhost:1433 (when using Docker)
  - Username: `sa`
  - Password: `Training123!`

## Platform-Specific Notes

### Windows Users

1. **Terminal Choice**:
   - Use PowerShell (recommended) or Command Prompt
   - Git Bash also works but may have issues with some commands
   - Windows Terminal is excellent if you have it

2. **Path Separators**:
   - The npm scripts handle path differences automatically
   - When typing paths manually, use backslashes: `cd RestfulAPI\bin`

3. **Firewall**:
   - You may get firewall prompts when first running the services
   - Allow access for Docker Desktop and dotnet.exe

4. **Docker Desktop**:
   - Ensure Docker Desktop is running before using Docker commands
   - May need to enable virtualization in BIOS if Docker won't start

### Mac Users

1. **Docker Desktop**:
   - Must be running before using Docker commands
   - Check the whale icon in the menu bar

2. **Port Conflicts**:
   - If ports are in use: `lsof -i :3000` to find the process
   - Kill with: `kill -9 <PID>`

### Linux Users

1. **Docker Permissions**:
   - Add your user to the docker group: `sudo usermod -aG docker $USER`
   - Log out and back in for changes to take effect

2. **Node.js Installation**:
   - Consider using nvm for Node.js version management
   - Or use NodeSource repositories for latest versions

## Dependency Versions

### Backend (.NET)
Defined in `RestfulAPI/RestfulAPI.csproj`:
- Target Framework: .NET 8.0
- Major packages:
  - Microsoft.AspNetCore.Authentication.JwtBearer
  - Microsoft.EntityFrameworkCore.InMemory
  - Swashbuckle.AspNetCore

### Frontend (React)
Defined in `ReactFrontend/package.json`:
- React: 18.x
- TypeScript: 5.x
- Vite: 5.x
- Major packages:
  - axios
  - @tanstack/react-query

## Troubleshooting

### "Command not found" errors
- Ensure Node.js and .NET SDK are in your PATH
- Restart your terminal after installation
- On Windows, restart your computer if needed

### Port already in use
```bash
# Windows
netstat -ano | findstr :3000
taskkill /PID <process-id> /F

# Mac/Linux
lsof -i :3000
kill -9 <process-id>
```

### Docker issues
```bash
# Clean restart
docker-compose down -v
docker system prune -f
docker-compose up --build
```

### npm install fails
```bash
# Clear npm cache
npm cache clean --force

# Delete node_modules and reinstall
rm -rf node_modules package-lock.json
npm install
```

## Creating a New Project from Scratch

If you want to create a similar project structure:

### 1. Create Backend
```bash
# Create API project
dotnet new webapi -n RestfulAPI --framework net8.0
cd RestfulAPI

# Add required packages
dotnet add package Microsoft.AspNetCore.Authentication.JwtBearer
dotnet add package Microsoft.EntityFrameworkCore.InMemory
dotnet add package Swashbuckle.AspNetCore
cd ..
```

### 2. Create Frontend
```bash
# Create React app with Vite
npm create vite@latest ReactFrontend -- --template react-ts
cd ReactFrontend

# Add required packages
npm install axios @tanstack/react-query
cd ..
```

### 3. Add Docker Support
Copy the provided `docker-compose.yml` and Dockerfiles to your project.

## Available npm Scripts

Run these from the SourceCode directory:

- `npm run setup` - Install all dependencies
- `npm run dev` - Start with Docker
- `npm run dev:backend` - Start only backend locally
- `npm run dev:frontend` - Start only frontend locally
- `npm run stop` - Stop Docker containers
- `npm run clean` - Clean all build artifacts
- `npm run test` - Run backend tests

## Getting Help

1. Check the logs:
   - Docker: `docker-compose logs -f`
   - Backend: Look for errors in the terminal
   - Frontend: Check browser console (F12)

2. Verify prerequisites:
   - `node --version` (should be 18+)
   - `dotnet --version` (should be 8.0+)
   - `docker --version`

3. Common issues are covered in the Troubleshooting section above

4. For Windows-specific .NET issues, try:
   - Running as Administrator
   - Repairing .NET SDK installation
   - Checking Windows Defender exclusions