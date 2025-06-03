using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.SignalR;

namespace ComprehensiveExample.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class OrdersController : ControllerBase
    {
        private readonly IOrderService _orderService;
        private readonly IInventoryService _inventoryService;
        private readonly IPaymentService _paymentService;
        private readonly INotificationService _notificationService;
        private readonly IBackgroundTaskQueue _backgroundQueue;
        private readonly IHubContext<OrderHub> _hubContext;
        private readonly ILogger<OrdersController> _logger;

        public OrdersController(
            IOrderService orderService,
            IInventoryService inventoryService,
            IPaymentService paymentService,
            INotificationService notificationService,
            IBackgroundTaskQueue backgroundQueue,
            IHubContext<OrderHub> hubContext,
            ILogger<OrdersController> logger)
        {
            _orderService = orderService;
            _inventoryService = inventoryService;
            _paymentService = paymentService;
            _notificationService = notificationService;
            _backgroundQueue = backgroundQueue;
            _hubContext = hubContext;
            _logger = logger;
        }

        // GET: api/orders/{id}
        [HttpGet("{id}")]
        public async Task<ActionResult<Order>> GetOrder(int id, CancellationToken cancellationToken)
        {
            _logger.LogInformation("Getting order {OrderId}", id);

            try
            {
                var order = await _orderService.GetOrderByIdAsync(id, cancellationToken);
                
                if (order == null)
                {
                    return NotFound();
                }

                return Ok(order);
            }
            catch (OperationCanceledException)
            {
                _logger.LogInformation("Get order {OrderId} was cancelled", id);
                return StatusCode(499, "Request was cancelled");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting order {OrderId}", id);
                return StatusCode(500, "Internal server error");
            }
        }

        // POST: api/orders
        [HttpPost]
        public async Task<ActionResult<Order>> CreateOrder(
            [FromBody] CreateOrderRequest request, 
            CancellationToken cancellationToken)
        {
            _logger.LogInformation("Creating order for customer {CustomerId}", request.CustomerId);

            try
            {
                // Step 1: Create the order
                var order = await _orderService.CreateOrderAsync(request, cancellationToken);

                // Step 2: Queue background processing (fire-and-forget)
                _backgroundQueue.QueueBackgroundWorkItem(async token =>
                {
                    await ProcessOrderInBackgroundAsync(order.Id, token);
                });

                // Step 3: Send real-time notification
                await _hubContext.Clients.All.SendAsync("OrderCreated", new 
                { 
                    OrderId = order.Id, 
                    CustomerId = order.CustomerId,
                    Status = order.Status.ToString(),
                    Timestamp = DateTime.UtcNow 
                }, cancellationToken);

                return CreatedAtAction(nameof(GetOrder), new { id = order.Id }, order);
            }
            catch (OperationCanceledException)
            {
                _logger.LogInformation("Create order for customer {CustomerId} was cancelled", request.CustomerId);
                return StatusCode(499, "Request was cancelled");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error creating order for customer {CustomerId}", request.CustomerId);
                return StatusCode(500, "Failed to create order");
            }
        }

        // POST: api/orders/{id}/process
        [HttpPost("{id}/process")]
        public async Task<ActionResult> ProcessOrder(int id, CancellationToken cancellationToken)
        {
            _logger.LogInformation("Processing order {OrderId}", id);

            try
            {
                // Get the order
                var order = await _orderService.GetOrderByIdAsync(id, cancellationToken);
                if (order == null)
                {
                    return NotFound();
                }

                // Process with timeout
                using var cts = CancellationTokenSource.CreateLinkedTokenSource(cancellationToken);
                cts.CancelAfter(TimeSpan.FromSeconds(30));

                var success = await ProcessOrderWithConcurrentOperationsAsync(order, cts.Token);

                if (success)
                {
                    // Send success notification
                    await _hubContext.Clients.All.SendAsync("OrderProcessed", new 
                    { 
                        OrderId = order.Id, 
                        Status = "Completed",
                        Timestamp = DateTime.UtcNow 
                    }, cancellationToken);

                    return Ok(new { Message = "Order processed successfully", OrderId = id });
                }
                else
                {
                    return StatusCode(500, "Order processing failed");
                }
            }
            catch (OperationCanceledException)
            {
                _logger.LogWarning("Order {OrderId} processing was cancelled or timed out", id);
                return StatusCode(408, "Order processing timed out");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error processing order {OrderId}", id);
                return StatusCode(500, "Order processing failed");
            }
        }

        // POST: api/orders/batch
        [HttpPost("batch")]
        public async Task<ActionResult<BatchOrderResult>> CreateBatchOrders(
            [FromBody] List<CreateOrderRequest> requests, 
            CancellationToken cancellationToken)
        {
            _logger.LogInformation("Creating batch of {Count} orders", requests.Count);

            try
            {
                // Process orders concurrently with controlled concurrency
                const int maxConcurrency = 5;
                using var semaphore = new SemaphoreSlim(maxConcurrency, maxConcurrency);
                
                var tasks = requests.Select(async request =>
                {
                    await semaphore.WaitAsync(cancellationToken);
                    try
                    {
                        return await _orderService.CreateOrderAsync(request, cancellationToken);
                    }
                    catch (Exception ex)
                    {
                        _logger.LogError(ex, "Failed to create order for customer {CustomerId}", request.CustomerId);
                        return null;
                    }
                    finally
                    {
                        semaphore.Release();
                    }
                });

                var results = await Task.WhenAll(tasks);
                var successfulOrders = results.Where(r => r != null).ToList();

                var batchResult = new BatchOrderResult
                {
                    TotalRequested = requests.Count,
                    SuccessfulOrders = successfulOrders.Count,
                    FailedOrders = requests.Count - successfulOrders.Count,
                    OrderIds = successfulOrders.Select(o => o!.Id).ToList()
                };

                return Ok(batchResult);
            }
            catch (OperationCanceledException)
            {
                _logger.LogInformation("Batch order creation was cancelled");
                return StatusCode(499, "Request was cancelled");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error creating batch orders");
                return StatusCode(500, "Batch order creation failed");
            }
        }

        // GET: api/orders/stream
        [HttpGet("stream")]
        public async IAsyncEnumerable<Order> StreamOrders(
            [FromQuery] int? customerId = null,
            [System.Runtime.CompilerServices.EnumeratorCancellation] CancellationToken cancellationToken = default)
        {
            _logger.LogInformation("Streaming orders for customer {CustomerId}", customerId);

            // Simulate streaming orders from database
            for (int i = 1; i <= 10; i++)
            {
                if (cancellationToken.IsCancellationRequested)
                    yield break;

                await Task.Delay(500, cancellationToken);

                yield return new Order
                {
                    Id = i,
                    CustomerId = customerId?.ToString() ?? $"Customer{i}",
                    TotalAmount = Random.Shared.Next(50, 500),
                    Status = OrderStatus.Completed,
                    CreatedAt = DateTime.UtcNow.AddDays(-i),
                    ProcessedAt = DateTime.UtcNow.AddDays(-i).AddHours(1)
                };
            }
        }

        // Private helper methods

        private async Task ProcessOrderInBackgroundAsync(int orderId, CancellationToken cancellationToken)
        {
            try
            {
                _logger.LogInformation("Starting background processing for order {OrderId}", orderId);

                // Get the order
                var order = await _orderService.GetOrderByIdAsync(orderId, cancellationToken);
                if (order == null)
                {
                    _logger.LogWarning("Order {OrderId} not found for background processing", orderId);
                    return;
                }

                // Process with concurrent operations
                var success = await ProcessOrderWithConcurrentOperationsAsync(order, cancellationToken);

                if (success)
                {
                    _logger.LogInformation("Background processing completed successfully for order {OrderId}", orderId);
                    
                    // Send completion notification
                    await _hubContext.Clients.All.SendAsync("OrderCompleted", new 
                    { 
                        OrderId = orderId, 
                        Status = "Completed",
                        Timestamp = DateTime.UtcNow 
                    }, cancellationToken);
                }
                else
                {
                    _logger.LogError("Background processing failed for order {OrderId}", orderId);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error in background processing for order {OrderId}", orderId);
            }
        }

        private async Task<bool> ProcessOrderWithConcurrentOperationsAsync(Order order, CancellationToken cancellationToken)
        {
            try
            {
                // Start all operations concurrently
                var inventoryTask = CheckInventoryForAllItemsAsync(order, cancellationToken);
                var paymentTask = _paymentService.ProcessPaymentAsync(order.TotalAmount, cancellationToken);
                var notificationTask = _notificationService.SendOrderConfirmationAsync(order.CustomerId, order.Id, cancellationToken);

                // Wait for inventory and payment tasks
                var results = await Task.WhenAll(inventoryTask, paymentTask);
                
                // Also await notification task but don't fail if it fails
                try
                {
                    await notificationTask;
                }
                catch (Exception ex)
                {
                    _logger.LogWarning(ex, "Failed to send notification for order {OrderId}", order.Id);
                }

                var inventorySuccess = results[0];
                var paymentSuccess = results[1];

                if (inventorySuccess && paymentSuccess)
                {
                    _logger.LogInformation("Order {OrderId} processed successfully", order.Id);
                    return true;
                }
                else
                {
                    _logger.LogWarning("Order {OrderId} processing failed - Inventory: {InventorySuccess}, Payment: {PaymentSuccess}", 
                        order.Id, inventorySuccess, paymentSuccess);
                    return false;
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error processing order {OrderId} with concurrent operations", order.Id);
                return false;
            }
        }

        private async Task<bool> CheckInventoryForAllItemsAsync(Order order, CancellationToken cancellationToken)
        {
            var inventoryTasks = order.Items.Select(item => 
                _inventoryService.CheckStockAsync(item.ProductId, item.Quantity, cancellationToken));

            var inventoryResults = await Task.WhenAll(inventoryTasks);
            return inventoryResults.All(result => result);
        }
    }

    public class BatchOrderResult
    {
        public int TotalRequested { get; set; }
        public int SuccessfulOrders { get; set; }
        public int FailedOrders { get; set; }
        public List<int> OrderIds { get; set; } = new();
    }
}