using BenchmarkDotNet.Running;
using ProductCatalog.PerformanceTests.Benchmarks;

namespace ProductCatalog.PerformanceTests;

public class Program
{
    public static void Main(string[] args)
    {
        Console.WriteLine("Running ProductCatalog Performance Tests");
        Console.WriteLine("=========================================");
        
        // Run all benchmarks
        BenchmarkRunner.Run<ProductServiceBenchmarks>();
        BenchmarkRunner.Run<OrderServiceBenchmarks>();
        
        // Or run specific benchmarks using command line args
        // var summary = BenchmarkSwitcher.FromAssembly(typeof(Program).Assembly).Run(args);
    }
}