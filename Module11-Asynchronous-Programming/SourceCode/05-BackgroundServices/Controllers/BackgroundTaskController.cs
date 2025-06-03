using Microsoft.AspNetCore.Mvc;
using BackgroundServices.Services;

namespace BackgroundServices.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class BackgroundTaskController : ControllerBase
    {
        private readonly IBackgroundTaskQueue _taskQueue;
        private readonly ILogger<BackgroundTaskController> _logger;

        public BackgroundTaskController(IBackgroundTaskQueue taskQueue, ILogger<BackgroundTaskController> logger)
        {
            _taskQueue = taskQueue;
            _logger = logger;
        }

        [HttpPost("queue-work")]
        public IActionResult QueueWork([FromBody] WorkRequest request)
        {
            _taskQueue.QueueBackgroundWorkItem(async token =>
            {
                var guid = Guid.NewGuid();
                _logger.LogInformation("Starting background work item {Id}: {TaskName}", guid, request.TaskName);

                try
                {
                    // Simulate async work
                    await Task.Delay(request.DurationMs, token);
                    
                    _logger.LogInformation("Completed background work item {Id}: {TaskName}", guid, request.TaskName);
                }
                catch (OperationCanceledException)
                {
                    _logger.LogInformation("Background work item {Id} was cancelled", guid);
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Error in background work item {Id}", guid);
                }
            });

            return Ok(new { Message = "Work item queued successfully", TaskName = request.TaskName });
        }

        [HttpPost("queue-file-processing")]
        public IActionResult QueueFileProcessing([FromBody] FileProcessingRequest request)
        {
            _taskQueue.QueueBackgroundWorkItem(async token =>
            {
                var guid = Guid.NewGuid();
                _logger.LogInformation("Starting file processing {Id}: {FileName}", guid, request.FileName);

                try
                {
                    // Simulate file processing
                    await SimulateFileProcessingAsync(request.FileName, request.FileSize, token);
                    
                    _logger.LogInformation("Completed file processing {Id}: {FileName}", guid, request.FileName);
                }
                catch (OperationCanceledException)
                {
                    _logger.LogInformation("File processing {Id} was cancelled", guid);
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Error in file processing {Id}", guid);
                }
            });

            return Ok(new { Message = "File processing queued successfully", FileName = request.FileName });
        }

        [HttpPost("queue-email-batch")]
        public IActionResult QueueEmailBatch([FromBody] EmailBatchRequest request)
        {
            _taskQueue.QueueBackgroundWorkItem(async token =>
            {
                var guid = Guid.NewGuid();
                _logger.LogInformation("Starting email batch {Id}: {RecipientCount} recipients", guid, request.Recipients.Count);

                try
                {
                    await SimulateEmailBatchAsync(request.Recipients, request.Subject, token);
                    
                    _logger.LogInformation("Completed email batch {Id}", guid);
                }
                catch (OperationCanceledException)
                {
                    _logger.LogInformation("Email batch {Id} was cancelled", guid);
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Error in email batch {Id}", guid);
                }
            });

            return Ok(new { Message = "Email batch queued successfully", RecipientCount = request.Recipients.Count });
        }

        [HttpPost("create-test-file")]
        public async Task<IActionResult> CreateTestFile([FromBody] CreateFileRequest request)
        {
            try
            {
                var tempPath = Path.GetTempPath();
                var fileName = $"test_{DateTime.UtcNow:yyyyMMdd_HHmmss}_{request.FileName}";
                var filePath = Path.Combine(tempPath, fileName);

                var content = $"Test file created at {DateTime.UtcNow}\nContent: {request.Content}";
                await System.IO.File.WriteAllTextAsync(filePath, content);

                _logger.LogInformation("Created test file: {FilePath}", filePath);

                return Ok(new { Message = "Test file created", FilePath = filePath, FileName = fileName });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error creating test file");
                return StatusCode(500, "Error creating test file");
            }
        }

        private async Task SimulateFileProcessingAsync(string fileName, long fileSize, CancellationToken cancellationToken)
        {
            // Simulate reading file in chunks
            const int chunkSize = 1024 * 1024; // 1MB chunks
            var chunks = (int)Math.Ceiling((double)fileSize / chunkSize);
            
            for (int i = 0; i < chunks; i++)
            {
                cancellationToken.ThrowIfCancellationRequested();
                
                // Simulate processing each chunk
                await Task.Delay(100, cancellationToken);
                
                if (i % 10 == 0) // Log progress every 10 chunks
                {
                    var progress = (double)(i + 1) / chunks * 100;
                    _logger.LogInformation("Processing {FileName}: {Progress:F1}% complete", fileName, progress);
                }
            }
        }

        private async Task SimulateEmailBatchAsync(List<string> recipients, string subject, CancellationToken cancellationToken)
        {
            for (int i = 0; i < recipients.Count; i++)
            {
                cancellationToken.ThrowIfCancellationRequested();
                
                // Simulate sending email
                await Task.Delay(200, cancellationToken);
                
                _logger.LogInformation("Sent email {Index}/{Total}: {Recipient} - {Subject}", 
                    i + 1, recipients.Count, recipients[i], subject);
            }
        }
    }

    // Request DTOs
    public class WorkRequest
    {
        public string TaskName { get; set; } = string.Empty;
        public int DurationMs { get; set; } = 1000;
    }

    public class FileProcessingRequest
    {
        public string FileName { get; set; } = string.Empty;
        public long FileSize { get; set; } = 1024 * 1024; // 1MB default
    }

    public class EmailBatchRequest
    {
        public List<string> Recipients { get; set; } = new();
        public string Subject { get; set; } = string.Empty;
    }

    public class CreateFileRequest
    {
        public string FileName { get; set; } = "test.txt";
        public string Content { get; set; } = "Sample content";
    }
}