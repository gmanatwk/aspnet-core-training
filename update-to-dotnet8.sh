#!/bin/bash

# Script to update all exercise files to .NET 8.0
# This script will:
# 1. Find all exercise markdown files
# 2. Update dotnet new commands to include --framework net8.0
# 3. Update package references to use version 8.0.x
# 4. Add .NET 8.0 SDK as a prerequisite where missing
# 5. Update C# syntax to modern C# 12 features

echo "Starting update to .NET 8.0..."
echo "==============================="

# Track statistics
FILES_UPDATED=0
TOTAL_FILES=0

# Find all exercise markdown files
EXERCISE_FILES=$(find . -path "*/Exercises/*.md" -type f)

# Function to update a single file
update_file() {
    local file="$1"
    local temp_file="${file}.tmp"
    local changes_made=false
    
    echo "Processing: $file"
    
    # Create a backup
    cp "$file" "${file}.bak"
    
    # Read the file and make updates
    while IFS= read -r line; do
        local updated_line="$line"
        
        # Update dotnet new commands to include --framework net8.0
        if [[ "$line" =~ dotnet\ new\ ([a-zA-Z]+)\ -n\ ([a-zA-Z0-9_-]+)$ ]]; then
            updated_line="dotnet new ${BASH_REMATCH[1]} -n ${BASH_REMATCH[2]} --framework net8.0"
            changes_made=true
            echo "  - Updated dotnet new command"
        fi
        
        # Update dotnet new commands that already have some flags
        if [[ "$line" =~ dotnet\ new\ ([a-zA-Z]+)\ (.*)$ ]] && [[ ! "$line" =~ --framework ]]; then
            local cmd="${BASH_REMATCH[1]}"
            local args="${BASH_REMATCH[2]}"
            updated_line="dotnet new $cmd $args --framework net8.0"
            changes_made=true
            echo "  - Updated dotnet new command with existing flags"
        fi
        
        # Update package references to 8.0.x versions
        # Entity Framework Core packages
        if [[ "$line" =~ Microsoft\.EntityFrameworkCore\.SqlServer.*[0-9]+\.[0-9]+\.[0-9]+ ]]; then
            updated_line=$(echo "$line" | sed -E 's/(Microsoft\.EntityFrameworkCore\.SqlServer)[^0-9]*[0-9]+\.[0-9]+\.[0-9]+/\1` (8.0.11)/g')
            changes_made=true
            echo "  - Updated EF Core SqlServer package"
        fi
        
        if [[ "$line" =~ Microsoft\.EntityFrameworkCore\.Tools.*[0-9]+\.[0-9]+\.[0-9]+ ]]; then
            updated_line=$(echo "$line" | sed -E 's/(Microsoft\.EntityFrameworkCore\.Tools)[^0-9]*[0-9]+\.[0-9]+\.[0-9]+/\1` (8.0.11)/g')
            changes_made=true
            echo "  - Updated EF Core Tools package"
        fi
        
        if [[ "$line" =~ Microsoft\.EntityFrameworkCore\.Design.*[0-9]+\.[0-9]+\.[0-9]+ ]]; then
            updated_line=$(echo "$line" | sed -E 's/(Microsoft\.EntityFrameworkCore\.Design)[^0-9]*[0-9]+\.[0-9]+\.[0-9]+/\1` (8.0.11)/g')
            changes_made=true
            echo "  - Updated EF Core Design package"
        fi
        
        # ASP.NET Core packages
        if [[ "$line" =~ Microsoft\.AspNetCore\.Authentication\.JwtBearer.*[0-9]+\.[0-9]+\.[0-9]+ ]]; then
            updated_line=$(echo "$line" | sed -E 's/(Microsoft\.AspNetCore\.Authentication\.JwtBearer)[^0-9]*[0-9]+\.[0-9]+\.[0-9]+/\1` (8.0.11)/g')
            changes_made=true
            echo "  - Updated JWT Bearer package"
        fi
        
        # Testing packages
        if [[ "$line" =~ Microsoft\.AspNetCore\.Mvc\.Testing.*[0-9]+\.[0-9]+\.[0-9]+ ]]; then
            updated_line=$(echo "$line" | sed -E 's/(Microsoft\.AspNetCore\.Mvc\.Testing)[^0-9]*[0-9]+\.[0-9]+\.[0-9]+/\1` (8.0.11)/g')
            changes_made=true
            echo "  - Updated MVC Testing package"
        fi
        
        # Update generic .NET version references
        if [[ "$line" =~ \.NET\ [567]\.0 ]]; then
            updated_line=$(echo "$line" | sed -E 's/\.NET [567]\.0/.NET 8.0/g')
            changes_made=true
            echo "  - Updated .NET version reference"
        fi
        
        # Update C# version references
        if [[ "$line" =~ C#\ (9|10|11)([^0-9]|$) ]]; then
            updated_line=$(echo "$line" | sed -E 's/C# (9|10|11)([^0-9]|$)/C# 12\2/g')
            changes_made=true
            echo "  - Updated C# version reference"
        fi
        
        echo "$updated_line"
    done < "$file" > "$temp_file"
    
    # Check if Prerequisites section exists and update it
    if grep -q "Prerequisites" "$file" && ! grep -q ".NET 8.0 SDK" "$file"; then
        # Update prerequisites section to include .NET 8.0 SDK
        awk '
        /^##.*Prerequisites/ {
            print
            getline
            print
            if ($0 ~ /^-/) {
                print "- .NET 8.0 SDK installed"
                found_dotnet = 0
                while ((getline) > 0 && $0 ~ /^-/) {
                    if ($0 !~ /\.NET [0-9]\.[0-9] SDK/) {
                        print
                    }
                }
                if ($0 !~ /^-/) print
            }
            next
        }
        { print }
        ' "$temp_file" > "${temp_file}.2"
        mv "${temp_file}.2" "$temp_file"
        changes_made=true
        echo "  - Added .NET 8.0 SDK prerequisite"
    fi
    
    # Update C# syntax to modern features
    # This is a basic example - you can expand this based on specific patterns
    if grep -q "var " "$file"; then
        # Example: Update to use target-typed new
        sed -i.tmp2 's/List<\([^>]*\)> \([a-zA-Z_][a-zA-Z0-9_]*\) = new List<\1>()/List<\1> \2 = new()/g' "$temp_file"
        sed -i.tmp2 's/Dictionary<\([^,>]*\), \([^>]*\)> \([a-zA-Z_][a-zA-Z0-9_]*\) = new Dictionary<\1, \2>()/Dictionary<\1, \2> \3 = new()/g' "$temp_file"
        rm -f "${temp_file}.tmp2"
        
        if diff -q "$temp_file" "${file}.bak" > /dev/null 2>&1; then
            :
        else
            changes_made=true
            echo "  - Updated to modern C# 12 syntax"
        fi
    fi
    
    # Move the updated file back
    mv "$temp_file" "$file"
    
    # Remove backup if no changes were made
    if [ "$changes_made" = false ]; then
        rm "${file}.bak"
        echo "  No changes needed"
    else
        ((FILES_UPDATED++))
        echo "  ✓ File updated (backup saved as ${file}.bak)"
    fi
    
    ((TOTAL_FILES++))
    echo ""
}

# Process all exercise files
for file in $EXERCISE_FILES; do
    update_file "$file"
done

# Also update README files that might contain version information
echo "Updating README files..."
find . -name "README.md" -type f | while read -r file; do
    if grep -q "\.NET [567]\.0\|C# \(9\|10\|11\)" "$file"; then
        update_file "$file"
    fi
done

echo "==============================="
echo "Update complete!"
echo "Files processed: $TOTAL_FILES"
echo "Files updated: $FILES_UPDATED"
echo ""
echo "To review changes, compare .bak files with updated files"
echo "To remove all backup files: find . -name '*.bak' -delete"