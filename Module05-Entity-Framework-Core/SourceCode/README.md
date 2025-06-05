# Module 05 - Entity Framework Core Docker Setup

This module demonstrates Entity Framework Core with SQL Server in a fully containerized environment.

## 🚀 Quick Start with Docker

### Prerequisites
- Docker Desktop installed
- No need for SQL Server or .NET SDK locally!

### Running the Application

1. **Start all services with Docker Compose:**
   ```bash
   cd Module05-Entity-Framework-Core/SourceCode
   docker-compose up -d
   ```

2. **Wait for SQL Server to initialize (30 seconds), then run migrations:**
   ```bash
   ./docker-init.sh
   ```
   
   Or manually:
   ```bash
   # For Product Catalog database
   docker exec efcore-demo-api dotnet ef database update --context ProductCatalogContext
   
   # For Book Store database
   docker exec efcore-demo-api dotnet ef database update --context BookStoreContext
   ```

3. **Access the application:**
   - Swagger UI: http://localhost:5003/swagger
   - API Base URL: http://localhost:5003
   - SQL Server: localhost:1434 (user: sa, password: YourStrong@Passw0rd123)

## 📊 Database Information

This demo uses two databases to showcase multiple DbContext scenarios:

1. **EFCoreDemoDB** - Product catalog with categories
2. **BookStoreDB** - Book store with authors and books

## 🛠️ Development Features

- **Hot Reload**: Code changes automatically restart the container
- **SQL Server Management**: Connect using Azure Data Studio or SSMS
  - Server: `localhost,1434`
  - Username: `sa`
  - Password: `YourStrong@Passw0rd123`
- **Persistent Data**: Database data persists in Docker volumes

## 📋 Available Endpoints

### Products API
- `GET /api/products` - Get all products with pagination
- `GET /api/products/{id}` - Get product by ID
- `POST /api/products` - Create new product
- `PUT /api/products/{id}` - Update product
- `DELETE /api/products/{id}` - Delete product

### Categories API
- `GET /api/categories` - Get all categories
- `GET /api/categories/{id}` - Get category with products

### Books API
- `GET /api/books` - Get all books
- `GET /api/books/{id}` - Get book details
- `GET /api/books/by-author/{authorId}` - Get books by author

### Query Test API
- `GET /api/querytest/linq-examples` - Various LINQ query demonstrations
- `GET /api/querytest/performance-test` - Query performance examples

## 🔧 Entity Framework Commands

### Create a new migration:
```bash
# Product Catalog
docker exec efcore-demo-api dotnet ef migrations add YourMigrationName --context ProductCatalogContext

# Book Store
docker exec efcore-demo-api dotnet ef migrations add YourMigrationName --context BookStoreContext
```

### Update database:
```bash
docker exec efcore-demo-api dotnet ef database update --context ProductCatalogContext
docker exec efcore-demo-api dotnet ef database update --context BookStoreContext
```

### View existing migrations:
```bash
docker exec efcore-demo-api dotnet ef migrations list --context ProductCatalogContext
```

## 🎓 Learning Objectives Covered

✅ Multiple DbContext configuration  
✅ Code-First approach with migrations  
✅ Repository pattern implementation  
✅ Unit of Work pattern  
✅ LINQ queries and performance optimization  
✅ Entity relationships (1-to-many, many-to-many)  
✅ Data seeding and initialization  
✅ DTO mapping with AutoMapper  

## 🔍 Troubleshooting

### Database Connection Issues
- Ensure SQL Server container is fully started (takes ~30 seconds)
- Check logs: `docker-compose logs db`
- Verify connection string in docker-compose.yml

### Migration Errors
- Check if database exists: connect to SQL Server and verify
- Review migration files in the Migrations folder
- Check container logs: `docker-compose logs efcore-api`

### Port Conflicts
- API runs on port 5003
- SQL Server runs on port 1434 (different from default 1433)
- Change ports in docker-compose.yml if needed

## 🧹 Clean Up

To stop and remove all containers:
```bash
docker-compose down
```

To also remove the database volume (deletes all data):
```bash
docker-compose down -v
```

## 📚 Additional Resources

- Review the repository pattern in `/Repositories`
- Check the Unit of Work implementation in `/UnitOfWork`
- Examine LINQ examples in `QueryTestController`
- Study entity configurations in the Data folder

## 🏭 Production Considerations

For production:
1. Use proper connection string management (secrets)
2. Implement proper logging and monitoring
3. Add health checks for database connectivity
4. Consider using managed database services
5. Implement proper backup strategies