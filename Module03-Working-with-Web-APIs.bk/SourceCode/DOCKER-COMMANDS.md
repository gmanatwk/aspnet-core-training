# Docker Commands Reference

This guide provides Docker commands that work on Windows, Mac, and Linux.

## Starting the Application

```bash
# Navigate to the SourceCode directory
cd Module03-Working-with-Web-APIs/SourceCode

# Start all services (frontend, API, database)
docker-compose up --build

# Start in background (detached mode)
docker-compose up -d --build
```

## Stopping the Application

```bash
# Stop all containers
docker-compose down

# Stop and remove all data (including database)
docker-compose down -v
```

## Viewing Logs

```bash
# View all logs
docker-compose logs

# View logs for specific service
docker-compose logs restfulapi
docker-compose logs react-frontend
docker-compose logs db

# Follow logs in real-time
docker-compose logs -f

# Follow logs for specific service
docker-compose logs -f restfulapi
```

## Managing Individual Services

```bash
# Restart a specific service
docker-compose restart restfulapi

# Stop a specific service
docker-compose stop react-frontend

# Start a stopped service
docker-compose start react-frontend

# Rebuild a specific service
docker-compose build restfulapi
```

## Useful Commands

```bash
# List running containers
docker ps

# List all containers (including stopped)
docker ps -a

# Execute commands in a running container
docker exec -it restfulapi bash
docker exec -it react-frontend sh

# View container details
docker inspect restfulapi

# Remove unused images and containers
docker system prune -f
```

## Troubleshooting

```bash
# If ports are in use, find and stop conflicting services
# Windows:
netstat -ano | findstr :3000
netstat -ano | findstr :5001
netstat -ano | findstr :1433

# Mac/Linux:
lsof -i :3000
lsof -i :5001
lsof -i :1433

# Force recreate containers
docker-compose up --build --force-recreate

# Clean restart (removes everything)
docker-compose down -v
docker system prune -f
docker-compose up --build
```

## Windows-Specific Notes

1. Make sure Docker Desktop is running
2. Use PowerShell or Command Prompt (not Git Bash for some commands)
3. If using PowerShell, you might need to use `docker-compose.exe` instead of `docker-compose`

## Service URLs

After running `docker-compose up --build`, access:
- React Frontend: http://localhost:3000
- API Swagger: http://localhost:5001/swagger
- API Health: http://localhost:5001/health
- SQL Server: localhost,1433 (user: sa, password: Training123!)