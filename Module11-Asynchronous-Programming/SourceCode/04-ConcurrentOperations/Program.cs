using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using System.Threading.Channels;

namespace ConcurrentOperations
{
    class Program
    {
        static async Task Main(string[] args)
        {
            Console.WriteLine("=== Concurrent Operations Examples ===\n");

            await RunTaskWhenAllExample();
            await RunTaskWhenAnyExample();
            await RunParallelVsTaskExample();
            await RunAsyncEnumerableExample();
            await RunChannelExample();
            await RunConcurrentCollectionsExample();
            await RunThrottledConcurrencyExample();

            Console.WriteLine("\nPress any key to exit...");
            Console.ReadKey();
        }

        // Example 1: Task.WhenAll - Wait for all tasks to complete
        static async Task RunTaskWhenAllExample()
        {
            Console.WriteLine("1. Task.WhenAll Example:");
            var stopwatch = Stopwatch.StartNew();

            var tasks = new List<Task<string>>
            {
                FetchDataAsync("Service A", 1000),
                FetchDataAsync("Service B", 1500),
                FetchDataAsync("Service C", 800),
                FetchDataAsync("Service D", 1200)
            };

            // Wait for all tasks to complete
            string[] results = await Task.WhenAll(tasks);

            stopwatch.Stop();
            Console.WriteLine($"All services completed in {stopwatch.ElapsedMilliseconds}ms");
            foreach (var result in results)
            {
                Console.WriteLine($"  - {result}");
            }
            Console.WriteLine();
        }

        // Example 2: Task.WhenAny - React to the first completed task
        static async Task RunTaskWhenAnyExample()
        {
            Console.WriteLine("2. Task.WhenAny Example:");
            var stopwatch = Stopwatch.StartNew();

            var tasks = new List<Task<string>>
            {
                FetchDataAsync("Fast Service", 500),
                FetchDataAsync("Medium Service", 1000),
                FetchDataAsync("Slow Service", 2000)
            };

            // Process results as they come in
            var remainingTasks = new HashSet<Task<string>>(tasks);
            
            while (remainingTasks.Count > 0)
            {
                var completedTask = await Task.WhenAny(remainingTasks);
                remainingTasks.Remove(completedTask);
                
                var result = await completedTask;
                Console.WriteLine($"  Completed: {result} (after {stopwatch.ElapsedMilliseconds}ms)");
            }

            Console.WriteLine($"All tasks completed in {stopwatch.ElapsedMilliseconds}ms\n");
        }

        // Example 3: Parallel.ForEach vs Task.Run comparison
        static async Task RunParallelVsTaskExample()
        {
            Console.WriteLine("3. Parallel.ForEach vs Task.Run:");
            
            var items = Enumerable.Range(1, 10).ToList();
            var stopwatch = Stopwatch.StartNew();

            // Using Parallel.ForEach (CPU-bound work)
            Console.WriteLine("Using Parallel.ForEach for CPU-bound work:");
            stopwatch.Restart();
            
            var results1 = new ConcurrentBag<int>();
            Parallel.ForEach(items, item =>
            {
                var result = PerformCpuBoundWork(item);
                results1.Add(result);
            });
            
            stopwatch.Stop();
            Console.WriteLine($"  Parallel.ForEach completed in {stopwatch.ElapsedMilliseconds}ms");

            // Using async/await for I/O-bound work
            Console.WriteLine("Using async/await for I/O-bound work:");
            stopwatch.Restart();
            
            var asyncTasks = items.Select(async item => await PerformIoBoundWorkAsync(item));
            var results2 = await Task.WhenAll(asyncTasks);
            
            stopwatch.Stop();
            Console.WriteLine($"  Async/await completed in {stopwatch.ElapsedMilliseconds}ms");
            Console.WriteLine();
        }

        // Example 4: IAsyncEnumerable for streaming data
        static async Task RunAsyncEnumerableExample()
        {
            Console.WriteLine("4. IAsyncEnumerable Example:");
            
            await foreach (var item in GenerateDataStreamAsync())
            {
                Console.WriteLine($"  Received: {item}");
            }
            
            Console.WriteLine("Stream completed\n");
        }

        // Example 5: Channel for producer-consumer pattern
        static async Task RunChannelExample()
        {
            Console.WriteLine("5. Channel Producer-Consumer Example:");
            
            var channel = Channel.CreateUnbounded<WorkItem>();
            var reader = channel.Reader;
            var writer = channel.Writer;

            // Start producer
            var producerTask = ProduceWorkItemsAsync(writer);
            
            // Start multiple consumers
            var consumerTasks = new[]
            {
                ConsumeWorkItemsAsync(reader, "Consumer 1"),
                ConsumeWorkItemsAsync(reader, "Consumer 2"),
                ConsumeWorkItemsAsync(reader, "Consumer 3")
            };

            // Wait for producer to finish
            await producerTask;
            
            // Signal completion and wait for consumers
            writer.Complete();
            await Task.WhenAll(consumerTasks);
            
            Console.WriteLine("Channel processing completed\n");
        }

        // Example 6: Concurrent collections
        static async Task RunConcurrentCollectionsExample()
        {
            Console.WriteLine("6. Concurrent Collections Example:");
            
            var concurrentBag = new ConcurrentBag<string>();
            var concurrentDict = new ConcurrentDictionary<int, string>();
            
            var tasks = Enumerable.Range(1, 10).Select(async i =>
            {
                await Task.Delay(100); // Simulate async work
                
                // Add to concurrent bag
                concurrentBag.Add($"Item {i}");
                
                // Add to concurrent dictionary
                concurrentDict.TryAdd(i, $"Value {i}");
                
                Console.WriteLine($"  Task {i} added items");
            });

            await Task.WhenAll(tasks);
            
            Console.WriteLine($"ConcurrentBag count: {concurrentBag.Count}");
            Console.WriteLine($"ConcurrentDictionary count: {concurrentDict.Count}");
            Console.WriteLine();
        }

        // Example 7: Throttled concurrency with SemaphoreSlim
        static async Task RunThrottledConcurrencyExample()
        {
            Console.WriteLine("7. Throttled Concurrency Example:");
            
            const int maxConcurrency = 3;
            using var semaphore = new SemaphoreSlim(maxConcurrency, maxConcurrency);
            
            var tasks = Enumerable.Range(1, 10).Select(async i =>
            {
                await semaphore.WaitAsync();
                try
                {
                    Console.WriteLine($"  Task {i} started (max {maxConcurrency} concurrent)");
                    await Task.Delay(1000); // Simulate work
                    Console.WriteLine($"  Task {i} completed");
                }
                finally
                {
                    semaphore.Release();
                }
            });

            await Task.WhenAll(tasks);
            Console.WriteLine("Throttled concurrency completed\n");
        }

        // Helper methods
        static async Task<string> FetchDataAsync(string serviceName, int delayMs)
        {
            await Task.Delay(delayMs);
            return $"{serviceName} data fetched in {delayMs}ms";
        }

        static int PerformCpuBoundWork(int input)
        {
            // Simulate CPU-intensive work
            var result = 0;
            for (int i = 0; i < 1000000; i++)
            {
                result += input * i;
            }
            Thread.Sleep(50); // Simulate additional CPU work
            return result;
        }

        static async Task<int> PerformIoBoundWorkAsync(int input)
        {
            // Simulate I/O-bound work
            await Task.Delay(100);
            return input * 2;
        }

        static async IAsyncEnumerable<string> GenerateDataStreamAsync()
        {
            for (int i = 1; i <= 5; i++)
            {
                await Task.Delay(300);
                yield return $"Stream item {i}";
            }
        }

        static async Task ProduceWorkItemsAsync(ChannelWriter<WorkItem> writer)
        {
            for (int i = 1; i <= 10; i++)
            {
                var workItem = new WorkItem { Id = i, Data = $"Work item {i}" };
                await writer.WriteAsync(workItem);
                Console.WriteLine($"  Produced: {workItem.Data}");
                await Task.Delay(200);
            }
        }

        static async Task ConsumeWorkItemsAsync(ChannelReader<WorkItem> reader, string consumerName)
        {
            await foreach (var workItem in reader.ReadAllAsync())
            {
                Console.WriteLine($"  {consumerName} processing: {workItem.Data}");
                await Task.Delay(500); // Simulate processing time
                Console.WriteLine($"  {consumerName} completed: {workItem.Data}");
            }
        }
    }

    public class WorkItem
    {
        public int Id { get; set; }
        public string Data { get; set; } = string.Empty;
    }
}