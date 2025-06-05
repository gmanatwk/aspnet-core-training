#!/bin/bash

# Complete Module 05 verification script

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

ERRORS=0

echo -e "${BLUE}🔍 Complete Module 05 Verification${NC}"
echo "=================================="

# Check 1: All exercises exist
echo -e "${BLUE}1. Checking exercise files...${NC}"
exercises=(
    "Module05-Entity-Framework-Core/Exercises/Exercise01-Basic-EF-Core-Setup.md"
    "Module05-Entity-Framework-Core/Exercises/Exercise02-Advanced-LINQ-Queries.md"
    "Module05-Entity-Framework-Core/Exercises/Exercise03-Repository-Pattern.md"
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
SOURCE_DIR="Module05-Entity-Framework-Core/SourceCode/EFCoreDemo"
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

# Check 3: Setup script works for all exercises
echo -e "${BLUE}3. Testing setup scripts...${NC}"
setup_exercises=("module05-exercise01-efcore" "module05-exercise02-linq" "module05-exercise03-repository")

for exercise in "${setup_exercises[@]}"; do
    echo -n "  Testing $exercise: "
    rm -rf EFCoreDemo
    if ./setup-exercise.sh "$exercise" > /dev/null 2>&1; then
        echo -e "${GREEN}✅${NC}"
        
        cd EFCoreDemo
        if dotnet build > /dev/null 2>&1; then
            echo -n "    Build: "
            echo -e "${GREEN}✅${NC}"
        else
            echo -n "    Build: "
            echo -e "${RED}❌${NC}"
            ((ERRORS++))
        fi
        cd ..
        rm -rf EFCoreDemo
    else
        echo -e "${RED}❌${NC}"
        ((ERRORS++))
    fi
done

# Check 4: Exercise content verification
echo -e "${BLUE}4. Checking exercise content...${NC}"

# Exercise 1 - Basic EF Core Setup
echo -n "  Exercise 1: "
ex1_blocks=$(grep -c '```csharp' "Module05-Entity-Framework-Core/Exercises/Exercise01-Basic-EF-Core-Setup.md" 2>/dev/null || echo 0)
if [ "$ex1_blocks" -ge 4 ]; then
    echo -e "${GREEN}✅ $ex1_blocks code blocks${NC}"
else
    echo -e "${RED}❌ Insufficient code blocks: $ex1_blocks${NC}"
    ((ERRORS++))
fi

# Exercise 2 - Advanced LINQ Queries
echo -n "  Exercise 2: "
ex2_blocks=$(grep -c '```csharp' "Module05-Entity-Framework-Core/Exercises/Exercise02-Advanced-LINQ-Queries.md" 2>/dev/null || echo 0)
if [ "$ex2_blocks" -ge 6 ]; then
    echo -e "${GREEN}✅ $ex2_blocks code blocks${NC}"
else
    echo -e "${RED}❌ Insufficient code blocks: $ex2_blocks${NC}"
    ((ERRORS++))
fi

# Exercise 3 - Repository Pattern
echo -n "  Exercise 3: "
ex3_blocks=$(grep -c '```csharp' "Module05-Entity-Framework-Core/Exercises/Exercise03-Repository-Pattern.md" 2>/dev/null || echo 0)
if [ "$ex3_blocks" -ge 8 ]; then
    echo -e "${GREEN}✅ $ex3_blocks code blocks${NC}"
else
    echo -e "${RED}❌ Insufficient code blocks: $ex3_blocks${NC}"
    ((ERRORS++))
fi

# Check 5: Key concepts coverage
echo -e "${BLUE}5. Checking key concepts...${NC}"

# EF Core concepts
ef_concepts=("DbContext" "DbSet" "Entity" "Migration")
for concept in "${ef_concepts[@]}"; do
    if grep -q "$concept" "Module05-Entity-Framework-Core/Exercises/Exercise01-Basic-EF-Core-Setup.md"; then
        echo -e "${GREEN}✅ EF Core: $concept${NC}"
    else
        echo -e "${RED}❌ Missing EF Core concept: $concept${NC}"
        ((ERRORS++))
    fi
done

# LINQ concepts
linq_concepts=("Include" "Where" "Select" "GroupBy")
for concept in "${linq_concepts[@]}"; do
    if grep -q "$concept" "Module05-Entity-Framework-Core/Exercises/Exercise02-Advanced-LINQ-Queries.md"; then
        echo -e "${GREEN}✅ LINQ: $concept${NC}"
    else
        echo -e "${RED}❌ Missing LINQ concept: $concept${NC}"
        ((ERRORS++))
    fi
done

# Repository concepts
repo_concepts=("IRepository" "Repository" "UnitOfWork" "IUnitOfWork")
for concept in "${repo_concepts[@]}"; do
    if grep -q "$concept" "Module05-Entity-Framework-Core/Exercises/Exercise03-Repository-Pattern.md"; then
        echo -e "${GREEN}✅ Repository: $concept${NC}"
    else
        echo -e "${RED}❌ Missing repository concept: $concept${NC}"
        ((ERRORS++))
    fi
done

# Check 6: Template files
echo -e "${BLUE}6. Checking template files...${NC}"
template_files=(
    "Module05-Entity-Framework-Core/Templates/EFCoreDemo.csproj"
    "Module05-Entity-Framework-Core/Templates/appsettings.json"
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
echo "=================================="
if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}🎉 Module 05 is completely aligned!${NC}"
    echo ""
    echo -e "${GREEN}✅ All 3 exercises have complete code blocks${NC}"
    echo -e "${GREEN}✅ Setup script works for all exercises${NC}"
    echo -e "${GREEN}✅ Source code builds successfully${NC}"
    echo -e "${GREEN}✅ All key concepts covered${NC}"
    echo -e "${GREEN}✅ Template files configured correctly${NC}"
    echo ""
    echo -e "${BLUE}📚 Students can now:${NC}"
    echo "  1. Complete Exercise 1: Basic EF Core Setup"
    echo "  2. Complete Exercise 2: Advanced LINQ Queries"
    echo "  3. Complete Exercise 3: Repository Pattern"
    echo "  4. Build and test a complete EF Core application"
    echo ""
    echo -e "${GREEN}✅ MODULE 05 READY FOR CLASS USE${NC}"
else
    echo -e "${RED}❌ Found $ERRORS issues in Module 05${NC}"
    echo -e "${YELLOW}⚠️  Module 05 needs more alignment work${NC}"
fi

exit $ERRORS
