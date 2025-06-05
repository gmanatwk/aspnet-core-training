#!/bin/bash

echo "Verifying all links from index.html"
echo "===================================="

BASE_URL="http://localhost:5000"

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to test endpoint
test_endpoint() {
    local url=$1
    local description=$2
    local method=${3:-GET}
    local expected_status=${4:-200}
    
    echo -n "Testing $description ($url)... "
    
    if [ "$method" == "GET" ]; then
        status=$(curl -s -o /dev/null -w "%{http_code}" "$BASE_URL$url")
    else
        status=$(curl -s -o /dev/null -w "%{http_code}" -X "$method" "$BASE_URL$url" -H "Content-Type: application/json")
    fi
    
    if [ "$status" == "$expected_status" ]; then
        echo -e "${GREEN}✓ OK (Status: $status)${NC}"
    elif [ "$status" == "000" ]; then
        echo -e "${RED}✗ FAILED (Connection refused - is the API running?)${NC}"
    else
        echo -e "${YELLOW}! WARNING (Status: $status, Expected: $expected_status)${NC}"
    fi
}

echo -e "\n1. Testing main pages from index.html:"
echo "--------------------------------------"
test_endpoint "/" "Home Page" "GET" "200"
test_endpoint "/swagger" "Swagger UI" "GET" "200"
test_endpoint "/swagger/index.html" "Swagger UI HTML" "GET" "200"
test_endpoint "/health" "Health Check" "GET" "200"

echo -e "\n2. Testing Products API v1:"
echo "---------------------------"
test_endpoint "/api/v1/products" "Products v1 - List" "GET" "200"
test_endpoint "/api/v1/products/1" "Products v1 - Get by ID" "GET" "200"
test_endpoint "/api/v1/products/999" "Products v1 - Not Found" "GET" "404"
test_endpoint "/api/v1/products/categories" "Products v1 - Categories" "GET" "200"
test_endpoint "/api/v1/products/search?query=test" "Products v1 - Search" "GET" "200"
test_endpoint "/api/v1/products/secure" "Products v1 - Secure (no auth)" "GET" "401"

echo -e "\n3. Testing Products API v2:"
echo "---------------------------"
test_endpoint "/api/v2/products" "Products v2 - List" "GET" "200"
test_endpoint "/api/v2/products/1" "Products v2 - Get by ID" "GET" "200"
test_endpoint "/api/v2/products/statistics" "Products v2 - Statistics" "GET" "200"
test_endpoint "/api/v2/products/export" "Products v2 - Export CSV" "GET" "200"
test_endpoint "/api/v2/products/bulk" "Products v2 - Bulk (no body)" "POST" "400"

echo -e "\n4. Testing Minimal API:"
echo "----------------------"
test_endpoint "/api/minimal/products" "Minimal API - List" "GET" "200"
test_endpoint "/api/minimal/products/1" "Minimal API - Get by ID" "GET" "200"

echo -e "\n5. Testing Authentication API:"
echo "-----------------------------"
test_endpoint "/api/auth/login" "Auth - Login (no body)" "POST" "400"
test_endpoint "/api/auth/register" "Auth - Register (no body)" "POST" "400"
test_endpoint "/api/auth/profile" "Auth - Profile (no auth)" "GET" "401"
test_endpoint "/api/auth/test" "Auth - Test (no auth)" "GET" "401"

echo -e "\n6. Testing versioning methods:"
echo "-----------------------------"
# Query string versioning (may not work if routes don't support it)
test_endpoint "/api/products?api-version=1.0" "Query String v1" "GET" "404"
test_endpoint "/api/products?api-version=2.0" "Query String v2" "GET" "404"

echo -e "\n7. Testing static files:"
echo "-----------------------"
test_endpoint "/index.html" "Index HTML" "GET" "200"
test_endpoint "/css/site.css" "Site CSS" "GET" "200"
test_endpoint "/js/site.js" "Site JS" "GET" "200"

echo -e "\n===================================="
echo "Test Summary:"
echo -e "${GREEN}✓${NC} = Working as expected"
echo -e "${YELLOW}!${NC} = Different status than expected"
echo -e "${RED}✗${NC} = Connection failed"
echo ""
echo "Note: Some endpoints may return 400/401/404 as expected behavior"
echo "Make sure the API is running with: dotnet run"