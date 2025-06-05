# Module 02: ASP.NET Core with React - Windows Setup Guide

## 🎯 Quick Start for Windows Students

This guide provides **direct Docker Compose commands** for Windows students to complete all Module 02 exercises without shell scripts.

## 📋 Prerequisites

- **Docker Desktop for Windows** installed and running
- **Git for Windows** (optional, for cloning)
- **Visual Studio Code** (recommended)

## 🚀 Exercise Setup Commands

### **Exercise 1: Basic Integration**
Set up React with ASP.NET Core using separate containers:

```cmd
# Clone or copy the source code to your local machine
# Navigate to the project directory
cd Module02-ASP.NET-Core-with-React\SourceCode\ReactTodoApp

# Start API and React development servers separately
docker-compose --profile api-only --profile react-dev up --build
```

**Access your application:**
- React Frontend: http://localhost:3000
- ASP.NET Core API: http://localhost:5002
- API Documentation: http://localhost:5002/swagger

### **Exercise 2: State Management & Routing**
Continue with the same setup as Exercise 1:

```cmd
# If containers are running, stop them first
docker-compose down

# Restart with the same configuration
docker-compose --profile api-only --profile react-dev up --build
```

### **Exercise 3: API Integration & Performance**
Use the development build with hot reload:

```cmd
# Stop previous containers
docker-compose down

# Start development build with hot reload
docker-compose --profile dev up --build
```

**Access your application:**
- Full Application: http://localhost:5001
- API Documentation: http://localhost:5001/swagger

### **Exercise 4: Docker Integration**
Use the production build:

```cmd
# Stop all previous containers
docker-compose down

# Build and start production container
docker-compose up --build
```

**Access your application:**
- Production Application: http://localhost:5000
- API Documentation: http://localhost:5000/swagger

## 🛠 Useful Docker Commands

### **View Running Containers**
```cmd
docker ps
```

### **View Application Logs**
```cmd
# View logs for all services
docker-compose logs

# View logs for specific service
docker-compose logs todo-app
docker-compose logs react-dev
docker-compose logs api-only
```

### **Stop All Containers**
```cmd
docker-compose down
```

### **Remove All Containers and Images**
```cmd
docker-compose down --rmi all --volumes --remove-orphans
```

### **Rebuild Containers (after code changes)**
```cmd
docker-compose up --build
```

## 📁 Project Structure

```
ReactTodoApp/
├── Controllers/           # ASP.NET Core API Controllers
├── Models/               # Data models
├── Services/             # Business logic services
├── ClientApp/            # React application
│   ├── src/
│   │   ├── components/   # React components
│   │   ├── services/     # API service calls
│   │   └── types/        # TypeScript type definitions
│   ├── package.json      # React dependencies
│   └── vite.config.ts    # Vite configuration
├── docker-compose.yml    # Multi-service Docker setup
├── Dockerfile           # Production build
├── Dockerfile.dev       # Development build
├── Dockerfile.api       # API-only build
└── README-Windows.md    # This file
```

## 🔧 Troubleshooting

### **Port Already in Use**
If you get port conflicts, modify the ports in `docker-compose.yml`:

```yaml
ports:
  - "5010:80"  # Change 5000 to 5010
```

### **Docker Desktop Not Running**
Ensure Docker Desktop is started and running before executing commands.

### **Build Failures**
Clear Docker cache and rebuild:

```cmd
docker system prune -f
docker-compose up --build --force-recreate
```

### **React Hot Reload Not Working**
For Windows, ensure the React development container has polling enabled:

```yaml
environment:
  - CHOKIDAR_USEPOLLING=true
```

## 📚 Exercise-Specific Notes

### **Exercise 1: Basic Integration**
- Focus on API endpoints working correctly
- Test CORS configuration between React and API
- Verify Swagger documentation is accessible

### **Exercise 2: State Management & Routing**
- Add React Router navigation
- Implement state management patterns
- Test routing between different pages

### **Exercise 3: API Integration & Performance**
- Optimize API calls with proper error handling
- Add loading states and user feedback
- Implement filtering and search functionality

### **Exercise 4: Docker Integration**
- Learn production Docker builds
- Understand multi-stage builds
- Practice container orchestration

## 🎓 Learning Outcomes

By the end of these exercises, you will have:

✅ **Integrated React with ASP.NET Core**
✅ **Implemented full CRUD operations**
✅ **Added routing and state management**
✅ **Optimized API communication**
✅ **Containerized a full-stack application**
✅ **Deployed using Docker Compose**

## 🆘 Getting Help

If you encounter issues:

1. **Check Docker Desktop** is running
2. **Verify port availability** (5000, 5001, 5002, 3000)
3. **Review container logs** using `docker-compose logs`
4. **Restart Docker Desktop** if needed
5. **Ask your instructor** for assistance

## 🌟 Success Criteria

Your setup is successful when:

- ✅ Containers start without errors
- ✅ React application loads in browser
- ✅ API endpoints respond correctly
- ✅ Swagger documentation is accessible
- ✅ CRUD operations work end-to-end
- ✅ No CORS errors in browser console

**Happy coding! 🚀**
