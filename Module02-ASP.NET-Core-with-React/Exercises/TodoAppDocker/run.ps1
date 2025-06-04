# Build and run in production mode
docker-compose up --build

# Or run in development mode with hot reload
docker-compose -f docker-compose.dev.yml up --build

# Run in background
docker-compose up -d --build