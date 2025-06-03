#!/usr/bin/env python3
"""
Update ASP.NET Core training materials to .NET 8.0
This script updates all exercise and documentation files to use .NET 8.0,
modern C# 12 syntax, and current package versions.
"""

import os
import re
import shutil
import datetime
from pathlib import Path
from typing import Dict, List, Tuple
import argparse
import json

# Package version mappings for .NET 8.0
PACKAGE_VERSIONS = {
    "Microsoft.EntityFrameworkCore.SqlServer": "8.0.11",
    "Microsoft.EntityFrameworkCore.Tools": "8.0.11",
    "Microsoft.EntityFrameworkCore.Design": "8.0.11",
    "Microsoft.EntityFrameworkCore.InMemory": "8.0.11",
    "Microsoft.EntityFrameworkCore.Sqlite": "8.0.11",
    "Microsoft.EntityFrameworkCore": "8.0.11",
    "Microsoft.AspNetCore.Authentication.JwtBearer": "8.0.11",
    "Microsoft.AspNetCore.Mvc.Testing": "8.0.11",
    "Microsoft.AspNetCore.SpaServices.Extensions": "8.0.11",
    "Microsoft.AspNetCore.Diagnostics.EntityFrameworkCore": "8.0.11",
    "Microsoft.AspNetCore.Identity.EntityFrameworkCore": "8.0.11",
    "Microsoft.AspNetCore.Identity.UI": "8.0.11",
    "Swashbuckle.AspNetCore": "6.8.1",
    "xunit": "2.9.2",
    "xunit.runner.visualstudio": "2.8.2",
    "Moq": "4.20.72",
    "FluentAssertions": "6.12.2",
    "BenchmarkDotNet": "0.14.0",
    "Serilog.AspNetCore": "8.0.3",
    "Serilog.Sinks.Console": "6.0.0",
    "Serilog.Sinks.File": "6.0.0",
    "AutoMapper.Extensions.Microsoft.DependencyInjection": "12.0.1",
    "Polly": "8.5.0",
    "MediatR": "12.4.1",
    "FluentValidation.AspNetCore": "11.3.0",
    "Newtonsoft.Json": "13.0.3",
    "Microsoft.Extensions.Caching.StackExchangeRedis": "8.0.11",
    "StackExchange.Redis": "2.8.16",
}

# C# 12 syntax patterns to update
CSHARP_SYNTAX_UPDATES = [
    # Global using statements
    (r'(```csharp\r?\n)(using System;)', r'\1global using System;'),
    
    # File-scoped namespaces
    (r'namespace\s+([\w.]+)\s*\r?\n\s*{', r'namespace \1;'),
    
    # Target-typed new expressions
    (r'(\w+<[^>]+>)\s+(\w+)\s*=\s*new\s+\1\s*\(\)', r'\1 \2 = new()'),
    (r'Dictionary<([^,>]+),\s*([^>]+)>\s+(\w+)\s*=\s*new Dictionary<\1,\s*\2>\(\)', r'Dictionary<\1, \2> \3 = new()'),
    (r'List<([^>]+)>\s+(\w+)\s*=\s*new List<\1>\(\)', r'List<\1> \2 = new()'),
    
    # Pattern matching improvements
    (r'if\s*\((\w+)\s+is\s+(\w+)\)\s*\r?\n\s*{\s*\r?\n\s*var\s+(\w+)\s*=\s*\(\2\)\s*\1;', r'if (\1 is \2 \3)'),
    
    # Switch expressions (simple cases)
    (r'switch\s*\((\w+)\)\s*\r?\n\s*{\s*\r?\n\s*case\s+"(\w+)":\s*return\s+(\w+);', r'\1 switch { "\2" => \3,'),
    
    # Raw string literals for multi-line strings
    (r'@"([^"]*\r?\n[^"]*)"', r'"""\1"""'),
    
    # Required members
    (r'public\s+(\w+)\s+(\w+)\s*{\s*get;\s*set;\s*}\s*=\s*null!;', r'public required \1 \2 { get; set; }'),
]

class DotNet8Updater:
    def __init__(self, root_path: str, dry_run: bool = False):
        self.root_path = Path(root_path)
        self.dry_run = dry_run
        self.files_updated = 0
        self.total_files = 0
        self.changes_log = []
        
    def find_files_to_update(self) -> List[Path]:
        """Find all markdown files that need updating."""
        files = []
        
        # Find exercise files
        for exercise_file in self.root_path.rglob("*/Exercises/*.md"):
            files.append(exercise_file)
            
        # Find README files
        for readme_file in self.root_path.rglob("README.md"):
            files.append(readme_file)
            
        # Find resource files
        for resource_file in self.root_path.rglob("*/Resources/*.md"):
            files.append(resource_file)
            
        return files
    
    def update_dotnet_new_commands(self, content: str) -> Tuple[str, List[str]]:
        """Update dotnet new commands to include --framework net8.0."""
        changes = []
        
        # Pattern for dotnet new without --framework
        pattern = r'dotnet new (\w+)(\s+-n\s+[\w-]+)(?!.*--framework)'
        matches = re.finditer(pattern, content)
        
        for match in matches:
            old_cmd = match.group(0)
            new_cmd = f'dotnet new {match.group(1)}{match.group(2)} --framework net8.0'
            content = content.replace(old_cmd, new_cmd)
            changes.append(f"Updated dotnet new command: {old_cmd} → {new_cmd}")
            
        return content, changes
    
    def update_package_versions(self, content: str) -> Tuple[str, List[str]]:
        """Update NuGet package versions to .NET 8.0 compatible versions."""
        changes = []
        
        for package, version in PACKAGE_VERSIONS.items():
            # Multiple patterns to catch different formats
            patterns = [
                rf'{re.escape(package)}`\s*\([\d.]+\)',
                rf'{re.escape(package)}\s+Version="[\d.]+"',
                rf'<PackageReference Include="{re.escape(package)}"\s+Version="[\d.]+"',
                rf'Install-Package {re.escape(package)} -Version [\d.]+',
                rf'dotnet add package {re.escape(package)} --version [\d.]+',
            ]
            
            for pattern in patterns:
                matches = re.finditer(pattern, content, re.IGNORECASE)
                for match in matches:
                    old_text = match.group(0)
                    if '`' in old_text:
                        new_text = f'{package}` ({version})'
                    elif 'Version="' in old_text:
                        new_text = re.sub(r'Version="[\d.]+"', f'Version="{version}"', old_text)
                    elif '-Version' in old_text:
                        new_text = re.sub(r'-Version [\d.]+', f'-Version {version}', old_text)
                    elif '--version' in old_text:
                        new_text = re.sub(r'--version [\d.]+', f'--version {version}', old_text)
                    else:
                        continue
                        
                    content = content.replace(old_text, new_text)
                    changes.append(f"Updated {package} version to {version}")
                    
        return content, changes
    
    def update_dotnet_versions(self, content: str) -> Tuple[str, List[str]]:
        """Update .NET version references."""
        changes = []
        
        # Update .NET version references
        dotnet_pattern = r'\.NET [567]\.0'
        matches = re.finditer(dotnet_pattern, content)
        for match in matches:
            content = content.replace(match.group(0), '.NET 8.0')
            changes.append(f"Updated {match.group(0)} to .NET 8.0")
            
        # Update target framework references
        framework_pattern = r'<TargetFramework>net[567]\.0</TargetFramework>'
        matches = re.finditer(framework_pattern, content)
        for match in matches:
            content = content.replace(match.group(0), '<TargetFramework>net8.0</TargetFramework>')
            changes.append(f"Updated target framework to net8.0")
            
        # Update C# version references
        csharp_pattern = r'C#\s+(9|10|11)(?!\d)'
        matches = re.finditer(csharp_pattern, content)
        for match in matches:
            content = content.replace(match.group(0), 'C# 12')
            changes.append(f"Updated {match.group(0)} to C# 12")
            
        return content, changes
    
    def add_dotnet8_prerequisite(self, content: str) -> Tuple[str, List[str]]:
        """Add .NET 8.0 SDK as a prerequisite if missing."""
        changes = []
        
        if '## Prerequisites' in content or '## 📋 Prerequisites' in content:
            if '.NET 8.0 SDK' not in content:
                # Find the prerequisites section
                prereq_pattern = r'(##\s*(?:📋\s*)?Prerequisites.*?\n)((?:[-*]\s+.*\n)*)'
                match = re.search(prereq_pattern, content, re.MULTILINE)
                
                if match:
                    header = match.group(1)
                    items = match.group(2)
                    
                    # Remove any existing .NET SDK references
                    items = re.sub(r'[-*]\s*\.NET \d+\.\d+ SDK.*\n', '', items)
                    
                    # Add .NET 8.0 SDK as first item
                    new_items = f"- .NET 8.0 SDK installed\n{items}"
                    
                    content = content.replace(match.group(0), f"{header}{new_items}")
                    changes.append("Added .NET 8.0 SDK prerequisite")
                    
        return content, changes
    
    def update_csharp_syntax(self, content: str) -> Tuple[str, List[str]]:
        """Update to modern C# 12 syntax."""
        changes = []
        
        for pattern, replacement in CSHARP_SYNTAX_UPDATES:
            matches = re.finditer(pattern, content, re.MULTILINE)
            for match in matches:
                content = re.sub(pattern, replacement, content, count=1)
                changes.append(f"Updated to C# 12 syntax: {match.group(0)[:50]}...")
                
        # Collection expressions (C# 12)
        array_pattern = r'new\s+(\w+)\[\]\s*{\s*([^}]+)\s*}'
        matches = re.finditer(array_pattern, content)
        for match in matches:
            if not any(keyword in match.group(0) for keyword in ['new[]', 'params', 'var']):
                content = content.replace(match.group(0), f'[{match.group(2)}]')
                changes.append("Updated to collection expression syntax")
                
        return content, changes
    
    def update_file(self, file_path: Path) -> bool:
        """Update a single file with all necessary changes."""
        print(f"Processing: {file_path}")
        self.total_files += 1
        
        try:
            # Read the file
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
                
            original_content = content
            all_changes = []
            
            # Apply all updates
            content, changes = self.update_dotnet_new_commands(content)
            all_changes.extend(changes)
            
            content, changes = self.update_package_versions(content)
            all_changes.extend(changes)
            
            content, changes = self.update_dotnet_versions(content)
            all_changes.extend(changes)
            
            content, changes = self.add_dotnet8_prerequisite(content)
            all_changes.extend(changes)
            
            content, changes = self.update_csharp_syntax(content)
            all_changes.extend(changes)
            
            # Check if any changes were made
            if content != original_content:
                if not self.dry_run:
                    # Create backup
                    backup_path = file_path.with_suffix(file_path.suffix + '.bak')
                    shutil.copy2(file_path, backup_path)
                    
                    # Write updated content
                    with open(file_path, 'w', encoding='utf-8') as f:
                        f.write(content)
                        
                    print(f"  ✓ File updated (backup saved as {backup_path.name})")
                else:
                    print(f"  ✓ File would be updated (dry run)")
                    
                self.files_updated += 1
                
                # Log changes
                for change in all_changes:
                    print(f"  - {change}")
                    self.changes_log.append(f"{file_path}: {change}")
                    
                return True
            else:
                print("  No changes needed")
                return False
                
        except Exception as e:
            print(f"  ✗ Error processing file: {e}")
            return False
    
    def generate_report(self) -> str:
        """Generate a detailed report of all changes."""
        report = f"""
.NET 8.0 Update Report
Generated: {datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')}
{'=' * 50}

Summary:
- Total files processed: {self.total_files}
- Files updated: {self.files_updated}
- Dry run: {self.dry_run}

Package Versions Updated:
{chr(10).join(f'  - {pkg}: {ver}' for pkg, ver in PACKAGE_VERSIONS.items())}

Detailed Changes:
{chr(10).join(f'  {change}' for change in self.changes_log[:100])}
{'  ... and more' if len(self.changes_log) > 100 else ''}

To restore from backups:
  find . -name "*.bak" -exec bash -c 'mv "$0" "${0%.bak}"' {} \;
"""
        return report
    
    def run(self):
        """Run the update process."""
        print("Starting .NET 8.0 update process...")
        print("=" * 50)
        
        # Find files to update
        files = self.find_files_to_update()
        print(f"Found {len(files)} files to process")
        print()
        
        # Update each file
        for file_path in files:
            self.update_file(file_path)
            print()
        
        # Generate and save report
        report = self.generate_report()
        report_path = self.root_path / f"dotnet8_update_report_{datetime.datetime.now().strftime('%Y%m%d_%H%M%S')}.txt"
        
        if not self.dry_run:
            with open(report_path, 'w', encoding='utf-8') as f:
                f.write(report)
                
        print("=" * 50)
        print(f"Update {'simulation' if self.dry_run else 'complete'}!")
        print(f"Files processed: {self.total_files}")
        print(f"Files {'would be' if self.dry_run else ''} updated: {self.files_updated}")
        
        if not self.dry_run:
            print(f"\nReport saved to: {report_path}")
            print("\nTo review changes, compare .bak files with updated files")
            print('To remove all backup files: find . -name "*.bak" -delete')


def main():
    parser = argparse.ArgumentParser(description='Update ASP.NET Core training materials to .NET 8.0')
    parser.add_argument('--dry-run', action='store_true', help='Preview changes without modifying files')
    parser.add_argument('--path', default='.', help='Root path of the training materials (default: current directory)')
    
    args = parser.parse_args()
    
    updater = DotNet8Updater(args.path, args.dry_run)
    updater.run()


if __name__ == '__main__':
    main()