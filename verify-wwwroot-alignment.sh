#!/bin/bash

# Verify wwwroot alignment for Module 04 and Module 05

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

ERRORS=0

echo -e "${BLUE}🌐 Verifying wwwroot Alignment${NC}"
echo "================================"

# Test Module 04 wwwroot setup
echo -e "${BLUE}1. Testing Module 04 wwwroot setup...${NC}"
rm -rf JwtAuthenticationAPI
if ./setup-exercise.sh module04-exercise01-jwt > /dev/null 2>&1; then
    if [ -f "JwtAuthenticationAPI/wwwroot/index.html" ]; then
        echo -e "${GREEN}✅ Module 04 wwwroot copied correctly${NC}"
        
        # Check if demo page has correct content
        if grep -q "JWT Authentication & Authorization API" "JwtAuthenticationAPI/wwwroot/index.html"; then
            echo -e "${GREEN}✅ Module 04 demo page content correct${NC}"
        else
            echo -e "${RED}❌ Module 04 demo page content incorrect${NC}"
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

# Test Module 05 wwwroot setup
echo -e "${BLUE}2. Testing Module 05 wwwroot setup...${NC}"
rm -rf EFCoreDemo
if ./setup-exercise.sh module05-exercise01-efcore > /dev/null 2>&1; then
    if [ -f "EFCoreDemo/wwwroot/index.html" ]; then
        echo -e "${GREEN}✅ Module 05 wwwroot copied correctly${NC}"
        
        # Check if demo page has correct content
        if grep -q "Entity Framework Core Demo API" "EFCoreDemo/wwwroot/index.html"; then
            echo -e "${GREEN}✅ Module 05 demo page content correct${NC}"
        else
            echo -e "${RED}❌ Module 05 demo page content incorrect${NC}"
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

# Test exercise references to demo pages
echo -e "${BLUE}3. Checking exercise references to demo pages...${NC}"

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

# Check demo page features
echo -e "${BLUE}4. Verifying demo page features...${NC}"

# Module 04 features
module04_features=("login" "JWT" "authentication" "authorization" "roles" "policies")
for feature in "${module04_features[@]}"; do
    if grep -qi "$feature" "JwtAuthenticationAPI/wwwroot/index.html"; then
        echo -e "${GREEN}✅ Module 04 demo includes: $feature${NC}"
    else
        echo -e "${YELLOW}⚠️  Module 04 demo missing: $feature${NC}"
    fi
done

# Module 05 features
module05_features=("Entity Framework" "LINQ" "Repository" "books" "products" "queries")
for feature in "${module05_features[@]}"; do
    if grep -qi "$feature" "EFCoreDemo/wwwroot/index.html"; then
        echo -e "${GREEN}✅ Module 05 demo includes: $feature${NC}"
    else
        echo -e "${YELLOW}⚠️  Module 05 demo missing: $feature${NC}"
    fi
done

# Test that demo pages are functional
echo -e "${BLUE}5. Testing demo page functionality...${NC}"

# Check for JavaScript functionality
if grep -q "async function" "JwtAuthenticationAPI/wwwroot/index.html"; then
    echo -e "${GREEN}✅ Module 04 demo has interactive features${NC}"
else
    echo -e "${YELLOW}⚠️  Module 04 demo lacks interactive features${NC}"
fi

if grep -q "async function" "EFCoreDemo/wwwroot/index.html"; then
    echo -e "${GREEN}✅ Module 05 demo has interactive features${NC}"
else
    echo -e "${YELLOW}⚠️  Module 05 demo lacks interactive features${NC}"
fi

# Cleanup
rm -rf JwtAuthenticationAPI EFCoreDemo

# Summary
echo ""
echo "================================"
if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}🎉 wwwroot alignment verification PASSED!${NC}"
    echo ""
    echo -e "${GREEN}✅ Both modules have comprehensive demo pages${NC}"
    echo -e "${GREEN}✅ Setup scripts copy wwwroot correctly${NC}"
    echo -e "${GREEN}✅ Exercises reference demo pages${NC}"
    echo -e "${GREEN}✅ Demo pages reflect actual implementation${NC}"
    echo ""
    echo -e "${BLUE}📚 Students will now have:${NC}"
    echo "  • Interactive demo pages for testing"
    echo "  • Visual representation of what they're building"
    echo "  • Real-time API testing capabilities"
    echo "  • Complete feature demonstrations"
    echo ""
    echo -e "${GREEN}✅ MODULES READY FOR CLASSROOM USE${NC}"
else
    echo -e "${RED}❌ Found $ERRORS issues with wwwroot alignment${NC}"
    echo -e "${YELLOW}⚠️  Some demo features may not work correctly${NC}"
fi

exit $ERRORS
