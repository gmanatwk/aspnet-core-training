#!/bin/bash

# Bash script to start the SSR vs CSR demonstration
# This script starts all three applications needed for the demo

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Default options
SKIP_INSTALL=false
API_ONLY=false
SHOW_HELP=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --skip-install)
            SKIP_INSTALL=true
            shift
            ;;
        --api-only)
            API_ONLY=true
            shift
            ;;
        --help|-h)
            SHOW_HELP=true
            shift
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            exit 1
            ;;
    esac
done

if [ "$SHOW_HELP" = true ]; then
    echo -e "${CYAN}SSR vs CSR Demo Startup Script${NC}"
    echo ""
    echo -e "${YELLOW}Usage: ./start-ssr-demo.sh [options]${NC}"
    echo ""
    echo -e "${GREEN}Options:${NC}"
    echo "  --skip-install    Skip npm install steps"
    echo "  --api-only        Start only the ASP.NET Core API"
    echo "  --help, -h        Show this help message"
    echo ""
    echo -e "${CYAN}This script will start:${NC}"
    echo "  1. ASP.NET Core API (Port 5000)"
    echo "  2. React SPA - CSR (Port 5173)"
    echo "  3. Next.js SSR (Port 3001)"
    echo ""
    exit 0
fi

echo -e "${MAGENTA}🚀 Starting SSR vs CSR Demonstration${NC}"
echo -e "${CYAN}==================================================${NC}"

# Function to check if a port is in use
check_port() {
    local port=$1
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1; then
        return 0  # Port is in use
    else
        return 1  # Port is free
    fi
}

# Function to cleanup background processes
cleanup() {
    echo ""
    echo -e "${YELLOW}🛑 Stopping all applications...${NC}"
    
    # Kill background jobs
    jobs -p | xargs -r kill 2>/dev/null
    
    # Kill processes by port if they're still running
    for port in 5000 5173 3001; do
        if check_port $port; then
            echo -e "${YELLOW}Stopping process on port $port...${NC}"
            lsof -ti:$port | xargs -r kill -9 2>/dev/null
        fi
    done
    
    echo -e "${GREEN}✅ All applications stopped${NC}"
    exit 0
}

# Set up signal handlers
trap cleanup SIGINT SIGTERM

# Check prerequisites
echo -e "${YELLOW}🔍 Checking prerequisites...${NC}"

# Check .NET
if command -v dotnet &> /dev/null; then
    DOTNET_VERSION=$(dotnet --version)
    echo -e "${GREEN}✅ .NET SDK: $DOTNET_VERSION${NC}"
else
    echo -e "${RED}❌ .NET SDK not found. Please install .NET 8.0 SDK${NC}"
    exit 1
fi

# Check Node.js
if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version)
    echo -e "${GREEN}✅ Node.js: $NODE_VERSION${NC}"
else
    echo -e "${RED}❌ Node.js not found. Please install Node.js 18+${NC}"
    exit 1
fi

# Check for port conflicts
PORTS=(5000 5173 3001)
CONFLICTS=()

for port in "${PORTS[@]}"; do
    if check_port $port; then
        CONFLICTS+=($port)
    fi
done

if [ ${#CONFLICTS[@]} -gt 0 ]; then
    echo -e "${YELLOW}⚠️  Port conflicts detected: ${CONFLICTS[*]}${NC}"
    echo -e "${YELLOW}Please stop applications using these ports or they will fail to start.${NC}"
    echo ""
fi

# Install dependencies if not skipped
if [ "$SKIP_INSTALL" = false ]; then
    echo -e "${YELLOW}📦 Installing dependencies...${NC}"
    
    # Install React SPA dependencies
    if [ -f "ClientApp/package.json" ]; then
        echo -e "${CYAN}Installing React SPA dependencies...${NC}"
        cd ClientApp
        npm install
        cd ..
    fi
    
    # Install Next.js dependencies
    if [ -f "NextJsApp/package.json" ]; then
        echo -e "${CYAN}Installing Next.js dependencies...${NC}"
        cd NextJsApp
        npm install
        cd ..
    fi
    
    echo -e "${GREEN}✅ Dependencies installed${NC}"
fi

echo ""
echo -e "${YELLOW}🎯 Starting applications...${NC}"

# Start ASP.NET Core API
echo -e "${CYAN}Starting ASP.NET Core API (Port 5000)...${NC}"
dotnet run --urls "http://localhost:5000" > /dev/null 2>&1 &
API_PID=$!

sleep 3

if [ "$API_ONLY" = true ]; then
    echo -e "${GREEN}✅ API started successfully!${NC}"
    echo ""
    echo -e "${CYAN}🌐 Access Points:${NC}"
    echo -e "${WHITE}  API: http://localhost:5000${NC}"
    echo -e "${WHITE}  Swagger: http://localhost:5000/swagger${NC}"
    echo ""
    echo -e "${YELLOW}Press Ctrl+C to stop the API${NC}"
    
    wait $API_PID
    exit 0
fi

# Start React SPA (CSR)
echo -e "${CYAN}Starting React SPA - CSR (Port 5173)...${NC}"
cd ClientApp
npm run dev > /dev/null 2>&1 &
REACT_PID=$!
cd ..

sleep 2

# Start Next.js SSR
echo -e "${CYAN}Starting Next.js SSR (Port 3001)...${NC}"
cd NextJsApp
npm run dev > /dev/null 2>&1 &
NEXT_PID=$!
cd ..

sleep 5

echo ""
echo -e "${GREEN}🎉 All applications started!${NC}"
echo -e "${CYAN}==================================================${NC}"
echo ""
echo -e "${CYAN}🌐 Access Points:${NC}"
echo -e "${WHITE}  📊 ASP.NET Core API: http://localhost:5000${NC}"
echo -e "${WHITE}  📚 API Documentation: http://localhost:5000/swagger${NC}"
echo -e "${YELLOW}  💻 React SPA (CSR): http://localhost:5173${NC}"
echo -e "${BLUE}  🚀 Next.js SSR: http://localhost:3001${NC}"
echo ""
echo -e "${MAGENTA}🎓 Teaching Demonstrations:${NC}"
echo -e "${WHITE}  1. Compare initial loading (throttle network to Slow 3G)${NC}"
echo -e "${WHITE}  2. View page source (Right-click → View Page Source)${NC}"
echo -e "${WHITE}  3. Disable JavaScript (DevTools → Settings → Disable JS)${NC}"
echo -e "${WHITE}  4. Run Lighthouse audits on both applications${NC}"
echo ""
echo -e "${CYAN}📖 For detailed teaching guide, see: SSR-vs-CSR-TEACHING-GUIDE.md${NC}"
echo ""
echo -e "${YELLOW}Press Ctrl+C to stop all applications${NC}"

# Wait for any background process to finish (or Ctrl+C)
wait
