using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using RestfulAPI.Data;
using RestfulAPI.DTOs;
using RestfulAPI.Models;

namespace RestfulAPI;

/// <summary>
/// Minimal API example for product management
/// This class demonstrates how to implement a RESTful API using minimal APIs in ASP.NET Core
/// </summary>
public static class MinimalApiExample
{
    public static void MapProductEndpoints(this WebApplication app)
    {
        var products = app.MapGroup("/api/minimal/products")
            .WithTags("Minimal API Products");

        // GET: Get all products
        products.MapGet("/", async (
            ApplicationDbContext db,
            [FromQuery] string? category,
            [FromQuery] decimal? minPrice,
            [FromQuery] decimal? maxPrice,
            [FromQuery] int page = 1,
            [FromQuery] int pageSize = 10) =>
        {
            var query = db.Products.Where(p => !p.IsDeleted);

            if (!string.IsNullOrWhiteSpace(category))
                query = query.Where(p => p.Category.ToLower() == category.ToLower());

            if (minPrice.HasValue)
                query = query.Where(p => p.Price >= minPrice.Value);

            if (maxPrice.HasValue)
                query = query.Where(p => p.Price <= maxPrice.Value);

            var totalRecords = await query.CountAsync();
            
            var products = await query
                .OrderBy(p => p.Name)
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .Select(p => new ProductDto
                {
                    Id = p.Id,
                    Name = p.Name,
                    Description = p.Description,
                    Price = p.Price,
                    Category = p.Category,
                    StockQuantity = p.StockQuantity,
                    IsAvailable = p.IsAvailable,
                    Sku = p.Sku,
                    IsActive = p.IsActive,
                    CreatedAt = p.CreatedAt,
                    UpdatedAt = p.UpdatedAt
                })
                .ToListAsync();

            return Results.Ok(new PagedResponse<ProductDto>(products, page, pageSize, totalRecords));
        })
        .WithName("GetMinimalProducts")
        .WithSummary("Get paginated products with optional filters")
        .Produces<PagedResponse<ProductDto>>();

        // GET: Get product by ID
        products.MapGet("/{id:int}", async (int id, ApplicationDbContext db) =>
        {
            var product = await db.Products
                .Where(p => p.Id == id && !p.IsDeleted)
                .Select(p => new ProductDto
                {
                    Id = p.Id,
                    Name = p.Name,
                    Description = p.Description,
                    Price = p.Price,
                    Category = p.Category,
                    StockQuantity = p.StockQuantity,
                    IsAvailable = p.IsAvailable,
                    Sku = p.Sku,
                    IsActive = p.IsActive,
                    CreatedAt = p.CreatedAt,
                    UpdatedAt = p.UpdatedAt
                })
                .FirstOrDefaultAsync();

            return product is not null 
                ? Results.Ok(product) 
                : Results.NotFound(new { message = $"Product with ID {id} not found" });
        })
        .WithName("GetMinimalProductById")
        .WithSummary("Get a specific product by ID")
        .Produces<ProductDto>()
        .Produces(StatusCodes.Status404NotFound);

        // POST: Create a new product
        products.MapPost("/", async (CreateProductDto createDto, ApplicationDbContext db) =>
        {
            var product = new Product
            {
                Name = createDto.Name,
                Description = createDto.Description,
                Price = createDto.Price,
                Category = createDto.Category,
                StockQuantity = createDto.StockQuantity,
                IsAvailable = createDto.StockQuantity > 0,
                Sku = createDto.Sku,
                IsActive = createDto.IsActive ?? true,
                CreatedAt = DateTime.UtcNow
            };

            db.Products.Add(product);
            await db.SaveChangesAsync();
            
            // Generate default SKU if not provided
            if (string.IsNullOrWhiteSpace(product.Sku))
            {
                product.Sku = $"PRD-{product.Id}";
                await db.SaveChangesAsync();
            }

            var productDto = new ProductDto
            {
                Id = product.Id,
                Name = product.Name,
                Description = product.Description,
                Price = product.Price,
                Category = product.Category,
                StockQuantity = product.StockQuantity,
                IsAvailable = product.IsAvailable,
                Sku = product.Sku,
                IsActive = product.IsActive,
                CreatedAt = product.CreatedAt,
                UpdatedAt = product.UpdatedAt
            };

            return Results.Created($"/api/minimal/products/{product.Id}", productDto);
        })
        .WithName("CreateMinimalProduct")
        .WithSummary("Create a new product")
        .Produces<ProductDto>(StatusCodes.Status201Created)
        .ProducesValidationProblem();

        // PUT: Update a product
        products.MapPut("/{id:int}", async (int id, UpdateProductDto updateDto, ApplicationDbContext db) =>
        {
            var product = await db.Products
                .FirstOrDefaultAsync(p => p.Id == id && !p.IsDeleted);

            if (product is null)
                return Results.NotFound(new { message = $"Product with ID {id} not found" });

            product.Name = updateDto.Name;
            product.Description = updateDto.Description;
            product.Price = updateDto.Price;
            product.Category = updateDto.Category;
            product.StockQuantity = updateDto.StockQuantity;
            product.IsAvailable = updateDto.IsAvailable.HasValue ? updateDto.IsAvailable.Value : product.IsAvailable;
            product.Sku = updateDto.Sku ?? product.Sku;
            product.IsActive = updateDto.IsActive.HasValue ? updateDto.IsActive.Value : product.IsActive;
            product.UpdatedAt = DateTime.UtcNow;

            await db.SaveChangesAsync();

            var productDto = new ProductDto
            {
                Id = product.Id,
                Name = product.Name,
                Description = product.Description,
                Price = product.Price,
                Category = product.Category,
                StockQuantity = product.StockQuantity,
                IsAvailable = product.IsAvailable,
                Sku = product.Sku,
                IsActive = product.IsActive,
                CreatedAt = product.CreatedAt,
                UpdatedAt = product.UpdatedAt
            };

            return Results.Ok(productDto);
        })
        .WithName("UpdateMinimalProduct")
        .WithSummary("Update an existing product")
        .Produces<ProductDto>()
        .Produces(StatusCodes.Status404NotFound)
        .ProducesValidationProblem();

        // DELETE: Delete a product
        products.MapDelete("/{id:int}", async (int id, ApplicationDbContext db) =>
        {
            var product = await db.Products
                .FirstOrDefaultAsync(p => p.Id == id && !p.IsDeleted);

            if (product is null)
                return Results.NotFound(new { message = $"Product with ID {id} not found" });

            // Soft delete
            product.IsDeleted = true;
            product.UpdatedAt = DateTime.UtcNow;
            
            await db.SaveChangesAsync();

            return Results.NoContent();
        })
        .WithName("DeleteMinimalProduct")
        .WithSummary("Delete a product (soft delete)")
        .Produces(StatusCodes.Status204NoContent)
        .Produces(StatusCodes.Status404NotFound);

        // GET: Search products
        products.MapGet("/search", async (
            [FromQuery] string q,
            ApplicationDbContext db,
            [FromQuery] int page = 1,
            [FromQuery] int pageSize = 10) =>
        {
            if (string.IsNullOrWhiteSpace(q))
                return Results.BadRequest(new { message = "Search query is required" });

            var query = db.Products
                .Where(p => !p.IsDeleted && 
                    (p.Name.Contains(q) || p.Description.Contains(q)));

            var totalRecords = await query.CountAsync();
            
            var products = await query
                .OrderBy(p => p.Name)
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .Select(p => new ProductDto
                {
                    Id = p.Id,
                    Name = p.Name,
                    Description = p.Description,
                    Price = p.Price,
                    Category = p.Category,
                    StockQuantity = p.StockQuantity,
                    IsAvailable = p.IsAvailable,
                    Sku = p.Sku,
                    IsActive = p.IsActive,
                    CreatedAt = p.CreatedAt,
                    UpdatedAt = p.UpdatedAt
                })
                .ToListAsync();

            return Results.Ok(new PagedResponse<ProductDto>(products, page, pageSize, totalRecords));
        })
        .WithName("SearchMinimalProducts")
        .WithSummary("Search products by name or description")
        .Produces<PagedResponse<ProductDto>>()
        .ProducesProblem(StatusCodes.Status400BadRequest);

        // GET: Get categories
        products.MapGet("/categories", async (ApplicationDbContext db) =>
        {
            var categories = await db.Products
                .Where(p => !p.IsDeleted)
                .Select(p => p.Category)
                .Distinct()
                .OrderBy(c => c)
                .ToListAsync();

            return Results.Ok(categories);
        })
        .WithName("GetMinimalProductCategories")
        .WithSummary("Get all unique product categories")
        .Produces<List<string>>();

        // Example with authentication
        products.MapGet("/secure", async (ApplicationDbContext db) =>
        {
            var products = await db.Products
                .Where(p => !p.IsDeleted)
                .Select(p => new ProductDto
                {
                    Id = p.Id,
                    Name = p.Name,
                    Description = p.Description,
                    Price = p.Price,
                    Category = p.Category,
                    StockQuantity = p.StockQuantity,
                    IsAvailable = p.IsAvailable,
                    Sku = p.Sku,
                    IsActive = p.IsActive,
                    CreatedAt = p.CreatedAt,
                    UpdatedAt = p.UpdatedAt
                })
                .ToListAsync();

            return Results.Ok(products);
        })
        .RequireAuthorization("RequireManagerRole")
        .WithName("GetSecureMinimalProducts")
        .WithSummary("Get products (requires authentication)")
        .Produces<List<ProductDto>>()
        .ProducesProblem(StatusCodes.Status401Unauthorized)
        .ProducesProblem(StatusCodes.Status403Forbidden);
    }

    /// <summary>
    /// Extension method to register minimal API endpoints in Program.cs
    /// Usage: app.MapProductEndpoints();
    /// </summary>
    public static void ConfigureMinimalApis(this WebApplication app)
    {
        app.MapProductEndpoints();
        
        // Additional minimal API examples
        app.MapGet("/api/minimal/health", () => Results.Ok(new 
        { 
            status = "Healthy", 
            timestamp = DateTime.UtcNow 
        }))
        .WithTags("Health")
        .WithName("MinimalHealthCheck");

        app.MapGet("/api/minimal/version", () => Results.Ok(new 
        { 
            version = "1.0.0",
            framework = ".NET 8.0",
            apiType = "Minimal API"
        }))
        .WithTags("Info")
        .WithName("MinimalApiVersion");
    }
}