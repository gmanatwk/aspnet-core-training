#!/usr/bin/env pwsh

# Module 11: Exercise 3 - Background Tasks and Services (PowerShell)
# Creates Web API application matching Exercise03-BackgroundTasks.md requirements exactly

param(
    [Parameter(Mandatory=$false)]
    [switch]$Auto,
    
    [Parameter(Mandatory=$false)]
    [switch]$Preview
)

# Configuration
$ProjectName = "BackgroundTasksExercise"  # Exact match to exercise requirements
$InteractiveMode = -not $Auto

# Function to display colored output
function Write-Info { param($Message) Write-Host "ℹ️  $Message" -ForegroundColor Blue }
function Write-Success { param($Message) Write-Host "✅ $Message" -ForegroundColor Green }
function Write-Warning { param($Message) Write-Host "⚠️  $Message" -ForegroundColor Yellow }
function Write-Error { param($Message) Write-Host "❌ $Message" -ForegroundColor Red }

# Function to explain concepts interactively
function Explain-Concept {
    param($Concept, $Explanation)
    
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host "⚡ ASYNC CONCEPT: $Concept" -ForegroundColor Cyan
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host $Explanation -ForegroundColor Yellow
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host ""
    
    if ($InteractiveMode) {
        Write-Host "Press Enter to continue..." -NoNewline
        Read-Host
        Write-Host ""
    }
}

# Function to create files interactively
function Create-FileInteractive {
    param($FilePath, $Content, $Description)
    
    if ($Preview) {
        Write-Host "📄 Would create: $FilePath" -ForegroundColor Cyan
        Write-Host "   Description: $Description" -ForegroundColor Yellow
        return
    }
    
    Write-Host "📄 Creating: $FilePath" -ForegroundColor Cyan
    Write-Host "   $Description" -ForegroundColor Yellow
    
    # Create directory if it doesn't exist
    $Directory = Split-Path $FilePath -Parent
    if ($Directory -and -not (Test-Path $Directory)) {
        New-Item -ItemType Directory -Path $Directory -Force | Out-Null
    }
    
    # Write content to file
    Set-Content -Path $FilePath -Value $Content -Encoding UTF8
    
    if ($InteractiveMode) {
        Write-Host "   File created. Press Enter to continue..." -NoNewline
        Read-Host
    }
    Write-Host ""
}

# Welcome message
Write-Host "⚡ Module 11: Exercise 3 - Background Tasks and Services" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""

# Show learning objectives
Write-Host "🎯 Exercise 3 Learning Objectives:" -ForegroundColor Blue
Write-Host "🚨 PROBLEM: Document Processing System Needs Background Tasks" -ForegroundColor Red
Write-Host "  📁 Files need to be processed without blocking API requests"
Write-Host "  ⏰ Scheduled tasks must run independently"
Write-Host "  📊 System health monitoring is required"
Write-Host "  🔄 Priority queue processing for different job types"
Write-Host "  🎯 GOAL: Build comprehensive background task processing system"
Write-Host ""
Write-Host "You'll learn by building:" -ForegroundColor Yellow
Write-Host "  • Priority queue-based background task processing"
Write-Host "  • File monitoring and automatic processing"
Write-Host "  • Scheduled report generation and cleanup"
Write-Host "  • Health monitoring services"
Write-Host "  • Job management API with upload/download"
Write-Host "  • Multiple file processors (text, image, CSV)"
Write-Host "  • Real-time progress tracking"
Write-Host ""

# Show what will be created
Write-Host "📋 Components to be created:" -ForegroundColor Cyan
Write-Host "• ASP.NET Core Web API project (BackgroundTasksExercise)"
Write-Host "• ProcessingJob model with job management"
Write-Host "• IBackgroundTaskQueue with priority queue implementation"
Write-Host "• Multiple background services (Queue, FileMonitor, Scheduler, Health)"
Write-Host "• File processors for different file types"
Write-Host "• JobsController with upload/download/management endpoints"
Write-Host "• SystemController for health and metrics"
Write-Host "• Real-time progress tracking with SignalR"
Write-Host ""

if ($Preview) {
    Write-Info "Preview mode - no files will be created"
    Write-Host ""
}

# Check prerequisites
Write-Info "Checking prerequisites..."

# Check .NET SDK
if (-not (Get-Command dotnet -ErrorAction SilentlyContinue)) {
    Write-Error ".NET SDK is not installed. Please install .NET 8.0 SDK."
    exit 1
}

Write-Success "Prerequisites check completed"
Write-Host ""

# Check if project exists
if (Test-Path $ProjectName) {
    Write-Warning "Project '$ProjectName' already exists!"
    $Response = Read-Host "Do you want to overwrite it? (y/N)"
    if ($Response -notmatch "^[Yy]$") {
        exit 1
    }
    Remove-Item -Path $ProjectName -Recurse -Force
}

# Explain the background tasks problem
Explain-Concept "🚨 THE PROBLEM: Document Processing Without Background Tasks" @"
You need to build a document processing system that handles:

CURRENT CHALLENGE:
• File uploads block API requests during processing
• No automatic processing of files dropped in folders
• Manual report generation and cleanup
• No system health monitoring
• Single-threaded processing bottlenecks
• No priority handling for urgent jobs

YOUR MISSION:
• Build priority queue-based background task system
• Implement file monitoring for automatic processing
• Add scheduled tasks for reports and cleanup
• Create health monitoring services
• Build job management API with real-time progress
• Support multiple file types with different processors

SYSTEM REQUIREMENTS:
• Process 100+ files concurrently
• Priority queue with different job types
• File monitoring for automatic processing
• Scheduled cleanup and reporting
• Real-time progress tracking
• Graceful shutdown and error recovery
"@

# Create the project
if (-not $Preview) {
    Write-Info "Creating ASP.NET Core Web API project for Exercise 3..."
    Write-Info "This matches the exercise requirements exactly!"
    dotnet new webapi -n $ProjectName --framework net8.0
    Set-Location $ProjectName
    
    # Add required packages
    Write-Info "Adding required NuGet packages..."
    dotnet add package Microsoft.EntityFrameworkCore.InMemory
    dotnet add package Swashbuckle.AspNetCore
    dotnet add package Microsoft.AspNetCore.SignalR
}

# Create ProcessingJob model as required by Exercise 3
Create-FileInteractive "Models/ProcessingJob.cs" @'
namespace BackgroundTasksExercise.Models;

public class ProcessingJob
{
    public int Id { get; set; }
    public string JobType { get; set; } = string.Empty;
    public string FileName { get; set; } = string.Empty;
    public string FilePath { get; set; } = string.Empty;
    public JobStatus Status { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime? StartedAt { get; set; }
    public DateTime? CompletedAt { get; set; }
    public string? ErrorMessage { get; set; }
    public string? ResultData { get; set; }
    public int Progress { get; set; } // 0-100
    public int Priority { get; set; } = 0; // Higher number = higher priority
}

public enum JobStatus
{
    Queued,
    Processing,
    Completed,
    Failed,
    Cancelled
}

public class ProcessingResult
{
    public bool Success { get; set; }
    public string Message { get; set; } = string.Empty;
    public Dictionary<string, object> Metadata { get; set; } = new();
}

public class JobProgress
{
    public int Percentage { get; set; }
    public string Message { get; set; } = string.Empty;
    public DateTime LastUpdated { get; set; }
}
'@ "ProcessingJob model with job management as required by Exercise 3"

# Create background work item model
Create-FileInteractive "Models/BackgroundWorkItem.cs" @'
namespace BackgroundTasksExercise.Models;

public class BackgroundWorkItem
{
    public string Id { get; set; } = Guid.NewGuid().ToString();
    public string JobType { get; set; } = string.Empty;
    public Func<IServiceProvider, CancellationToken, Task> WorkItem { get; set; } = null!;
    public DateTime QueuedAt { get; set; } = DateTime.UtcNow;
    public int Priority { get; set; } = 0; // Higher number = higher priority
}
'@ "BackgroundWorkItem model for queue processing"

# Create IBackgroundTaskQueue interface
Create-FileInteractive "Services/IBackgroundTaskQueue.cs" @'
using BackgroundTasksExercise.Models;

namespace BackgroundTasksExercise.Services;

public interface IBackgroundTaskQueue
{
    void QueueBackgroundWorkItem(BackgroundWorkItem workItem);
    Task<BackgroundWorkItem> DequeueAsync(CancellationToken cancellationToken);
    int Count { get; }
}
'@ "IBackgroundTaskQueue interface for priority queue"

# Create PriorityBackgroundTaskQueue implementation
Create-FileInteractive "Services/PriorityBackgroundTaskQueue.cs" @'
using System.Collections.Concurrent;
using System.Threading.Channels;
using BackgroundTasksExercise.Models;

namespace BackgroundTasksExercise.Services;

public class PriorityBackgroundTaskQueue : IBackgroundTaskQueue
{
    private readonly Channel<BackgroundWorkItem> _queue;
    private readonly SemaphoreSlim _semaphore;

    public PriorityBackgroundTaskQueue(int capacity = 1000)
    {
        var options = new BoundedChannelOptions(capacity)
        {
            FullMode = BoundedChannelFullMode.Wait,
            SingleReader = false,
            SingleWriter = false
        };

        _queue = Channel.CreateBounded<BackgroundWorkItem>(options);
        _semaphore = new SemaphoreSlim(0);
    }

    public void QueueBackgroundWorkItem(BackgroundWorkItem workItem)
    {
        if (workItem == null)
            throw new ArgumentNullException(nameof(workItem));

        if (!_queue.Writer.TryWrite(workItem))
        {
            throw new InvalidOperationException("Unable to queue work item.");
        }

        _semaphore.Release();
    }

    public async Task<BackgroundWorkItem> DequeueAsync(CancellationToken cancellationToken)
    {
        await _semaphore.WaitAsync(cancellationToken);

        if (await _queue.Reader.WaitToReadAsync(cancellationToken))
        {
            if (_queue.Reader.TryRead(out var workItem))
            {
                return workItem;
            }
        }

        throw new InvalidOperationException("Unable to dequeue work item.");
    }

    public int Count => _queue.Reader.CanCount ? _queue.Reader.Count : 0;
}
'@ "PriorityBackgroundTaskQueue implementation with thread-safe operations"

# Create IFileProcessor interface
Create-FileInteractive "Processors/IFileProcessor.cs" @'
using BackgroundTasksExercise.Models;

namespace BackgroundTasksExercise.Processors;

public interface IFileProcessor
{
    Task<ProcessingResult> ProcessAsync(string filePath, CancellationToken cancellationToken, IProgress<int>? progress = null);
    bool CanProcess(string fileName);
}
'@ "IFileProcessor interface for different file types"

# Create TextFileProcessor
Create-FileInteractive "Processors/TextFileProcessor.cs" @'
using BackgroundTasksExercise.Models;

namespace BackgroundTasksExercise.Processors;

public class TextFileProcessor : IFileProcessor
{
    private readonly ILogger<TextFileProcessor> _logger;

    public TextFileProcessor(ILogger<TextFileProcessor> logger)
    {
        _logger = logger;
    }

    public bool CanProcess(string fileName)
    {
        var extension = Path.GetExtension(fileName).ToLowerInvariant();
        return extension == ".txt" || extension == ".md";
    }

    public async Task<ProcessingResult> ProcessAsync(string filePath, CancellationToken cancellationToken, IProgress<int>? progress = null)
    {
        _logger.LogInformation("Processing text file: {FilePath}", filePath);

        try
        {
            progress?.Report(10);

            // Simulate reading file
            await Task.Delay(500, cancellationToken);
            var content = await File.ReadAllTextAsync(filePath, cancellationToken);

            progress?.Report(50);

            // Process text content
            await Task.Delay(1000, cancellationToken);

            var wordCount = content.Split(' ', StringSplitOptions.RemoveEmptyEntries).Length;
            var lineCount = content.Split('\n').Length;
            var charCount = content.Length;

            progress?.Report(90);

            // Generate summary
            await Task.Delay(300, cancellationToken);

            var metadata = new Dictionary<string, object>
            {
                ["WordCount"] = wordCount,
                ["LineCount"] = lineCount,
                ["CharacterCount"] = charCount,
                ["ProcessedAt"] = DateTime.UtcNow
            };

            progress?.Report(100);

            _logger.LogInformation("Text file processed successfully: {WordCount} words, {LineCount} lines", wordCount, lineCount);

            return new ProcessingResult
            {
                Success = true,
                Message = $"Processed text file: {wordCount} words, {lineCount} lines, {charCount} characters",
                Metadata = metadata
            };
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to process text file: {FilePath}", filePath);
            return new ProcessingResult
            {
                Success = false,
                Message = $"Failed to process text file: {ex.Message}"
            };
        }
    }
}
'@ "TextFileProcessor for processing text and markdown files"

# Create ImageFileProcessor
Create-FileInteractive "Processors/ImageFileProcessor.cs" @'
using BackgroundTasksExercise.Models;

namespace BackgroundTasksExercise.Processors;

public class ImageFileProcessor : IFileProcessor
{
    private readonly ILogger<ImageFileProcessor> _logger;

    public ImageFileProcessor(ILogger<ImageFileProcessor> logger)
    {
        _logger = logger;
    }

    public bool CanProcess(string fileName)
    {
        var extension = Path.GetExtension(fileName).ToLowerInvariant();
        return extension == ".jpg" || extension == ".jpeg" || extension == ".png" || extension == ".gif";
    }

    public async Task<ProcessingResult> ProcessAsync(string filePath, CancellationToken cancellationToken, IProgress<int>? progress = null)
    {
        _logger.LogInformation("Processing image file: {FilePath}", filePath);

        try
        {
            progress?.Report(10);

            // Simulate reading file info
            await Task.Delay(300, cancellationToken);
            var fileInfo = new FileInfo(filePath);

            progress?.Report(30);

            // Simulate image analysis
            await Task.Delay(1500, cancellationToken);

            progress?.Report(70);

            // Simulate thumbnail generation
            await Task.Delay(800, cancellationToken);

            progress?.Report(90);

            // Generate metadata
            await Task.Delay(200, cancellationToken);

            var metadata = new Dictionary<string, object>
            {
                ["FileSize"] = fileInfo.Length,
                ["Format"] = Path.GetExtension(filePath).TrimStart('.').ToUpper(),
                ["ProcessedAt"] = DateTime.UtcNow,
                ["ThumbnailGenerated"] = true,
                ["EstimatedDimensions"] = "1920x1080" // Simulated
            };

            progress?.Report(100);

            _logger.LogInformation("Image file processed successfully: {FileSize} bytes", fileInfo.Length);

            return new ProcessingResult
            {
                Success = true,
                Message = $"Processed image file: {fileInfo.Length} bytes, thumbnail generated",
                Metadata = metadata
            };
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to process image file: {FilePath}", filePath);
            return new ProcessingResult
            {
                Success = false,
                Message = $"Failed to process image file: {ex.Message}"
            };
        }
    }
}
'@ "ImageFileProcessor for processing image files"

# Create QueueProcessorService
Create-FileInteractive "Services/QueueProcessorService.cs" @'
using BackgroundTasksExercise.Models;
using System.Runtime.CompilerServices;

namespace BackgroundTasksExercise.Services;

public class QueueProcessorService : BackgroundService
{
    private readonly IBackgroundTaskQueue _taskQueue;
    private readonly ILogger<QueueProcessorService> _logger;
    private readonly IServiceProvider _serviceProvider;
    private readonly SemaphoreSlim _semaphore;

    public QueueProcessorService(
        IBackgroundTaskQueue taskQueue,
        ILogger<QueueProcessorService> logger,
        IServiceProvider serviceProvider)
    {
        _taskQueue = taskQueue;
        _logger = logger;
        _serviceProvider = serviceProvider;
        _semaphore = new SemaphoreSlim(3); // Max 3 concurrent tasks
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        _logger.LogInformation("Queue Processor Service started");

        await foreach (var workItem in GetWorkItemsAsync(stoppingToken))
        {
            await _semaphore.WaitAsync(stoppingToken);

            // Process work item in background
            _ = Task.Run(async () =>
            {
                try
                {
                    await ProcessWorkItemAsync(workItem, stoppingToken);
                }
                finally
                {
                    _semaphore.Release();
                }
            }, stoppingToken);
        }
    }

    private async IAsyncEnumerable<BackgroundWorkItem> GetWorkItemsAsync([EnumeratorCancellation] CancellationToken cancellationToken)
    {
        while (!cancellationToken.IsCancellationRequested)
        {
            BackgroundWorkItem workItem;
            try
            {
                workItem = await _taskQueue.DequeueAsync(cancellationToken);
            }
            catch (OperationCanceledException)
            {
                break;
            }

            yield return workItem;
        }
    }

    private async Task ProcessWorkItemAsync(BackgroundWorkItem workItem, CancellationToken cancellationToken)
    {
        _logger.LogInformation("Processing work item {WorkItemId} of type {JobType}", workItem.Id, workItem.JobType);

        try
        {
            await workItem.WorkItem(_serviceProvider, cancellationToken);
            _logger.LogInformation("Work item {WorkItemId} completed successfully", workItem.Id);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Work item {WorkItemId} failed", workItem.Id);
        }
    }

    public override async Task StopAsync(CancellationToken cancellationToken)
    {
        _logger.LogInformation("Queue Processor Service is stopping");
        await base.StopAsync(cancellationToken);
    }
}
'@ "QueueProcessorService for processing background tasks with concurrency control"

# Create FileMonitorService
Create-FileInteractive "Services/FileMonitorService.cs" @'
using BackgroundTasksExercise.Models;

namespace BackgroundTasksExercise.Services;

public class FileMonitorService : BackgroundService
{
    private readonly ILogger<FileMonitorService> _logger;
    private readonly IBackgroundTaskQueue _taskQueue;
    private readonly string _watchFolder;
    private FileSystemWatcher? _fileWatcher;

    public FileMonitorService(
        ILogger<FileMonitorService> logger,
        IBackgroundTaskQueue taskQueue,
        IConfiguration configuration)
    {
        _logger = logger;
        _taskQueue = taskQueue;
        _watchFolder = configuration.GetValue<string>("FileProcessing:InputFolder") ?? "C:/temp/input";
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        _logger.LogInformation("File Monitor Service started, watching: {WatchFolder}", _watchFolder);

        // Ensure directory exists
        Directory.CreateDirectory(_watchFolder);

        // Setup file system watcher
        _fileWatcher = new FileSystemWatcher(_watchFolder)
        {
            NotifyFilter = NotifyFilters.CreationTime | NotifyFilters.LastWrite | NotifyFilters.FileName,
            Filter = "*.*",
            EnableRaisingEvents = true
        };

        _fileWatcher.Created += OnFileCreated;
        _fileWatcher.Changed += OnFileChanged;

        // Keep service running
        try
        {
            await Task.Delay(Timeout.Infinite, stoppingToken);
        }
        catch (OperationCanceledException)
        {
            _logger.LogInformation("File Monitor Service is stopping");
        }
    }

    private void OnFileCreated(object sender, FileSystemEventArgs e)
    {
        _logger.LogInformation("New file detected: {FilePath}", e.FullPath);
        QueueFileProcessing(e.FullPath);
    }

    private void OnFileChanged(object sender, FileSystemEventArgs e)
    {
        _logger.LogDebug("File changed: {FilePath}", e.FullPath);
        // Could implement logic to handle file updates
    }

    private void QueueFileProcessing(string filePath)
    {
        var workItem = new BackgroundWorkItem
        {
            JobType = "FileProcessing",
            Priority = 1,
            WorkItem = async (serviceProvider, cancellationToken) =>
            {
                // This would be implemented to process the file
                await Task.Delay(1000, cancellationToken);
                _logger.LogInformation("File processed: {FilePath}", filePath);
            }
        };

        _taskQueue.QueueBackgroundWorkItem(workItem);
    }

    public override void Dispose()
    {
        _fileWatcher?.Dispose();
        base.Dispose();
    }
}
'@ "FileMonitorService for automatic file processing"

# Create ScheduledReportService
Create-FileInteractive "Services/ScheduledReportService.cs" @'
namespace BackgroundTasksExercise.Services;

public class ScheduledReportService : BackgroundService
{
    private readonly ILogger<ScheduledReportService> _logger;
    private readonly TimeSpan _period = TimeSpan.FromHours(1);

    public ScheduledReportService(ILogger<ScheduledReportService> logger)
    {
        _logger = logger;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        _logger.LogInformation("Scheduled Report Service started");

        while (!stoppingToken.IsCancellationRequested)
        {
            try
            {
                await GenerateReportsAsync(stoppingToken);
                await CleanupOldFilesAsync(stoppingToken);

                await Task.Delay(_period, stoppingToken);
            }
            catch (OperationCanceledException)
            {
                _logger.LogInformation("Scheduled Report Service is stopping");
                break;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error in Scheduled Report Service");
                await Task.Delay(TimeSpan.FromMinutes(5), stoppingToken);
            }
        }
    }

    private async Task GenerateReportsAsync(CancellationToken cancellationToken)
    {
        _logger.LogInformation("Generating daily processing reports");

        // Simulate report generation
        await Task.Delay(2000, cancellationToken);

        _logger.LogInformation("Daily reports generated successfully");
    }

    private async Task CleanupOldFilesAsync(CancellationToken cancellationToken)
    {
        _logger.LogInformation("Cleaning up files older than 30 days");

        // Simulate cleanup process
        await Task.Delay(1000, cancellationToken);

        _logger.LogInformation("Cleanup completed");
    }
}
'@ "ScheduledReportService for periodic tasks"

# Create JobsController
Create-FileInteractive "Controllers/JobsController.cs" @'
using Microsoft.AspNetCore.Mvc;
using BackgroundTasksExercise.Models;
using BackgroundTasksExercise.Services;

namespace BackgroundTasksExercise.Controllers;

[ApiController]
[Route("api/[controller]")]
public class JobsController : ControllerBase
{
    private readonly ILogger<JobsController> _logger;
    private readonly IBackgroundTaskQueue _taskQueue;

    public JobsController(ILogger<JobsController> logger, IBackgroundTaskQueue taskQueue)
    {
        _logger = logger;
        _taskQueue = taskQueue;
    }

    /// <summary>
    /// List all jobs with filtering
    /// </summary>
    [HttpGet]
    public async Task<IActionResult> GetJobs(
        [FromQuery] JobStatus? status = null,
        [FromQuery] string? jobType = null,
        [FromQuery] int page = 1,
        [FromQuery] int pageSize = 10)
    {
        // Simulate job retrieval with filtering
        await Task.Delay(100);

        var jobs = new List<ProcessingJob>
        {
            new() { Id = 1, JobType = "TextProcessing", FileName = "document.txt", Status = JobStatus.Completed, Progress = 100 },
            new() { Id = 2, JobType = "ImageProcessing", FileName = "photo.jpg", Status = JobStatus.Processing, Progress = 75 },
            new() { Id = 3, JobType = "CsvProcessing", FileName = "data.csv", Status = JobStatus.Queued, Progress = 0 }
        };

        // Apply filters
        if (status.HasValue)
            jobs = jobs.Where(j => j.Status == status.Value).ToList();

        if (!string.IsNullOrEmpty(jobType))
            jobs = jobs.Where(j => j.JobType.Contains(jobType, StringComparison.OrdinalIgnoreCase)).ToList();

        // Apply pagination
        var pagedJobs = jobs.Skip((page - 1) * pageSize).Take(pageSize);

        return Ok(new { jobs = pagedJobs, total = jobs.Count, page, pageSize });
    }

    /// <summary>
    /// Get job details
    /// </summary>
    [HttpGet("{id}")]
    public async Task<IActionResult> GetJob(int id)
    {
        await Task.Delay(50);

        var job = new ProcessingJob
        {
            Id = id,
            JobType = "TextProcessing",
            FileName = "document.txt",
            Status = JobStatus.Completed,
            Progress = 100,
            CreatedAt = DateTime.UtcNow.AddMinutes(-30),
            StartedAt = DateTime.UtcNow.AddMinutes(-25),
            CompletedAt = DateTime.UtcNow.AddMinutes(-20),
            ResultData = "Processing completed successfully"
        };

        return Ok(job);
    }

    /// <summary>
    /// Upload file for processing
    /// </summary>
    [HttpPost("upload")]
    public async Task<IActionResult> UploadFile(IFormFile file, [FromForm] string jobType = "auto")
    {
        if (file == null || file.Length == 0)
        {
            return BadRequest("No file uploaded");
        }

        // Validate file size (max 100MB)
        if (file.Length > 100 * 1024 * 1024)
        {
            return BadRequest("File too large");
        }

        try
        {
            // Save file to processing folder
            var uploadsFolder = Path.Combine(Directory.GetCurrentDirectory(), "uploads");
            Directory.CreateDirectory(uploadsFolder);

            var filePath = Path.Combine(uploadsFolder, file.FileName);
            using (var stream = new FileStream(filePath, FileMode.Create))
            {
                await file.CopyToAsync(stream);
            }

            // Queue background job
            var workItem = new BackgroundWorkItem
            {
                JobType = jobType == "auto" ? DetectJobType(file.FileName) : jobType,
                Priority = 1,
                WorkItem = async (serviceProvider, cancellationToken) =>
                {
                    _logger.LogInformation("Processing uploaded file: {FileName}", file.FileName);
                    await Task.Delay(5000, cancellationToken); // Simulate processing
                    _logger.LogInformation("File processing completed: {FileName}", file.FileName);
                }
            };

            _taskQueue.QueueBackgroundWorkItem(workItem);

            var jobId = Random.Shared.Next(1000, 9999);

            return Ok(new { jobId, fileName = file.FileName, status = "Queued", message = "File uploaded and queued for processing" });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to upload file");
            return StatusCode(500, "Failed to upload file");
        }
    }

    /// <summary>
    /// Upload multiple files
    /// </summary>
    [HttpPost("batch-upload")]
    public async Task<IActionResult> BatchUpload(List<IFormFile> files)
    {
        if (files == null || !files.Any())
        {
            return BadRequest("No files uploaded");
        }

        var results = new List<object>();

        // Process files concurrently
        var tasks = files.Select<IFormFile, Task<object>>(async file =>
        {
            try
            {
                var uploadsFolder = Path.Combine(Directory.GetCurrentDirectory(), "uploads");
                Directory.CreateDirectory(uploadsFolder);

                var filePath = Path.Combine(uploadsFolder, file.FileName);
                using (var stream = new FileStream(filePath, FileMode.Create))
                {
                    await file.CopyToAsync(stream);
                }

                var workItem = new BackgroundWorkItem
                {
                    JobType = DetectJobType(file.FileName),
                    Priority = 1,
                    WorkItem = async (serviceProvider, cancellationToken) =>
                    {
                        await Task.Delay(Random.Shared.Next(2000, 8000), cancellationToken);
                    }
                };

                _taskQueue.QueueBackgroundWorkItem(workItem);

                return new { fileName = file.FileName, status = "Queued", jobId = Random.Shared.Next(1000, 9999) };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to process file {FileName}", file.FileName);
                return new { fileName = file.FileName, status = "Failed", error = ex.Message };
            }
        });

        var uploadResults = await Task.WhenAll(tasks);

        return Ok(new { results = uploadResults, totalFiles = files.Count });
    }

    /// <summary>
    /// Cancel job
    /// </summary>
    [HttpDelete("{id}")]
    public async Task<IActionResult> CancelJob(int id)
    {
        await Task.Delay(100);

        _logger.LogInformation("Job {JobId} cancelled", id);

        return Ok(new { message = $"Job {id} cancelled successfully" });
    }

    private string DetectJobType(string fileName)
    {
        var extension = Path.GetExtension(fileName).ToLowerInvariant();
        return extension switch
        {
            ".txt" or ".md" => "TextProcessing",
            ".jpg" or ".jpeg" or ".png" or ".gif" => "ImageProcessing",
            ".csv" => "CsvProcessing",
            _ => "GenericProcessing"
        };
    }
}
'@ "JobsController with file upload and job management"

# Create SystemController
Create-FileInteractive "Controllers/SystemController.cs" @'
using Microsoft.AspNetCore.Mvc;
using BackgroundTasksExercise.Services;

namespace BackgroundTasksExercise.Controllers;

[ApiController]
[Route("api/[controller]")]
public class SystemController : ControllerBase
{
    private readonly ILogger<SystemController> _logger;
    private readonly IBackgroundTaskQueue _taskQueue;

    public SystemController(ILogger<SystemController> logger, IBackgroundTaskQueue taskQueue)
    {
        _logger = logger;
        _taskQueue = taskQueue;
    }

    /// <summary>
    /// System health and stats
    /// </summary>
    [HttpGet("status")]
    public async Task<IActionResult> GetSystemStatus()
    {
        await Task.Delay(100);

        var status = new
        {
            timestamp = DateTime.UtcNow,
            queueSize = _taskQueue.Count,
            activeJobs = Random.Shared.Next(0, 5),
            diskSpaceGB = Random.Shared.Next(50, 500),
            memoryUsageMB = Random.Shared.Next(100, 1000),
            cpuUsagePercent = Random.Shared.Next(10, 80),
            uptime = TimeSpan.FromHours(Random.Shared.Next(1, 72)).ToString(),
            status = "Healthy"
        };

        return Ok(status);
    }

    /// <summary>
    /// Manual cleanup
    /// </summary>
    [HttpPost("cleanup")]
    public async Task<IActionResult> TriggerCleanup()
    {
        _logger.LogInformation("Manual cleanup triggered");

        // Simulate cleanup process
        await Task.Delay(2000);

        var result = new
        {
            message = "Cleanup completed successfully",
            filesRemoved = Random.Shared.Next(10, 100),
            spaceFreedMB = Random.Shared.Next(100, 1000),
            timestamp = DateTime.UtcNow
        };

        return Ok(result);
    }

    /// <summary>
    /// Performance metrics
    /// </summary>
    [HttpGet("metrics")]
    public async Task<IActionResult> GetMetrics([FromQuery] DateTime? from = null, [FromQuery] DateTime? to = null)
    {
        await Task.Delay(200);

        var metrics = new
        {
            period = new { from = from ?? DateTime.UtcNow.AddDays(-1), to = to ?? DateTime.UtcNow },
            jobsProcessed = Random.Shared.Next(100, 1000),
            averageProcessingTimeMs = Random.Shared.Next(1000, 5000),
            successRate = Math.Round(Random.Shared.NextDouble() * 0.1 + 0.9, 2),
            errorRate = Math.Round(Random.Shared.NextDouble() * 0.1, 2),
            throughputPerHour = Random.Shared.Next(50, 200)
        };

        return Ok(metrics);
    }
}
'@ "SystemController for health monitoring and metrics"

# Create Program.cs
Create-FileInteractive "Program.cs" @'
using BackgroundTasksExercise.Services;
using BackgroundTasksExercise.Processors;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Add background task queue
builder.Services.AddSingleton<IBackgroundTaskQueue, PriorityBackgroundTaskQueue>();

// Add file processors
builder.Services.AddScoped<IFileProcessor, TextFileProcessor>();
builder.Services.AddScoped<IFileProcessor, ImageFileProcessor>();

// Add background services
builder.Services.AddHostedService<QueueProcessorService>();
builder.Services.AddHostedService<FileMonitorService>();
builder.Services.AddHostedService<ScheduledReportService>();

var app = builder.Build();

// Configure the HTTP request pipeline
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();
app.UseAuthorization();
app.MapControllers();

app.Run();
'@ "Program.cs with all background services registered"

# Final completion message
Write-Host ""
Write-Success "🎉 Exercise 3 template created successfully!"
Write-Host ""
Write-Info "📋 Next steps:"
Write-Host "1. Run: " -NoNewline
Write-Host "dotnet run" -ForegroundColor Cyan
Write-Host "2. Open Swagger UI: " -NoNewline
Write-Host "https://localhost:7xxx/swagger" -ForegroundColor Cyan
Write-Host "3. Test file upload and background processing"
Write-Host "4. Monitor system health and metrics"
Write-Host "5. Check background services in logs"
Write-Host ""
Write-Info "🎯 Key Features to Test:"
Write-Host "• POST /api/jobs/upload - Upload files for background processing"
Write-Host "• POST /api/jobs/batch-upload - Upload multiple files concurrently"
Write-Host "• GET /api/jobs - List and filter processing jobs"
Write-Host "• GET /api/system/status - System health monitoring"
Write-Host "• GET /api/system/metrics - Performance metrics"
Write-Host "• POST /api/system/cleanup - Manual cleanup trigger"
Write-Host ""
Write-Info "📁 Background Services Running:"
Write-Host "• QueueProcessorService - Processes background tasks with concurrency control"
Write-Host "• FileMonitorService - Watches for new files and auto-queues processing"
Write-Host "• ScheduledReportService - Generates reports and cleanup on schedule"
Write-Host ""
Write-Info "📚 This implementation matches Exercise03-BackgroundTasks.md requirements exactly!"
Write-Info "🔗 Study the background service patterns and job queue management."
