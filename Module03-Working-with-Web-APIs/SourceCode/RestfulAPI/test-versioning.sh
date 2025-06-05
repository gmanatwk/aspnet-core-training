#!/bin/bash

echo "Testing API Versioning"
echo "====================="

# Base URL
BASE_URL="http://localhost:5000"

echo -e "\n1. Testing URL Segment Versioning"
echo "--------------------------------"
echo "V1: GET $BASE_URL/api/v1/products"
curl -s "$BASE_URL/api/v1/products" | jq '.data[0] | {id, name, category}' 2>/dev/null || echo "API might not be running"

echo -e "\n\nV2: GET $BASE_URL/api/v2/products"
curl -s "$BASE_URL/api/v2/products" | jq '.metadata' 2>/dev/null || echo "API might not be running"

echo -e "\n\n2. Testing Query String Versioning"
echo "-----------------------------------"
echo "V1: GET $BASE_URL/api/products?api-version=1.0"
curl -s "$BASE_URL/api/products?api-version=1.0" -H "Accept: application/json" | jq '.data[0] | {id, name}' 2>/dev/null || echo "Note: This might return 404 if route doesn't support query string versioning"

echo -e "\n\n3. Testing Header Versioning"
echo "----------------------------"
echo "V1: GET $BASE_URL/api/products with X-Version: 1.0"
curl -s "$BASE_URL/api/products" -H "X-Version: 1.0" -H "Accept: application/json" | jq '.data[0] | {id, name}' 2>/dev/null || echo "Note: This might return 404 if route doesn't support header versioning"

echo -e "\n\n4. Testing V2 Exclusive Features"
echo "--------------------------------"
echo "Statistics: GET $BASE_URL/api/v2/products/statistics"
curl -s "$BASE_URL/api/v2/products/statistics" | jq '.' 2>/dev/null || echo "API might not be running"

echo -e "\n\n5. Checking API Version Headers"
echo "-------------------------------"
echo "Headers from V2 endpoint:"
curl -sI "$BASE_URL/api/v2/products" | grep -E "(X-API-Version|api-supported-versions)" || echo "API might not be running"

echo -e "\n\nDone! If you see 'API might not be running', please start the API with 'dotnet run'"