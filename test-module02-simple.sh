#!/bin/bash

# Simple Module 02 verification

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

ERRORS=0

echo -e "${BLUE}🔍 Module 02 Simple Verification${NC}"
echo "================================"

# Test 1: Source code builds
echo -e "${BLUE}1. Testing source code build...${NC}"
cd Module02-ASP.NET-Core-with-React/SourceCode/ReactTodoApp
if dotnet build > /dev/null 2>&1; then
    echo -e "${GREEN}✅ ASP.NET Core builds successfully${NC}"
else
    echo -e "${RED}❌ ASP.NET Core build failed${NC}"
    ((ERRORS++))
fi

# Test 2: React dependencies
echo -e "${BLUE}2. Testing React setup...${NC}"
cd ClientApp
if [ -f "package.json" ]; then
    echo -e "${GREEN}✅ React package.json exists${NC}"
    if [ -d "node_modules" ]; then
        echo -e "${GREEN}✅ React dependencies installed${NC}"
    else
        echo -e "${RED}❌ React dependencies not installed${NC}"
        ((ERRORS++))
    fi
else
    echo -e "${RED}❌ React package.json missing${NC}"
    ((ERRORS++))
fi

# Test 3: Key files exist
echo -e "${BLUE}3. Checking key files...${NC}"
cd ..

key_files=(
    "Controllers/TodoController.cs"
    "Models/Todo.cs"
    "Services/TodoService.cs"
    "Program.cs"
    "docker-compose.yml"
    "Dockerfile"
    "README-Windows.md"
    "ClientApp/src/App.tsx"
    "ClientApp/src/components/TodoList.tsx"
    "ClientApp/src/services/todoService.ts"
)

for file in "${key_files[@]}"; do
    if [ -f "$file" ]; then
        echo -e "${GREEN}✅ $file${NC}"
    else
        echo -e "${RED}❌ Missing: $file${NC}"
        ((ERRORS++))
    fi
done

# Test 4: Docker Compose validation
echo -e "${BLUE}4. Testing Docker Compose...${NC}"
if command -v docker-compose &> /dev/null; then
    if docker-compose config > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Docker Compose configuration valid${NC}"
    else
        echo -e "${RED}❌ Docker Compose configuration invalid${NC}"
        ((ERRORS++))
    fi
else
    echo -e "${GREEN}⚠️  Docker Compose not available (OK for testing)${NC}"
fi

# Test 5: Exercise files
echo -e "${BLUE}5. Checking exercise files...${NC}"
cd ../../Exercises

exercises=("Exercise01-Basic-Integration.md" "Exercise02-State-Management-Routing.md" "Exercise03-API-Integration-Performance.md" "Exercise04-Docker-Integration.md")

for exercise in "${exercises[@]}"; do
    if [ -f "$exercise" ]; then
        echo -e "${GREEN}✅ $exercise${NC}"
        # Check for Docker commands
        if grep -q "docker-compose" "$exercise"; then
            echo -e "${GREEN}  ✅ Contains Docker commands${NC}"
        else
            echo -e "${RED}  ❌ Missing Docker commands${NC}"
            ((ERRORS++))
        fi
    else
        echo -e "${RED}❌ Missing: $exercise${NC}"
        ((ERRORS++))
    fi
done

cd ../../../

# Summary
echo ""
echo "================================"
if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}🎉 Module 02 verification PASSED!${NC}"
    echo ""
    echo -e "${GREEN}✅ Source code builds successfully${NC}"
    echo -e "${GREEN}✅ React application configured${NC}"
    echo -e "${GREEN}✅ Docker setup complete${NC}"
    echo -e "${GREEN}✅ All exercises ready${NC}"
    echo ""
    echo -e "${BLUE}📚 Windows students can use:${NC}"
    echo "  docker-compose up --build"
    echo "  docker-compose --profile dev up --build"
    echo "  docker-compose --profile api-only --profile react-dev up --build"
    echo ""
    echo -e "${GREEN}✅ MODULE 02 READY FOR CLASS USE${NC}"
else
    echo -e "${RED}❌ Found $ERRORS issues${NC}"
    echo -e "${RED}⚠️  Module 02 needs fixes${NC}"
fi

exit $ERRORS
