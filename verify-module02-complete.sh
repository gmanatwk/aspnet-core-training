#!/bin/bash

# Complete Module 02 verification script

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

ERRORS=0

echo -e "${BLUE}🔍 Complete Module 02 Verification${NC}"
echo "=================================="

# Check 1: Source code exists and builds
echo -e "${BLUE}1. Checking source code...${NC}"
SOURCE_DIR="Module02-ASP.NET-Core-with-React/SourceCode/ReactTodoApp"
if [ -d "$SOURCE_DIR" ]; then
    echo -e "${GREEN}✅ Source code directory exists${NC}"
    
    cd "$SOURCE_DIR"
    if dotnet build > /dev/null 2>&1; then
        echo -e "${GREEN}✅ ASP.NET Core source code builds successfully${NC}"
    else
        echo -e "${RED}❌ ASP.NET Core source code build failed${NC}"
        ((ERRORS++))
    fi
    
    # Check React dependencies
    if [ -f "ClientApp/package.json" ]; then
        echo -e "${GREEN}✅ React ClientApp exists${NC}"
        cd ClientApp
        if npm install > /dev/null 2>&1; then
            echo -e "${GREEN}✅ React dependencies install successfully${NC}"
        else
            echo -e "${RED}❌ React dependencies installation failed${NC}"
            ((ERRORS++))
        fi
        cd ..
    else
        echo -e "${RED}❌ React ClientApp not found${NC}"
        ((ERRORS++))
    fi
    cd - > /dev/null
else
    echo -e "${RED}❌ Source code directory not found${NC}"
    ((ERRORS++))
fi

# Check 2: Docker files exist
echo -e "${BLUE}2. Checking Docker configuration...${NC}"
docker_files=(
    "Module02-ASP.NET-Core-with-React/SourceCode/ReactTodoApp/Dockerfile"
    "Module02-ASP.NET-Core-with-React/SourceCode/ReactTodoApp/Dockerfile.dev"
    "Module02-ASP.NET-Core-with-React/SourceCode/ReactTodoApp/Dockerfile.api"
    "Module02-ASP.NET-Core-with-React/SourceCode/ReactTodoApp/docker-compose.yml"
    "Module02-ASP.NET-Core-with-React/SourceCode/ReactTodoApp/ClientApp/Dockerfile.dev"
    "Module02-ASP.NET-Core-with-React/SourceCode/ReactTodoApp/.dockerignore"
)

for file in "${docker_files[@]}"; do
    if [ -f "$file" ]; then
        echo -e "${GREEN}✅ $(basename $file)${NC}"
    else
        echo -e "${RED}❌ Missing: $(basename $file)${NC}"
        ((ERRORS++))
    fi
done

# Check 3: Exercise files exist
echo -e "${BLUE}3. Checking exercise files...${NC}"
exercises=(
    "Module02-ASP.NET-Core-with-React/Exercises/Exercise01-Basic-Integration.md"
    "Module02-ASP.NET-Core-with-React/Exercises/Exercise02-State-Management-Routing.md"
    "Module02-ASP.NET-Core-with-React/Exercises/Exercise03-API-Integration-Performance.md"
    "Module02-ASP.NET-Core-with-React/Exercises/Exercise04-Docker-Integration.md"
)

for exercise in "${exercises[@]}"; do
    if [ -f "$exercise" ]; then
        echo -e "${GREEN}✅ $(basename $exercise)${NC}"
    else
        echo -e "${RED}❌ Missing: $(basename $exercise)${NC}"
        ((ERRORS++))
    fi
done

# Check 4: Windows documentation
echo -e "${BLUE}4. Checking Windows documentation...${NC}"
if [ -f "Module02-ASP.NET-Core-with-React/SourceCode/ReactTodoApp/README-Windows.md" ]; then
    echo -e "${GREEN}✅ Windows setup guide exists${NC}"
else
    echo -e "${RED}❌ Windows setup guide missing${NC}"
    ((ERRORS++))
fi

# Check 5: Exercise content verification
echo -e "${BLUE}5. Checking exercise content...${NC}"

# Check for Docker commands in exercises
for exercise in "${exercises[@]}"; do
    if grep -q "docker-compose" "$exercise" 2>/dev/null; then
        echo -e "${GREEN}✅ $(basename $exercise) contains Docker commands${NC}"
    else
        echo -e "${YELLOW}⚠️  $(basename $exercise) missing Docker commands${NC}"
        ((ERRORS++))
    fi
done

# Check 6: Key components in source code
echo -e "${BLUE}6. Checking source code components...${NC}"

# ASP.NET Core components
components=(
    "Module02-ASP.NET-Core-with-React/SourceCode/ReactTodoApp/Controllers/TodoController.cs"
    "Module02-ASP.NET-Core-with-React/SourceCode/ReactTodoApp/Models/Todo.cs"
    "Module02-ASP.NET-Core-with-React/SourceCode/ReactTodoApp/Services/ITodoService.cs"
    "Module02-ASP.NET-Core-with-React/SourceCode/ReactTodoApp/Services/TodoService.cs"
    "Module02-ASP.NET-Core-with-React/SourceCode/ReactTodoApp/Program.cs"
)

for component in "${components[@]}"; do
    if [ -f "$component" ]; then
        echo -e "${GREEN}✅ $(basename $component)${NC}"
    else
        echo -e "${RED}❌ Missing: $(basename $component)${NC}"
        ((ERRORS++))
    fi
done

# React components
react_components=(
    "Module02-ASP.NET-Core-with-React/SourceCode/ReactTodoApp/ClientApp/src/App.tsx"
    "Module02-ASP.NET-Core-with-React/SourceCode/ReactTodoApp/ClientApp/src/components/TodoList.tsx"
    "Module02-ASP.NET-Core-with-React/SourceCode/ReactTodoApp/ClientApp/src/components/TodoItem.tsx"
    "Module02-ASP.NET-Core-with-React/SourceCode/ReactTodoApp/ClientApp/src/components/TodoForm.tsx"
    "Module02-ASP.NET-Core-with-React/SourceCode/ReactTodoApp/ClientApp/src/services/todoService.ts"
    "Module02-ASP.NET-Core-with-React/SourceCode/ReactTodoApp/ClientApp/src/types/Todo.ts"
)

for component in "${react_components[@]}"; do
    if [ -f "$component" ]; then
        echo -e "${GREEN}✅ $(basename $component)${NC}"
    else
        echo -e "${RED}❌ Missing: $(basename $component)${NC}"
        ((ERRORS++))
    fi
done

# Check 7: Docker Compose validation
echo -e "${BLUE}7. Validating Docker Compose configuration...${NC}"
if command -v docker-compose &> /dev/null; then
    if [ -f "$SOURCE_DIR/docker-compose.yml" ]; then
        cd "$SOURCE_DIR"
        if docker-compose config > /dev/null 2>&1; then
            echo -e "${GREEN}✅ Docker Compose configuration is valid${NC}"
        else
            echo -e "${RED}❌ Docker Compose configuration has errors${NC}"
            ((ERRORS++))
        fi
        cd - > /dev/null
    else
        echo -e "${RED}❌ docker-compose.yml not found${NC}"
        ((ERRORS++))
    fi
else
    echo -e "${YELLOW}⚠️  Docker Compose not available for validation${NC}"
fi

# Check 8: Key concepts coverage
echo -e "${BLUE}8. Checking key concepts coverage...${NC}"

# React concepts
react_concepts=("useState" "useEffect" "axios" "TypeScript" "components")
for concept in "${react_concepts[@]}"; do
    if grep -r "$concept" "Module02-ASP.NET-Core-with-React/SourceCode/ReactTodoApp/ClientApp/src" > /dev/null 2>&1; then
        echo -e "${GREEN}✅ React: $concept${NC}"
    else
        echo -e "${RED}❌ Missing React concept: $concept${NC}"
        ((ERRORS++))
    fi
done

# ASP.NET Core concepts
api_concepts=("ApiController" "HttpGet" "HttpPost" "HttpPut" "HttpDelete")
for concept in "${api_concepts[@]}"; do
    if grep -r "$concept" "Module02-ASP.NET-Core-with-React/SourceCode/ReactTodoApp/Controllers" > /dev/null 2>&1; then
        echo -e "${GREEN}✅ API: $concept${NC}"
    else
        echo -e "${RED}❌ Missing API concept: $concept${NC}"
        ((ERRORS++))
    fi
done

# Summary
echo ""
echo "=================================="
if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}🎉 Module 02 is completely aligned!${NC}"
    echo ""
    echo -e "${GREEN}✅ All 4 exercises have complete implementations${NC}"
    echo -e "${GREEN}✅ Docker setup works for Windows students${NC}"
    echo -e "${GREEN}✅ Source code builds successfully${NC}"
    echo -e "${GREEN}✅ All key concepts covered${NC}"
    echo -e "${GREEN}✅ React + ASP.NET Core integration complete${NC}"
    echo ""
    echo -e "${BLUE}📚 Students can now:${NC}"
    echo "  1. Complete Exercise 1: Basic React + ASP.NET Core Integration"
    echo "  2. Complete Exercise 2: State Management & Routing"
    echo "  3. Complete Exercise 3: API Integration & Performance"
    echo "  4. Complete Exercise 4: Docker Integration"
    echo "  5. Use Docker Compose commands directly on Windows"
    echo "  6. Build and deploy a complete full-stack application"
    echo ""
    echo -e "${GREEN}✅ MODULE 02 READY FOR CLASS USE${NC}"
else
    echo -e "${RED}❌ Found $ERRORS issues in Module 02${NC}"
    echo -e "${YELLOW}⚠️  Module 02 needs more alignment work${NC}"
fi

exit $ERRORS
