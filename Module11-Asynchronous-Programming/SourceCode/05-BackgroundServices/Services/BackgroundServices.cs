using System.Collections.Concurrent;

namespace BackgroundServices.Services
{
    // Queue service for background processing
    public interface IBackgroundTaskQueue
    {
        void QueueBackgroundWorkItem(Func<CancellationToken, Task> workItem);
        Task<Func<CancellationToken, Task>> DequeueAsync(CancellationToken cancellationToken);
    }

    public class BackgroundTaskQueue : IBackgroundTaskQueue
    {
        private readonly ConcurrentQueue<Func<CancellationToken, Task>> _workItems = new();
        private readonly SemaphoreSlim _signal = new(0);

        public void QueueBackgroundWorkItem(Func<CancellationToken, Task> workItem)
        {
            if (workItem == null)
                throw new ArgumentNullException(nameof(workItem));

            _workItems.Enqueue(workItem);
            _signal.Release();
        }

        public async Task<Func<CancellationToken, Task>> DequeueAsync(CancellationToken cancellationToken)
        {
            await _signal.WaitAsync(cancellationToken);
            _workItems.TryDequeue(out var workItem);
            return workItem!;
        }
    }

    // Background service that processes queued work items
    public class QueuedHostedService : BackgroundService
    {
        private readonly IBackgroundTaskQueue _taskQueue;
        private readonly ILogger<QueuedHostedService> _logger;

        public QueuedHostedService(IBackgroundTaskQueue taskQueue, ILogger<QueuedHostedService> logger)
        {
            _taskQueue = taskQueue;
            _logger = logger;
        }

        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {
            _logger.LogInformation("Queued Hosted Service is running");

            await BackgroundProcessing(stoppingToken);
        }

        private async Task BackgroundProcessing(CancellationToken stoppingToken)
        {
            while (!stoppingToken.IsCancellationRequested)
            {
                try
                {
                    var workItem = await _taskQueue.DequeueAsync(stoppingToken);
                    await workItem(stoppingToken);
                }
                catch (OperationCanceledException)
                {
                    // Expected when cancellation is requested
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Error occurred executing work item");
                }
            }
        }

        public override async Task StopAsync(CancellationToken stoppingToken)
        {
            _logger.LogInformation("Queued Hosted Service is stopping");
            await base.StopAsync(stoppingToken);
        }
    }

    // Timed background service that runs periodically
    public class TimedHostedService : BackgroundService
    {
        private readonly ILogger<TimedHostedService> _logger;
        private readonly IServiceScopeFactory _scopeFactory;

        public TimedHostedService(ILogger<TimedHostedService> logger, IServiceScopeFactory scopeFactory)
        {
            _logger = logger;
            _scopeFactory = scopeFactory;
        }

        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {
            _logger.LogInformation("Timed Hosted Service running");

            using var timer = new PeriodicTimer(TimeSpan.FromSeconds(10));

            while (!stoppingToken.IsCancellationRequested && await timer.WaitForNextTickAsync(stoppingToken))
            {
                await DoWork(stoppingToken);
            }
        }

        private async Task DoWork(CancellationToken stoppingToken)
        {
            using var scope = _scopeFactory.CreateScope();
            var scopedService = scope.ServiceProvider.GetRequiredService<IScopedProcessingService>();

            try
            {
                await scopedService.DoWorkAsync(stoppingToken);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error occurred in timed service");
            }
        }

        public override async Task StopAsync(CancellationToken stoppingToken)
        {
            _logger.LogInformation("Timed Hosted Service is stopping");
            await base.StopAsync(stoppingToken);
        }
    }

    // File monitoring background service
    public class FileMonitorService : BackgroundService
    {
        private readonly ILogger<FileMonitorService> _logger;
        private readonly string _watchPath;
        private FileSystemWatcher? _fileWatcher;

        public FileMonitorService(ILogger<FileMonitorService> logger, IConfiguration configuration)
        {
            _logger = logger;
            _watchPath = configuration["FileMonitor:WatchPath"] ?? Path.GetTempPath();
        }

        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {
            _logger.LogInformation("File Monitor Service starting. Watching: {Path}", _watchPath);

            if (!Directory.Exists(_watchPath))
            {
                Directory.CreateDirectory(_watchPath);
            }

            _fileWatcher = new FileSystemWatcher(_watchPath)
            {
                Filter = "*.txt",
                EnableRaisingEvents = true,
                IncludeSubdirectories = false
            };

            _fileWatcher.Created += OnFileCreated;
            _fileWatcher.Changed += OnFileChanged;
            _fileWatcher.Deleted += OnFileDeleted;

            try
            {
                await Task.Delay(Timeout.Infinite, stoppingToken);
            }
            catch (OperationCanceledException)
            {
                // Expected when cancellation is requested
            }
        }

        private async void OnFileCreated(object sender, FileSystemEventArgs e)
        {
            _logger.LogInformation("File created: {FilePath}", e.FullPath);
            await ProcessFileAsync(e.FullPath);
        }

        private async void OnFileChanged(object sender, FileSystemEventArgs e)
        {
            _logger.LogInformation("File changed: {FilePath}", e.FullPath);
            await ProcessFileAsync(e.FullPath);
        }

        private void OnFileDeleted(object sender, FileSystemEventArgs e)
        {
            _logger.LogInformation("File deleted: {FilePath}", e.FullPath);
        }

        private async Task ProcessFileAsync(string filePath)
        {
            try
            {
                // Wait a bit for file to be fully written
                await Task.Delay(500);
                
                if (File.Exists(filePath))
                {
                    var content = await File.ReadAllTextAsync(filePath);
                    _logger.LogInformation("Processed file content: {Length} characters", content.Length);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error processing file: {FilePath}", filePath);
            }
        }

        public override void Dispose()
        {
            _fileWatcher?.Dispose();
            base.Dispose();
        }
    }

    // Scoped service for dependency injection in background services
    public interface IScopedProcessingService
    {
        Task DoWorkAsync(CancellationToken stoppingToken);
    }

    public class ScopedProcessingService : IScopedProcessingService
    {
        private readonly ILogger<ScopedProcessingService> _logger;

        public ScopedProcessingService(ILogger<ScopedProcessingService> logger)
        {
            _logger = logger;
        }

        public async Task DoWorkAsync(CancellationToken stoppingToken)
        {
            _logger.LogInformation("Scoped Processing Service is working");

            // Simulate some async work
            await Task.Delay(2000, stoppingToken);

            // Simulate processing data
            var processedItems = Random.Shared.Next(1, 10);
            _logger.LogInformation("Processed {ItemCount} items", processedItems);
        }
    }

    // Health check service that runs as background service
    public class HealthCheckService : BackgroundService
    {
        private readonly ILogger<HealthCheckService> _logger;
        private readonly IHttpClientFactory _httpClientFactory;
        private readonly string[] _healthCheckUrls;

        public HealthCheckService(
            ILogger<HealthCheckService> logger, 
            IHttpClientFactory httpClientFactory,
            IConfiguration configuration)
        {
            _logger = logger;
            _httpClientFactory = httpClientFactory;
            _healthCheckUrls = configuration.GetSection("HealthCheck:Urls").Get<string[]>() ?? Array.Empty<string>();
        }

        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {
            _logger.LogInformation("Health Check Service starting");

            using var timer = new PeriodicTimer(TimeSpan.FromMinutes(1));

            while (!stoppingToken.IsCancellationRequested && await timer.WaitForNextTickAsync(stoppingToken))
            {
                await PerformHealthChecks(stoppingToken);
            }
        }

        private async Task PerformHealthChecks(CancellationToken stoppingToken)
        {
            if (_healthCheckUrls.Length == 0)
            {
                _logger.LogInformation("No health check URLs configured");
                return;
            }

            using var httpClient = _httpClientFactory.CreateClient();
            httpClient.Timeout = TimeSpan.FromSeconds(30);

            var healthCheckTasks = _healthCheckUrls.Select(async url =>
            {
                try
                {
                    var response = await httpClient.GetAsync(url, stoppingToken);
                    var isHealthy = response.IsSuccessStatusCode;
                    
                    _logger.LogInformation(
                        "Health check for {Url}: {Status} ({StatusCode})",
                        url,
                        isHealthy ? "Healthy" : "Unhealthy",
                        response.StatusCode);
                    
                    return new { Url = url, IsHealthy = isHealthy };
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Health check failed for {Url}", url);
                    return new { Url = url, IsHealthy = false };
                }
            });

            var results = await Task.WhenAll(healthCheckTasks);
            var healthyCount = results.Count(r => r.IsHealthy);
            
            _logger.LogInformation(
                "Health check summary: {HealthyCount}/{TotalCount} services healthy",
                healthyCount,
                results.Length);
        }
    }
}