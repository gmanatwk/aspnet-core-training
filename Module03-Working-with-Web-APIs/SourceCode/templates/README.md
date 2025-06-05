# Project Templates

These templates ensure consistent dependencies across all platforms (Windows, Mac, Linux).

## Backend Template (ASP.NET Core)

The `backend-template.csproj` file contains all the necessary NuGet packages for the RestfulAPI project:

- **Target Framework**: .NET 8.0
- **Authentication**: JWT Bearer tokens
- **Database**: Entity Framework Core with SQL Server and InMemory providers
- **API Documentation**: Swashbuckle (Swagger)
- **Cross-Origin Requests**: CORS support

### To use this template:
1. Create a new Web API project: `dotnet new webapi -n YourApiName --framework net8.0`
2. Replace the generated `.csproj` file with `backend-template.csproj`
3. Rename it to match your project name
4. Run `dotnet restore`

## Frontend Template (React + TypeScript)

The `frontend-package.json` file contains all necessary npm packages for the React frontend:

- **React**: Version 18 with TypeScript support
- **Build Tool**: Vite for fast development and optimized builds
- **HTTP Client**: Axios for API calls
- **Data Fetching**: TanStack Query (React Query) for server state management
- **Linting**: ESLint with TypeScript support

### To use this template:
1. Create a new Vite project: `npm create vite@latest YourAppName -- --template react-ts`
2. Replace the generated `package.json` with `frontend-package.json`
3. Run `npm install`

## Version Locking

These templates use specific version ranges to ensure compatibility:
- Backend: Major versions are locked (e.g., `8.0.0` for .NET 8 packages)
- Frontend: Minor versions are locked (e.g., `^18.2.0` for React)

## Updating Dependencies

To update to the latest compatible versions:

### Backend:
```bash
dotnet list package --outdated
dotnet add package <PackageName> --version <NewVersion>
```

### Frontend:
```bash
npm outdated
npm update
# or for major updates
npm install <package>@latest
```

## Cross-Platform Compatibility

These templates are tested to work on:
- Windows 10/11 (PowerShell, Command Prompt)
- macOS (Terminal, iTerm2)
- Ubuntu/Debian Linux
- WSL2 (Windows Subsystem for Linux)

The dependency versions are chosen for maximum compatibility across all platforms.