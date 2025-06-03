#!/bin/bash

echo "Setting up Module 02 - React Integration..."

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check for Node.js
if ! command_exists node; then
    echo "❌ Node.js is not installed. Please install Node.js (v18 or higher) from https://nodejs.org/"
    exit 1
fi

echo "✅ Node.js version: $(node --version)"

# Check for .NET SDK
if ! command_exists dotnet; then
    echo "❌ .NET SDK is not installed. Please install .NET 8 SDK from https://dotnet.microsoft.com/download"
    exit 1
fi

echo "✅ .NET SDK version: $(dotnet --version)"

# Install Node dependencies
echo "📦 Installing React dependencies..."
cd ClientApp
npm install

# Generate development certificates if needed
echo "🔐 Setting up HTTPS certificates..."
cd ..
dotnet dev-certs https --trust

echo "✅ Setup complete!"
echo ""
echo "To run the application:"
echo "1. Open a terminal and run: dotnet run"
echo "2. Open your browser to: https://localhost:7000"
echo ""
echo "The React dev server will start automatically on port 3000."
echo "API endpoints are available at: https://localhost:7000/swagger"