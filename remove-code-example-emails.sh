#!/bin/bash

# Script to safely remove example emails from code files
# Only updates XML documentation comments and non-functional references

echo "============================================"
echo "Safely Removing Example Emails from Code"
echo "============================================"
echo ""

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

# Counter
modified=0

echo "1. Updating XML documentation comments..."
echo "----------------------------------------"

# Update XML documentation examples in C# files
for file in $(find . -name "*.cs" -not -path "*/bin/*" -not -path "*/obj/*" -not -path "*/node_modules/*"); do
    if grep -q "<example>.*@example\.com</example>" "$file"; then
        echo -e "${YELLOW}Processing:${NC} $file"
        cp "$file" "$file.email-backup"
        
        # Replace example emails in XML comments only
        sed -i '' 's/<example>user@example\.com<\/example>/<example>user@yourdomain.com<\/example>/g' "$file"
        sed -i '' 's/<example>newuser@example\.com<\/example>/<example>newuser@yourdomain.com<\/example>/g' "$file"
        sed -i '' 's/<example>admin@example\.com<\/example>/<example>admin@yourdomain.com<\/example>/g' "$file"
        
        ((modified++))
        echo -e "  ${GREEN}✓${NC} Updated XML documentation"
    fi
done

echo ""
echo "2. Updating non-functional email references..."
echo "----------------------------------------------"

# Update email in Swagger contact info (safe to change)
swagger_files=$(find . -name "Program.cs" -not -path "*/bin/*" -not -path "*/obj/*" -not -path "*/node_modules/*")
for file in $swagger_files; do
    if grep -q "api-support@example\.com" "$file"; then
        echo -e "${YELLOW}Processing:${NC} $file"
        cp "$file" "$file.email-backup"
        
        sed -i '' 's/api-support@example\.com/api-support@yourdomain.com/g' "$file"
        
        ((modified++))
        echo -e "  ${GREEN}✓${NC} Updated Swagger contact email"
    fi
done

echo ""
echo "3. Checking functional email usage..."
echo "-------------------------------------"

# List files with functional email usage (DO NOT MODIFY)
echo -e "${RED}The following files contain functional email data (NOT modified):${NC}"

# Check seed data
if grep -l "@example\.com" Module04-Authentication-and-Authorization/SourceCode/JwtAuthenticationAPI/Services/UserService.cs 2>/dev/null; then
    echo "  - Module04: UserService.cs (seed data for authentication)"
fi

if grep -l "@example\.com" Module13-Building-Microservices/SourceCode/ECommerceMS/CustomerService/Data/CustomerDbContext.cs 2>/dev/null; then
    echo "  - Module13: CustomerDbContext.cs (seed data for customers)"
fi

if grep -l "@example\.com" Module07-Testing-Applications/SourceCode/ProductCatalog.IntegrationTests/CustomWebApplicationFactory.cs 2>/dev/null; then
    echo "  - Module07: CustomWebApplicationFactory.cs (test data)"
fi

if grep -l "@example\.com" Module08-Performance-Optimization/Exercises/Solutions/Exercise02-Database-Solution/Program.cs 2>/dev/null; then
    echo "  - Module08: Exercise solution (data generation)"
fi

echo ""
echo "============================================"
echo "Summary"
echo "============================================"
echo -e "${GREEN}Safely modified $modified files${NC}"
echo -e "${YELLOW}Preserved functional email data in seed/test files${NC}"
echo ""
echo "Backup files created with .email-backup extension"
echo ""
echo "To restore original files:"
echo "  find . -name '*.email-backup' -exec sh -c 'mv {} \${0%.email-backup}' {} \;"
echo ""
echo -e "${GREEN}✓ All changes are safe and won't affect build/runtime${NC}"