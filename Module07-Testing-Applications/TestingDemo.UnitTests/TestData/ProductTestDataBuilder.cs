using TestingDemo.API.Models;

namespace TestingDemo.UnitTests.TestData;

public class ProductTestDataBuilder
{
    private Product _product = new()
    {
        Id = 1,
        Name = "Test Product",
        Description = "Test Description",
        Price = 10.99m,
        StockQuantity = 5,
        IsActive = true,
        CreatedAt = DateTime.UtcNow
    };

    public ProductTestDataBuilder WithId(int id)
    {
        _product.Id = id;
        return this;
    }

    public ProductTestDataBuilder WithName(string name)
    {
        _product.Name = name;
        return this;
    }

    public ProductTestDataBuilder WithPrice(decimal price)
    {
        _product.Price = price;
        return this;
    }

    public ProductTestDataBuilder WithStockQuantity(int quantity)
    {
        _product.StockQuantity = quantity;
        return this;
    }

    public ProductTestDataBuilder WithIsActive(bool isActive)
    {
        _product.IsActive = isActive;
        return this;
    }

    public Product Build() => _product;

    public static ProductTestDataBuilder AProduct() => new();
}
