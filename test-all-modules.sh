#!/bin/bash

# Test script for all ASP.NET Core training modules
# This script builds each module and reports the results

echo "========================================="
echo "ASP.NET Core Training Modules Test Report"
echo "========================================="
echo ""

# Color codes for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to test a project
test_project() {
    local project_path="$1"
    local project_name="$2"
    
    echo -n "Testing $project_name... "
    
    if [ -f "$project_path" ]; then
        cd "$(dirname "$project_path")"
        if dotnet build --nologo --verbosity quiet > /dev/null 2>&1; then
            echo -e "${GREEN}✓ BUILD SUCCESS${NC}"
            return 0
        else
            echo -e "${RED}✗ BUILD FAILED${NC}"
            return 1
        fi
    else
        echo -e "${RED}✗ PROJECT NOT FOUND${NC}"
        return 1
    fi
}

# Initialize counters
total_projects=0
successful_builds=0
failed_builds=0

# Module 01
echo "Module 01 - Introduction to ASP.NET Core"
echo "----------------------------------------"
test_project "Module01-Introduction-to-ASP.NET-Core/SourceCode/BasicWebApp/BasicWebApp.csproj" "BasicWebApp"
((total_projects++))
[ $? -eq 0 ] && ((successful_builds++)) || ((failed_builds++))
echo ""

# Module 02
echo "Module 02 - ASP.NET Core with React"
echo "------------------------------------"
test_project "Module02-ASP.NET-Core-with-React/SourceCode/ReactIntegration/ReactIntegration.csproj" "ReactIntegration"
((total_projects++))
[ $? -eq 0 ] && ((successful_builds++)) || ((failed_builds++))
echo ""

# Module 03
echo "Module 03 - Working with Web APIs"
echo "----------------------------------"
test_project "Module03-Working-with-Web-APIs/SourceCode/RestfulAPI/RestfulAPI.csproj" "RestfulAPI"
((total_projects++))
[ $? -eq 0 ] && ((successful_builds++)) || ((failed_builds++))
echo ""

# Module 04
echo "Module 04 - Authentication and Authorization"
echo "--------------------------------------------"
test_project "Module04-Authentication-and-Authorization/SourceCode/JwtAuthenticationAPI/JwtAuthenticationAPI.csproj" "JwtAuthenticationAPI"
((total_projects++))
[ $? -eq 0 ] && ((successful_builds++)) || ((failed_builds++))
echo ""

# Module 05
echo "Module 05 - Entity Framework Core"
echo "----------------------------------"
test_project "Module05-Entity-Framework-Core/SourceCode/EFCoreDemo/EFCoreDemo.csproj" "EFCoreDemo"
((total_projects++))
[ $? -eq 0 ] && ((successful_builds++)) || ((failed_builds++))
echo ""

# Module 06
echo "Module 06 - Debugging and Troubleshooting"
echo "-----------------------------------------"
test_project "Module06-Debugging-and-Troubleshooting/SourceCode/DebuggingDemo/DebuggingDemo.csproj" "DebuggingDemo"
((total_projects++))
[ $? -eq 0 ] && ((successful_builds++)) || ((failed_builds++))
echo ""

# Module 07
echo "Module 07 - Testing Applications"
echo "---------------------------------"
test_project "Module07-Testing-Applications/SourceCode/ProductCatalog.API/ProductCatalog.API.csproj" "ProductCatalog.API"
((total_projects++))
[ $? -eq 0 ] && ((successful_builds++)) || ((failed_builds++))
test_project "Module07-Testing-Applications/SourceCode/ProductCatalog.UnitTests/ProductCatalog.UnitTests.csproj" "ProductCatalog.UnitTests"
((total_projects++))
[ $? -eq 0 ] && ((successful_builds++)) || ((failed_builds++))
test_project "Module07-Testing-Applications/SourceCode/ProductCatalog.IntegrationTests/ProductCatalog.IntegrationTests.csproj" "ProductCatalog.IntegrationTests"
((total_projects++))
[ $? -eq 0 ] && ((successful_builds++)) || ((failed_builds++))
test_project "Module07-Testing-Applications/SourceCode/ProductCatalog.PerformanceTests/ProductCatalog.PerformanceTests.csproj" "ProductCatalog.PerformanceTests"
((total_projects++))
[ $? -eq 0 ] && ((successful_builds++)) || ((failed_builds++))
echo ""

# Module 08
echo "Module 08 - Performance Optimization"
echo "------------------------------------"
test_project "Module08-Performance-Optimization/SourceCode/PerformanceDemo/PerformanceDemo.csproj" "PerformanceDemo"
((total_projects++))
[ $? -eq 0 ] && ((successful_builds++)) || ((failed_builds++))
echo ""

# Module 09
echo "Module 09 - Azure Container Apps"
echo "---------------------------------"
test_project "Module09-Azure-Container-Apps/SourceCode/ContainerAppsDemo/ProductApi/ProductApi.csproj" "ProductApi"
((total_projects++))
[ $? -eq 0 ] && ((successful_builds++)) || ((failed_builds++))
echo ""

# Module 10
echo "Module 10 - Security Fundamentals"
echo "----------------------------------"
test_project "Module10-Security-Fundamentals/SourceCode/01-SecurityHeaders/SecurityHeaders.csproj" "SecurityHeaders"
((total_projects++))
[ $? -eq 0 ] && ((successful_builds++)) || ((failed_builds++))
test_project "Module10-Security-Fundamentals/SourceCode/02-InputValidation/InputValidation.csproj" "InputValidation"
((total_projects++))
[ $? -eq 0 ] && ((successful_builds++)) || ((failed_builds++))
echo ""

# Module 11
echo "Module 11 - Asynchronous Programming"
echo "-------------------------------------"
test_project "Module11-Asynchronous-Programming/SourceCode/01-BasicAsync/BasicAsync.csproj" "BasicAsync"
((total_projects++))
[ $? -eq 0 ] && ((successful_builds++)) || ((failed_builds++))
test_project "Module11-Asynchronous-Programming/SourceCode/02-AsyncControllers/AsyncControllers.csproj" "AsyncControllers"
((total_projects++))
[ $? -eq 0 ] && ((successful_builds++)) || ((failed_builds++))
test_project "Module11-Asynchronous-Programming/SourceCode/03-AsyncDatabase/AsyncDatabase.csproj" "AsyncDatabase"
((total_projects++))
[ $? -eq 0 ] && ((successful_builds++)) || ((failed_builds++))
test_project "Module11-Asynchronous-Programming/SourceCode/04-ConcurrentOperations/ConcurrentOperations.csproj" "ConcurrentOperations"
((total_projects++))
[ $? -eq 0 ] && ((successful_builds++)) || ((failed_builds++))
test_project "Module11-Asynchronous-Programming/SourceCode/05-BackgroundServices/BackgroundServices.csproj" "BackgroundServices"
((total_projects++))
[ $? -eq 0 ] && ((successful_builds++)) || ((failed_builds++))
test_project "Module11-Asynchronous-Programming/SourceCode/06-ComprehensiveExample/ComprehensiveExample.csproj" "ComprehensiveExample"
((total_projects++))
[ $? -eq 0 ] && ((successful_builds++)) || ((failed_builds++))
echo ""

# Module 12
echo "Module 12 - Dependency Injection and Middleware"
echo "-----------------------------------------------"
test_project "Module12-Dependency-Injection-and-Middleware/SourceCode/DILifetimeDemo/DILifetimeDemo.csproj" "DILifetimeDemo"
((total_projects++))
[ $? -eq 0 ] && ((successful_builds++)) || ((failed_builds++))
echo ""

# Module 13
echo "Module 13 - Building Microservices"
echo "-----------------------------------"
test_project "Module13-Building-Microservices/SourceCode/ECommerceMS/ProductService/ProductService.csproj" "ProductService"
((total_projects++))
[ $? -eq 0 ] && ((successful_builds++)) || ((failed_builds++))
test_project "Module13-Building-Microservices/SourceCode/ECommerceMS/OrderService/OrderService.csproj" "OrderService"
((total_projects++))
[ $? -eq 0 ] && ((successful_builds++)) || ((failed_builds++))
test_project "Module13-Building-Microservices/SourceCode/ECommerceMS/CustomerService/CustomerService.csproj" "CustomerService"
((total_projects++))
[ $? -eq 0 ] && ((successful_builds++)) || ((failed_builds++))
test_project "Module13-Building-Microservices/SourceCode/ECommerceMS/ApiGateway/ApiGateway.csproj" "ApiGateway"
((total_projects++))
[ $? -eq 0 ] && ((successful_builds++)) || ((failed_builds++))
test_project "Module13-Building-Microservices/SourceCode/ECommerceMS/SharedLibrary/SharedLibrary.csproj" "SharedLibrary"
((total_projects++))
[ $? -eq 0 ] && ((successful_builds++)) || ((failed_builds++))
echo ""

# Summary
echo "========================================="
echo "TEST SUMMARY"
echo "========================================="
echo "Total Projects Tested: $total_projects"
echo -e "Successful Builds: ${GREEN}$successful_builds${NC}"
echo -e "Failed Builds: ${RED}$failed_builds${NC}"
echo ""

if [ $failed_builds -eq 0 ]; then
    echo -e "${GREEN}✓ All modules build successfully!${NC}"
    exit 0
else
    echo -e "${RED}✗ Some modules failed to build${NC}"
    exit 1
fi