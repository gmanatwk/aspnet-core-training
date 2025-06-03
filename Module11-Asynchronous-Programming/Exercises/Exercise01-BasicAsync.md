# Exercise 1: Basic Async Programming

## Objective
Practice fundamental async/await patterns and understand the difference between synchronous and asynchronous operations.

## Prerequisites
- Basic understanding of C# and .NET
- Completed review of 01-BasicAsync example

## Instructions

### Part 1: Create an Async Console Application

1. Create a new console application called `AsyncExercise01`
2. Implement the following async methods:

```csharp
// Method that simulates downloading data from a web service
static async Task<string> DownloadDataAsync(string url, int delayMs)
{
    // TODO: Implement this method
    // - Log the start of download with URL
    // - Simulate network delay using Task.Delay
    // - Return simulated data
}

// Method that processes downloaded data
static async Task<ProcessedData> ProcessDataAsync(string rawData)
{
    // TODO: Implement this method
    // - Log the start of processing
    // - Simulate processing time (500ms)
    // - Return ProcessedData object with summary
}

// Method that saves processed data
static async Task SaveDataAsync(ProcessedData data, string fileName)
{
    // TODO: Implement this method
    // - Log the start of saving
    // - Simulate file I/O (300ms)
    // - Log completion
}
```

3. Create a `ProcessedData` class with the following properties:
   - `string Summary`
   - `int CharacterCount`
   - `DateTime ProcessedAt`

### Part 2: Implement Sequential vs Concurrent Operations

1. Create a method `ProcessUrlsSequentiallyAsync` that:
   - Processes a list of URLs one by one
   - Measures total execution time
   - Returns results in order

2. Create a method `ProcessUrlsConcurrentlyAsync` that:
   - Processes all URLs concurrently using `Task.WhenAll`
   - Measures total execution time
   - Returns results (order may vary)

3. Test both methods with these URLs:
   - "https://api1.example.com" (1000ms delay)
   - "https://api2.example.com" (1500ms delay)
   - "https://api3.example.com" (800ms delay)

### Part 3: Exception Handling

1. Create a method `DownloadWithRetryAsync` that:
   - Attempts to download data
   - Retries up to 3 times if it fails
   - Has a 50% chance of failure on each attempt
   - Uses exponential backoff (1s, 2s, 4s delays)

2. Implement proper exception handling for:
   - Individual download failures
   - Aggregate exceptions when using `Task.WhenAll`

## Expected Output

Your program should output something like:

```
=== Sequential Processing ===
Downloading from https://api1.example.com...
Processing data from https://api1.example.com...
Saving data to api1_data.txt...
Downloading from https://api2.example.com...
Processing data from https://api2.example.com...
Saving data to api2_data.txt...
Downloading from https://api3.example.com...
Processing data from https://api3.example.com...
Saving data to api3_data.txt...
Sequential processing completed in 6600ms

=== Concurrent Processing ===
Downloading from https://api1.example.com...
Downloading from https://api2.example.com...
Downloading from https://api3.example.com...
Processing data from https://api3.example.com...
Processing data from https://api1.example.com...
Processing data from https://api2.example.com...
Saving data to api3_data.txt...
Saving data to api1_data.txt...
Saving data to api2_data.txt...
Concurrent processing completed in 2300ms

=== Retry Logic Test ===
Attempting download (try 1/3)...
Download failed, retrying in 1000ms...
Attempting download (try 2/3)...
Download successful!
```

## Success Criteria

- ✅ Sequential processing takes significantly longer than concurrent
- ✅ Proper async/await usage throughout
- ✅ Exception handling works correctly
- ✅ Retry logic implements exponential backoff
- ✅ All methods are properly async (no blocking calls)
- ✅ Logging provides clear progress information

## Bonus Challenges

1. **Cancellation Support**: Add `CancellationToken` support to all async methods
2. **Progress Reporting**: Implement `IProgress<T>` to report download progress
3. **Timeout Handling**: Add timeout functionality to downloads
4. **Result Caching**: Cache download results to avoid duplicate requests

## Common Mistakes to Avoid

- ❌ Don't use `.Result` or `.Wait()` - this blocks threads
- ❌ Don't forget to await async calls
- ❌ Don't ignore exceptions in fire-and-forget scenarios
- ❌ Don't create unnecessary tasks with `Task.Run`

## Hints

- Use `Task.Delay()` for simulating async operations
- Use `Stopwatch` for measuring execution time
- Use `Random` for simulating failures in retry logic
- Consider using `ConfigureAwait(false)` in library methods

## Solution Files

After completing the exercise, compare your solution with:
- `Solutions/Exercise01/AsyncExercise01.csproj`
- `Solutions/Exercise01/Program.cs`
- `Solutions/Exercise01/Models/ProcessedData.cs`