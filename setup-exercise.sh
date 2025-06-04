#!/bin/bash

# Exercise Setup Script
# Usage: ./setup-exercise.sh <exercise-name>

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

if [ $# -eq 0 ]; then
    echo -e "${RED}❌ Usage: $0 <exercise-name>${NC}"
    echo "Available exercises:"
    echo "  Module 3:"
    echo "    - exercise01-basic-api"
    echo "    - exercise02-authentication"
    echo "    - exercise03-documentation"
    echo "  Module 4:"
    echo "    - module04-exercise01-jwt"
    exit 1
fi

EXERCISE_NAME=$1

# Set project name based on exercise
case $EXERCISE_NAME in
    "module04-exercise01-jwt")
        PROJECT_NAME="JwtAuthExercise"
        ;;
    *)
        PROJECT_NAME="LibraryAPI"
        ;;
esac

echo -e "${BLUE}🚀 Setting up $EXERCISE_NAME${NC}"
echo "=================================="

# Step 1: Create project
echo -n "1. Creating Web API project... "
if dotnet new webapi -n "$PROJECT_NAME" --framework net8.0 > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗${NC}"
    exit 1
fi

cd "$PROJECT_NAME"

# Step 2: Copy the correct project file template
echo -n "2. Applying package versions... "

# Determine template path based on exercise
TEMPLATE_PATH=""
case $EXERCISE_NAME in
    "module04-exercise01-jwt")
        TEMPLATE_PATH="../Module04-Authentication-and-Authorization/Templates/JwtAuthExercise.csproj"
        ;;
    *)
        TEMPLATE_PATH="../Module03-Working-with-Web-APIs/Templates/LibraryAPI.csproj"
        ;;
esac

if [ -f "$TEMPLATE_PATH" ]; then
    cp "$TEMPLATE_PATH" "./$PROJECT_NAME.csproj"

    # Copy appsettings.json if it exists for this exercise
    APPSETTINGS_PATH=""
    case $EXERCISE_NAME in
        "module04-exercise01-jwt")
            APPSETTINGS_PATH="../Module04-Authentication-and-Authorization/Templates/appsettings.json"
            ;;
    esac

    if [ -f "$APPSETTINGS_PATH" ]; then
        cp "$APPSETTINGS_PATH" "./appsettings.json"
    fi

    echo -e "${GREEN}✓${NC}"
else
    echo -e "${YELLOW}⚠️  Template not found, using manual package installation${NC}"
    
    # Install packages with specific versions
    case $EXERCISE_NAME in
        "exercise01-basic-api")
            dotnet add package Microsoft.EntityFrameworkCore.InMemory --version 8.0.11 > /dev/null 2>&1
            dotnet add package Swashbuckle.AspNetCore --version 6.8.1 > /dev/null 2>&1
            ;;
        "exercise02-authentication")
            dotnet add package Microsoft.EntityFrameworkCore.InMemory --version 8.0.11 > /dev/null 2>&1
            dotnet add package Microsoft.AspNetCore.Authentication.JwtBearer --version 8.0.11 > /dev/null 2>&1
            dotnet add package Microsoft.AspNetCore.Identity.EntityFrameworkCore --version 8.0.11 > /dev/null 2>&1
            dotnet add package System.IdentityModel.Tokens.Jwt --version 8.0.2 > /dev/null 2>&1
            dotnet add package Swashbuckle.AspNetCore --version 6.8.1 > /dev/null 2>&1
            ;;
        "exercise03-documentation")
            dotnet add package Microsoft.EntityFrameworkCore.InMemory --version 8.0.11 > /dev/null 2>&1
            dotnet add package Microsoft.AspNetCore.Authentication.JwtBearer --version 8.0.11 > /dev/null 2>&1
            dotnet add package Microsoft.AspNetCore.Identity.EntityFrameworkCore --version 8.0.11 > /dev/null 2>&1
            dotnet add package System.IdentityModel.Tokens.Jwt --version 8.0.2 > /dev/null 2>&1
            dotnet add package Swashbuckle.AspNetCore --version 6.8.1 > /dev/null 2>&1
            dotnet add package Swashbuckle.AspNetCore.Annotations --version 6.8.1 > /dev/null 2>&1
            dotnet add package Asp.Versioning.Mvc --version 8.0.0 > /dev/null 2>&1
            dotnet add package Asp.Versioning.Mvc.ApiExplorer --version 8.0.0 > /dev/null 2>&1
            dotnet add package AspNetCore.HealthChecks.UI --version 8.0.2 > /dev/null 2>&1
            dotnet add package AspNetCore.HealthChecks.UI.Client --version 8.0.2 > /dev/null 2>&1
            dotnet add package AspNetCore.HealthChecks.UI.InMemory.Storage --version 8.0.2 > /dev/null 2>&1
            ;;
        "module04-exercise01-jwt")
            dotnet add package Microsoft.AspNetCore.Authentication.JwtBearer --version 8.0.11 > /dev/null 2>&1
            dotnet add package System.IdentityModel.Tokens.Jwt --version 8.0.2 > /dev/null 2>&1
            dotnet add package Microsoft.IdentityModel.Tokens --version 8.0.2 > /dev/null 2>&1
            dotnet add package Swashbuckle.AspNetCore --version 6.8.1 > /dev/null 2>&1
            ;;
    esac
    echo -e "${GREEN}✓${NC}"
fi

# Step 3: Restore packages
echo -n "3. Restoring packages... "
if dotnet restore > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗${NC}"
    exit 1
fi

# Step 4: Verify build
echo -n "4. Verifying build... "
if dotnet build --nologo --verbosity quiet > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗${NC}"
    echo "Build failed. Check the output:"
    dotnet build --nologo --verbosity minimal
    exit 1
fi

# Step 5: Run package verification
echo -n "5. Verifying package versions... "
if [ -f "../verify-packages.sh" ]; then
    if ../verify-packages.sh > /dev/null 2>&1; then
        echo -e "${GREEN}✓${NC}"
    else
        echo -e "${YELLOW}⚠️  Some package versions may be incorrect${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  Verification script not found${NC}"
fi

echo ""
echo -e "${GREEN}🎉 Exercise setup complete!${NC}"
echo -e "📁 Project created in: ${BLUE}$(pwd)${NC}"
echo ""
echo -e "${YELLOW}💡 Next steps:${NC}"
echo "1. Follow the exercise instructions"
echo "2. Run '../verify-packages.sh' to check package versions"
echo "3. Run 'dotnet run' to start the application"
echo ""
