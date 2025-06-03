# PowerShell script to update all exercise files to .NET 8.0
# This script will:
# 1. Find all exercise markdown files
# 2. Update dotnet new commands to include --framework net8.0
# 3. Update package references to use version 8.0.x
# 4. Add .NET 8.0 SDK as a prerequisite where missing
# 5. Update C# syntax to modern C# 12 features

Write-Host "Starting update to .NET 8.0..." -ForegroundColor Green
Write-Host "===============================" -ForegroundColor Green

# Track statistics
$script:filesUpdated = 0
$script:totalFiles = 0

# Define package version mappings
$packageVersions = @{
    "Microsoft.EntityFrameworkCore.SqlServer" = "8.0.11"
    "Microsoft.EntityFrameworkCore.Tools" = "8.0.11"
    "Microsoft.EntityFrameworkCore.Design" = "8.0.11"
    "Microsoft.EntityFrameworkCore.InMemory" = "8.0.11"
    "Microsoft.EntityFrameworkCore.Sqlite" = "8.0.11"
    "Microsoft.AspNetCore.Authentication.JwtBearer" = "8.0.11"
    "Microsoft.AspNetCore.Mvc.Testing" = "8.0.11"
    "Microsoft.AspNetCore.SpaServices.Extensions" = "8.0.11"
    "Swashbuckle.AspNetCore" = "6.8.1"
    "xunit" = "2.9.2"
    "xunit.runner.visualstudio" = "2.8.2"
    "Moq" = "4.20.72"
    "FluentAssertions" = "6.12.2"
    "BenchmarkDotNet" = "0.14.0"
    "Serilog.AspNetCore" = "8.0.3"
    "AutoMapper.Extensions.Microsoft.DependencyInjection" = "12.0.1"
}

# Function to update a single file
function Update-ExerciseFile {
    param(
        [string]$FilePath
    )
    
    Write-Host "Processing: $FilePath" -ForegroundColor Yellow
    
    $content = Get-Content -Path $FilePath -Raw
    $originalContent = $content
    $changesMade = $false
    
    # Create a backup
    $backupPath = "$FilePath.bak"
    Copy-Item -Path $FilePath -To $backupPath -Force
    
    # Update dotnet new commands to include --framework net8.0
    $dotnetNewPattern = 'dotnet new (\w+)(\s+-n\s+[\w-]+)(?!.*--framework)'
    if ($content -match $dotnetNewPattern) {
        $content = $content -replace $dotnetNewPattern, 'dotnet new $1$2 --framework net8.0'
        $changesMade = $true
        Write-Host "  - Updated dotnet new command" -ForegroundColor Cyan
    }
    
    # Update package references to 8.0.x versions
    foreach ($package in $packageVersions.Keys) {
        $pattern = "$package`.*(\d+\.\d+\.\d+)"
        if ($content -match $pattern) {
            $newVersion = $packageVersions[$package]
            $content = $content -replace $pattern, "$package`` ($newVersion)"
            $changesMade = $true
            Write-Host "  - Updated $package to version $newVersion" -ForegroundColor Cyan
        }
    }
    
    # Update generic .NET version references
    $dotnetVersionPattern = '\.NET [567]\.0'
    if ($content -match $dotnetVersionPattern) {
        $content = $content -replace $dotnetVersionPattern, '.NET 8.0'
        $changesMade = $true
        Write-Host "  - Updated .NET version reference" -ForegroundColor Cyan
    }
    
    # Update C# version references
    $csharpVersionPattern = 'C#\s+(9|10|11)(?!\d)'
    if ($content -match $csharpVersionPattern) {
        $content = $content -replace $csharpVersionPattern, 'C# 12'
        $changesMade = $true
        Write-Host "  - Updated C# version reference" -ForegroundColor Cyan
    }
    
    # Update target framework in csproj examples
    $targetFrameworkPattern = '<TargetFramework>net[567]\.0</TargetFramework>'
    if ($content -match $targetFrameworkPattern) {
        $content = $content -replace $targetFrameworkPattern, '<TargetFramework>net8.0</TargetFramework>'
        $changesMade = $true
        Write-Host "  - Updated target framework reference" -ForegroundColor Cyan
    }
    
    # Add .NET 8.0 SDK prerequisite if missing
    if ($content -match '##.*Prerequisites' -and $content -notmatch '\.NET 8\.0 SDK') {
        $prerequisitesPattern = '(##.*Prerequisites.*?\r?\n)(.*?)(\r?\n##|\r?\n###|\Z)'
        $content = $content -replace $prerequisitesPattern, {
            $match = $_
            $header = $match.Groups[1].Value
            $items = $match.Groups[2].Value
            $nextSection = $match.Groups[3].Value
            
            # Remove any existing .NET SDK references
            $items = $items -replace '- \.NET \d+\.\d+ SDK.*\r?\n', ''
            
            # Add .NET 8.0 SDK as first item
            $newItems = "- .NET 8.0 SDK installed`r`n$items"
            
            return "$header$newItems$nextSection"
        }
        $changesMade = $true
        Write-Host "  - Added .NET 8.0 SDK prerequisite" -ForegroundColor Cyan
    }
    
    # Update to modern C# 12 syntax examples
    # Global using statements
    if ($content -match 'using System;' -and $content -notmatch 'global using') {
        $content = $content -replace '(```csharp\r?\n)(using System;)', '$1global using System;'
        $changesMade = $true
        Write-Host "  - Updated to use global using statements" -ForegroundColor Cyan
    }
    
    # File-scoped namespaces
    $namespaceBracePattern = 'namespace\s+([\w.]+)\s*\r?\n\s*{'
    if ($content -match $namespaceBracePattern) {
        $content = $content -replace $namespaceBracePattern, 'namespace $1;'
        # Also remove the closing brace for namespace
        $content = $content -replace '}\s*//\s*namespace.*', ''
        $changesMade = $true
        Write-Host "  - Updated to file-scoped namespaces" -ForegroundColor Cyan
    }
    
    # Target-typed new expressions
    $targetTypedNewPattern = '(\w+<[^>]+>)\s+(\w+)\s*=\s*new\s+\1\s*\(\)'
    if ($content -match $targetTypedNewPattern) {
        $content = $content -replace $targetTypedNewPattern, '$1 $2 = new()'
        $changesMade = $true
        Write-Host "  - Updated to target-typed new expressions" -ForegroundColor Cyan
    }
    
    # Primary constructors (for simple classes)
    $simpleCtorPattern = 'public\s+class\s+(\w+)\s*\r?\n\s*{\s*\r?\n\s*private\s+readonly\s+(\w+)\s+_(\w+);\s*\r?\n\s*\r?\n\s*public\s+\1\((\2\s+\w+)\)\s*\r?\n\s*{\s*\r?\n\s*_\3\s*=\s*\w+;\s*\r?\n\s*}'
    if ($content -match $simpleCtorPattern) {
        $content = $content -replace $simpleCtorPattern, 'public class $1($2 $3)'
        $changesMade = $true
        Write-Host "  - Updated to use primary constructors" -ForegroundColor Cyan
    }
    
    # Save the updated content
    if ($changesMade) {
        Set-Content -Path $FilePath -Value $content -NoNewline
        $script:filesUpdated++
        Write-Host "  ✓ File updated (backup saved as $backupPath)" -ForegroundColor Green
    } else {
        Remove-Item -Path $backupPath
        Write-Host "  No changes needed" -ForegroundColor Gray
    }
    
    $script:totalFiles++
    Write-Host ""
}

# Find and process all exercise files
Write-Host "Searching for exercise files..." -ForegroundColor Yellow
$exerciseFiles = Get-ChildItem -Path . -Filter "*.md" -Recurse | 
    Where-Object { $_.DirectoryName -match "\\Exercises|/Exercises" }

foreach ($file in $exerciseFiles) {
    Update-ExerciseFile -FilePath $file.FullName
}

# Also update README files that might contain version information
Write-Host "Updating README files..." -ForegroundColor Yellow
$readmeFiles = Get-ChildItem -Path . -Filter "README.md" -Recurse

foreach ($file in $readmeFiles) {
    $content = Get-Content -Path $file.FullName -Raw
    if ($content -match '\.NET [567]\.0|C#\s+(9|10|11)') {
        Update-ExerciseFile -FilePath $file.FullName
    }
}

# Summary
Write-Host "===============================" -ForegroundColor Green
Write-Host "Update complete!" -ForegroundColor Green
Write-Host "Files processed: $script:totalFiles" -ForegroundColor White
Write-Host "Files updated: $script:filesUpdated" -ForegroundColor White
Write-Host ""
Write-Host "To review changes, compare .bak files with updated files" -ForegroundColor Yellow
Write-Host "To remove all backup files: Get-ChildItem -Filter '*.bak' -Recurse | Remove-Item" -ForegroundColor Yellow

# Generate a report of all changes
$reportPath = "DotNet8UpdateReport_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"
@"
.NET 8.0 Update Report
Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
======================================

Total Files Processed: $script:totalFiles
Total Files Updated: $script:filesUpdated

Package Versions Updated:
$(foreach ($pkg in $packageVersions.GetEnumerator()) {
    "  - $($pkg.Key): $($pkg.Value)"
})

To restore from backups:
Get-ChildItem -Filter '*.bak' -Recurse | ForEach-Object {
    Move-Item -Path `$_.FullName -Destination (`$_.FullName -replace '\.bak$','') -Force
}
"@ | Out-File -FilePath $reportPath

Write-Host ""
Write-Host "Report saved to: $reportPath" -ForegroundColor Green