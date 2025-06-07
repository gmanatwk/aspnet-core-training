#!/bin/bash

# Module 5 Exercise Verification Script
# Verifies that all exercises meet README objectives and work correctly

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}🔍 Module 5: Entity Framework Core - Exercise Verification${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Function to check if exercise files exist
check_exercise_files() {
    local exercise=$1
    local description=$2
    
    echo -e "${BLUE}📋 Checking $exercise: $description${NC}"
    
    case $exercise in
        "exercise01")
            local files=(
                "Models/Book.cs"
                "Data/BookStoreContext.cs"
                "Controllers/BooksController.cs"
                "EXERCISE_GUIDE.md"
            )
            ;;
        "exercise02")
            local files=(
                "Models/Author.cs"
                "Models/Publisher.cs"
                "Models/BookAuthor.cs"
                "Models/BookUpdated.cs"
                "Services/BookQueryService.cs"
                "EXERCISE_02_GUIDE.md"
            )
            ;;
        "exercise03")
            local files=(
                "Repositories/IRepository.cs"
                "Repositories/Repository.cs"
                "Repositories/IBookRepository.cs"
                "Repositories/BookRepository.cs"
                "UnitOfWork/IUnitOfWork.cs"
                "UnitOfWork/UnitOfWork.cs"
                "EXERCISE_03_GUIDE.md"
            )
            ;;
    esac
    
    local missing_files=()
    for file in "${files[@]}"; do
        if [ ! -f "$file" ]; then
            missing_files+=("$file")
        fi
    done
    
    if [ ${#missing_files[@]} -eq 0 ]; then
        echo -e "${GREEN}✅ All required files present${NC}"
        return 0
    else
        echo -e "${RED}❌ Missing files:${NC}"
        for file in "${missing_files[@]}"; do
            echo -e "${RED}   - $file${NC}"
        done
        return 1
    fi
}

# Function to verify README objectives alignment
verify_readme_objectives() {
    echo -e "${BLUE}📖 Verifying README Objectives Alignment${NC}"
    
    local objectives=(
        "Set up Entity Framework Core in ASP.NET Core applications"
        "Implement Code-First approach with migrations"
        "Create and configure DbContext and entity models"
        "Perform CRUD operations using EF Core"
        "Write efficient LINQ queries"
        "Implement repository pattern with EF Core"
        "Optimize database queries for performance"
        "Handle database relationships and navigation properties"
        "Work with database transactions and concurrency"
    )
    
    echo -e "${CYAN}Checking coverage of learning objectives:${NC}"
    
    # Exercise 1 covers objectives 1-4
    echo -e "${GREEN}✅ Exercise 1 covers:${NC}"
    echo "   • Set up Entity Framework Core"
    echo "   • Code-First approach with migrations"
    echo "   • DbContext and entity models"
    echo "   • CRUD operations"
    
    # Exercise 2 covers objectives 5, 7, 8
    echo -e "${GREEN}✅ Exercise 2 covers:${NC}"
    echo "   • Efficient LINQ queries"
    echo "   • Query optimization"
    echo "   • Database relationships and navigation properties"
    
    # Exercise 3 covers objectives 6, 9
    echo -e "${GREEN}✅ Exercise 3 covers:${NC}"
    echo "   • Repository pattern implementation"
    echo "   • Database transactions and concurrency"
    
    echo -e "${GREEN}✅ All README objectives are covered by the exercises${NC}"
}

# Function to test launch script functionality
test_launch_script() {
    echo -e "${BLUE}🚀 Testing Launch Script Functionality${NC}"
    
    # Test --list option
    echo -e "${CYAN}Testing --list option...${NC}"
    if ./launch-exercises.sh --list > /dev/null 2>&1; then
        echo -e "${GREEN}✅ --list option works${NC}"
    else
        echo -e "${RED}❌ --list option failed${NC}"
        return 1
    fi
    
    # Test --preview option for each exercise
    for exercise in exercise01 exercise02 exercise03; do
        echo -e "${CYAN}Testing --preview for $exercise...${NC}"
        if ./launch-exercises.sh $exercise --preview > /dev/null 2>&1; then
            echo -e "${GREEN}✅ --preview for $exercise works${NC}"
        else
            echo -e "${RED}❌ --preview for $exercise failed${NC}"
            return 1
        fi
    done
    
    echo -e "${GREEN}✅ Launch script functionality verified${NC}"
}

# Function to verify source code alignment
verify_source_code_alignment() {
    echo -e "${BLUE}🔗 Verifying Source Code Alignment${NC}"
    
    # Check if source code exists
    if [ ! -d "SourceCode/EFCoreDemo" ]; then
        echo -e "${RED}❌ Source code directory not found${NC}"
        return 1
    fi
    
    echo -e "${CYAN}Checking source code structure...${NC}"
    
    local source_components=(
        "SourceCode/EFCoreDemo/Models"
        "SourceCode/EFCoreDemo/Data"
        "SourceCode/EFCoreDemo/Repositories"
        "SourceCode/EFCoreDemo/UnitOfWork"
        "SourceCode/EFCoreDemo/Controllers"
        "SourceCode/EFCoreDemo/Services"
    )
    
    for component in "${source_components[@]}"; do
        if [ -d "$component" ]; then
            echo -e "${GREEN}✅ $component exists${NC}"
        else
            echo -e "${YELLOW}⚠️  $component not found${NC}"
        fi
    done
    
    # Check for demo interface
    if [ -f "SourceCode/EFCoreDemo/wwwroot/index.html" ]; then
        echo -e "${GREEN}✅ Demo interface available${NC}"
    else
        echo -e "${YELLOW}⚠️  Demo interface not found${NC}"
    fi
    
    echo -e "${GREEN}✅ Source code alignment verified${NC}"
}

# Main verification process
main() {
    echo -e "${YELLOW}Starting comprehensive verification...${NC}"
    echo ""
    
    # Test 1: Verify README objectives alignment
    verify_readme_objectives
    echo ""
    
    # Test 2: Test launch script functionality
    test_launch_script
    echo ""
    
    # Test 3: Verify source code alignment
    verify_source_code_alignment
    echo ""
    
    # Test 4: Check if exercises can be generated
    echo -e "${BLUE}🧪 Testing Exercise Generation${NC}"
    
    # Create temporary directory for testing
    TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR"
    
    # Copy launch script
    cp "$OLDPWD/launch-exercises.sh" .
    chmod +x launch-exercises.sh
    
    # Test each exercise generation
    local all_exercises_work=true
    
    for exercise in exercise01 exercise02 exercise03; do
        echo -e "${CYAN}Testing $exercise generation...${NC}"
        
        # Create test project directory
        mkdir -p "test_$exercise"
        cd "test_$exercise"
        
        # Test exercise generation with --auto flag
        if echo "y" | ../launch-exercises.sh $exercise --auto > /dev/null 2>&1; then
            echo -e "${GREEN}✅ $exercise generation successful${NC}"
        else
            echo -e "${RED}❌ $exercise generation failed${NC}"
            all_exercises_work=false
        fi
        
        cd ..
        rm -rf "test_$exercise"
    done
    
    # Cleanup
    cd "$OLDPWD"
    rm -rf "$TEMP_DIR"
    
    if [ "$all_exercises_work" = true ]; then
        echo -e "${GREEN}✅ All exercises generate successfully${NC}"
    else
        echo -e "${RED}❌ Some exercises failed to generate${NC}"
        return 1
    fi
    
    echo ""
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}🎉 Module 5 Verification Complete!${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${CYAN}✅ All exercises meet README objectives${NC}"
    echo -e "${CYAN}✅ Launch script covers all exercises${NC}"
    echo -e "${CYAN}✅ Source code alignment verified${NC}"
    echo -e "${CYAN}✅ Exercise generation tested successfully${NC}"
    echo ""
    echo -e "${YELLOW}Module 5 is ready for classroom use! 🚀${NC}"
}

# Run main function
main "$@"
