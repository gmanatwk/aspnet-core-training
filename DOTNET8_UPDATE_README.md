# .NET 8.0 Update Scripts

This directory contains scripts to update all ASP.NET Core training materials to use .NET 8.0, modern C# 12 syntax, and current package versions.

## 📋 Overview

The update scripts perform the following tasks:
1. Find all exercise markdown files
2. Update `dotnet new` commands to include `--framework net8.0`
3. Update package references to use version 8.0.x where appropriate
4. Add .NET 8.0 SDK as a prerequisite where missing
5. Update any outdated C# syntax to use modern C# 12 features

## 🚀 Available Scripts

### 1. **update-to-dotnet8.sh** (Linux/macOS)
Bash script for Unix-based systems.

```bash
./update-to-dotnet8.sh
```

### 2. **Update-ToDotNet8.ps1** (Windows)
PowerShell script for Windows systems.

```powershell
.\Update-ToDotNet8.ps1
```

### 3. **update_to_dotnet8.py** (Cross-platform)
Python script that works on all platforms with more sophisticated pattern matching.

```bash
# Dry run (preview changes without modifying files)
python update_to_dotnet8.py --dry-run

# Actual update
python update_to_dotnet8.py

# Update specific directory
python update_to_dotnet8.py --path ./Module01-Introduction-to-ASP.NET-Core
```

### 4. **verify-dotnet8-update.sh** (Verification)
Script to verify that all files have been properly updated.

```bash
./verify-dotnet8-update.sh
```

## 📦 Package Versions Updated

The scripts update the following packages to their .NET 8.0 compatible versions:

| Package | Version |
|---------|---------|
| Microsoft.EntityFrameworkCore.* | 8.0.11 |
| Microsoft.AspNetCore.Authentication.JwtBearer | 8.0.11 |
| Microsoft.AspNetCore.Mvc.Testing | 8.0.11 |
| Swashbuckle.AspNetCore | 6.8.1 |
| xunit | 2.9.2 |
| Moq | 4.20.72 |
| FluentAssertions | 6.12.2 |
| BenchmarkDotNet | 0.14.0 |
| Serilog.AspNetCore | 8.0.3 |
| AutoMapper.Extensions.Microsoft.DependencyInjection | 12.0.1 |

## 🔄 C# 12 Syntax Updates

The scripts update code examples to use modern C# 12 features:

- **Global using statements**
  ```csharp
  global using System;
  ```

- **File-scoped namespaces**
  ```csharp
  namespace MyApp.Services;
  ```

- **Target-typed new expressions**
  ```csharp
  List<string> items = new();
  ```

- **Primary constructors**
  ```csharp
  public class ProductService(ILogger<ProductService> logger)
  ```

- **Collection expressions**
  ```csharp
  int[] numbers = [1, 2, 3, 4, 5];
  ```

## 🛡️ Safety Features

- **Automatic Backups**: All scripts create `.bak` files before modifying
- **Dry Run Mode**: Python script supports preview mode
- **Detailed Reporting**: All changes are logged and reported
- **Verification**: Separate script to verify successful updates

## 📊 Reports

After running the update scripts, you'll get:

1. **Console Output**: Real-time progress and changes
2. **Update Report**: Detailed list of all changes made
3. **Backup Files**: Original content preserved as `.bak` files

## 🔧 Restoring from Backups

If you need to restore the original files:

### Linux/macOS:
```bash
find . -name "*.bak" -exec bash -c 'mv "$0" "${0%.bak}"' {} \;
```

### Windows (PowerShell):
```powershell
Get-ChildItem -Filter "*.bak" -Recurse | ForEach-Object {
    Move-Item -Path $_.FullName -Destination ($_.FullName -replace '\.bak$','') -Force
}
```

### Remove backup files after verification:
```bash
find . -name "*.bak" -delete
```

## ⚠️ Important Notes

1. **Review Changes**: Always review the changes before committing
2. **Test Projects**: Build and test sample projects after updates
3. **Git Integration**: Consider committing before running updates
4. **Custom Patterns**: The Python script can be extended for custom patterns

## 🐛 Troubleshooting

### Script won't run (Permission denied)
```bash
chmod +x update-to-dotnet8.sh
chmod +x verify-dotnet8-update.sh
```

### Python script requirements
- Python 3.6 or higher
- No external dependencies required

### PowerShell execution policy
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

## 📝 Manual Updates

Some updates may require manual intervention:

1. **Complex LINQ queries** that could benefit from new C# 12 features
2. **Custom middleware** that could use new minimal API features
3. **Test projects** that might need additional package updates
4. **Docker files** that need base image updates

## 🤝 Contributing

To add new patterns or package versions:

1. Edit the package version mappings in the scripts
2. Add new regex patterns for syntax updates
3. Test thoroughly on sample files
4. Submit a pull request with your changes

## 📚 Resources

- [What's new in .NET 8](https://learn.microsoft.com/en-us/dotnet/core/whats-new/dotnet-8)
- [What's new in C# 12](https://learn.microsoft.com/en-us/dotnet/csharp/whats-new/csharp-12)
- [.NET 8 Migration Guide](https://learn.microsoft.com/en-us/dotnet/core/compatibility/8.0)
- [ASP.NET Core 8.0 Documentation](https://learn.microsoft.com/en-us/aspnet/core/release-notes/aspnetcore-8.0)