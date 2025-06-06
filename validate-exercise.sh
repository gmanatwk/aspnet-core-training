#!/bin/bash
# Exercise validation script
EXERCISE=$1

echo "🔍 Validating exercise: $EXERCISE"

# Check if project builds
echo -n "Checking if project builds... "
if dotnet build --nologo --verbosity quiet > /dev/null 2>&1; then
    echo "✅"
else
    echo "❌"
    echo "Build failed. Run 'dotnet build' to see errors."
    exit 1
fi

# Check for remaining TODOs
echo -n "Checking for incomplete TODOs... "
TODO_COUNT=$(grep -r "TODO" . --include="*.cs" --include="*.tsx" --include="*.ts" | wc -l)
if [ $TODO_COUNT -gt 0 ]; then
    echo "⚠️  Found $TODO_COUNT TODOs"
else
    echo "✅"
fi

# Run tests if they exist
if [ -f "*.Tests.csproj" ]; then
    echo -n "Running tests... "
    if dotnet test --nologo --verbosity quiet > /dev/null 2>&1; then
        echo "✅"
    else
        echo "❌"
    fi
fi

echo ""
echo "Validation complete!"

