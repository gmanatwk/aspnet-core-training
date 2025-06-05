#!/bin/bash

# Quick test of Module 04 Exercise 1

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🔍 Quick Module 04 Test${NC}"
echo "======================="

# Clean up
rm -rf JwtAuthenticationAPI

# Test setup
echo -e "${BLUE}1. Testing setup...${NC}"
./setup-exercise.sh module04-exercise01-jwt > /dev/null 2>&1

cd JwtAuthenticationAPI

# Test build
echo -e "${BLUE}2. Testing build...${NC}"
if dotnet build > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Project builds${NC}"
else
    echo -e "${RED}❌ Build failed${NC}"
    exit 1
fi

# Check appsettings.json
echo -e "${BLUE}3. Checking JWT configuration...${NC}"
if grep -q "ExpiryMinutes" appsettings.json; then
    echo -e "${GREEN}✅ JWT config correct${NC}"
else
    echo -e "${RED}❌ JWT config issue${NC}"
    cat appsettings.json
fi

# Test source code comparison
echo -e "${BLUE}4. Comparing with source code...${NC}"
SOURCE_DIR="../Module04-Authentication-and-Authorization/SourceCode/JwtAuthenticationAPI"

if [ -f "$SOURCE_DIR/Models/AuthModels.cs" ]; then
    echo -e "${GREEN}✅ Source code exists${NC}"
    
    # Check if source builds
    cd "$SOURCE_DIR"
    if dotnet build > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Source code builds${NC}"
    else
        echo -e "${RED}❌ Source code build failed${NC}"
    fi
    cd - > /dev/null
else
    echo -e "${RED}❌ Source code not found${NC}"
fi

cd ..
rm -rf JwtAuthenticationAPI

echo -e "${GREEN}✅ Quick test complete${NC}"
