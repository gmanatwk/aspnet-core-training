# Ensuring Consistent Package Versions

This project uses several mechanisms to ensure all developers and machines get the exact same package versions:

## .NET Packages

1. **Exact Versions in .csproj**
   - All NuGet packages use exact versions (no ^ or ~ prefixes)
   - Example: `Version="8.0.0"` not `Version="8.0.*"`

2. **Package Lock File**
   - Set `RestorePackagesWithLockFile` to `true` in .csproj
   - Creates `packages.lock.json` after first restore
   - Commit this file to source control

3. **Global.json**
   - Specifies minimum .NET SDK version
   - Uses `rollForward: latestMinor` for flexibility
   - Ensures everyone uses .NET 8.x

## Node.js Packages

1. **Exact Versions in package.json**
   - All dependencies use exact versions
   - Example: `"react": "18.2.0"` not `"react": "^18.2.0"`

2. **Package-lock.json**
   - Generated automatically by npm
   - Always commit this file
   - Use `npm ci` instead of `npm install` for exact restoration

3. **.nvmrc File**
   - Specifies Node.js version (18.18.0)
   - Use with nvm: `nvm use`

4. **Overrides Section**
   - Forces specific versions for transitive dependencies
   - Prevents version conflicts

## Docker Support

The included Dockerfile ensures consistent environments:
- Uses specific Node.js image: `node:18.18.0-alpine`
- Uses specific .NET images: `mcr.microsoft.com/dotnet/sdk:8.0`
- Builds are reproducible across all environments

## Best Practices

1. **Always use setup scripts**
   - `setup.sh` / `setup.bat` use `npm ci` not `npm install`
   - This installs exact versions from package-lock.json

2. **Don't update packages randomly**
   - Test thoroughly before updating any package
   - Update all team members when packages change

3. **Commit lock files**
   - Always commit `package-lock.json`
   - Always commit `packages.lock.json` (once generated)

4. **Use Docker for ultimate consistency**
   ```bash
   docker build -t react-aspnet .
   docker run -p 5000:80 react-aspnet
   ```

## Version Summary

### .NET
- SDK: 8.0.x (any 8.0 version)
- Runtime: 8.0
- Packages:
  - Microsoft.AspNetCore.OpenApi: 8.0.0
  - Swashbuckle.AspNetCore: 6.5.0

### Node.js
- Node: 18.18.0
- npm: (comes with Node)
- Packages:
  - react: 18.2.0
  - react-dom: 18.2.0
  - vite: 5.0.10
  - typescript: 5.3.3
  - @vitejs/plugin-react: 4.2.1

## Troubleshooting Version Issues

### .NET Version Mismatch
```bash
# Check installed SDKs
dotnet --list-sdks

# Install .NET 8 SDK if missing
# Visit: https://dotnet.microsoft.com/download/dotnet/8.0
```

### Node Version Mismatch
```bash
# Check Node version
node --version

# Using nvm
nvm install 18.18.0
nvm use 18.18.0

# Or use the .nvmrc file
nvm use
```

### Clear Package Caches
```bash
# .NET
dotnet nuget locals all --clear

# Node
npm cache clean --force
rm -rf node_modules package-lock.json
npm install
```