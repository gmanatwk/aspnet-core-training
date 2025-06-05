# Module 06 - Debugging and Troubleshooting Docker Setup

This module demonstrates debugging, logging, health checks, and troubleshooting techniques in a containerized ASP.NET Core environment.

## 🚀 Quick Start with Docker

### Prerequisites
- Docker Desktop installed
- No need for .NET SDK or SQL Server locally!

### Running the Application

1. **Start all services with Docker Compose:**
   ```bash
   cd Module06-Debugging-and-Troubleshooting/SourceCode
   docker-compose up
   ```

2. **Access the applications:**
   - API/Swagger: http://localhost:5004/swagger
   - Health Checks: http://localhost:5004/health
   - Health Checks UI: http://localhost:5005
   - SQL Server: localhost:1435 (sa/YourStrong@Passw0rd123)

## 🛠️ Debugging Features

### 1. Logging
- **Console Logs**: View in real-time with `docker-compose logs -f debugging-api`
- **File Logs**: Persisted in `./logs` directory (mapped volume)
- **Structured Logging**: Using Serilog with multiple sinks
- **Log Levels**: Configurable via environment variables

### 2. Health Checks
- **Database Health**: `/health/db`
- **External API Health**: `/health/external`
- **Custom Health Checks**: `/health/custom`
- **Health UI Dashboard**: http://localhost:5005

### 3. Performance Monitoring
- **Request Timing**: Automatic timing for all requests
- **Slow Request Detection**: Configurable threshold (default 500ms)
- **Performance Metrics**: Available at `/api/diagnostics/metrics`

### 4. Exception Handling
- **Global Exception Handler**: Catches all unhandled exceptions
- **Problem Details**: RFC 7807 compliant error responses
- **Exception Logging**: All exceptions logged with stack traces
- **Test Endpoints**: `/api/test/exception` endpoints for testing

## 📋 Available Endpoints

### Diagnostic Endpoints
- `GET /api/diagnostics/info` - System information
- `GET /api/diagnostics/environment` - Environment variables
- `GET /api/diagnostics/metrics` - Performance metrics
- `GET /api/diagnostics/memory` - Memory usage
- `GET /api/diagnostics/logs?lines=50` - Recent log entries

### Test Endpoints (for debugging scenarios)
- `GET /api/test/exception` - Throws a test exception
- `GET /api/test/slow-request` - Simulates slow request
- `GET /api/test/memory-leak` - Simulates memory issues
- `GET /api/test/deadlock` - Simulates deadlock scenario
- `POST /api/test/validation-error` - Tests validation errors

### Health Check Endpoints
- `GET /health` - Overall health status
- `GET /health/ready` - Readiness check
- `GET /health/live` - Liveness check

## 🔍 Debugging Techniques

### View Container Logs
```bash
# All logs
docker-compose logs -f

# Specific service
docker-compose logs -f debugging-api

# Last 100 lines
docker-compose logs --tail=100 debugging-api
```

### Access Container Shell
```bash
# Enter the container
docker exec -it debugging-demo-api bash

# Run diagnostic tools inside container
dotnet-counters collect -n DebuggingDemo
dotnet-trace collect -n DebuggingDemo
```

### Monitor Performance
```bash
# CPU and memory usage
docker stats debugging-demo-api

# Detailed metrics
curl http://localhost:5004/api/diagnostics/metrics
```

### Debug Database Issues
```bash
# Check database logs
docker-compose logs db

# Connect to SQL Server
docker exec -it debugging-sqlserver /opt/mssql-tools/bin/sqlcmd \
  -S localhost -U sa -P YourStrong@Passw0rd123
```

## 🎓 Learning Scenarios

### 1. Exception Handling
- Trigger exceptions: `GET /api/test/exception`
- View formatted error responses
- Check logs for stack traces
- Test custom business exceptions

### 2. Performance Issues
- Create slow requests: `GET /api/test/slow-request`
- Monitor performance middleware logs
- Check metrics endpoint
- Analyze request timing

### 3. Memory Debugging
- Simulate memory leak: `GET /api/test/memory-leak`
- Use `docker stats` to monitor memory
- Generate memory dumps with `dotnet-gcdump`

### 4. Health Monitoring
- Stop SQL Server: `docker-compose stop db`
- Watch health checks fail
- See automatic retries in logs
- Monitor via Health UI

## 🔧 Configuration

### Environment Variables
Configure logging and performance settings via docker-compose.yml:

```yaml
- Serilog__MinimumLevel__Default=Debug
- PerformanceSettings__SlowRequestThresholdMs=500
- PerformanceSettings__EnablePerformanceLogging=true
```

### Logging Levels
- `Trace`: Most detailed logging
- `Debug`: Debugging information
- `Information`: General information
- `Warning`: Warning messages
- `Error`: Error messages
- `Critical`: Critical failures

## 📊 Monitoring Tools

### Built-in Tools
1. **Swagger UI**: Interactive API documentation
2. **Health Checks UI**: Visual health monitoring
3. **Diagnostic Endpoints**: Custom monitoring data

### Docker Tools
```bash
# Resource usage
docker stats

# Inspect container
docker inspect debugging-demo-api

# View processes
docker top debugging-demo-api
```

## 🧹 Clean Up

Stop all containers:
```bash
docker-compose down
```

Remove volumes and clean logs:
```bash
docker-compose down -v
rm -rf ./logs/*
```

## 🚨 Troubleshooting

### Container Won't Start
- Check logs: `docker-compose logs debugging-api`
- Verify ports aren't in use: 5004, 5005, 1435
- Ensure Docker has enough resources

### Can't Connect to Database
- Wait 30 seconds for SQL Server to initialize
- Check database logs: `docker-compose logs db`
- Verify connection string in docker-compose.yml

### Logs Not Appearing
- Check volume mapping in docker-compose.yml
- Ensure `./logs` directory exists and has write permissions
- Verify Serilog configuration

## 📚 Advanced Debugging

### Remote Debugging
While full IDE debugging isn't available in containers, you can:
1. Use extensive logging
2. Access container shell for investigation
3. Use .NET diagnostic tools
4. Analyze memory dumps offline

### Production-like Debugging
Test production scenarios:
```bash
# Run with production settings
ASPNETCORE_ENVIRONMENT=Production docker-compose up
```

## 🎯 Key Learning Points

1. **Structured Logging** - Essential for containerized apps
2. **Health Checks** - Critical for orchestration platforms
3. **Performance Monitoring** - Built-in middleware approach
4. **Exception Handling** - Global handlers with proper formatting
5. **Diagnostic Endpoints** - Custom endpoints for troubleshooting

This setup provides a comprehensive debugging and troubleshooting environment that works consistently across all platforms!