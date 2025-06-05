#!/bin/bash

# Comprehensive wwwroot verification for Module 04 and Module 05

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

ERRORS=0
WARNINGS=0

echo -e "${BLUE}🔍 COMPREHENSIVE WWWROOT VERIFICATION${NC}"
echo "=================================================="

# Function to check if endpoint exists in demo page
check_endpoint_in_demo() {
    local demo_file="$1"
    local endpoint="$2"
    local description="$3"
    
    if grep -q "$endpoint" "$demo_file"; then
        echo -e "${GREEN}✅ $description: $endpoint${NC}"
        return 0
    else
        echo -e "${RED}❌ Missing $description: $endpoint${NC}"
        ((ERRORS++))
        return 1
    fi
}

# Function to check if feature is mentioned in demo page
check_feature_in_demo() {
    local demo_file="$1"
    local feature="$2"
    local description="$3"
    
    if grep -qi "$feature" "$demo_file"; then
        echo -e "${GREEN}✅ $description: $feature${NC}"
        return 0
    else
        echo -e "${YELLOW}⚠️  $description missing: $feature${NC}"
        ((WARNINGS++))
        return 1
    fi
}

# Test 1: Setup and copy verification
echo -e "${PURPLE}1. SETUP SCRIPT INTEGRATION TEST${NC}"
echo "================================="

# Clean up any existing projects
rm -rf JwtAuthenticationAPI EFCoreDemo TestJWT TestEF

# Test Module 04 setup
echo -e "${BLUE}Testing Module 04 setup...${NC}"
if ./setup-exercise.sh module04-exercise01-jwt > /dev/null 2>&1; then
    if [ -f "JwtAuthenticationAPI/wwwroot/index.html" ]; then
        echo -e "${GREEN}✅ Module 04 wwwroot copied successfully${NC}"
        
        # Verify content integrity
        if diff -q "Module04-Authentication-and-Authorization/SourceCode/JwtAuthenticationAPI/wwwroot/index.html" "JwtAuthenticationAPI/wwwroot/index.html" > /dev/null; then
            echo -e "${GREEN}✅ Module 04 wwwroot content matches source${NC}"
        else
            echo -e "${RED}❌ Module 04 wwwroot content differs from source${NC}"
            ((ERRORS++))
        fi
    else
        echo -e "${RED}❌ Module 04 wwwroot not copied${NC}"
        ((ERRORS++))
    fi
else
    echo -e "${RED}❌ Module 04 setup failed${NC}"
    ((ERRORS++))
fi

# Test Module 05 setup
echo -e "${BLUE}Testing Module 05 setup...${NC}"
if ./setup-exercise.sh module05-exercise01-efcore > /dev/null 2>&1; then
    if [ -f "EFCoreDemo/wwwroot/index.html" ]; then
        echo -e "${GREEN}✅ Module 05 wwwroot copied successfully${NC}"
        
        # Verify content integrity
        if diff -q "Module05-Entity-Framework-Core/SourceCode/EFCoreDemo/wwwroot/index.html" "EFCoreDemo/wwwroot/index.html" > /dev/null; then
            echo -e "${GREEN}✅ Module 05 wwwroot content matches source${NC}"
        else
            echo -e "${RED}❌ Module 05 wwwroot content differs from source${NC}"
            ((ERRORS++))
        fi
    else
        echo -e "${RED}❌ Module 05 wwwroot not copied${NC}"
        ((ERRORS++))
    fi
else
    echo -e "${RED}❌ Module 05 setup failed${NC}"
    ((ERRORS++))
fi

echo ""

# Test 2: API Endpoint Accuracy
echo -e "${PURPLE}2. API ENDPOINT ACCURACY VERIFICATION${NC}"
echo "====================================="

echo -e "${BLUE}Module 04 - Authentication & Authorization Endpoints:${NC}"
MODULE04_DEMO="JwtAuthenticationAPI/wwwroot/index.html"

# Exercise 1 endpoints
check_endpoint_in_demo "$MODULE04_DEMO" "POST /api/auth/login" "Exercise 1 Login"
check_endpoint_in_demo "$MODULE04_DEMO" "GET /api/auth/protected" "Exercise 1 Protected"

# Exercise 2 endpoints  
check_endpoint_in_demo "$MODULE04_DEMO" "GET /api/admin/dashboard" "Exercise 2 Admin Dashboard"
check_endpoint_in_demo "$MODULE04_DEMO" "GET /api/admin/users" "Exercise 2 Admin Users"
check_endpoint_in_demo "$MODULE04_DEMO" "GET /api/editor/content" "Exercise 2 Editor Content"

# Exercise 3 endpoints
check_endpoint_in_demo "$MODULE04_DEMO" "GET /api/policy/adult-content" "Exercise 3 Adult Policy"
check_endpoint_in_demo "$MODULE04_DEMO" "GET /api/policy/it-resources" "Exercise 3 IT Policy"
check_endpoint_in_demo "$MODULE04_DEMO" "GET /api/policy/business-hours" "Exercise 3 Business Hours"
check_endpoint_in_demo "$MODULE04_DEMO" "GET /api/policy/senior-it-data" "Exercise 3 Senior IT"

echo ""
echo -e "${BLUE}Module 05 - Entity Framework Core Endpoints:${NC}"
MODULE05_DEMO="EFCoreDemo/wwwroot/index.html"

# Exercise 1 endpoints (Books CRUD)
check_endpoint_in_demo "$MODULE05_DEMO" "GET /api/books" "Exercise 1 Get Books"
check_endpoint_in_demo "$MODULE05_DEMO" "GET /api/books/{id}" "Exercise 1 Get Book by ID"
check_endpoint_in_demo "$MODULE05_DEMO" "POST /api/books" "Exercise 1 Create Book"
check_endpoint_in_demo "$MODULE05_DEMO" "PUT /api/books/{id}" "Exercise 1 Update Book"
check_endpoint_in_demo "$MODULE05_DEMO" "DELETE /api/books/{id}" "Exercise 1 Delete Book"

# Exercise 2 endpoints (LINQ Queries)
check_endpoint_in_demo "$MODULE05_DEMO" "GET /api/querytest/books-with-publishers" "Exercise 2 Books with Publishers"
check_endpoint_in_demo "$MODULE05_DEMO" "GET /api/querytest/books-by-author" "Exercise 2 Books by Author"
check_endpoint_in_demo "$MODULE05_DEMO" "GET /api/querytest/average-price-by-publisher" "Exercise 2 Average Price"
check_endpoint_in_demo "$MODULE05_DEMO" "GET /api/querytest/search" "Exercise 2 Search"

# Additional endpoints
check_endpoint_in_demo "$MODULE05_DEMO" "GET /api/products" "Product Catalog"

echo ""

# Test 3: Interactive Features Verification
echo -e "${PURPLE}3. INTERACTIVE FEATURES VERIFICATION${NC}"
echo "===================================="

echo -e "${BLUE}Module 04 Interactive Features:${NC}"
check_feature_in_demo "$MODULE04_DEMO" "async function login" "Login Function"
check_feature_in_demo "$MODULE04_DEMO" "copyToken" "Copy Token Function"
check_feature_in_demo "$MODULE04_DEMO" "testProtectedEndpoint" "Test Protected Function"
check_feature_in_demo "$MODULE04_DEMO" "loginForm" "Login Form"

echo ""
echo -e "${BLUE}Module 05 Interactive Features:${NC}"
check_feature_in_demo "$MODULE05_DEMO" "async function testQuery" "Test Query Function"
check_feature_in_demo "$MODULE05_DEMO" "queryDemo" "Query Demo Section"
check_feature_in_demo "$MODULE05_DEMO" "queryResults" "Query Results Display"

echo ""

# Test 4: Exercise References Verification
echo -e "${PURPLE}4. EXERCISE REFERENCES VERIFICATION${NC}"
echo "==================================="

echo -e "${BLUE}Checking exercise files reference demo pages:${NC}"

# Module 04 Exercise 1
if grep -q "Demo Application" "Module04-Authentication-and-Authorization/Exercises/Exercise01-JWT-Implementation.md"; then
    echo -e "${GREEN}✅ Module 04 Exercise 1 references demo page${NC}"
else
    echo -e "${RED}❌ Module 04 Exercise 1 missing demo reference${NC}"
    ((ERRORS++))
fi

# Module 05 Exercise 1
if grep -q "Demo Application" "Module05-Entity-Framework-Core/Exercises/Exercise01-Basic-EF-Core-Setup.md"; then
    echo -e "${GREEN}✅ Module 05 Exercise 1 references demo page${NC}"
else
    echo -e "${RED}❌ Module 05 Exercise 1 missing demo reference${NC}"
    ((ERRORS++))
fi

echo ""

# Test 5: Content Accuracy and Completeness
echo -e "${PURPLE}5. CONTENT ACCURACY VERIFICATION${NC}"
echo "================================="

echo -e "${BLUE}Module 04 Content Features:${NC}"
check_feature_in_demo "$MODULE04_DEMO" "JWT Authentication" "JWT Authentication"
check_feature_in_demo "$MODULE04_DEMO" "Role-based authorization" "Role-based Authorization"
check_feature_in_demo "$MODULE04_DEMO" "Custom authorization policies" "Custom Policies"
check_feature_in_demo "$MODULE04_DEMO" "admin/admin123" "Test User Admin"
check_feature_in_demo "$MODULE04_DEMO" "user/user123" "Test User Regular"

echo ""
echo -e "${BLUE}Module 05 Content Features:${NC}"
check_feature_in_demo "$MODULE05_DEMO" "Entity Framework Core" "Entity Framework Core"
check_feature_in_demo "$MODULE05_DEMO" "LINQ" "LINQ Queries"
check_feature_in_demo "$MODULE05_DEMO" "Repository" "Repository Pattern"
check_feature_in_demo "$MODULE05_DEMO" "Unit of Work" "Unit of Work"
check_feature_in_demo "$MODULE05_DEMO" "BookStore" "BookStore API"

echo ""

# Clean up
rm -rf JwtAuthenticationAPI EFCoreDemo

# Summary
echo "=================================================="
echo -e "${PURPLE}VERIFICATION SUMMARY${NC}"
echo "=================================================="

if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}🎉 PERFECT! All verifications passed!${NC}"
    echo ""
    echo -e "${GREEN}✅ Setup scripts work correctly${NC}"
    echo -e "${GREEN}✅ wwwroot content matches source code${NC}"
    echo -e "${GREEN}✅ All API endpoints are documented${NC}"
    echo -e "${GREEN}✅ Interactive features are present${NC}"
    echo -e "${GREEN}✅ Exercise references are correct${NC}"
    echo -e "${GREEN}✅ Content accuracy is verified${NC}"
    echo ""
    echo -e "${BLUE}🚀 MODULES ARE PRODUCTION-READY!${NC}"
elif [ $ERRORS -eq 0 ]; then
    echo -e "${YELLOW}⚠️  Verification completed with $WARNINGS warnings${NC}"
    echo -e "${GREEN}✅ No critical errors found${NC}"
    echo -e "${YELLOW}⚠️  Some optional features may be missing${NC}"
    echo ""
    echo -e "${BLUE}📚 MODULES ARE READY FOR CLASSROOM USE${NC}"
else
    echo -e "${RED}❌ Verification failed with $ERRORS errors and $WARNINGS warnings${NC}"
    echo -e "${YELLOW}⚠️  Critical issues need to be addressed${NC}"
fi

exit $ERRORS
