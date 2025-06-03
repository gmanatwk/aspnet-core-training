# React + ASP.NET Core Integration

This project demonstrates a simple, reliable integration between React (using Vite) and ASP.NET Core that works on both Windows and macOS.

## Prerequisites

- .NET 8.0 SDK or later
- Node.js 16.0 or later
- npm (comes with Node.js)

## Quick Start

### 1. Initial Setup (one time only)

**macOS/Linux:**
```bash
./setup.sh
```

**Windows:**
```cmd
setup.bat
```

This will:
- Check prerequisites
- Install all dependencies
- Build the React app for production

### 2. Running the Application

#### Option A: Development Mode (Recommended for learning)

**macOS/Linux:**
```bash
./run.sh
```

**Windows:**
```cmd
run.bat
```

This starts:
- ASP.NET Core API on http://localhost:5000
- React dev server on http://localhost:3000

#### Option B: Production Mode

```bash
dotnet run
```

Then browse to http://localhost:5000

## Project Structure

```
ReactIntegration/
├── Controllers/                 # API controllers
│   └── WeatherForecastController.cs
├── client-app/                  # React application (Vite)
│   ├── src/
│   │   ├── App.tsx             # Main React component
│   │   ├── App.css             # Component styles
│   │   ├── main.tsx            # Entry point
│   │   └── index.css           # Global styles
│   ├── public/                 # Static assets
│   ├── package.json            # Node dependencies
│   ├── vite.config.ts          # Vite configuration
│   └── tsconfig.json           # TypeScript configuration
├── wwwroot/                    # Built React app (after build)
├── Program.cs                  # ASP.NET Core configuration
├── ReactIntegration.csproj     # .NET project file
├── appsettings.json           # ASP.NET Core settings
├── setup.sh/.bat              # Setup scripts
└── run.sh/.bat                # Run scripts
```

## How It Works

1. **Development Mode**: 
   - Two servers run independently
   - Vite proxies API calls to ASP.NET Core
   - Hot module replacement for React
   - API changes require restart

2. **Production Mode**:
   - React app is built to wwwroot
   - ASP.NET Core serves both API and static files
   - Single deployment unit

## Key Features

- ✅ Simple setup - no complex configurations
- ✅ Cross-platform - works on Windows, macOS, and Linux
- ✅ Fast development - Vite provides instant HMR
- ✅ Production ready - builds to static files
- ✅ TypeScript support - full type safety
- ✅ No proxy issues - reliable proxy configuration

## Troubleshooting

### Port Already in Use

Kill processes on the ports:

**macOS/Linux:**
```bash
lsof -ti:3000 | xargs kill -9
lsof -ti:5000 | xargs kill -9
```

**Windows:**
```cmd
netstat -ano | findstr :3000
taskkill /PID [PID] /F
```

### Node Modules Issues

```bash
cd client-app
rm -rf node_modules package-lock.json
npm install
```

### Build Errors

Make sure you're using:
- Node.js 16 or later
- .NET 8 SDK

## Adding New Features

### Adding a New API Endpoint

1. Create a new controller in the `Controllers` folder
2. Add your endpoint methods
3. The React app can call it via `/api/your-endpoint`

### Adding React Components

1. Create components in `client-app/src`
2. Import and use them in `App.tsx`
3. Vite will automatically hot reload

### Adding npm Packages

```bash
cd client-app
npm install package-name
```

### Adding NuGet Packages

```bash
dotnet add package PackageName
```

## Why Vite Instead of Create React App?

- **Faster**: Instant server start and hot module replacement
- **Simpler**: Less configuration and fewer dependencies
- **Reliable**: No issues with stuck processes or complex proxy setups
- **Modern**: Better TypeScript support and ES modules

## Next Steps

- Add React Router for multiple pages
- Add state management (Context API or Zustand)
- Add authentication with JWT tokens
- Deploy to Azure or any cloud provider