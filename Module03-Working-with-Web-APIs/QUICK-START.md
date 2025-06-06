# Module 03 - Quick Start Guide

## 🎯 RECOMMENDED: Use the Complete Working Implementation

The **SourceCode** folder contains a complete, production-ready implementation that matches all exercises perfectly.

### Option 1: API Only (Fastest)
```bash
cd SourceCode/RestfulAPI
dotnet run
```
- **Swagger UI**: http://localhost:5000
- **API**: http://localhost:5000/api/v1/products

### Option 2: Full-Stack with Docker (Best Experience)
```bash
cd SourceCode
docker-compose up --build
```
- **React Frontend**: http://localhost:3000
- **API**: http://localhost:5001
- **Swagger UI**: http://localhost:5001

## 🔧 What's Included in SourceCode

### ✅ Complete Products API
- Full CRUD operations for Products
- JWT Authentication & Authorization
- API Versioning (v1 and v2)
- Swagger/OpenAPI documentation
- Entity Framework with SQL Server + In-memory fallback
- Comprehensive error handling
- Health checks and monitoring

### ✅ Modern React Frontend
- TypeScript + React 18
- Vite for fast development
- React Query for data fetching
- Full product management UI
- Authentication integration

### ✅ Production Features
- Docker containerization
- Comprehensive test suite (50+ tests)
- CORS configuration
- Response caching and compression
- Global exception handling
- Request/response logging

## 📚 Exercise Alignment

All exercises are designed to work with the **SourceCode** implementation:

- **Exercise 01**: Basic CRUD API ✅ (Complete in SourceCode)
- **Exercise 02**: Authentication & Security ✅ (Complete in SourceCode)  
- **Exercise 03**: Documentation & Versioning ✅ (Complete in SourceCode)

## 🛠️ Alternative: Basic Template

If you prefer to build from scratch, use the launch script:

```bash
./launch-exercises.sh exercise01
```

**Note**: The template is basic and may not match all exercise requirements. The SourceCode version is recommended for the best learning experience.

## 🧪 Testing the API

### Test Credentials (SourceCode version)
- **Admin**: `admin@test.com` / `Admin123!`
- **Manager**: `manager@test.com` / `Manager123!`
- **User**: `user@test.com` / `User123!`

### Key Endpoints
- `GET /api/v1/products` - Get all products
- `POST /api/v1/products` - Create product
- `POST /api/auth/login` - Login
- `GET /health` - Health check

## 🚀 Ready to Start?

1. **Choose your approach** (SourceCode recommended)
2. **Follow the setup instructions** above
3. **Open Swagger UI** to explore the API
4. **Complete the exercises** using the working implementation

The SourceCode version is production-ready and perfect for learning! 🎯
