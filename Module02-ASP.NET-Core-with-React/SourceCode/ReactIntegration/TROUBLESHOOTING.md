# Module 02 - React Integration Troubleshooting Guide

## Common Issues and Solutions

### 1. Port Conflicts

**Problem**: "Port 3000/5000/7000 is already in use"

**Solution**:
```bash
# Find process using the port (macOS/Linux)
lsof -i :3000
# Kill the process
kill -9 [PID]

# Windows
netstat -ano | findstr :3000
taskkill /PID [PID] /F
```

### 2. HTTPS Certificate Issues

**Problem**: "NET::ERR_CERT_AUTHORITY_INVALID" or certificate warnings

**Solution**:
```bash
# Clean and regenerate certificates
dotnet dev-certs https --clean
dotnet dev-certs https --trust
```

### 3. Proxy Connection Issues

**Problem**: React app can't connect to ASP.NET Core API

**Solution**:
- Ensure the ASP.NET Core app is running on the correct port
- Check `ClientApp/package.json` has correct proxy setting
- The proxy should point to `http://localhost:5000` (HTTP, not HTTPS)

### 4. Node Module Issues

**Problem**: "Cannot find module" or dependency errors

**Solution**:
```bash
cd ClientApp
rm -rf node_modules package-lock.json
npm install
```

### 5. React Scripts Version Issues

**Problem**: Deprecation warnings or compatibility issues

**Solution**:
The `NODE_OPTIONS=--no-deprecation` in package.json suppresses warnings. This is normal with react-scripts 5.x.

### 6. Build Errors

**Problem**: TypeScript or build errors

**Solution**:
- Ensure all TypeScript types are installed
- Check for missing imports
- Run `npm run build` in ClientApp to see detailed errors

### 7. API Not Responding

**Problem**: API calls return 404 or connection refused

**Solution**:
1. Check the ASP.NET Core app is running
2. Verify the WeatherForecastController exists
3. Check the browser network tab for actual URLs being called
4. Ensure the proxy is configured correctly

### 8. Hot Reload Not Working

**Problem**: Changes to React components don't update automatically

**Solution**:
- Ensure you're running in development mode
- Check that webpack dev server is running (you'll see it in the console)
- Try restarting the application

## Running the Application

### Correct Startup Sequence:

1. Open terminal in the ReactIntegration folder
2. Run: `dotnet run`
3. Wait for both servers to start:
   - ASP.NET Core on https://localhost:7000
   - React dev server on http://localhost:3000
4. Browse to https://localhost:7000

### Manual Startup (if automatic doesn't work):

Terminal 1:
```bash
dotnet run --no-launch-profile
```

Terminal 2:
```bash
cd ClientApp
npm start
```

## Environment Details

- **ASP.NET Core**: Runs on ports 5000 (HTTP) and 7000 (HTTPS)
- **React Dev Server**: Runs on port 3000
- **Proxy**: React proxies API calls from port 3000 to port 5000

## Still Having Issues?

1. Check the console output for specific error messages
2. Look at browser developer tools (F12) for network and console errors
3. Ensure you have the latest versions:
   - .NET 8 SDK
   - Node.js 18+ 
   - npm 9+

4. Try the setup script:
```bash
./setup.sh
```