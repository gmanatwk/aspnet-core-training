#!/bin/bash

# Test script to verify Module 11 launch script fix
echo "🧪 Testing Module 11 launch script fix..."

# Clean up any existing project
if [ -d "AsyncDemo" ]; then
    echo "🧹 Cleaning up existing project..."
    rm -rf AsyncDemo
fi

# Test creating the project structure using the bash script
echo "📦 Testing project creation with bash script..."
./launch-exercises.sh exercise01

if [ $? -eq 0 ] && [ -d "AsyncDemo" ]; then
    echo "✅ Project created successfully with bash script"
    
    # Check if all required files exist
    echo "🔍 Checking required files..."
    
    required_files=(
        "AsyncDemo/Models/User.cs"
        "AsyncDemo/Data/IAsyncDataService.cs" 
        "AsyncDemo/Data/AsyncDataService.cs"
        "AsyncDemo/Services/AsyncBasicsService.cs"
    )
    
    all_files_exist=true
    for file in "${required_files[@]}"; do
        if [ -f "$file" ]; then
            echo "  ✅ $file exists"
        else
            echo "  ❌ $file missing"
            all_files_exist=false
        fi
    done
    
    if [ "$all_files_exist" = true ]; then
        echo "✅ All required files created"
        
        # Test build
        echo "🔨 Testing build..."
        cd AsyncDemo
        dotnet build --no-restore
        
        if [ $? -eq 0 ]; then
            echo "✅ Build successful! Module 11 fix verified."
            cd ..
            echo ""
            echo "🎉 Module 11 launch script fix completed successfully!"
            echo ""
            echo "📋 Fixed issues:"
            echo "  • Added User model to exercise01"
            echo "  • Added IAsyncDataService interface to exercise01" 
            echo "  • Added AsyncDataService implementation to exercise01"
            echo "  • Added GetDataWithTimeoutAsync method to AsyncBasicsService"
            echo "  • Removed duplicate code from exercise02"
            echo "  • Updated service registration instructions"
            echo ""
            echo "💡 The existing AsyncApiController should now compile without errors!"
            exit 0
        else
            echo "❌ Build failed. There may still be issues."
            cd ..
            exit 1
        fi
    else
        echo "❌ Some required files are missing"
        exit 1
    fi
else
    echo "❌ Project creation failed"
    exit 1
fi
