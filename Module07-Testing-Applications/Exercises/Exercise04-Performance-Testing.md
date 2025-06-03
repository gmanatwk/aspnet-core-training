# Exercise 4: Performance Testing

## Objective
Learn to use performance testing tools to measure and optimize the performance of ASP.NET Core applications.

## Prerequisites
- Visual Studio or Visual Studio Code
- .NET 8 SDK
- BenchmarkDotNet knowledge from the module content

## Exercise Description

In this exercise, you will implement performance benchmarks for a data processing service that handles various operations on collections of items. You'll measure the performance of different implementation approaches and optimize the code based on the benchmark results.

## Tasks

### 1. Create a Data Processing Service

Create a console application with the following components:

1. A `Product` model:
```csharp
public class Product
{
    public int Id { get; set; }
    public string Name { get; set; }
    public string Category { get; set; }
    public decimal Price { get; set; }
    public int Stock { get; set; }
    public bool IsActive { get; set; }
    public DateTime CreatedAt { get; set; }
    public List<string> Tags { get; set; } = new List<string>();
}
```

2. A `DataProcessor` class with methods to benchmark:
```csharp
public class DataProcessor
{
    // Method 1: Filter products by category using LINQ
    public List<Product> FilterProductsByCategory_Linq(List<Product> products, string category)
    {
        return products.Where(p => p.Category == category && p.IsActive).ToList();
    }
    
    // Method 2: Filter products by category using foreach loop
    public List<Product> FilterProductsByCategory_Loop(List<Product> products, string category)
    {
        var result = new List<Product>();
        foreach (var product in products)
        {
            if (product.Category == category && product.IsActive)
            {
                result.Add(product);
            }
        }
        return result;
    }
    
    // Method 3: Calculate total inventory value using LINQ
    public decimal CalculateTotalInventoryValue_Linq(List<Product> products)
    {
        return products.Where(p => p.IsActive).Sum(p => p.Price * p.Stock);
    }
    
    // Method 4: Calculate total inventory value using foreach loop
    public decimal CalculateTotalInventoryValue_Loop(List<Product> products)
    {
        decimal total = 0;
        foreach (var product in products)
        {
            if (product.IsActive)
            {
                total += product.Price * product.Stock;
            }
        }
        return total;
    }
    
    // Method 5: Group products by category using LINQ
    public Dictionary<string, List<Product>> GroupProductsByCategory_Linq(List<Product> products)
    {
        return products
            .Where(p => p.IsActive)
            .GroupBy(p => p.Category)
            .ToDictionary(g => g.Key, g => g.ToList());
    }
    
    // Method 6: Group products by category using foreach loop
    public Dictionary<string, List<Product>> GroupProductsByCategory_Loop(List<Product> products)
    {
        var result = new Dictionary<string, List<Product>>();
        
        foreach (var product in products)
        {
            if (!product.IsActive)
                continue;
                
            if (!result.ContainsKey(product.Category))
            {
                result[product.Category] = new List<Product>();
            }
            
            result[product.Category].Add(product);
        }
        
        return result;
    }
    
    // Method 7: Find products with specific tag using LINQ with Any
    public List<Product> FindProductsWithTag_LinqAny(List<Product> products, string tag)
    {
        return products
            .Where(p => p.IsActive && p.Tags.Any(t => t == tag))
            .ToList();
    }
    
    // Method 8: Find products with specific tag using LINQ with Contains
    public List<Product> FindProductsWithTag_LinqContains(List<Product> products, string tag)
    {
        return products
            .Where(p => p.IsActive && p.Tags.Contains(tag))
            .ToList();
    }
    
    // Method 9: Find products with specific tag using foreach loop
    public List<Product> FindProductsWithTag_Loop(List<Product> products, string tag)
    {
        var result = new List<Product>();
        
        foreach (var product in products)
        {
            if (!product.IsActive)
                continue;
                
            foreach (var productTag in product.Tags)
            {
                if (productTag == tag)
                {
                    result.Add(product);
                    break;
                }
            }
        }
        
        return result;
    }
    
    // Method 10: Sort products by price using LINQ
    public List<Product> SortProductsByPrice_Linq(List<Product> products)
    {
        return products
            .Where(p => p.IsActive)
            .OrderBy(p => p.Price)
            .ToList();
    }
    
    // Method 11: Sort products by price using manual sorting
    public List<Product> SortProductsByPrice_Manual(List<Product> products)
    {
        var result = products.Where(p => p.IsActive).ToList();
        
        // Bubble sort for demonstration (not efficient)
        for (int i = 0; i < result.Count - 1; i++)
        {
            for (int j = 0; j < result.Count - i - 1; j++)
            {
                if (result[j].Price > result[j + 1].Price)
                {
                    var temp = result[j];
                    result[j] = result[j + 1];
                    result[j + 1] = temp;
                }
            }
        }
        
        return result;
    }
}
```

### 2. Create Benchmark Classes

Create a benchmark project using BenchmarkDotNet:

1. Install the BenchmarkDotNet package:
```
dotnet add package BenchmarkDotNet
```

2. Create a data generator to produce test data:
```csharp
public static class DataGenerator
{
    private static readonly Random _random = new Random(42); // Fixed seed for reproducibility
    private static readonly string[] _categories = { "Electronics", "Clothing", "Books", "Home", "Sports" };
    private static readonly string[] _tags = { "New", "Sale", "Clearance", "Featured", "Bestseller", "Limited", "Organic", "Premium" };
    
    public static List<Product> GenerateProducts(int count)
    {
        var products = new List<Product>();
        
        for (int i = 1; i <= count; i++)
        {
            var product = new Product
            {
                Id = i,
                Name = $"Product {i}",
                Category = _categories[_random.Next(_categories.Length)],
                Price = Math.Round((decimal)(_random.NextDouble() * 1000), 2),
                Stock = _random.Next(0, 100),
                IsActive = _random.Next(10) < 8, // 80% active
                CreatedAt = DateTime.UtcNow.AddDays(-_random.Next(365))
            };
            
            // Add 1-3 random tags
            int tagCount = _random.Next(1, 4);
            var tagIndexes = Enumerable.Range(0, _tags.Length).OrderBy(x => _random.Next()).Take(tagCount).ToList();
            foreach (var index in tagIndexes)
            {
                product.Tags.Add(_tags[index]);
            }
            
            products.Add(product);
        }
        
        return products;
    }
}
```

3. Create a benchmark class for filtering operations:
```csharp
[MemoryDiagnoser]
[Orderer(SummaryOrderPolicy.FastestToSlowest)]
[RankColumn]
public class FilteringBenchmarks
{
    private DataProcessor _processor;
    private List<Product> _smallDataset;
    private List<Product> _mediumDataset;
    private List<Product> _largeDataset;
    private string _targetCategory;
    
    [GlobalSetup]
    public void Setup()
    {
        _processor = new DataProcessor();
        _smallDataset = DataGenerator.GenerateProducts(100);
        _mediumDataset = DataGenerator.GenerateProducts(10_000);
        _largeDataset = DataGenerator.GenerateProducts(100_000);
        _targetCategory = "Electronics"; // Use a category we know exists
    }
    
    [Benchmark]
    public List<Product> Linq_Small()
    {
        return _processor.FilterProductsByCategory_Linq(_smallDataset, _targetCategory);
    }
    
    [Benchmark]
    public List<Product> Loop_Small()
    {
        return _processor.FilterProductsByCategory_Loop(_smallDataset, _targetCategory);
    }
    
    [Benchmark]
    public List<Product> Linq_Medium()
    {
        return _processor.FilterProductsByCategory_Linq(_mediumDataset, _targetCategory);
    }
    
    [Benchmark]
    public List<Product> Loop_Medium()
    {
        return _processor.FilterProductsByCategory_Loop(_mediumDataset, _targetCategory);
    }
    
    [Benchmark]
    public List<Product> Linq_Large()
    {
        return _processor.FilterProductsByCategory_Linq(_largeDataset, _targetCategory);
    }
    
    [Benchmark]
    public List<Product> Loop_Large()
    {
        return _processor.FilterProductsByCategory_Loop(_largeDataset, _targetCategory);
    }
}
```

4. Create a benchmark class for calculation operations:
```csharp
[MemoryDiagnoser]
[Orderer(SummaryOrderPolicy.FastestToSlowest)]
[RankColumn]
public class CalculationBenchmarks
{
    private DataProcessor _processor;
    private List<Product> _smallDataset;
    private List<Product> _mediumDataset;
    private List<Product> _largeDataset;
    
    [GlobalSetup]
    public void Setup()
    {
        _processor = new DataProcessor();
        _smallDataset = DataGenerator.GenerateProducts(100);
        _mediumDataset = DataGenerator.GenerateProducts(10_000);
        _largeDataset = DataGenerator.GenerateProducts(100_000);
    }
    
    [Benchmark]
    public decimal Linq_Small()
    {
        return _processor.CalculateTotalInventoryValue_Linq(_smallDataset);
    }
    
    [Benchmark]
    public decimal Loop_Small()
    {
        return _processor.CalculateTotalInventoryValue_Loop(_smallDataset);
    }
    
    [Benchmark]
    public decimal Linq_Medium()
    {
        return _processor.CalculateTotalInventoryValue_Linq(_mediumDataset);
    }
    
    [Benchmark]
    public decimal Loop_Medium()
    {
        return _processor.CalculateTotalInventoryValue_Loop(_mediumDataset);
    }
    
    [Benchmark]
    public decimal Linq_Large()
    {
        return _processor.CalculateTotalInventoryValue_Linq(_largeDataset);
    }
    
    [Benchmark]
    public decimal Loop_Large()
    {
        return _processor.CalculateTotalInventoryValue_Loop(_largeDataset);
    }
}
```

5. Create a benchmark class for grouping operations:
```csharp
[MemoryDiagnoser]
[Orderer(SummaryOrderPolicy.FastestToSlowest)]
[RankColumn]
public class GroupingBenchmarks
{
    private DataProcessor _processor;
    private List<Product> _smallDataset;
    private List<Product> _mediumDataset;
    private List<Product> _largeDataset;
    
    [GlobalSetup]
    public void Setup()
    {
        _processor = new DataProcessor();
        _smallDataset = DataGenerator.GenerateProducts(100);
        _mediumDataset = DataGenerator.GenerateProducts(10_000);
        _largeDataset = DataGenerator.GenerateProducts(100_000);
    }
    
    [Benchmark]
    public Dictionary<string, List<Product>> Linq_Small()
    {
        return _processor.GroupProductsByCategory_Linq(_smallDataset);
    }
    
    [Benchmark]
    public Dictionary<string, List<Product>> Loop_Small()
    {
        return _processor.GroupProductsByCategory_Loop(_smallDataset);
    }
    
    [Benchmark]
    public Dictionary<string, List<Product>> Linq_Medium()
    {
        return _processor.GroupProductsByCategory_Linq(_mediumDataset);
    }
    
    [Benchmark]
    public Dictionary<string, List<Product>> Loop_Medium()
    {
        return _processor.GroupProductsByCategory_Loop(_mediumDataset);
    }
    
    [Benchmark]
    public Dictionary<string, List<Product>> Linq_Large()
    {
        return _processor.GroupProductsByCategory_Linq(_largeDataset);
    }
    
    [Benchmark]
    public Dictionary<string, List<Product>> Loop_Large()
    {
        return _processor.GroupProductsByCategory_Loop(_largeDataset);
    }
}
```

6. Create a benchmark class for tag search operations:
```csharp
[MemoryDiagnoser]
[Orderer(SummaryOrderPolicy.FastestToSlowest)]
[RankColumn]
public class TagSearchBenchmarks
{
    private DataProcessor _processor;
    private List<Product> _smallDataset;
    private List<Product> _mediumDataset;
    private List<Product> _largeDataset;
    private string _targetTag;
    
    [GlobalSetup]
    public void Setup()
    {
        _processor = new DataProcessor();
        _smallDataset = DataGenerator.GenerateProducts(100);
        _mediumDataset = DataGenerator.GenerateProducts(10_000);
        _largeDataset = DataGenerator.GenerateProducts(100_000);
        _targetTag = "Sale"; // Use a tag we know exists
    }
    
    [Benchmark]
    public List<Product> LinqAny_Small()
    {
        return _processor.FindProductsWithTag_LinqAny(_smallDataset, _targetTag);
    }
    
    [Benchmark]
    public List<Product> LinqContains_Small()
    {
        return _processor.FindProductsWithTag_LinqContains(_smallDataset, _targetTag);
    }
    
    [Benchmark]
    public List<Product> Loop_Small()
    {
        return _processor.FindProductsWithTag_Loop(_smallDataset, _targetTag);
    }
    
    [Benchmark]
    public List<Product> LinqAny_Medium()
    {
        return _processor.FindProductsWithTag_LinqAny(_mediumDataset, _targetTag);
    }
    
    [Benchmark]
    public List<Product> LinqContains_Medium()
    {
        return _processor.FindProductsWithTag_LinqContains(_mediumDataset, _targetTag);
    }
    
    [Benchmark]
    public List<Product> Loop_Medium()
    {
        return _processor.FindProductsWithTag_Loop(_mediumDataset, _targetTag);
    }
    
    [Benchmark]
    public List<Product> LinqAny_Large()
    {
        return _processor.FindProductsWithTag_LinqAny(_largeDataset, _targetTag);
    }
    
    [Benchmark]
    public List<Product> LinqContains_Large()
    {
        return _processor.FindProductsWithTag_LinqContains(_largeDataset, _targetTag);
    }
    
    [Benchmark]
    public List<Product> Loop_Large()
    {
        return _processor.FindProductsWithTag_Loop(_largeDataset, _targetTag);
    }
}
```

7. Create a benchmark class for sorting operations:
```csharp
[MemoryDiagnoser]
[Orderer(SummaryOrderPolicy.FastestToSlowest)]
[RankColumn]
public class SortingBenchmarks
{
    private DataProcessor _processor;
    private List<Product> _smallDataset;
    private List<Product> _mediumDataset;
    
    [GlobalSetup]
    public void Setup()
    {
        _processor = new DataProcessor();
        _smallDataset = DataGenerator.GenerateProducts(100);
        _mediumDataset = DataGenerator.GenerateProducts(10_000);
        // Note: Skip large dataset for sorting as bubble sort would be too slow
    }
    
    [Benchmark]
    public List<Product> Linq_Small()
    {
        return _processor.SortProductsByPrice_Linq(_smallDataset);
    }
    
    [Benchmark]
    public List<Product> Manual_Small()
    {
        return _processor.SortProductsByPrice_Manual(_smallDataset);
    }
    
    [Benchmark]
    public List<Product> Linq_Medium()
    {
        return _processor.SortProductsByPrice_Linq(_mediumDataset);
    }
    
    [Benchmark]
    public List<Product> Manual_Medium()
    {
        return _processor.SortProductsByPrice_Manual(_mediumDataset);
    }
}
```

8. Create a Program.cs file to run the benchmarks:
```csharp
using BenchmarkDotNet.Running;

namespace PerformanceTesting
{
    public class Program
    {
        public static void Main(string[] args)
        {
            // Run all benchmarks
            // BenchmarkRunner.Run<FilteringBenchmarks>();
            // BenchmarkRunner.Run<CalculationBenchmarks>();
            // BenchmarkRunner.Run<GroupingBenchmarks>();
            // BenchmarkRunner.Run<TagSearchBenchmarks>();
            // BenchmarkRunner.Run<SortingBenchmarks>();
            
            // Or use BenchmarkSwitcher to select at runtime
            var switcher = new BenchmarkSwitcher(new[] {
                typeof(FilteringBenchmarks),
                typeof(CalculationBenchmarks),
                typeof(GroupingBenchmarks),
                typeof(TagSearchBenchmarks),
                typeof(SortingBenchmarks)
            });
            
            switcher.Run(args);
        }
    }
}
```

### 3. Run the Benchmarks

Run the benchmarks and collect the results:

```
dotnet run -c Release
```

### 4. Analyze and Optimize

Based on the benchmark results, implement optimized versions of at least three methods:

1. Optimize the product filtering method:
```csharp
// Method: Optimized version for filtering products by category
public List<Product> FilterProductsByCategory_Optimized(List<Product> products, string category)
{
    // Your optimized implementation here
    // Consider using parallel processing, avoiding unnecessary allocations, etc.
}
```

2. Optimize the tag search method:
```csharp
// Method: Optimized version for finding products with a specific tag
public List<Product> FindProductsWithTag_Optimized(List<Product> products, string tag)
{
    // Your optimized implementation here
    // Consider using HashSet for lookups, parallel processing, etc.
}
```

3. Optimize the sorting method:
```csharp
// Method: Optimized version for sorting products by price
public List<Product> SortProductsByPrice_Optimized(List<Product> products)
{
    // Your optimized implementation here
    // Consider using better sorting algorithms, parallel sorting, etc.
}
```

### 5. Benchmark the Optimized Methods

Add benchmarks for the optimized methods and compare them with the original implementations:

```csharp
[Benchmark]
public List<Product> Optimized_Medium()
{
    return _processor.FilterProductsByCategory_Optimized(_mediumDataset, _targetCategory);
}

[Benchmark]
public List<Product> Optimized_Large()
{
    return _processor.FilterProductsByCategory_Optimized(_largeDataset, _targetCategory);
}
```

### 6. Document Your Findings

Create a markdown document that summarizes:

1. The original benchmark results
2. The optimizations you applied
3. The improved benchmark results
4. Analysis of why the optimizations worked

## Expected Output

A complete benchmark project with results showing performance improvements in the optimized methods.

## Bonus Tasks

1. Add memory allocation analysis using the `[MemoryDiagnoser]` attribute.
2. Implement and benchmark different sorting algorithms.
3. Test the impact of different collection types (List vs Array vs ImmutableList).
4. Implement parallel versions of methods and benchmark them against sequential versions.

## Submission

Submit the benchmark project with all implementations and a document explaining your findings.

## Evaluation Criteria

- Proper use of BenchmarkDotNet
- Quality of the benchmark design
- Effectiveness of optimizations
- Understanding of performance implications as demonstrated in documentation
- Proper analysis of benchmark results