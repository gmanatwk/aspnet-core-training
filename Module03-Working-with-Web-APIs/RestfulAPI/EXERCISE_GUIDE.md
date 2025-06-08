# Exercise 1: Complete Products API

## 🎯 What You Have Built
This script has created a **complete, working Products API** with all the features from the exercise:

### ✅ Features Implemented:
- **Full CRUD Operations**: GET, POST, PUT, DELETE for products
- **Advanced Filtering**: Filter by category, name, price range
- **Input Validation**: Data annotations and SKU uniqueness validation
- **Error Handling**: Proper HTTP status codes and error messages
- **Entity Framework**: In-memory database with seed data
- **DTOs**: Clean separation between API contracts and domain models
- **Swagger Documentation**: Interactive API documentation with XML comments

### 🚀 Testing Your API:
1. **Run the application**:
   ```bash
   dotnet run
   ```

2. **Open Swagger UI**:
   - Navigate to: `http://localhost:5000/swagger`
   - Explore all available endpoints

3. **Test the endpoints**:
   - **GET /api/products** - Get all products (3 seeded products)
   - **GET /api/products?category=Electronics** - Filter by category
   - **GET /api/products?name=Laptop** - Filter by name
   - **GET /api/products?minPrice=30&maxPrice=100** - Filter by price range
   - **GET /api/products/1** - Get specific product
   - **POST /api/products** - Create new product
   - **PUT /api/products/1** - Update existing product
   - **DELETE /api/products/1** - Delete product
   - **GET /api/products/by-category/Electronics** - Get products by category

### 📊 Sample Data Included:
1. **Laptop Computer** (Electronics, $999.99)
2. **Wireless Mouse** (Accessories, $29.99)
3. **Programming Book** (Books, $49.99)

### 🧪 Example API Calls:

**Create a new product:**
```bash
curl -X POST "http://localhost:5000/api/products" \
  -H "Content-Type: application/json" \
  -d {
