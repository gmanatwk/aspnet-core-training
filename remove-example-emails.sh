#!/bin/bash

# Script to replace example.com emails with appropriate placeholders
# in C# source files, JSON files, and XML files

echo "Starting email replacement process..."

# Counter for tracking replacements
total_replacements=0

# Function to process files
process_file() {
    local file="$1"
    local temp_file="${file}.tmp"
    
    # Check if file exists and is readable
    if [[ ! -r "$file" ]]; then
        return
    fi
    
    # Count occurrences before replacement
    local count=$(grep -o '[a-zA-Z0-9._%+-]*@example\.com' "$file" 2>/dev/null | wc -l)
    
    if [[ $count -gt 0 ]]; then
        echo "Processing: $file (found $count example.com emails)"
        
        # Create a temporary file with replacements
        # Replace various patterns of example.com emails
        sed -E \
            -e 's/([a-zA-Z0-9._%+-]+)@example\.com/\1@yourdomain.com/g' \
            -e 's/user@example\.com/user@yourdomain.com/g' \
            -e 's/admin@example\.com/admin@yourdomain.com/g' \
            -e 's/test@example\.com/test@yourdomain.com/g' \
            -e 's/noreply@example\.com/noreply@yourdomain.com/g' \
            -e 's/support@example\.com/support@yourdomain.com/g' \
            -e 's/info@example\.com/info@yourdomain.com/g' \
            -e 's/contact@example\.com/contact@yourdomain.com/g' \
            -e 's/email@example\.com/email@yourdomain.com/g' \
            "$file" > "$temp_file"
        
        # Check if sed was successful
        if [[ $? -eq 0 ]]; then
            # Replace original file with processed file
            mv "$temp_file" "$file"
            total_replacements=$((total_replacements + count))
        else
            echo "Error processing $file"
            rm -f "$temp_file"
        fi
    fi
}

# Find and process all C# files (.cs)
echo -e "\nProcessing C# files..."
find . -type f -name "*.cs" ! -path "*/bin/*" ! -path "*/obj/*" | while read -r file; do
    process_file "$file"
done

# Find and process all JSON files
echo -e "\nProcessing JSON files..."
find . -type f -name "*.json" ! -path "*/bin/*" ! -path "*/obj/*" | while read -r file; do
    process_file "$file"
done

# Find and process all XML files
echo -e "\nProcessing XML files..."
find . -type f -name "*.xml" ! -path "*/bin/*" ! -path "*/obj/*" | while read -r file; do
    process_file "$file"
done

# Also process .csproj files (which are XML)
echo -e "\nProcessing .csproj files..."
find . -type f -name "*.csproj" ! -path "*/bin/*" ! -path "*/obj/*" | while read -r file; do
    process_file "$file"
done

# Also process .config files
echo -e "\nProcessing .config files..."
find . -type f -name "*.config" ! -path "*/bin/*" ! -path "*/obj/*" | while read -r file; do
    process_file "$file"
done

echo -e "\nEmail replacement complete!"
echo "Total replacements made: $total_replacements"

# Optional: Create a summary of all files that were modified
echo -e "\nCreating modification summary..."
find . -type f \( -name "*.cs" -o -name "*.json" -o -name "*.xml" -o -name "*.csproj" -o -name "*.config" \) \
    ! -path "*/bin/*" ! -path "*/obj/*" \
    -exec grep -l '@yourdomain\.com' {} \; > modified_files.txt

if [[ -s modified_files.txt ]]; then
    echo "List of modified files saved to: modified_files.txt"
    echo "Total files modified: $(wc -l < modified_files.txt)"
else
    rm -f modified_files.txt
    echo "No files were modified."
fi