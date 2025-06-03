using Bogus;
using PerformanceDemo.Models;

namespace PerformanceDemo.Data;

public static class DbInitializer
{
    public static void Initialize(ApplicationDbContext context)
    {
        // Look for any existing data
        if (context.Products.Any())
        {
            return;  // DB has been seeded already
        }
        
        // Generate seed data using Bogus
        SeedData(context);
    }
    
    private static void SeedData(ApplicationDbContext context)
    {
        // Create categories
        var categories = new[]
        {
            new Category { Name = "Electronics", Description = "Electronic devices and gadgets" },
            new Category { Name = "Clothing", Description = "Apparel and fashion items" },
            new Category { Name = "Home", Description = "Home goods and furniture" },
            new Category { Name = "Sports", Description = "Sports equipment and athletic wear" },
            new Category { Name = "Books", Description = "Books and publications" }
        };
        
        context.Categories.AddRange(categories);
        context.SaveChanges();
        
        // Create tags
        var tags = new[]
        {
            new Tag { Name = "New Arrival" },
            new Tag { Name = "Best Seller" },
            new Tag { Name = "Sale" },
            new Tag { Name = "Limited Edition" },
            new Tag { Name = "Clearance" }
        };
        
        context.Tags.AddRange(tags);
        context.SaveChanges();
        
        // Create products with Bogus
        var productFaker = new Faker<Product>()
            .RuleFor(p => p.Name, f => f.Commerce.ProductName())
            .RuleFor(p => p.Description, f => f.Commerce.ProductDescription())
            .RuleFor(p => p.Price, f => Math.Round(f.Random.Decimal(10, 1000), 2))
            .RuleFor(p => p.Stock, f => f.Random.Int(0, 100))
            .RuleFor(p => p.CategoryId, f => f.PickRandom(categories).Id)
            .RuleFor(p => p.SKU, f => f.Commerce.Ean13())
            .RuleFor(p => p.IsActive, f => f.Random.Bool(0.9f))  // 90% active
            .RuleFor(p => p.Weight, f => Math.Round(f.Random.Decimal(0.1m, 50m), 2))
            .RuleFor(p => p.ImageUrl, f => f.Image.PicsumUrl())
            .RuleFor(p => p.CreatedAt, f => f.Date.Past(2));
            
        var products = productFaker.Generate(1000);  // Generate 1000 products
        context.Products.AddRange(products);
        context.SaveChanges();
        
        // Create product tags
        var random = new Random();
        foreach (var product in products)
        {
            // Add 1-3 random tags to each product
            var tagCount = random.Next(1, 4);
            var shuffledTags = tags.OrderBy(_ => random.Next()).Take(tagCount);
            
            foreach (var tag in shuffledTags)
            {
                context.ProductTags.Add(new ProductTag
                {
                    ProductId = product.Id,
                    TagId = tag.Id,
                    CreatedAt = product.CreatedAt.AddDays(random.Next(1, 30))
                });
            }
        }
        context.SaveChanges();
        
        // Create customers for orders
        var customers = new List<(string Name, string Email)>();
        var faker = new Faker();
        for (int i = 0; i < 100; i++)
        {
            customers.Add((faker.Name.FullName(), faker.Internet.Email()));
        }
        
        // Create orders
        var orderFaker = new Faker<Order>()
            .RuleFor(o => o.OrderDate, f => f.Date.Past(1))
            .RuleFor(o => o.Status, f => f.PickRandom<OrderStatus>())
            .RuleFor(o => o.Notes, f => f.Random.Bool(0.3f) ? f.Lorem.Sentence() : null);  // 30% with notes
            
        var orders = new List<Order>();
        foreach (var customer in customers)
        {
            // Create 1-5 orders per customer
            var orderCount = random.Next(1, 6);
            for (int i = 0; i < orderCount; i++)
            {
                var order = orderFaker.Generate();
                order.CustomerName = customer.Name;
                order.CustomerEmail = customer.Email;
                
                // Create 1-5 order items per order
                var itemCount = random.Next(1, 6);
                decimal totalAmount = 0;
                
                for (int j = 0; j < itemCount; j++)
                {
                    var product = products[random.Next(products.Count)];
                    var quantity = random.Next(1, 5);
                    
                    var orderItem = new OrderItem
                    {
                        ProductId = product.Id,
                        Quantity = quantity,
                        UnitPrice = product.Price
                    };
                    
                    totalAmount += orderItem.TotalPrice;
                    order.OrderItems.Add(orderItem);
                }
                
                order.TotalAmount = totalAmount;
                orders.Add(order);
            }
        }
        
        context.Orders.AddRange(orders);
        context.SaveChanges();
    }
}