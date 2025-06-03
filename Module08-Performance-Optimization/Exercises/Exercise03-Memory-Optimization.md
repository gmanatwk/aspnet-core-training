# Exercise 3: Memory Optimization

## Objective
Reduce memory allocations and improve garbage collection behavior in a high-throughput ASP.NET Core application.

## Prerequisites
- Visual Studio or Visual Studio Code
- .NET 8 SDK
- Basic understanding of memory management in .NET

## Exercise Description

In this exercise, you will identify and fix memory allocation issues in a sample ASP.NET Core application. You'll implement various techniques to reduce allocations, use value types efficiently, and implement object pooling.

## Tasks

### 1. Setup the Project

1. Create a new ASP.NET Core Web API project:
   ```
   dotnet new webapi -n MemoryOptimization
   ```

2. Add the required NuGet packages:
   ```
   dotnet add package BenchmarkDotNet
   dotnet add package Microsoft.Diagnostics.NETCore.Client
   dotnet add package Microsoft.Extensions.ObjectPool
   ```

3. Create a controller for testing string operations:
   ```csharp
   [ApiController]
   [Route("api/[controller]")]
   public class StringProcessingController : ControllerBase
   {
       private readonly IStringProcessor _stringProcessor;
       
       public StringProcessingController(IStringProcessor stringProcessor)
       {
           _stringProcessor = stringProcessor;
       }
       
       [HttpPost("process")]
       public ActionResult<string> ProcessString([FromBody] string input)
       {
           return Ok(_stringProcessor.Process(input));
       }
   }
   ```

### 2. Identify String Allocation Issues

1. Create an interface and an inefficient implementation with excessive string allocations:
   ```csharp
   public interface IStringProcessor
   {
       string Process(string input);
   }
   
   public class IneffientStringProcessor : IStringProcessor
   {
       public string Process(string input)
       {
           if (string.IsNullOrEmpty(input))
               return string.Empty;
               
           // Inefficient string operations with multiple allocations
           var result = input.ToUpper();
           result = result.Replace("  ", " ");
           
           var words = result.Split(' ');
           result = string.Empty;
           
           foreach (var word in words)
           {
               if (!string.IsNullOrWhiteSpace(word))
               {
                   if (!string.IsNullOrEmpty(result))
                       result += " ";
                   
                   result += word.Trim();
               }
           }
           
           return result;
       }
   }
   ```

2. Create an optimized version using StringBuilder and minimizing allocations:
   ```csharp
   public class OptimizedStringProcessor : IStringProcessor
   {
       public string Process(string input)
       {
           // TODO: Implement with StringBuilder and fewer allocations
       }
   }
   ```

### 3. Implement Span<T> for String Operations

1. Create a processor that uses Span<T> to reduce allocations:
   ```csharp
   public class SpanStringProcessor : IStringProcessor
   {
       public string Process(string input)
       {
           // TODO: Implement using ReadOnlySpan<char> and Span<char>
           // to avoid string allocations during processing
       }
   }
   ```

### 4. Implement Object Pooling

1. Create a class that requires expensive initialization:
   ```csharp
   public class ExpensiveObject
   {
       private readonly byte[] _buffer;
       
       public ExpensiveObject(int bufferSize = 1024 * 1024) // 1MB buffer
       {
           _buffer = new byte[bufferSize];
           // Simulate expensive initialization
           for (int i = 0; i < _buffer.Length; i++)
           {
               _buffer[i] = (byte)(i % 256);
           }
       }
       
       public byte[] ProcessData(byte[] input)
       {
           // Simulate data processing
           var result = new byte[input.Length];
           for (int i = 0; i < input.Length; i++)
           {
               result[i] = (byte)(_buffer[i % _buffer.Length] ^ input[i]);
           }
           return result;
       }
   }
   ```

2. Create a controller that uses this expensive object without pooling:
   ```csharp
   [ApiController]
   [Route("api/[controller]")]
   public class DataProcessingController : ControllerBase
   {
       [HttpPost("process-no-pooling")]
       public ActionResult<byte[]> ProcessWithoutPooling([FromBody] byte[] data)
       {
           // Create a new instance for each request (inefficient)
           var processor = new ExpensiveObject();
           return Ok(processor.ProcessData(data));
       }
       
       [HttpPost("process-with-pooling")]
       public ActionResult<byte[]> ProcessWithPooling([FromBody] byte[] data)
       {
           // TODO: Implement using ObjectPool
       }
   }
   ```

3. Implement object pooling for the expensive object:
   ```csharp
   public class ExpensiveObjectPolicy : IPooledObjectPolicy<ExpensiveObject>
   {
       public ExpensiveObject Create()
       {
           return new ExpensiveObject();
       }
       
       public bool Return(ExpensiveObject obj)
       {
           // You could perform cleanup here if needed
           return true;
       }
   }
   ```

4. Register the object pool in `Program.cs`:
   ```csharp
   builder.Services.AddSingleton<ObjectPoolProvider, DefaultObjectPoolProvider>();
   builder.Services.AddSingleton<IPooledObjectPolicy<ExpensiveObject>, ExpensiveObjectPolicy>();
   builder.Services.AddSingleton(serviceProvider =>
   {
       var provider = serviceProvider.GetRequiredService<ObjectPoolProvider>();
       var policy = serviceProvider.GetRequiredService<IPooledObjectPolicy<ExpensiveObject>>();
       return provider.Create(policy);
   });
   ```

### 5. Use ArrayPool<T> for Buffer Management

1. Create a service that processes large data buffers:
   ```csharp
   public interface IBufferProcessor
   {
       byte[] ProcessBuffer(byte[] input);
   }
   
   public class IneffientBufferProcessor : IBufferProcessor
   {
       public byte[] ProcessBuffer(byte[] input)
       {
           // Allocate temporary buffers for processing
           var tempBuffer1 = new byte[input.Length];
           var tempBuffer2 = new byte[input.Length];
           
           // First transformation
           for (int i = 0; i < input.Length; i++)
           {
               tempBuffer1[i] = (byte)(input[i] + 1);
           }
           
           // Second transformation
           for (int i = 0; i < input.Length; i++)
           {
               tempBuffer2[i] = (byte)(tempBuffer1[i] * 2);
           }
           
           // Final transformation
           var result = new byte[input.Length];
           for (int i = 0; i < input.Length; i++)
           {
               result[i] = (byte)(tempBuffer2[i] - 1);
           }
           
           return result;
       }
   }
   ```

2. Create an optimized version using ArrayPool<T>:
   ```csharp
   public class OptimizedBufferProcessor : IBufferProcessor
   {
       public byte[] ProcessBuffer(byte[] input)
       {
           // TODO: Implement using ArrayPool<byte>.Shared to rent buffers
           // instead of allocating new arrays
       }
   }
   ```

### 6. Implement Value Types and ref Structs

1. Create a struct for point calculations:
   ```csharp
   // Mutable reference struct that can only live on the stack
   public ref struct Point3D
   {
       public double X;
       public double Y;
       public double Z;
       
       public Point3D(double x, double y, double z)
       {
           X = x;
           Y = y;
           Z = z;
       }
       
       public readonly double DistanceTo(in Point3D other)
       {
           double dx = X - other.X;
           double dy = Y - other.Y;
           double dz = Z - other.Z;
           return Math.Sqrt(dx * dx + dy * dy + dz * dz);
       }
   }
   ```

2. Create a benchmark to compare with class-based implementation:
   ```csharp
   public class Point3DClass
   {
       public double X { get; set; }
       public double Y { get; set; }
       public double Z { get; set; }
       
       public Point3DClass(double x, double y, double z)
       {
           X = x;
           Y = y;
           Z = z;
       }
       
       public double DistanceTo(Point3DClass other)
       {
           double dx = X - other.X;
           double dy = Y - other.Y;
           double dz = Z - other.Z;
           return Math.Sqrt(dx * dx + dy * dy + dz * dz);
       }
   }
   
   [MemoryDiagnoser]
   public class ValueTypesBenchmarks
   {
       private const int IterationCount = 1_000_000;
       
       [Benchmark(Baseline = true)]
       public double Point3DClass_DistanceCalculations()
       {
           double totalDistance = 0;
           var points = new Point3DClass[100];
           
           // Initialize points
           for (int i = 0; i < points.Length; i++)
           {
               points[i] = new Point3DClass(i, i * 2, i * 3);
           }
           
           // Perform distance calculations
           for (int iter = 0; iter < IterationCount / points.Length; iter++)
           {
               for (int i = 0; i < points.Length - 1; i++)
               {
                   totalDistance += points[i].DistanceTo(points[i + 1]);
               }
           }
           
           return totalDistance;
       }
       
       [Benchmark]
       public double Point3DStruct_DistanceCalculations()
       {
           // TODO: Implement the same benchmark using Point3D struct
       }
   }
   ```

### 7. Reduce Closure Allocations

1. Create a service with closure allocations:
   ```csharp
   public class ClosureService
   {
       public async Task ProcessItemsWithClosure(List<int> items)
       {
           foreach (var item in items)
           {
               // This creates a closure, capturing 'item'
               await Task.Delay(10).ContinueWith(t => 
               {
                   Console.WriteLine($"Processed item: {item}");
               });
           }
       }
       
       public async Task ProcessItemsWithoutClosure(List<int> items)
       {
           // TODO: Implement without creating closures
       }
   }
   ```

### 8. Benchmark Memory Improvements

1. Create comprehensive benchmarks for all optimization techniques:
   ```csharp
   [MemoryDiagnoser]
   [Orderer(SummaryOrderPolicy.FastestToSlowest)]
   [RankColumn]
   public class MemoryOptimizationBenchmarks
   {
       // TODO: Implement benchmarks for all optimization techniques
   }
   ```

## Expected Output

1. All optimized implementations should show significant reductions in memory allocations.
2. The benchmark results should demonstrate the impact of each optimization technique.
3. The application should handle the same workload with less memory pressure and fewer garbage collections.

## Bonus Tasks

1. Implement custom memory pooling for specific object types.
2. Use `Span<T>` and `Memory<T>` for advanced memory management scenarios.
3. Implement a custom allocator for specific scenarios.
4. Profile the application using dotMemory or similar tools to identify additional optimization opportunities.

## Submission

Submit your project with implementations of all memory optimization techniques, including benchmark results and an analysis of the improvements.

## Evaluation Criteria

- Reduction in memory allocations
- Proper use of StringBuilder, Span<T>, and pooling
- Effective implementation of value types
- Elimination of closure allocations where appropriate
- Benchmark results showing memory improvements
- Code quality and organization