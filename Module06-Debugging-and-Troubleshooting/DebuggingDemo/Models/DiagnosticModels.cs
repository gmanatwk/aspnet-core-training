namespace DebuggingDemo.Models;

/// <summary>
/// Sample model for debugging exercises
/// </summary>
public class User
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public DateTime CreatedAt { get; set; }
    public bool IsActive { get; set; }

    // Method with potential bug for debugging practice
    public string GetDisplayName()
    {
        // TODO: Fix the bug in this method during debugging
        return $"{Name} ({Email})";
    }
}

/// <summary>
/// Sample order model for debugging complex scenarios
/// </summary>
public class Order
{
    public int Id { get; set; }
    public int UserId { get; set; }
    public List<OrderItem> Items { get; set; } = new();
    public DateTime OrderDate { get; set; }
    public decimal Total { get; set; }

    // Method with calculation bug for debugging
    public decimal CalculateTotal()
    {
        // TODO: Debug this calculation method
        decimal total = 0;
        foreach (var item in Items)
        {
            total += item.Price * item.Quantity;
        }
        return total;
    }
}

/// <summary>
/// Order item model
/// </summary>
public class OrderItem
{
    public int Id { get; set; }
    public string ProductName { get; set; } = string.Empty;
    public decimal Price { get; set; }
    public int Quantity { get; set; }
}

/// <summary>
/// Diagnostic information model
/// </summary>
public class DiagnosticInfo
{
    public string MachineName { get; set; } = Environment.MachineName;
    public string OSVersion { get; set; } = Environment.OSVersion.ToString();
    public DateTime ServerTime { get; set; } = DateTime.UtcNow;
    public string ApplicationVersion { get; set; } = "1.0.0";
    public long WorkingSet { get; set; } = Environment.WorkingSet;
}
