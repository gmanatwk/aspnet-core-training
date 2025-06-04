# Package Version Management Guide

This guide ensures all trainees use consistent package versions across all exercises.

## 🎯 Why Package Version Consistency Matters

- **Reproducible Builds**: Everyone gets the same results
- **Security**: Use known secure package versions
- **Compatibility**: Avoid version conflicts between packages
- **Support**: Easier to troubleshoot when everyone uses the same versions

## 🔧 Tools Provided

### 1. Setup Script
```bash
./setup-exercise.sh <exercise-name>
```
Automatically creates projects with correct package versions.

**Available exercises:**
- `exercise01-basic-api`
- `exercise02-authentication`
- `exercise03-documentation`

### 2. Package Verification Script
```bash
./verify-packages.sh
```
Run this in any project directory to verify package versions.

### 3. Project Templates
Located in `Module03-Working-with-Web-APIs/Templates/`
- Pre-configured .csproj files with locked versions

### 4. Global Configuration
- `Directory.Build.props`: Centralized version management
- `global.json`: Locks .NET SDK version

## 📦 Locked Package Versions

| Package | Version | Purpose |
|---------|---------|---------|
| Microsoft.AspNetCore.Authentication.JwtBearer | 8.0.11 | JWT Authentication |
| Microsoft.AspNetCore.Identity.EntityFrameworkCore | 8.0.11 | Identity Framework |
| Microsoft.EntityFrameworkCore.InMemory | 8.0.11 | In-Memory Database |
| System.IdentityModel.Tokens.Jwt | 8.0.2 | JWT Token Handling |
| Swashbuckle.AspNetCore | 6.8.1 | API Documentation |

## 🚀 Quick Start for Trainees

### Method 1: Use Setup Script (Recommended)
```bash
# Navigate to training directory
cd aspnet-core-training

# Set up exercise
./setup-exercise.sh exercise01-basic-api

# Start working
cd LibraryAPI
```

### Method 2: Manual Setup with Verification
```bash
# Create project
dotnet new webapi -n LibraryAPI --framework net8.0
cd LibraryAPI

# Add packages with specific versions
dotnet add package Microsoft.EntityFrameworkCore.InMemory --version 8.0.11
dotnet add package Swashbuckle.AspNetCore --version 6.8.1

# Verify versions
../verify-packages.sh
```

## 🔍 Troubleshooting

### Package Version Mismatch
```bash
# Check current versions
../verify-packages.sh

# Fix incorrect versions
dotnet add package PackageName --version CorrectVersion
```

### Build Errors
```bash
# Clean and restore
dotnet clean
dotnet restore
dotnet build
```

### SDK Version Issues
```bash
# Check SDK version
dotnet --version

# Should be 8.0.x - if not, install .NET 8.0 SDK
```

## 📋 For Instructors

### Adding New Packages
1. Update `Directory.Build.props` with new version variables
2. Update package verification script
3. Update project templates
4. Update exercise instructions

### Version Updates
1. Test new versions thoroughly
2. Update all configuration files
3. Update documentation
4. Notify trainees of changes

## 🛡️ Security Considerations

- All package versions are chosen for security and stability
- Regular security updates are applied
- Vulnerable packages are avoided or updated immediately
- Version locks prevent accidental security downgrades

## 📞 Support

If you encounter package-related issues:
1. Run `./verify-packages.sh` to check versions
2. Use `./setup-exercise.sh` to start fresh
3. Check this guide for troubleshooting steps
4. Contact instructor if issues persist
