using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Threading;
using System.Threading.Tasks;

namespace BasicAsync
{
    class Program
    {
        static async Task Main(string[] args)
        {
            Console.WriteLine("=== Basic Async Programming Examples ===\n");

            await RunBasicExample();
            await RunComparisonExample();
            await RunTaskReturnExample();
            await RunExceptionHandlingExample();

            Console.WriteLine("\nPress any key to exit...");
            Console.ReadKey();
        }

        // Example 1: Basic async/await pattern
        static async Task RunBasicExample()
        {
            Console.WriteLine("1. Basic Async Example:");
            Console.WriteLine("Starting async operation...");

            string result = await GetDataAsync();
            Console.WriteLine($"Result: {result}");
            Console.WriteLine("Operation completed.\n");
        }

        static async Task<string> GetDataAsync()
        {
            // Simulate an async operation (like a web request or database call)
            await Task.Delay(2000); // 2 second delay
            return "Data retrieved successfully!";
        }

        // Example 2: Compare sync vs async performance
        static async Task RunComparisonExample()
        {
            Console.WriteLine("2. Sync vs Async Comparison:");

            var stopwatch = Stopwatch.StartNew();

            // Synchronous approach
            Console.WriteLine("Running synchronous operations...");
            stopwatch.Restart();
            
            SyncOperation("Task 1");
            SyncOperation("Task 2");
            SyncOperation("Task 3");
            
            stopwatch.Stop();
            Console.WriteLine($"Synchronous total time: {stopwatch.ElapsedMilliseconds}ms");

            // Asynchronous approach
            Console.WriteLine("Running asynchronous operations...");
            stopwatch.Restart();

            await Task.WhenAll(
                AsyncOperation("Task 1"),
                AsyncOperation("Task 2"),
                AsyncOperation("Task 3")
            );

            stopwatch.Stop();
            Console.WriteLine($"Asynchronous total time: {stopwatch.ElapsedMilliseconds}ms\n");
        }

        static void SyncOperation(string taskName)
        {
            Console.WriteLine($"  {taskName} started");
            Thread.Sleep(1000); // Simulate work
            Console.WriteLine($"  {taskName} completed");
        }

        static async Task AsyncOperation(string taskName)
        {
            Console.WriteLine($"  {taskName} started");
            await Task.Delay(1000); // Simulate async work
            Console.WriteLine($"  {taskName} completed");
        }

        // Example 3: Different Task return types
        static async Task RunTaskReturnExample()
        {
            Console.WriteLine("3. Task Return Types:");

            // Task (no return value)
            await DoWorkAsync();

            // Task<T> (with return value)
            int result = await CalculateAsync(10, 20);
            Console.WriteLine($"Calculation result: {result}");

            // Multiple async operations
            var tasks = new List<Task<int>>
            {
                CalculateAsync(1, 2),
                CalculateAsync(3, 4),
                CalculateAsync(5, 6)
            };

            int[] results = await Task.WhenAll(tasks);
            Console.WriteLine($"All results: [{string.Join(", ", results)}]\n");
        }

        static async Task DoWorkAsync()
        {
            Console.WriteLine("  Doing some work...");
            await Task.Delay(500);
            Console.WriteLine("  Work completed!");
        }

        static async Task<int> CalculateAsync(int a, int b)
        {
            Console.WriteLine($"  Calculating {a} + {b}...");
            await Task.Delay(300);
            return a + b;
        }

        // Example 4: Exception handling in async methods
        static async Task RunExceptionHandlingExample()
        {
            Console.WriteLine("4. Exception Handling:");

            try
            {
                await RiskyOperationAsync();
            }
            catch (InvalidOperationException ex)
            {
                Console.WriteLine($"Caught exception: {ex.Message}");
            }

            // Multiple async operations with exception handling
            var tasks = new[]
            {
                SafeOperationAsync("Task 1"),
                SafeOperationAsync("Task 2"),
                RiskyOperationAsync("Task 3") // This will throw
            };

            try
            {
                await Task.WhenAll(tasks);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"One or more tasks failed: {ex.Message}");
                
                // Check individual task results
                foreach (var task in tasks)
                {
                    if (task.IsFaulted)
                    {
                        Console.WriteLine($"  Faulted task exception: {task.Exception?.GetBaseException().Message}");
                    }
                    else if (task.IsCompletedSuccessfully)
                    {
                        Console.WriteLine($"  Task completed successfully");
                    }
                }
            }

            Console.WriteLine();
        }

        static async Task SafeOperationAsync(string taskName)
        {
            Console.WriteLine($"  {taskName} executing safely...");
            await Task.Delay(200);
            Console.WriteLine($"  {taskName} completed safely");
        }

        static async Task RiskyOperationAsync(string taskName = "Risky operation")
        {
            Console.WriteLine($"  {taskName} starting...");
            await Task.Delay(100);
            throw new InvalidOperationException($"{taskName} failed!");
        }
    }
}