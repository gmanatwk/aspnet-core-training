#!/bin/bash

# Complete Module 04 verification script

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

ERRORS=0

echo -e "${BLUE}🔍 Complete Module 04 Verification${NC}"
echo "=================================="

# Check 1: All exercises exist
echo -e "${BLUE}1. Checking exercise files...${NC}"
exercises=(
    "Module04-Authentication-and-Authorization/Exercises/Exercise01-JWT-Implementation.md"
    "Module04-Authentication-and-Authorization/Exercises/Exercise02-Role-Based-Authorization.md"
    "Module04-Authentication-and-Authorization/Exercises/Exercise03-Custom-Authorization-Policies.md"
)

for exercise in "${exercises[@]}"; do
    if [ -f "$exercise" ]; then
        echo -e "${GREEN}✅ $(basename $exercise)${NC}"
    else
        echo -e "${RED}❌ Missing: $(basename $exercise)${NC}"
        ((ERRORS++))
    fi
done

# Check 2: Source code exists and builds
echo -e "${BLUE}2. Checking source code...${NC}"
SOURCE_DIR="Module04-Authentication-and-Authorization/SourceCode/JwtAuthenticationAPI"
if [ -d "$SOURCE_DIR" ]; then
    echo -e "${GREEN}✅ Source code directory exists${NC}"
    
    cd "$SOURCE_DIR"
    if dotnet build > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Source code builds successfully${NC}"
    else
        echo -e "${RED}❌ Source code build failed${NC}"
        ((ERRORS++))
    fi
    cd - > /dev/null
else
    echo -e "${RED}❌ Source code directory not found${NC}"
    ((ERRORS++))
fi

# Check 3: Setup script works
echo -e "${BLUE}3. Testing setup script...${NC}"
rm -rf JwtAuthenticationAPI
if ./setup-exercise.sh module04-exercise01-jwt > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Setup script works${NC}"
    
    cd JwtAuthenticationAPI
    if dotnet build > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Generated project builds${NC}"
    else
        echo -e "${RED}❌ Generated project build failed${NC}"
        ((ERRORS++))
    fi
    cd ..
    rm -rf JwtAuthenticationAPI
else
    echo -e "${RED}❌ Setup script failed${NC}"
    ((ERRORS++))
fi

# Check 4: Exercise content verification
echo -e "${BLUE}4. Checking exercise content...${NC}"

# Exercise 1 - JWT Implementation
echo -n "  Exercise 1: "
ex1_blocks=$(grep -c '```csharp' "Module04-Authentication-and-Authorization/Exercises/Exercise01-JWT-Implementation.md" 2>/dev/null || echo 0)
if [ "$ex1_blocks" -ge 6 ]; then
    echo -e "${GREEN}✅ $ex1_blocks code blocks${NC}"
else
    echo -e "${RED}❌ Insufficient code blocks: $ex1_blocks${NC}"
    ((ERRORS++))
fi

# Exercise 2 - Role-Based Authorization
echo -n "  Exercise 2: "
ex2_blocks=$(grep -c '```csharp' "Module04-Authentication-and-Authorization/Exercises/Exercise02-Role-Based-Authorization.md" 2>/dev/null || echo 0)
if [ "$ex2_blocks" -ge 4 ]; then
    echo -e "${GREEN}✅ $ex2_blocks code blocks${NC}"
else
    echo -e "${RED}❌ Insufficient code blocks: $ex2_blocks${NC}"
    ((ERRORS++))
fi

# Exercise 3 - Custom Authorization Policies
echo -n "  Exercise 3: "
ex3_blocks=$(grep -c '```csharp' "Module04-Authentication-and-Authorization/Exercises/Exercise03-Custom-Authorization-Policies.md" 2>/dev/null || echo 0)
if [ "$ex3_blocks" -ge 8 ]; then
    echo -e "${GREEN}✅ $ex3_blocks code blocks${NC}"
else
    echo -e "${RED}❌ Insufficient code blocks: $ex3_blocks${NC}"
    ((ERRORS++))
fi

# Check 5: Key concepts coverage
echo -e "${BLUE}5. Checking key concepts...${NC}"

# JWT concepts
jwt_concepts=("JwtTokenService" "AuthController" "LoginRequest" "LoginResponse")
for concept in "${jwt_concepts[@]}"; do
    if grep -q "$concept" "Module04-Authentication-and-Authorization/Exercises/Exercise01-JWT-Implementation.md"; then
        echo -e "${GREEN}✅ JWT: $concept${NC}"
    else
        echo -e "${RED}❌ Missing JWT concept: $concept${NC}"
        ((ERRORS++))
    fi
done

# Role-based concepts
role_concepts=("AdminController" "EditorController" "UsersController" "Policy")
for concept in "${role_concepts[@]}"; do
    if grep -q "$concept" "Module04-Authentication-and-Authorization/Exercises/Exercise02-Role-Based-Authorization.md"; then
        echo -e "${GREEN}✅ Roles: $concept${NC}"
    else
        echo -e "${RED}❌ Missing role concept: $concept${NC}"
        ((ERRORS++))
    fi
done

# Custom policy concepts
policy_concepts=("MinimumAgeRequirement" "DepartmentRequirement" "WorkingHoursRequirement" "PolicyController")
for concept in "${policy_concepts[@]}"; do
    if grep -q "$concept" "Module04-Authentication-and-Authorization/Exercises/Exercise03-Custom-Authorization-Policies.md"; then
        echo -e "${GREEN}✅ Policies: $concept${NC}"
    else
        echo -e "${RED}❌ Missing policy concept: $concept${NC}"
        ((ERRORS++))
    fi
done

# Check 6: Template files
echo -e "${BLUE}6. Checking template files...${NC}"
template_files=(
    "Module04-Authentication-and-Authorization/Templates/JwtAuthExercise.csproj"
    "Module04-Authentication-and-Authorization/Templates/appsettings.json"
)

for template in "${template_files[@]}"; do
    if [ -f "$template" ]; then
        echo -e "${GREEN}✅ $(basename $template)${NC}"
        
        # Check JWT config in appsettings.json
        if [[ "$template" == *"appsettings.json" ]]; then
            if grep -q '"ExpiryMinutes": 60' "$template"; then
                echo -e "${GREEN}✅ JWT configuration correct${NC}"
            else
                echo -e "${RED}❌ JWT configuration issue${NC}"
                ((ERRORS++))
            fi
        fi
    else
        echo -e "${RED}❌ Missing template: $(basename $template)${NC}"
        ((ERRORS++))
    fi
done

# Summary
echo ""
echo "=================================="
if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}🎉 Module 04 is completely aligned!${NC}"
    echo ""
    echo -e "${GREEN}✅ All 3 exercises have complete code blocks${NC}"
    echo -e "${GREEN}✅ Setup script works correctly${NC}"
    echo -e "${GREEN}✅ Source code builds successfully${NC}"
    echo -e "${GREEN}✅ All key concepts covered${NC}"
    echo -e "${GREEN}✅ Template files configured correctly${NC}"
    echo ""
    echo -e "${BLUE}📚 Students can now:${NC}"
    echo "  1. Complete Exercise 1: JWT Implementation"
    echo "  2. Complete Exercise 2: Role-Based Authorization"
    echo "  3. Complete Exercise 3: Custom Authorization Policies"
    echo "  4. Build and test a complete authentication system"
    echo ""
    echo -e "${GREEN}✅ MODULE 04 READY FOR CLASS USE${NC}"
else
    echo -e "${RED}❌ Found $ERRORS issues in Module 04${NC}"
    echo -e "${YELLOW}⚠️  Module 04 needs more alignment work${NC}"
fi

exit $ERRORS
