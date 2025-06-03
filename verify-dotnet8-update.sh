#!/bin/bash

# Script to verify that all exercise files have been properly updated to .NET 8.0
# This script checks for any remaining outdated references

echo "Verifying .NET 8.0 update..."
echo "============================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Counters
ISSUES_FOUND=0
FILES_CHECKED=0

# Function to check a file for outdated references
check_file() {
    local file="$1"
    local issues=""
    
    ((FILES_CHECKED++))
    
    # Check for old .NET versions
    if grep -q "\.NET [567]\.0" "$file"; then
        issues="${issues}Found old .NET version reference\n"
        ((ISSUES_FOUND++))
    fi
    
    # Check for old C# versions
    if grep -q "C# \(9\|10\|11\)" "$file"; then
        issues="${issues}Found old C# version reference\n"
        ((ISSUES_FOUND++))
    fi
    
    # Check for dotnet new without --framework
    if grep -E "dotnet new \w+ -n \w+" "$file" | grep -v "\-\-framework" > /dev/null; then
        issues="${issues}Found 'dotnet new' command without --framework flag\n"
        ((ISSUES_FOUND++))
    fi
    
    # Check for old target framework
    if grep -q "<TargetFramework>net[567]\.0</TargetFramework>" "$file"; then
        issues="${issues}Found old target framework in csproj example\n"
        ((ISSUES_FOUND++))
    fi
    
    # Check for missing .NET 8.0 SDK prerequisite
    if grep -q "Prerequisites" "$file" && ! grep -q "\.NET 8\.0 SDK" "$file"; then
        issues="${issues}Missing .NET 8.0 SDK in prerequisites\n"
        ((ISSUES_FOUND++))
    fi
    
    # Check for outdated package versions (sampling common ones)
    if grep -q "Microsoft\.EntityFrameworkCore.*[567]\.0\." "$file"; then
        issues="${issues}Found outdated Entity Framework Core package version\n"
        ((ISSUES_FOUND++))
    fi
    
    if grep -q "Microsoft\.AspNetCore\.Authentication\.JwtBearer.*[567]\.0\." "$file"; then
        issues="${issues}Found outdated JWT Bearer package version\n"
        ((ISSUES_FOUND++))
    fi
    
    # Report issues for this file
    if [ -n "$issues" ]; then
        echo -e "${RED}✗ Issues found in: $file${NC}"
        echo -e "${YELLOW}$issues${NC}"
    else
        echo -e "${GREEN}✓ $file${NC}"
    fi
}

# Find all markdown files to check
echo "Checking exercise files..."
find . -path "*/Exercises/*.md" -type f | while read -r file; do
    check_file "$file"
done

echo ""
echo "Checking README files..."
find . -name "README.md" -type f | while read -r file; do
    check_file "$file"
done

echo ""
echo "Checking resource files..."
find . -path "*/Resources/*.md" -type f | while read -r file; do
    check_file "$file"
done

# Summary
echo ""
echo "============================"
echo "Verification Summary"
echo "============================"
echo "Files checked: $FILES_CHECKED"

if [ $ISSUES_FOUND -eq 0 ]; then
    echo -e "${GREEN}✓ All files are properly updated to .NET 8.0!${NC}"
else
    echo -e "${RED}✗ Found $ISSUES_FOUND issues that need attention${NC}"
    echo ""
    echo "Run the update script to fix these issues:"
    echo "  ./update-to-dotnet8.sh"
fi

# Generate detailed report
REPORT_FILE="dotnet8-verification-report.txt"
echo "" > "$REPORT_FILE"
echo ".NET 8.0 Verification Report" >> "$REPORT_FILE"
echo "Generated: $(date)" >> "$REPORT_FILE"
echo "============================" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

echo "Checking for specific patterns..." >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

echo "Files with old .NET versions:" >> "$REPORT_FILE"
grep -l "\.NET [567]\.0" $(find . -name "*.md" -type f) 2>/dev/null >> "$REPORT_FILE" || echo "None found" >> "$REPORT_FILE"

echo "" >> "$REPORT_FILE"
echo "Files with old C# versions:" >> "$REPORT_FILE"
grep -l "C# \(9\|10\|11\)" $(find . -name "*.md" -type f) 2>/dev/null >> "$REPORT_FILE" || echo "None found" >> "$REPORT_FILE"

echo "" >> "$REPORT_FILE"
echo "Files with dotnet new missing --framework:" >> "$REPORT_FILE"
grep -l "dotnet new.*-n" $(find . -name "*.md" -type f) 2>/dev/null | while read -r file; do
    if ! grep -q "dotnet new.*--framework" "$file"; then
        echo "$file" >> "$REPORT_FILE"
    fi
done

echo ""
echo "Detailed report saved to: $REPORT_FILE"