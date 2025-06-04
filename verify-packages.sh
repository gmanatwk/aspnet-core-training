#!/bin/bash

# Package Version Verification Script
# Run this script in your project directory to verify package versions

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔍 Verifying Package Versions${NC}"
echo "=================================="

# Expected versions (package:version format)
EXPECTED_PACKAGES=(
    "Microsoft.AspNetCore.Authentication.JwtBearer:8.0.11"
    "Microsoft.AspNetCore.Identity.EntityFrameworkCore:8.0.11"
    "Microsoft.AspNetCore.OpenApi:8.0.11"
    "Microsoft.EntityFrameworkCore.InMemory:8.0.11"
    "Microsoft.EntityFrameworkCore.Tools:8.0.11"
    "System.IdentityModel.Tokens.Jwt:8.0.2"
    "Swashbuckle.AspNetCore:6.8.1"
)

# Check if project file exists
PROJECT_FILE=$(ls *.csproj 2>/dev/null | head -1)
if [ -z "$PROJECT_FILE" ]; then
    echo -e "${RED}❌ No .csproj file found in current directory${NC}"
    exit 1
fi
echo -e "📁 Checking project: ${BLUE}$PROJECT_FILE${NC}"
echo ""

# Function to check package version
check_package() {
    local package_name=$1
    local expected_version=$2
    
    # Extract version from project file
    local actual_version=$(grep -o "PackageReference.*$package_name.*Version=\"[^\"]*\"" "$PROJECT_FILE" | grep -o 'Version="[^"]*"' | cut -d'"' -f2)
    
    if [ -z "$actual_version" ]; then
        echo -e "${RED}❌ $package_name: NOT FOUND${NC}"
        return 1
    elif [ "$actual_version" = "$expected_version" ]; then
        echo -e "${GREEN}✅ $package_name: $actual_version${NC}"
        return 0
    else
        echo -e "${YELLOW}⚠️  $package_name: $actual_version (expected: $expected_version)${NC}"
        return 1
    fi
}

# Check .NET version
echo -e "${BLUE}🎯 Checking .NET Target Framework${NC}"
TARGET_FRAMEWORK=$(grep -o '<TargetFramework>[^<]*</TargetFramework>' "$PROJECT_FILE" | sed 's/<[^>]*>//g')
if [ "$TARGET_FRAMEWORK" = "net8.0" ]; then
    echo -e "${GREEN}✅ Target Framework: $TARGET_FRAMEWORK${NC}"
else
    echo -e "${RED}❌ Target Framework: $TARGET_FRAMEWORK (expected: net8.0)${NC}"
fi
echo ""

# Check package versions
echo -e "${BLUE}📦 Checking Package Versions${NC}"
all_correct=true

for package_entry in "${EXPECTED_PACKAGES[@]}"; do
    package_name=$(echo "$package_entry" | cut -d':' -f1)
    expected_version=$(echo "$package_entry" | cut -d':' -f2)

    if ! check_package "$package_name" "$expected_version"; then
        all_correct=false
    fi
done

echo ""

# Summary
if [ "$all_correct" = true ]; then
    echo -e "${GREEN}🎉 All package versions are correct!${NC}"
    exit 0
else
    echo -e "${RED}❌ Some packages have incorrect versions${NC}"
    echo ""
    echo -e "${YELLOW}💡 To fix package versions, run:${NC}"
    echo ""
    for package_entry in "${EXPECTED_PACKAGES[@]}"; do
        package_name=$(echo "$package_entry" | cut -d':' -f1)
        expected_version=$(echo "$package_entry" | cut -d':' -f2)
        echo "dotnet add package $package_name --version $expected_version"
    done
    echo ""
    exit 1
fi
