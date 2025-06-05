#!/bin/bash

# Verify Module 04 exercises alignment with source code

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SOURCE_CODE_DIR="Module04-Authentication-and-Authorization/SourceCode/JwtAuthenticationAPI"
EXERCISE_DIR="Module04-Authentication-and-Authorization/Exercises"
ERRORS=0

echo -e "${BLUE}🔍 Verifying Module 04 Exercise Alignment${NC}"
echo "=========================================="

# Check if source code exists
if [ ! -d "$SOURCE_CODE_DIR" ]; then
    echo -e "${RED}❌ Source code directory not found: $SOURCE_CODE_DIR${NC}"
    exit 1
fi

# Check if exercises exist
if [ ! -d "$EXERCISE_DIR" ]; then
    echo -e "${RED}❌ Exercise directory not found: $EXERCISE_DIR${NC}"
    exit 1
fi

echo -e "${BLUE}📁 Found directories:${NC}"
echo "  Source Code: $SOURCE_CODE_DIR"
echo "  Exercises: $EXERCISE_DIR"
echo ""

# Test 1: Check if setup script works for Module 04
echo -e "${BLUE}1. Testing setup script for Module 04...${NC}"
if ./setup-exercise.sh module04-exercise01-jwt > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Setup script works${NC}"
    
    # Check if project builds
    if [ -d "JwtAuthenticationAPI" ]; then
        cd JwtAuthenticationAPI
        if dotnet build > /dev/null 2>&1; then
            echo -e "${GREEN}✅ Generated project builds successfully${NC}"
        else
            echo -e "${RED}❌ Generated project fails to build${NC}"
            ((ERRORS++))
        fi
        cd ..
        rm -rf JwtAuthenticationAPI
    else
        echo -e "${RED}❌ Project directory not created${NC}"
        ((ERRORS++))
    fi
else
    echo -e "${RED}❌ Setup script failed${NC}"
    ((ERRORS++))
fi

# Test 2: Check source code builds
echo -e "${BLUE}2. Testing source code builds...${NC}"
cd "$SOURCE_CODE_DIR"
if dotnet build > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Source code builds successfully${NC}"
else
    echo -e "${RED}❌ Source code fails to build${NC}"
    ((ERRORS++))
fi
cd - > /dev/null

# Test 3: Check key files exist in source code
echo -e "${BLUE}3. Checking key files in source code...${NC}"
key_files=(
    "Controllers/AuthController.cs"
    "Controllers/UsersController.cs"
    "Models/User.cs"
    "Models/LoginRequest.cs"
    "Models/RegisterRequest.cs"
    "Services/JwtService.cs"
    "Program.cs"
)

for file in "${key_files[@]}"; do
    if [ -f "$SOURCE_CODE_DIR/$file" ]; then
        echo -e "${GREEN}✅ $file${NC}"
    else
        echo -e "${RED}❌ Missing: $file${NC}"
        ((ERRORS++))
    fi
done

# Test 4: Check exercises reference key concepts
echo -e "${BLUE}4. Checking exercise content...${NC}"
exercises=(
    "Exercise01-JWT-Implementation.md"
    "Exercise02-Role-Based-Authorization.md"
    "Exercise03-Custom-Authorization-Policies.md"
)

key_concepts=(
    "JwtService"
    "AuthController"
    "JWT"
    "Bearer"
    "Authorization"
    "Claims"
)

for exercise in "${exercises[@]}"; do
    if [ -f "$EXERCISE_DIR/$exercise" ]; then
        echo -n "  Checking $exercise... "
        missing_concepts=()
        
        for concept in "${key_concepts[@]}"; do
            if ! grep -q "$concept" "$EXERCISE_DIR/$exercise"; then
                missing_concepts+=("$concept")
            fi
        done
        
        if [ ${#missing_concepts[@]} -eq 0 ]; then
            echo -e "${GREEN}✅${NC}"
        else
            echo -e "${YELLOW}⚠️  Missing concepts: ${missing_concepts[*]}${NC}"
        fi
    else
        echo -e "${RED}❌ Exercise not found: $exercise${NC}"
        ((ERRORS++))
    fi
done

# Test 5: Check if exercises have code blocks
echo -e "${BLUE}5. Checking for code blocks in exercises...${NC}"
for exercise in "${exercises[@]}"; do
    if [ -f "$EXERCISE_DIR/$exercise" ]; then
        code_blocks=$(grep -c '```csharp' "$EXERCISE_DIR/$exercise" || echo 0)
        echo "  $exercise: $code_blocks code blocks"
        
        if [ "$code_blocks" -eq 0 ]; then
            echo -e "${YELLOW}⚠️  No C# code blocks found in $exercise${NC}"
        fi
    fi
done

# Test 6: Check template files
echo -e "${BLUE}6. Checking template files...${NC}"
template_files=(
    "Module04-Authentication-and-Authorization/Templates/JwtAuthExercise.csproj"
    "Module04-Authentication-and-Authorization/Templates/appsettings.json"
)

for template in "${template_files[@]}"; do
    if [ -f "$template" ]; then
        echo -e "${GREEN}✅ $(basename $template)${NC}"
    else
        echo -e "${RED}❌ Missing template: $(basename $template)${NC}"
        ((ERRORS++))
    fi
done

# Summary
echo ""
echo "=========================================="
if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}🎉 Module 04 appears to be properly aligned!${NC}"
    echo -e "${GREEN}✅ Source code builds${NC}"
    echo -e "${GREEN}✅ Setup script works${NC}"
    echo -e "${GREEN}✅ Key files present${NC}"
    echo -e "${GREEN}✅ Exercises reference key concepts${NC}"
else
    echo -e "${RED}❌ Found $ERRORS issues in Module 04${NC}"
    echo -e "${YELLOW}⚠️  Module 04 may need alignment work${NC}"
fi

exit $ERRORS
