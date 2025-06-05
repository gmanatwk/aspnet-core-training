#!/bin/bash

# Module 05 Assessment Script

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

ISSUES=0

echo -e "${BLUE}🔍 Module 05 Assessment${NC}"
echo "========================"

# Check 1: Source code builds
echo -e "${BLUE}1. Testing source code build...${NC}"
cd Module05-Entity-Framework-Core/SourceCode/EFCoreDemo
if dotnet build > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Source code builds successfully${NC}"
else
    echo -e "${RED}❌ Source code build failed${NC}"
    ((ISSUES++))
fi
cd - > /dev/null

# Check 2: Exercise content analysis
echo -e "${BLUE}2. Analyzing exercise content...${NC}"

exercises=(
    "Module05-Entity-Framework-Core/Exercises/Exercise01-Basic-EF-Core-Setup.md"
    "Module05-Entity-Framework-Core/Exercises/Exercise02-Advanced-LINQ-Queries.md"
    "Module05-Entity-Framework-Core/Exercises/Exercise03-Repository-Pattern.md"
)

for exercise in "${exercises[@]}"; do
    if [ -f "$exercise" ]; then
        code_blocks=$(grep -c '```csharp' "$exercise" 2>/dev/null || echo 0)
        echo "  $(basename $exercise): $code_blocks C# code blocks"
        
        if [ "$code_blocks" -lt 3 ]; then
            echo -e "${YELLOW}    ⚠️  Insufficient code blocks${NC}"
            ((ISSUES++))
        fi
    else
        echo -e "${RED}❌ Missing: $(basename $exercise)${NC}"
        ((ISSUES++))
    fi
done

# Check 3: Setup script support
echo -e "${BLUE}3. Checking setup script support...${NC}"
if grep -q "module05" setup-exercise.sh; then
    echo -e "${GREEN}✅ Setup script supports Module 05${NC}"
else
    echo -e "${RED}❌ Setup script missing Module 05 support${NC}"
    ((ISSUES++))
fi

# Check 4: Key source code components
echo -e "${BLUE}4. Checking source code components...${NC}"

components=(
    "Module05-Entity-Framework-Core/SourceCode/EFCoreDemo/Models/BookEntities.cs"
    "Module05-Entity-Framework-Core/SourceCode/EFCoreDemo/Data/BookStoreContext.cs"
    "Module05-Entity-Framework-Core/SourceCode/EFCoreDemo/Controllers/BooksController.cs"
    "Module05-Entity-Framework-Core/SourceCode/EFCoreDemo/Repositories/IRepository.cs"
    "Module05-Entity-Framework-Core/SourceCode/EFCoreDemo/UnitOfWork/IUnitOfWork.cs"
    "Module05-Entity-Framework-Core/SourceCode/EFCoreDemo/Services/BookQueryService.cs"
)

for component in "${components[@]}"; do
    if [ -f "$component" ]; then
        echo -e "${GREEN}✅ $(basename $component)${NC}"
    else
        echo -e "${RED}❌ Missing: $(basename $component)${NC}"
        ((ISSUES++))
    fi
done

# Check 5: Exercise progression analysis
echo -e "${BLUE}5. Analyzing exercise progression...${NC}"

# Exercise 1 should have basic EF setup
if grep -q "BookStoreContext" "Module05-Entity-Framework-Core/Exercises/Exercise01-Basic-EF-Core-Setup.md"; then
    echo -e "${GREEN}✅ Exercise 1 covers DbContext${NC}"
else
    echo -e "${RED}❌ Exercise 1 missing DbContext content${NC}"
    ((ISSUES++))
fi

# Exercise 2 should have LINQ queries
if grep -q "LINQ" "Module05-Entity-Framework-Core/Exercises/Exercise02-Advanced-LINQ-Queries.md"; then
    echo -e "${GREEN}✅ Exercise 2 covers LINQ${NC}"
else
    echo -e "${RED}❌ Exercise 2 missing LINQ content${NC}"
    ((ISSUES++))
fi

# Exercise 3 should have Repository pattern
if grep -q "Repository" "Module05-Entity-Framework-Core/Exercises/Exercise03-Repository-Pattern.md"; then
    echo -e "${GREEN}✅ Exercise 3 covers Repository pattern${NC}"
else
    echo -e "${RED}❌ Exercise 3 missing Repository content${NC}"
    ((ISSUES++))
fi

# Summary
echo ""
echo "========================"
if [ $ISSUES -eq 0 ]; then
    echo -e "${GREEN}✅ Module 05 assessment complete - No major issues${NC}"
    echo -e "${BLUE}📋 Ready for alignment work${NC}"
else
    echo -e "${YELLOW}⚠️  Found $ISSUES issues that need attention${NC}"
    echo -e "${BLUE}📋 Alignment work required${NC}"
fi

echo ""
echo -e "${BLUE}🎯 Alignment Tasks Needed:${NC}"
echo "1. Add setup script support for Module 05"
echo "2. Add complete code blocks to exercises"
echo "3. Ensure exercise-source code alignment"
echo "4. Create verification scripts"
echo "5. Test end-to-end exercise workflow"

exit $ISSUES
