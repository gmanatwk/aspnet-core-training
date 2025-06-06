# Exercise 1: Create a Complete RESTful Products API

## 🎯 Objective
Build a complete RESTful API for managing products in an e-commerce system, implementing proper HTTP methods, status codes, validation, and documentation.

## ⏱️ Estimated Time
45 minutes

## 📋 Prerequisites
- Completed Module 1
- .NET 8.0 SDK installed
- Understanding of HTTP methods
- Basic knowledge of REST principles

## 📝 Instructions

### Part 0: Project Setup (2 minutes)

**Run the launch script to create a complete working API:**
```bash
# From the Module03-Working-with-Web-APIs directory
./launch-exercises.sh exercise01
```

**The script creates a complete, working Products API with:**
- ✅ Full CRUD operations (GET, POST, PUT, DELETE)
- ✅ Advanced filtering (category, name, price range)
- ✅ Input validation and error handling
- ✅ Entity Framework with in-memory database
- ✅ Swagger documentation with XML comments
- ✅ SKU uniqueness validation
- ✅ Seed data for testing

**Test the API:**
```bash
cd RestfulAPI
dotnet run
# Navigate to: http://localhost:5000/swagger
```

## 🎓 What You've Built

The launch script has created a **complete, production-ready Products API** with the following structure:

```
RestfulAPI/
├── Controllers/
│   └── ProductsController.cs    # Complete CRUD API with filtering
├── Models/
│   └── Product.cs              # Full Product entity with validation
├── DTOs/
│   └── ProductDtos.cs          # ProductDto, CreateProductDto, UpdateProductDto
├── Data/
│   └── ApplicationDbContext.cs # EF Core context with seed data
├── Program.cs                  # Complete app configuration
├── appsettings.json           # Configuration settings
└── EXERCISE_GUIDE.md          # Testing and usage guide
```

### 🚀 API Endpoints Available

**Products API (`/api/products`):**
- **GET** `/api/products` - Get all products with optional filtering
- **GET** `/api/products/{id}` - Get specific product by ID
- **POST** `/api/products` - Create new product
- **PUT** `/api/products/{id}` - Update existing product
- **DELETE** `/api/products/{id}` - Delete product
- **GET** `/api/products/by-category/{category}` - Get products by category

### 🔍 Advanced Filtering Options

The API supports sophisticated filtering:
```bash
# Filter by category
GET /api/products?category=Electronics

# Filter by name
GET /api/products?name=Laptop

# Filter by price range
GET /api/products?minPrice=30&maxPrice=100

# Combine multiple filters
GET /api/products?category=Electronics&minPrice=500&maxPrice=1500
```

1. **Laptop Computer** - Electronics, $999.99, SKU: ELEC-LAP-001
2. **Wireless Mouse** - Accessories, $29.99, SKU: ACC-MOU-002
3. **Programming Book** - Books, $49.99, SKU: BOOK-PROG-003

## 🧪 Testing Your API

### 1. Using Swagger UI (Recommended)
1. Run the application: `dotnet run`
2. Navigate to: `http://localhost:5000/swagger`
3. Explore and test all endpoints interactively

### 2. Using curl Commands

**Get all products:**
```bash
curl -X GET "http://localhost:5000/api/products"
```

**Filter products by category:**
```bash
curl -X GET "http://localhost:5000/api/products?category=Electronics"
```

**Create a new product:**
```bash
curl -X POST "http://localhost:5000/api/products" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Wireless Headphones",
    "description": "High-quality wireless headphones with noise cancellation",
    "price": 199.99,
    "category": "Electronics",
    "stockQuantity": 75,
    "sku": "ELEC-HEAD-004",
    "isActive": true
  }'
```

**Update a product:**
```bash
curl -X PUT "http://localhost:5000/api/products/1" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Updated Laptop Computer",
    "description": "Updated description",
    "price": 1099.99,
    "category": "Electronics",
    "stockQuantity": 45,
    "sku": "ELEC-LAP-001",
    "isActive": true,
    "isAvailable": true
  }'
```

**Delete a product:**
```bash
curl -X DELETE "http://localhost:5000/api/products/1"
```

## 🎓 Key Learning Points

### 1. RESTful API Design
- **Resource-based URLs**: `/api/products` (not `/api/getProducts`)
- **HTTP methods**: GET (read), POST (create), PUT (update), DELETE (delete)
- **Status codes**: 200 (OK), 201 (Created), 404 (Not Found), 400 (Bad Request)
- **Consistent response format**: Always return JSON

### 2. Entity Framework Core
- **Code-first approach**: Define models, generate database
- **In-memory database**: Perfect for development and testing
- **Query filters**: Automatic soft-delete filtering
- **Seed data**: Pre-populate database with test data

### 3. Data Transfer Objects (DTOs)
- **Separation of concerns**: API contracts vs domain models
- **Input validation**: Data annotations for automatic validation
- **Versioning support**: Can evolve independently from domain models
- **Security**: Control what data is exposed

### 4. Input Validation
- **Data annotations**: `[Required]`, `[Range]`, `[StringLength]`
- **Custom validation**: SKU format validation with regex
- **Business rules**: SKU uniqueness validation
- **Error responses**: Meaningful validation error messages

### 5. Swagger Documentation
- **Interactive documentation**: Test API directly from browser
- **XML comments**: Rich documentation from code comments
- **Schema generation**: Automatic request/response examples
- **Development productivity**: No need for separate API client

## ✅ Success Criteria

Verify your API works correctly by testing these scenarios:

### Basic CRUD Operations
- [ ] **GET /api/products** returns all 3 seeded products
- [ ] **GET /api/products/1** returns the laptop product
- [ ] **GET /api/products/999** returns 404 Not Found
- [ ] **POST /api/products** with valid data creates new product and returns 201
- [ ] **POST /api/products** with invalid data returns 400 with validation errors
- [ ] **PUT /api/products/1** with valid data updates product and returns 204
- [ ] **DELETE /api/products/1** removes product and returns 204

### Advanced Features
- [ ] **Filtering**: `/api/products?category=Electronics` returns only electronics
- [ ] **Price filtering**: `/api/products?minPrice=30&maxPrice=100` works correctly
- [ ] **SKU validation**: Creating product with duplicate SKU returns 400 error
- [ ] **Swagger UI**: Documentation loads at `/swagger` and all endpoints are testable

### Data Validation
- [ ] Required fields (name, category, SKU) are enforced
- [ ] Price must be greater than 0
- [ ] SKU format validation works (uppercase letters, numbers, hyphens only)
- [ ] String length limits are enforced

## 🚀 Next Steps

Your Products API is now complete and ready for **Exercise 2**, where you will add:
- JWT authentication and authorization
- User registration and login
- Role-based access control
- Protected endpoints

## 🤔 Reflection Questions

1. **Why use DTOs instead of exposing entity models directly?**
   - Security: Control what data is exposed
   - Versioning: API contracts can evolve independently
   - Validation: Input-specific validation rules
   - Performance: Only transfer needed data

2. **What's the purpose of the `[ApiController]` attribute?**
   - Automatic model validation
   - Automatic HTTP 400 responses for validation errors
   - Binding source parameter inference
   - Problem details for error responses

3. **How does Entity Framework's query filter work?**
   - Automatically applies `WHERE !IsDeleted` to all queries
   - Implements soft delete pattern
   - Transparent to application code
   - Can be overridden when needed

4. **What are the benefits of using async/await in API controllers?**
   - Non-blocking I/O operations
   - Better scalability under load
   - Improved resource utilization
   - Standard pattern for modern .NET applications
## 🚀 Bonus Challenges

If you want to extend your API further, consider these enhancements:

1. **Add Product Search**:
   - Create advanced search endpoint
   - Search by name, description, and category
   - Add price range filtering

2. **Add Product Categories**:
   - Create separate Category entity
   - Implement category management endpoints
   - Add category statistics

3. **Add Pagination**:
   - Implement pagination for product list
   - Add sorting options (by name, price, category)
   - Return pagination metadata in headers

4. **Add Inventory Management**:
   - Create stock adjustment endpoints
   - Add low stock alerts
   - Implement stock history tracking

## 🆘 Troubleshooting

**Issue**: Launch script fails to run
**Solution**: Make sure you're in the Module03-Working-with-Web-APIs directory and the script has execute permissions: `chmod +x launch-exercises.sh`

**Issue**: Swagger UI not showing
**Solution**: Ensure you're running in Development mode and accessing `http://localhost:5000/swagger` (note HTTP, not HTTPS for development)

**Issue**: 404 errors on API calls
**Solution**: Check that the application is running and you're using the correct base URL. The API endpoints start with `/api/products`

**Issue**: Database seems empty
**Solution**: The in-memory database is seeded automatically. If you don't see data, restart the application.

**Issue**: Package restore errors
**Solution**: Run `dotnet restore` in the RestfulAPI directory to ensure all packages are properly installed.

---

**🎉 Congratulations! You've built a complete, production-ready RESTful API!**

