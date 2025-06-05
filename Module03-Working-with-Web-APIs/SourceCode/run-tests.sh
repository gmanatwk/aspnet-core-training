#!/bin/bash

echo "Running Module 03 - Web API Tests"
echo "================================="

cd RestfulAPI.Tests

echo "Restoring packages..."
dotnet restore

echo "Building test project..."
dotnet build

echo "Running tests..."
dotnet test --logger "console;verbosity=normal"

echo "Test execution completed!"