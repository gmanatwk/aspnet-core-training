# Module 04 - JWT Authentication API Docker Setup

This module demonstrates JWT authentication and authorization in ASP.NET Core with complete Docker support.

## 🚀 Quick Start with Docker

### Prerequisites
- Docker Desktop installed
- No need for .NET SDK locally!

### Running the Application

1. **Start the API with Docker Compose:**
   ```bash
   cd Module04-Authentication-and-Authorization/SourceCode
   docker-compose up
   ```

2. **Access the application:**
   - Swagger UI: http://localhost:5002/swagger
   - API Base URL: http://localhost:5002
   - Interactive UI: http://localhost:5002

### Test Credentials

The API includes pre-configured test users:

| Username    | Password   | Roles/Claims                           |
|-------------|------------|----------------------------------------|
| admin       | admin123   | Admin role, IT dept, age 38           |
| user        | user123    | User role                              |
| editor      | editor123  | Editor role, Content dept              |
| senior_dev  | senior123  | Employee role, IT dept, age 38        |
| junior_dev  | junior123  | Employee role, IT dept, age 22        |

## 📝 Testing the API

### 1. Get JWT Token
```bash
curl -X POST http://localhost:5002/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username": "admin", "password": "admin123"}'
```

### 2. Use Token for Protected Endpoints
```bash
curl -X GET http://localhost:5002/api/auth/protected \
  -H "Authorization: Bearer YOUR_JWT_TOKEN_HERE"
```

## 🛠️ Development Features

- **Hot Reload**: Code changes automatically restart the container
- **Volume Mapping**: Edit code locally, see changes immediately
- **No Local Dependencies**: Everything runs in Docker

## 📋 Available Endpoints

### Authentication
- `POST /api/auth/login` - Get JWT token
- `POST /api/auth/register` - Register new user
- `GET /api/auth/protected` - Test authentication

### Role-Based Authorization
- `GET /api/admin/dashboard` - Admin only
- `GET /api/editor/content` - Editor or Admin
- `GET /api/users/profile` - Any authenticated user

### Policy-Based Authorization
- `GET /api/policy/adult-content` - Age 18+ required
- `GET /api/policy/it-resources` - IT department only
- `GET /api/policy/business-hours` - Access during 9-5 only
- `GET /api/policy/senior-it-data` - Complex policy example

## 🔧 Docker Commands

### Start Services
```bash
docker-compose up        # Run with logs
docker-compose up -d     # Run in background
```

### Stop Services
```bash
docker-compose down      # Stop and remove containers
```

### View Logs
```bash
docker-compose logs -f jwt-api
```

### Rebuild After Code Changes
```bash
docker-compose build
docker-compose up
```

## 🏭 Production Deployment

For production deployment:
```bash
docker-compose -f docker-compose.prod.yml up -d
```

## 🎓 Learning Objectives Covered

✅ JWT token generation and validation  
✅ Role-based authorization  
✅ Policy-based authorization  
✅ Custom authorization handlers  
✅ Swagger integration with JWT  
✅ CORS configuration  
✅ Containerized development environment

## 🔍 Troubleshooting

### Container Won't Start
- Check if port 5002 is already in use
- Run `docker-compose logs` to see error details

### Can't Access API
- Ensure Docker Desktop is running
- Check container status: `docker ps`
- Verify URL: http://localhost:5002 (not https)

### Authentication Issues
- Token format: `Authorization: Bearer <token>`
- Check token expiration (60 minutes by default)
- Verify username/password from test users list

## 📚 Next Steps

After completing this module:
1. Try implementing additional authorization policies
2. Add more complex role hierarchies
3. Integrate with external authentication providers
4. Move to Module 05 - Entity Framework Core