# API Endpoints Reference

## 🏠 Main Pages
- **Home Page**: `/` (redirects to `/index.html`)
- **Swagger UI**: `/swagger`
- **Health Check**: `/health`

## 📦 Products API v1
- **List Products**: `GET /api/v1/products`
- **Get Product**: `GET /api/v1/products/{id}`
- **Create Product**: `POST /api/v1/products`
- **Update Product**: `PUT /api/v1/products/{id}`
- **Patch Product**: `PATCH /api/v1/products/{id}`
- **Delete Product**: `DELETE /api/v1/products/{id}`
- **Get Categories**: `GET /api/v1/products/categories`
- **Search Products**: `GET /api/v1/products/search?query={query}`
- **Secure Products**: `GET /api/v1/products/secure` (requires auth)

## 🚀 Products API v2
- **List Products**: `GET /api/v2/products` (with enhanced metadata)
- **Get Product**: `GET /api/v2/products/{id}?includeStats=true`
- **Bulk Create**: `POST /api/v2/products/bulk`
- **Statistics**: `GET /api/v2/products/statistics`
- **Export CSV**: `GET /api/v2/products/export?category={category}`

## ⚡ Minimal API
- **List Products**: `GET /api/minimal/products`
- **Get Product**: `GET /api/minimal/products/{id}`
- **Create Product**: `POST /api/minimal/products`
- **Delete Product**: `DELETE /api/minimal/products/{id}`

## 🔐 Authentication API
- **Register**: `POST /api/auth/register`
- **Login**: `POST /api/auth/login`
- **Profile**: `GET /api/auth/profile` (requires auth)
- **Change Password**: `POST /api/auth/change-password` (requires auth)
- **Validate Token**: `POST /api/auth/validate-token`
- **Test Auth**: `GET /api/auth/test` (requires auth)
- **Admin Test**: `GET /api/auth/admin-test` (requires Admin role)

## 🔀 Versioning Methods

### 1. URL Segment (Primary - All endpoints support this)
```
/api/v1/products
/api/v2/products
```

### 2. Query String (Controllers must be configured to support this)
```
/api/products?api-version=1.0
/api/products?api-version=2.0
```
Note: Current implementation uses URL segment routing, so this may return 404

### 3. Header
```
X-Version: 1.0
X-Version: 2.0
```

### 4. Media Type
```
Accept: application/json;ver=1.0
Accept: application/json;ver=2.0
```

## ✅ All Links in index.html are correct:
1. `/swagger` - API Documentation ✓
2. `/api/v1/products` - Products API v1 ✓
3. `/api/v2/products` - Products API v2 ✓
4. `/api/minimal/products` - Minimal API ✓
5. `/health` - Health Check ✓
6. `/api/auth/login` - Authentication ✓