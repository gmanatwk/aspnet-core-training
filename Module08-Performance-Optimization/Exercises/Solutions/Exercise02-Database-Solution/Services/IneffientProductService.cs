using DatabaseOptimization.Data;
using DatabaseOptimization.Models;
using Microsoft.EntityFrameworkCore;

namespace DatabaseOptimization.Services;

public interface IIneffientProductService
{
    Task<List<ProductDto>> GetProductsWithCategoryAsync();
    Task<List<OrderSummaryDto>> GetOrdersWithDetailsAsync();
    Task<List<ProductDetailDto>> GetProductsWithAllDetailsAsync();
    Task<List<ProductDto>> GetProductsForDisplayAsync();
    Task<List<ProductDto>> GetProductsPageInefficient(int pageNumber, int pageSize);
}

/// <summary>
/// Service with inefficient database query patterns - demonstrates common anti-patterns
/// </summary>
public class IneffientProductService : IIneffientProductService
{
    private readonly AppDbContext _context;
    private readonly ILogger<IneffientProductService> _logger;

    public IneffientProductService(AppDbContext context, ILogger<IneffientProductService> logger)
    {
        _context = context;
        _logger = logger;
    }

    /// <summary>
    /// N+1 query problem example - loads products then queries category for each one
    /// </summary>
    public async Task<List<ProductDto>> GetProductsWithCategoryAsync()
    {
        _logger.LogInformation("Getting products with categories (inefficient - N+1 problem)");
        
        // First query: Get all products
        var products = await _context.Products.ToListAsync();

        var productDtos = new List<ProductDto>();
        
        // N queries: One for each product's category (N+1 problem!)
        foreach (var product in products)
        {
            // This will cause a separate query for each product
            var category = await _context.Categories.FindAsync(product.CategoryId);

            productDtos.Add(new ProductDto
            {
                Id = product.Id,
                Name = product.Name,
                Description = product.Description,
                Price = product.Price,
                Stock = product.Stock,
                CategoryName = category?.Name ?? "Unknown"
            });
        }

        return productDtos;
    }

    /// <summary>
    /// Another N+1 problem - loads orders then queries items for each one
    /// </summary>
    public async Task<List<OrderSummaryDto>> GetOrdersWithDetailsAsync()
    {
        _logger.LogInformation("Getting orders with details (inefficient - N+1 problem)");
        
        // First query: Get all orders
        var orders = await _context.Orders.ToListAsync();

        var orderDtos = new List<OrderSummaryDto>();
        
        // N queries: One for each order's items
        foreach (var order in orders)
        {
            var orderItems = await _context.OrderItems
                .Where(oi => oi.OrderId == order.Id)
                .ToListAsync();

            var orderDto = new OrderSummaryDto
            {
                Id = order.Id,
                CustomerName = order.CustomerName,
                OrderDate = order.OrderDate,
                TotalAmount = order.TotalAmount,
                ItemCount = orderItems.Count
            };

            orderDtos.Add(orderDto);
        }

        return orderDtos;
    }

    /// <summary>
    /// Complex query with multiple includes - generates large Cartesian product
    /// </summary>
    public async Task<List<ProductDetailDto>> GetProductsWithAllDetailsAsync()
    {
        _logger.LogInformation("Getting products with all details (inefficient - complex joins)");
        
        // This creates a massive Cartesian product due to multiple one-to-many relationships
        var products = await _context.Products
            .Include(p => p.Category)
            .Include(p => p.ProductTags)
                .ThenInclude(pt => pt.Tag)
            .Include(p => p.OrderItems)
                .ThenInclude(oi => oi.Order)
            .ToListAsync();

        // Transform to DTOs in memory (inefficient)
        return products.Select(p => new ProductDetailDto
        {
            Id = p.Id,
            Name = p.Name,
            Description = p.Description,
            Price = p.Price,
            Stock = p.Stock,
            CategoryName = p.Category?.Name ?? "Unknown",
            Tags = p.ProductTags.Select(pt => pt.Tag?.Name ?? "").ToList(),
            RecentOrders = p.OrderItems
                .Where(oi => oi.Order?.OrderDate >= DateTime.UtcNow.AddDays(-30))
                .Select(oi => new OrderSummaryDto
                {
                    Id = oi.Order!.Id,
                    CustomerName = oi.Order.CustomerName,
                    OrderDate = oi.Order.OrderDate,
                    TotalAmount = oi.Order.TotalAmount,
                    ItemCount = 0 // Would need another query to get this
                })
                .ToList()
        }).ToList();
    }

    /// <summary>
    /// Using tracking queries for read-only operations
    /// </summary>
    public async Task<List<ProductDto>> GetProductsForDisplayAsync()
    {
        _logger.LogInformation("Getting products for display (inefficient - tracking enabled)");
        
        // Tracking is enabled unnecessarily for read-only operation
        var products = await _context.Products
            .Include(p => p.Category)
            .ToListAsync();

        // Transform to DTOs in memory instead of using projection
        return products.Select(p => new ProductDto
        {
            Id = p.Id,
            Name = p.Name,
            Description = p.Description,
            Price = p.Price,
            Stock = p.Stock,
            CategoryName = p.Category?.Name ?? "Unknown"
        }).ToList();
    }

    /// <summary>
    /// Inefficient pagination - loads all records and then takes a page
    /// </summary>
    public async Task<List<ProductDto>> GetProductsPageInefficient(int pageNumber, int pageSize)
    {
        _logger.LogInformation("Getting products page (inefficient - loads all data first)");
        
        // Loads ALL products into memory first, then does pagination in memory
        var allProducts = await _context.Products
            .Include(p => p.Category)
            .ToListAsync();

        return allProducts
            .Skip((pageNumber - 1) * pageSize)
            .Take(pageSize)
            .Select(p => new ProductDto
            {
                Id = p.Id,
                Name = p.Name,
                Description = p.Description,
                Price = p.Price,
                Stock = p.Stock,
                CategoryName = p.Category?.Name ?? "Unknown"
            })
            .ToList();
    }
}
