#!/bin/bash

# Script to check all exercises for code examples and ensure they're current

echo "======================================"
echo "ASP.NET Core Training Exercise Checker"
echo "======================================"
echo ""

# Function to extract and test code snippets
check_exercise() {
    local exercise_file="$1"
    local module_name="$2"
    
    echo "Checking: $exercise_file"
    
    # Check for C# code blocks
    if grep -q '```csharp' "$exercise_file"; then
        echo "  ✓ Contains C# code examples"
        
        # Check for .NET 8 specific patterns
        if grep -q 'net8\.0\|\.NET 8\|dotnet new.*net8' "$exercise_file"; then
            echo "  ✓ References .NET 8"
        else
            echo "  ⚠ May need .NET 8 update"
        fi
    fi
    
    # Check for bash/shell code blocks
    if grep -q '```bash\|```shell' "$exercise_file"; then
        echo "  ✓ Contains command line examples"
    fi
    
    # Check for configuration examples
    if grep -q '```json\|```xml' "$exercise_file"; then
        echo "  ✓ Contains configuration examples"
    fi
    
    echo ""
}

# Find all exercise files
for module_dir in Module*; do
    if [ -d "$module_dir/Exercises" ]; then
        echo "======================================" 
        echo "Module: $module_dir"
        echo "======================================" 
        
        for exercise_file in "$module_dir/Exercises"/*.md; do
            if [ -f "$exercise_file" ]; then
                check_exercise "$exercise_file" "$module_dir"
            fi
        done
    fi
done

echo "======================================"
echo "Summary Complete"
echo "======================================"