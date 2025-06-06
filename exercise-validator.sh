#!/bin/bash

# Enhanced Exercise Validation Framework
# Validates exercise completion with detailed feedback

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Icons
CHECK="✅"
CROSS="❌"
WARNING="⚠️"
INFO="ℹ️"
ROCKET="🚀"

# Function to print status
print_status() {
    local status=$1
    local message=$2
    
    case $status in
        "success")
            echo -e "${GREEN}${CHECK} ${message}${NC}"
            ;;
        "error")
            echo -e "${RED}${CROSS} ${message}${NC}"
            ;;
        "warning")
            echo -e "${YELLOW}${WARNING} ${message}${NC}"
            ;;
        "info")
            echo -e "${CYAN}${INFO} ${message}${NC}"
            ;;
    esac
}

# Function to check if a file exists
check_file_exists() {
    local file=$1
    local description=$2
    
    if [ -f "$file" ]; then
        print_status "success" "$description exists"
        return 0
    else
        print_status "error" "$description is missing"
        return 1
    fi
}

# Function to check if a directory exists
check_directory_exists() {
    local dir=$1
    local description=$2
    
    if [ -d "$dir" ]; then
        print_status "success" "$description exists"
        return 0
    else
        print_status "error" "$description is missing"
        return 1
    fi
}

# Function to check for patterns in files
check_pattern_in_file() {
    local file=$1
    local pattern=$2
    local description=$3
    
    if [ -f "$file" ] && grep -q "$pattern" "$file"; then
        print_status "success" "$description found"
        return 0
    else
        print_status "error" "$description not found"
        return 1
    fi
}

# Function to count TODOs
count_todos() {
    local count=$(grep -r "TODO" . --include="*.cs" --include="*.tsx" --include="*.ts" 2>/dev/null | wc -l)
    
    if [ $count -eq 0 ]; then
        print_status "success" "All TODOs completed"
    else
        print_status "warning" "Found $count incomplete TODOs"
    fi
    
    return $count
}

# Function to run build
check_build() {
    echo -n "Checking if project builds... "
    
    if dotnet build --nologo --verbosity quiet > /dev/null 2>&1; then
        echo -e "${GREEN}${CHECK}${NC}"
        return 0
    else
        echo -e "${RED}${CROSS}${NC}"
        print_status "error" "Build failed. Run 'dotnet build' to see errors"
        return 1
    fi
}

# Function to run tests
check_tests() {
    local test_project=$(find . -name "*.Tests.csproj" 2>/dev/null | head -1)
    
    if [ -n "$test_project" ]; then
        echo -n "Running tests... "
        if dotnet test "$test_project" --nologo --verbosity quiet > /dev/null 2>&1; then
            echo -e "${GREEN}${CHECK}${NC}"
            return 0
        else
            echo -e "${RED}${CROSS}${NC}"
            print_status "error" "Tests failed. Run 'dotnet test' to see errors"
            return 1
        fi
    else
        print_status "info" "No test project found"
        return 0
    fi
}

# Function to check API endpoints
check_api_endpoints() {
    local port=${1:-5000}
    
    echo "Checking API endpoints..."
    
    # Start the application in background
    dotnet run --urls "http://localhost:$port" > /dev/null 2>&1 &
    local pid=$!
    
    # Wait for startup
    sleep 5
    
    # Check if process is still running
    if ! ps -p $pid > /dev/null; then
        print_status "error" "Application failed to start"
        return 1
    fi
    
    # Check health endpoint if exists
    if curl -s -o /dev/null -w "%{http_code}" "http://localhost:$port/health" | grep -q "200"; then
        print_status "success" "Health endpoint responding"
    fi
    
    # Check Swagger UI
    if curl -s -o /dev/null -w "%{http_code}" "http://localhost:$port/swagger" | grep -q "200"; then
        print_status "success" "Swagger UI available"
    else
        print_status "warning" "Swagger UI not accessible"
    fi
    
    # Stop the application
    kill $pid 2>/dev/null
    
    return 0
}

# Main validation function
validate_exercise() {
    local exercise=$1
    local project_dir=$2
    
    echo -e "${MAGENTA}🔍 Validating Exercise: $exercise${NC}"
    echo "================================================"
    echo ""
    
    # Change to project directory
    if [ -n "$project_dir" ] && [ -d "$project_dir" ]; then
        cd "$project_dir"
    fi
    
    # Common checks
    echo -e "${CYAN}📋 Basic Checks:${NC}"
    check_file_exists "*.csproj" "Project file"
    check_file_exists "Program.cs" "Program.cs"
    check_file_exists "appsettings.json" "appsettings.json"
    echo ""
    
    # Build check
    echo -e "${CYAN}🔨 Build Check:${NC}"
    check_build
    echo ""
    
    # TODO check
    echo -e "${CYAN}📝 TODO Check:${NC}"
    count_todos
    echo ""
    
    # Exercise-specific validation
    echo -e "${CYAN}🎯 Exercise-Specific Checks:${NC}"
    
    case $exercise in
        module02-exercise*)
            # React integration checks
            check_directory_exists "ClientApp" "React ClientApp directory"
            check_file_exists "ClientApp/package.json" "React package.json"
            check_file_exists "ClientApp/src/App.tsx" "React App component"
            
            if [ -d "ClientApp" ]; then
                echo -n "Checking React dependencies... "
                cd ClientApp
                if npm list react > /dev/null 2>&1; then
                    echo -e "${GREEN}${CHECK}${NC}"
                else
                    echo -e "${YELLOW}${WARNING} Run 'npm install' in ClientApp${NC}"
                fi
                cd ..
            fi
            ;;
            
        module03-exercise01)
            # Basic API checks
            check_directory_exists "Controllers" "Controllers directory"
            check_directory_exists "Models" "Models directory"
            check_file_exists "Models/Book.cs" "Book model"
            check_pattern_in_file "Program.cs" "AddDbContext" "DbContext configuration"
            ;;
            
        module03-exercise02)
            # Authentication checks
            check_pattern_in_file "Program.cs" "AddAuthentication" "Authentication configuration"
            check_pattern_in_file "Program.cs" "AddJwtBearer" "JWT Bearer configuration"
            check_file_exists "Controllers/AuthController.cs" "Auth controller"
            ;;
            
        module03-exercise03)
            # API documentation checks
            check_pattern_in_file "Program.cs" "AddApiVersioning" "API versioning"
            check_pattern_in_file "Program.cs" "AddSwaggerGen" "Swagger configuration"
            check_directory_exists "Configuration" "Configuration directory"
            ;;
            
        module04-exercise*)
            # JWT checks
            check_file_exists "Services/JwtTokenService.cs" "JWT Token Service"
            check_pattern_in_file "appsettings.json" "Jwt" "JWT configuration"
            check_pattern_in_file "Program.cs" "AddAuthentication" "Authentication setup"
            ;;
            
        module05-exercise*)
            # EF Core checks
            check_pattern_in_file "Program.cs" "AddDbContext" "DbContext registration"
            check_directory_exists "Data" "Data directory"
            check_directory_exists "Models" "Models directory"
            
            if [[ $exercise == "module05-exercise03" ]]; then
                check_directory_exists "Repositories" "Repositories directory"
                check_pattern_in_file "Program.cs" "AddScoped.*Repository" "Repository registration"
            fi
            ;;
    esac
    
    echo ""
    
    # Test check
    echo -e "${CYAN}🧪 Test Check:${NC}"
    check_tests
    echo ""
    
    # Summary
    echo -e "${MAGENTA}📊 Validation Summary${NC}"
    echo "================================================"
    
    # Count successes and failures
    local total_checks=$(($(echo -e "${CHECK}" | wc -l) + $(echo -e "${CROSS}" | wc -l)))
    local successes=$(echo -e "${CHECK}" | wc -l)
    local failures=$(echo -e "${CROSS}" | wc -l)
    
    if [ $failures -eq 0 ]; then
        echo -e "${GREEN}🎉 All checks passed! Great job!${NC}"
        echo -e "${GREEN}Your exercise implementation looks complete.${NC}"
    else
        echo -e "${YELLOW}Some checks need attention.${NC}"
        echo -e "Passed: ${GREEN}$successes${NC} | Failed: ${RED}$failures${NC}"
    fi
    
    echo ""
    echo -e "${CYAN}💡 Next Steps:${NC}"
    
    if [ $failures -gt 0 ]; then
        echo "1. Fix the issues marked with ${CROSS}"
        echo "2. Run this validator again"
    else
        echo "1. Test your application manually"
        echo "2. Compare with the solution if needed"
        echo "3. Move on to the next exercise!"
    fi
}

# Parse command line arguments
if [ $# -eq 0 ]; then
    echo -e "${RED}❌ Usage: $0 <exercise-name> [project-directory]${NC}"
    echo ""
    echo "Examples:"
    echo "  $0 module02-exercise01"
    echo "  $0 module03-exercise02 LibraryAPI"
    exit 1
fi

EXERCISE=$1
PROJECT_DIR=${2:-"."}

# Run validation
validate_exercise "$EXERCISE" "$PROJECT_DIR"