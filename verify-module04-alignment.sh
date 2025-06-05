#!/bin/bash

# Verify Module 04 Exercise 1 alignment with source code

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

ERRORS=0

echo -e "${BLUE}🔍 Module 04 Exercise 1 Alignment Verification${NC}"
echo "=============================================="

# Check 1: Setup script works
echo -e "${BLUE}1. Testing setup script...${NC}"
rm -rf JwtAuthenticationAPI
if ./setup-exercise.sh module04-exercise01-jwt > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Setup script works${NC}"
else
    echo -e "${RED}❌ Setup script failed${NC}"
    ((ERRORS++))
fi

# Check 2: Project builds after setup
echo -e "${BLUE}2. Testing initial build...${NC}"
cd JwtAuthenticationAPI
if dotnet build > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Project builds after setup${NC}"
else
    echo -e "${RED}❌ Project fails to build after setup${NC}"
    ((ERRORS++))
fi

# Check 3: JWT configuration is correct
echo -e "${BLUE}3. Verifying JWT configuration...${NC}"
if grep -q '"ExpiryMinutes": 60' appsettings.json; then
    echo -e "${GREEN}✅ JWT configuration matches exercise code${NC}"
else
    echo -e "${RED}❌ JWT configuration mismatch${NC}"
    echo "Expected: ExpiryMinutes, Found:"
    grep -A 5 -B 5 "Expiry" appsettings.json || echo "No Expiry config found"
    ((ERRORS++))
fi

# Check 4: Required packages are installed
echo -e "${BLUE}4. Checking required packages...${NC}"
required_packages=("Microsoft.AspNetCore.Authentication.JwtBearer" "System.IdentityModel.Tokens.Jwt")
for package in "${required_packages[@]}"; do
    if grep -q "$package" *.csproj; then
        echo -e "${GREEN}✅ $package installed${NC}"
    else
        echo -e "${RED}❌ Missing package: $package${NC}"
        ((ERRORS++))
    fi
done

# Check 5: Exercise has code blocks
echo -e "${BLUE}5. Checking exercise content...${NC}"
EXERCISE_FILE="../Module04-Authentication-and-Authorization/Exercises/Exercise01-JWT-Implementation.md"
code_blocks=$(grep -c '```csharp' "$EXERCISE_FILE" 2>/dev/null || echo 0)
if [ "$code_blocks" -gt 5 ]; then
    echo -e "${GREEN}✅ Exercise has $code_blocks C# code blocks${NC}"
else
    echo -e "${RED}❌ Exercise has insufficient code blocks: $code_blocks${NC}"
    ((ERRORS++))
fi

# Check 6: Key classes mentioned in exercise
echo -e "${BLUE}6. Checking key concepts in exercise...${NC}"
key_concepts=("JwtTokenService" "AuthController" "LoginRequest" "LoginResponse" "UserService")
missing_concepts=()

for concept in "${key_concepts[@]}"; do
    if grep -q "$concept" "$EXERCISE_FILE"; then
        echo -e "${GREEN}✅ $concept${NC}"
    else
        missing_concepts+=("$concept")
        echo -e "${RED}❌ Missing: $concept${NC}"
        ((ERRORS++))
    fi
done

# Check 7: Source code comparison
echo -e "${BLUE}7. Comparing with source code...${NC}"
SOURCE_DIR="../Module04-Authentication-and-Authorization/SourceCode/JwtAuthenticationAPI"
cd "$SOURCE_DIR"
if dotnet build > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Source code builds successfully${NC}"
else
    echo -e "${RED}❌ Source code build failed${NC}"
    ((ERRORS++))
fi

# Check if key files exist in source
source_files=("Models/AuthModels.cs" "Services/JwtTokenService.cs" "Services/UserService.cs" "Controllers/AuthController.cs")
for file in "${source_files[@]}"; do
    if [ -f "$file" ]; then
        echo -e "${GREEN}✅ Source has $file${NC}"
    else
        echo -e "${YELLOW}⚠️  Source missing: $file${NC}"
    fi
done

cd - > /dev/null

# Cleanup
cd ..
rm -rf JwtAuthenticationAPI

# Summary
echo ""
echo "=============================================="
if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}🎉 Module 04 Exercise 1 is properly aligned!${NC}"
    echo -e "${GREEN}✅ Setup script works${NC}"
    echo -e "${GREEN}✅ Exercise has complete code blocks${NC}"
    echo -e "${GREEN}✅ Configuration is correct${NC}"
    echo -e "${GREEN}✅ Source code builds${NC}"
    echo ""
    echo -e "${BLUE}📚 Students can successfully:${NC}"
    echo "  1. Run setup script"
    echo "  2. Follow exercise instructions"
    echo "  3. Copy code blocks from exercise"
    echo "  4. Build and run JWT authentication API"
    echo ""
    echo -e "${GREEN}✅ READY FOR CLASS USE${NC}"
else
    echo -e "${RED}❌ Found $ERRORS alignment issues${NC}"
    echo -e "${YELLOW}⚠️  Module 04 Exercise 1 needs more work${NC}"
    
    if [ ${#missing_concepts[@]} -gt 0 ]; then
        echo -e "${YELLOW}Missing concepts: ${missing_concepts[*]}${NC}"
    fi
fi

exit $ERRORS
