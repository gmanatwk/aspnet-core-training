# Messaging Patterns for Microservices

## 🎯 Overview
This guide covers essential messaging patterns for microservices communication, focusing on asynchronous messaging strategies that enable loose coupling, scalability, and resilience in distributed systems.

## 🔄 Why Asynchronous Messaging?

### Benefits
- **Loose Coupling** - Services don't need to know about each other directly
- **Resilience** - Services can be offline temporarily without breaking the system
- **Scalability** - Messages can be buffered and processed at different rates
- **Event-Driven Architecture** - React to business events as they occur
- **Temporal Decoupling** - Producer and consumer don't need to be active simultaneously

### Challenges
- **Complexity** - More moving parts to manage
- **Eventual Consistency** - Data consistency is eventual, not immediate
- **Message Ordering** - Ensuring correct order of message processing
- **Duplicate Messages** - Handling message delivery guarantees
- **Error Handling** - Dealing with failed message processing

## 📨 Message Types

### Commands
Messages that represent an intention to perform an action.

```csharp
public class CreateOrderCommand
{
    public Guid OrderId { get; set; }
    public Guid CustomerId { get; set; }
    public List<OrderItem> Items { get; set; } = new();
    public DateTime RequestedDeliveryDate { get; set; }
    public Address ShippingAddress { get; set; }
}

// Command Handler
public class CreateOrderCommandHandler : IMessageHandler<CreateOrderCommand>
{
    private readonly IOrderRepository _orderRepository;
    private readonly IEventBus _eventBus;

    public async Task HandleAsync(CreateOrderCommand command)
    {
        var order = new Order(
            command.OrderId,
            command.CustomerId,
            command.Items,
            command.RequestedDeliveryDate,
            command.ShippingAddress);

        await _orderRepository.SaveAsync(order);

        // Publish domain event
        await _eventBus.PublishAsync(new OrderCreatedEvent
        {
            OrderId = order.Id,
            CustomerId = order.CustomerId,
            Items = order.Items.Select(i => new OrderItemDto
            {
                ProductId = i.ProductId,
                Quantity = i.Quantity,
                UnitPrice = i.UnitPrice
            }).ToList(),
            TotalAmount = order.TotalAmount
        });
    }
}
```

### Events
Messages that represent something that has already happened.

```csharp
public class OrderCreatedEvent : DomainEvent
{
    public Guid OrderId { get; set; }
    public Guid CustomerId { get; set; }
    public List<OrderItemDto> Items { get; set; } = new();
    public decimal TotalAmount { get; set; }
    public DateTime OrderDate { get; set; }
}

// Event Handler in Inventory Service
public class OrderCreatedEventHandler : IMessageHandler<OrderCreatedEvent>
{
    private readonly IInventoryService _inventoryService;
    private readonly IEventBus _eventBus;

    public async Task HandleAsync(OrderCreatedEvent @event)
    {
        try
        {
            // Reserve inventory for the order
            var reservationResults = new List<InventoryReservation>();
            
            foreach (var item in @event.Items)
            {
                var reservation = await _inventoryService.ReserveAsync(
                    item.ProductId, 
                    item.Quantity);
                    
                reservationResults.Add(reservation);
            }

            // Publish inventory reserved event
            await _eventBus.PublishAsync(new InventoryReservedEvent
            {
                OrderId = @event.OrderId,
                Reservations = reservationResults
            });
        }
        catch (InsufficientInventoryException ex)
        {
            // Publish inventory reservation failed event
            await _eventBus.PublishAsync(new InventoryReservationFailedEvent
            {
                OrderId = @event.OrderId,
                Reason = ex.Message,
                FailedItems = ex.FailedItems
            });
        }
    }
}
```

### Queries
Messages that request information without causing side effects.

```csharp
public class GetCustomerOrdersQuery
{
    public Guid CustomerId { get; set; }
    public DateTime? StartDate { get; set; }
    public DateTime? EndDate { get; set; }
    public int PageSize { get; set; } = 20;
    public int PageNumber { get; set; } = 1;
}

public class GetCustomerOrdersQueryHandler : IMessageHandler<GetCustomerOrdersQuery, CustomerOrdersResult>
{
    private readonly IOrderQueryRepository _repository;

    public async Task<CustomerOrdersResult> HandleAsync(GetCustomerOrdersQuery query)
    {
        var orders = await _repository.GetCustomerOrdersAsync(
            query.CustomerId,
            query.StartDate,
            query.EndDate,
            query.PageSize,
            query.PageNumber);

        return new CustomerOrdersResult
        {
            Orders = orders.Select(o => new OrderSummaryDto
            {
                OrderId = o.Id,
                OrderDate = o.OrderDate,
                Status = o.Status.ToString(),
                TotalAmount = o.TotalAmount
            }).ToList(),
            TotalCount = await _repository.GetCustomerOrderCountAsync(query.CustomerId),
            PageNumber = query.PageNumber,
            PageSize = query.PageSize
        };
    }
}
```

## 🏗️ Messaging Patterns

### Publish-Subscribe Pattern

Multiple consumers can subscribe to the same event type.

```csharp
// Event Bus Interface
public interface IEventBus
{
    Task PublishAsync<T>(T @event) where T : class;
    Task SubscribeAsync<T>(Func<T, Task> handler) where T : class;
    Task SubscribeAsync<T, TH>() where T : class where TH : class, IEventHandler<T>;
}

// RabbitMQ Implementation
public class RabbitMQEventBus : IEventBus, IDisposable
{
    private readonly IConnection _connection;
    private readonly IModel _channel;
    private readonly IServiceProvider _serviceProvider;
    private readonly string _exchangeName = "microservices_events";

    public async Task PublishAsync<T>(T @event) where T : class
    {
        var eventName = typeof(T).Name;
        var message = JsonSerializer.Serialize(@event);
        var body = Encoding.UTF8.GetBytes(message);

        _channel.BasicPublish(
            exchange: _exchangeName,
            routingKey: eventName,
            basicProperties: null,
            body: body);

        await Task.CompletedTask;
    }

    public async Task SubscribeAsync<T, TH>() where T : class where TH : class, IEventHandler<T>
    {
        var eventName = typeof(T).Name;
        var queueName = $"{eventName}_{typeof(TH).Name}";

        _channel.QueueDeclare(queue: queueName, durable: true, exclusive: false, autoDelete: false);
        _channel.QueueBind(queue: queueName, exchange: _exchangeName, routingKey: eventName);

        var consumer = new EventingBasicConsumer(_channel);
        consumer.Received += async (model, ea) =>
        {
            var body = ea.Body.ToArray();
            var message = Encoding.UTF8.GetString(body);

            try
            {
                var @event = JsonSerializer.Deserialize<T>(message);
                using var scope = _serviceProvider.CreateScope();
                var handler = scope.ServiceProvider.GetRequiredService<TH>();
                await handler.HandleAsync(@event);

                _channel.BasicAck(deliveryTag: ea.DeliveryTag, multiple: false);
            }
            catch (Exception ex)
            {
                // Log error and handle retry logic
                _logger.LogError(ex, "Error processing event {EventName}", eventName);
                _channel.BasicNack(deliveryTag: ea.DeliveryTag, multiple: false, requeue: true);
            }
        };

        _channel.BasicConsume(queue: queueName, autoAck: false, consumer: consumer);
        await Task.CompletedTask;
    }
}
```

### Request-Reply Pattern

Synchronous-like communication over asynchronous messaging.

```csharp
public class RequestReplyService
{
    private readonly IModel _channel;
    private readonly ConcurrentDictionary<string, TaskCompletionSource<string>> _pendingRequests = new();

    public async Task<TResponse> SendRequestAsync<TRequest, TResponse>(TRequest request, string targetQueue)
    {
        var correlationId = Guid.NewGuid().ToString();
        var replyQueue = $"reply_{correlationId}";
        
        // Declare temporary reply queue
        _channel.QueueDeclare(queue: replyQueue, durable: false, exclusive: true, autoDelete: true);

        var tcs = new TaskCompletionSource<string>();
        _pendingRequests[correlationId] = tcs;

        // Set up consumer for reply queue
        var consumer = new EventingBasicConsumer(_channel);
        consumer.Received += (model, ea) =>
        {
            var responseCorrelationId = ea.BasicProperties.CorrelationId;
            if (_pendingRequests.TryRemove(responseCorrelationId, out var pendingTcs))
            {
                var responseMessage = Encoding.UTF8.GetString(ea.Body.ToArray());
                pendingTcs.SetResult(responseMessage);
            }
        };

        _channel.BasicConsume(queue: replyQueue, autoAck: true, consumer: consumer);

        // Send request
        var properties = _channel.CreateBasicProperties();
        properties.CorrelationId = correlationId;
        properties.ReplyTo = replyQueue;

        var requestMessage = JsonSerializer.Serialize(request);
        var requestBody = Encoding.UTF8.GetBytes(requestMessage);

        _channel.BasicPublish(
            exchange: "",
            routingKey: targetQueue,
            basicProperties: properties,
            body: requestBody);

        // Wait for response with timeout
        using var cts = new CancellationTokenSource(TimeSpan.FromSeconds(30));
        cts.Token.Register(() => 
        {
            if (_pendingRequests.TryRemove(correlationId, out var timeoutTcs))
            {
                timeoutTcs.SetException(new TimeoutException("Request timed out"));
            }
        });

        var responseJson = await tcs.Task;
        return JsonSerializer.Deserialize<TResponse>(responseJson);
    }
}
```

### Message Channel Patterns

#### Point-to-Point Channel
Only one consumer receives each message.

```csharp
public class OrderProcessingQueue
{
    private readonly IModel _channel;
    private readonly string _queueName = "order_processing";

    public void Initialize()
    {
        // Declare queue with single consumer
        _channel.QueueDeclare(
            queue: _queueName,
            durable: true,
            exclusive: false,
            autoDelete: false);

        // Set QoS to process one message at a time
        _channel.BasicQos(prefetchSize: 0, prefetchCount: 1, global: false);
    }

    public async Task SendOrderForProcessingAsync(ProcessOrderCommand command)
    {
        var message = JsonSerializer.Serialize(command);
        var body = Encoding.UTF8.GetBytes(message);

        var properties = _channel.CreateBasicProperties();
        properties.Persistent = true; // Make message persistent

        _channel.BasicPublish(
            exchange: "",
            routingKey: _queueName,
            basicProperties: properties,
            body: body);
    }
}
```

#### Topic-Based Channel
Messages are routed based on topics/routing keys.

```csharp
public class TopicBasedEventBus
{
    private readonly IModel _channel;
    private readonly string _exchangeName = "topic_exchange";

    public void Initialize()
    {
        _channel.ExchangeDeclare(
            exchange: _exchangeName,
            type: ExchangeType.Topic,
            durable: true);
    }

    public async Task PublishAsync<T>(T @event, string routingKey) where T : class
    {
        var message = JsonSerializer.Serialize(@event);
        var body = Encoding.UTF8.GetBytes(message);

        _channel.BasicPublish(
            exchange: _exchangeName,
            routingKey: routingKey,
            basicProperties: null,
            body: body);
    }

    public void Subscribe(string routingPattern, Func<string, byte[], Task> handler)
    {
        var queueName = _channel.QueueDeclare().QueueName;
        _channel.QueueBind(queue: queueName, exchange: _exchangeName, routingKey: routingPattern);

        var consumer = new EventingBasicConsumer(_channel);
        consumer.Received += async (model, ea) =>
        {
            try
            {
                await handler(ea.RoutingKey, ea.Body.ToArray());
                _channel.BasicAck(deliveryTag: ea.DeliveryTag, multiple: false);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error processing message with routing key {RoutingKey}", ea.RoutingKey);
                _channel.BasicNack(deliveryTag: ea.DeliveryTag, multiple: false, requeue: true);
            }
        };

        _channel.BasicConsume(queue: queueName, autoAck: false, consumer: consumer);
    }
}

// Usage examples:
// Publish: eventBus.PublishAsync(orderCreated, "order.created.electronics");
// Subscribe: eventBus.Subscribe("order.created.*", HandleOrderCreated);
// Subscribe: eventBus.Subscribe("order.#", HandleAnyOrderEvent);
```

## 🔄 Message Processing Patterns

### Idempotent Message Processing

Ensure messages can be processed multiple times safely.

```csharp
public class IdempotentOrderProcessor : IMessageHandler<ProcessOrderCommand>
{
    private readonly IOrderRepository _orderRepository;
    private readonly IIdempotencyService _idempotencyService;

    public async Task HandleAsync(ProcessOrderCommand command)
    {
        var idempotencyKey = $"process_order_{command.OrderId}_{command.MessageId}";
        
        if (await _idempotencyService.IsProcessedAsync(idempotencyKey))
        {
            // Message already processed, skip
            return;
        }

        try
        {
            // Process the order
            var order = await _orderRepository.GetByIdAsync(command.OrderId);
            await order.ProcessAsync(command.ProcessingInstructions);
            await _orderRepository.SaveAsync(order);

            // Mark as processed
            await _idempotencyService.MarkAsProcessedAsync(idempotencyKey);
        }
        catch (Exception ex)
        {
            // Don't mark as processed on failure
            throw;
        }
    }
}

public interface IIdempotencyService
{
    Task<bool> IsProcessedAsync(string key);
    Task MarkAsProcessedAsync(string key);
    Task MarkAsProcessedAsync(string key, TimeSpan expiration);
}

public class RedisIdempotencyService : IIdempotencyService
{
    private readonly IDatabase _database;

    public async Task<bool> IsProcessedAsync(string key)
    {
        return await _database.KeyExistsAsync($"idempotency:{key}");
    }

    public async Task MarkAsProcessedAsync(string key)
    {
        await MarkAsProcessedAsync(key, TimeSpan.FromHours(24));
    }

    public async Task MarkAsProcessedAsync(string key, TimeSpan expiration)
    {
        await _database.StringSetAsync($"idempotency:{key}", DateTime.UtcNow.ToString(), expiration);
    }
}
```

### Message Deduplication

Remove duplicate messages before processing.

```csharp
public class DeduplicatingMessageHandler<T> : IMessageHandler<T> where T : class
{
    private readonly IMessageHandler<T> _innerHandler;
    private readonly IMessageDeduplicator _deduplicator;

    public async Task HandleAsync(T message)
    {
        var messageId = GetMessageId(message);
        
        if (await _deduplicator.IsDuplicateAsync(messageId))
        {
            // Skip duplicate message
            return;
        }

        await _innerHandler.HandleAsync(message);
        await _deduplicator.RecordMessageAsync(messageId);
    }

    private string GetMessageId(T message)
    {
        // Extract message ID from message properties or generate based on content
        if (message is IMessage msg)
        {
            return msg.MessageId;
        }

        // Generate content-based hash
        var json = JsonSerializer.Serialize(message);
        using var sha256 = SHA256.Create();
        var hash = sha256.ComputeHash(Encoding.UTF8.GetBytes(json));
        return Convert.ToBase64String(hash);
    }
}
```

### Retry with Exponential Backoff

Handle transient failures with intelligent retry logic.

```csharp
public class RetryableMessageHandler<T> : IMessageHandler<T> where T : class
{
    private readonly IMessageHandler<T> _innerHandler;
    private readonly ILogger<RetryableMessageHandler<T>> _logger;
    private readonly RetryPolicy _retryPolicy;

    public async Task HandleAsync(T message)
    {
        var attempt = 0;
        var maxAttempts = _retryPolicy.MaxAttempts;

        while (attempt < maxAttempts)
        {
            try
            {
                await _innerHandler.HandleAsync(message);
                return; // Success
            }
            catch (Exception ex) when (IsTransientException(ex) && attempt < maxAttempts - 1)
            {
                attempt++;
                var delay = _retryPolicy.CalculateDelay(attempt);
                
                _logger.LogWarning(ex, 
                    "Message processing failed (attempt {Attempt}/{MaxAttempts}). Retrying in {Delay}ms",
                    attempt, maxAttempts, delay.TotalMilliseconds);
                
                await Task.Delay(delay);
            }
        }

        // All retries exhausted, send to dead letter queue
        await SendToDeadLetterQueueAsync(message);
    }

    private bool IsTransientException(Exception ex)
    {
        return ex is HttpRequestException ||
               ex is TimeoutException ||
               ex is SocketException ||
               (ex is SqlException sqlEx && IsTransientSqlError(sqlEx.Number));
    }
}

public class RetryPolicy
{
    public int MaxAttempts { get; set; } = 3;
    public TimeSpan BaseDelay { get; set; } = TimeSpan.FromSeconds(1);
    public double BackoffMultiplier { get; set; } = 2.0;
    public TimeSpan MaxDelay { get; set; } = TimeSpan.FromMinutes(5);

    public TimeSpan CalculateDelay(int attempt)
    {
        var delay = TimeSpan.FromMilliseconds(
            BaseDelay.TotalMilliseconds * Math.Pow(BackoffMultiplier, attempt - 1));
        
        return delay > MaxDelay ? MaxDelay : delay;
    }
}
```

## 🔀 Message Routing Patterns

### Content-Based Router

Route messages based on message content.

```csharp
public class ContentBasedMessageRouter
{
    private readonly Dictionary<Func<object, bool>, string> _routes = new();

    public void AddRoute<T>(Func<T, bool> condition, string destination) where T : class
    {
        _routes.Add(msg => msg is T typedMsg && condition(typedMsg), destination);
    }

    public string GetDestination(object message)
    {
        foreach (var (condition, destination) in _routes)
        {
            if (condition(message))
            {
                return destination;
            }
        }
        
        return "default_queue"; // Fallback destination
    }
}

// Usage
var router = new ContentBasedMessageRouter();

// Route high-value orders to priority queue
router.AddRoute<OrderCreatedEvent>(order => order.TotalAmount > 1000, "high_priority_orders");

// Route international orders to special processing
router.AddRoute<OrderCreatedEvent>(order => order.ShippingCountry != "US", "international_orders");

// Route electronics orders to electronics team
router.AddRoute<OrderCreatedEvent>(order => 
    order.Items.Any(item => item.Category == "Electronics"), "electronics_orders");
```

### Recipient List Pattern

Send the same message to multiple recipients.

```csharp
public class RecipientListRouter
{
    private readonly Dictionary<Type, List<string>> _recipients = new();

    public void AddRecipient<T>(string destination)
    {
        var messageType = typeof(T);
        if (!_recipients.ContainsKey(messageType))
        {
            _recipients[messageType] = new List<string>();
        }
        _recipients[messageType].Add(destination);
    }

    public async Task RouteMessageAsync<T>(T message) where T : class
    {
        var messageType = typeof(T);
        if (_recipients.TryGetValue(messageType, out var destinations))
        {
            var tasks = destinations.Select(dest => SendToDestinationAsync(message, dest));
            await Task.WhenAll(tasks);
        }
    }

    private async Task SendToDestinationAsync<T>(T message, string destination)
    {
        // Implementation depends on your messaging infrastructure
        await _messageBus.SendAsync(message, destination);
    }
}

// Configuration
router.AddRecipient<CustomerCreatedEvent>("email_service");
router.AddRecipient<CustomerCreatedEvent>("analytics_service");
router.AddRecipient<CustomerCreatedEvent>("recommendation_service");

// Usage
await router.RouteMessageAsync(new CustomerCreatedEvent { CustomerId = customerId });
```

### Message Filter

Filter out messages that don't meet certain criteria.

```csharp
public class MessageFilter<T> : IMessageHandler<T> where T : class
{
    private readonly IMessageHandler<T> _innerHandler;
    private readonly Func<T, bool> _filterPredicate;
    private readonly ILogger<MessageFilter<T>> _logger;

    public MessageFilter(IMessageHandler<T> innerHandler, Func<T, bool> filterPredicate, ILogger<MessageFilter<T>> logger)
    {
        _innerHandler = innerHandler;
        _filterPredicate = filterPredicate;
        _logger = logger;
    }

    public async Task HandleAsync(T message)
    {
        if (_filterPredicate(message))
        {
            await _innerHandler.HandleAsync(message);
        }
        else
        {
            _logger.LogDebug("Message filtered out: {MessageType}", typeof(T).Name);
        }
    }
}

// Usage examples
var businessHoursFilter = new MessageFilter<ProcessOrderCommand>(
    orderProcessor,
    cmd => DateTime.Now.Hour >= 9 && DateTime.Now.Hour <= 17,
    logger);

var validOrderFilter = new MessageFilter<OrderCreatedEvent>(
    orderHandler,
    order => order.TotalAmount > 0 && order.Items.Any(),
    logger);
```

## 🏭 Message Transformation Patterns

### Message Translator

Transform messages between different formats.

```csharp
public class MessageTranslator<TInput, TOutput> : IMessageHandler<TInput> 
    where TInput : class 
    where TOutput : class
{
    private readonly IMessageHandler<TOutput> _targetHandler;
    private readonly Func<TInput, TOutput> _transformer;

    public async Task HandleAsync(TInput message)
    {
        var transformedMessage = _transformer(message);
        await _targetHandler.HandleAsync(transformedMessage);
    }
}

// Example: Transform external API events to internal domain events
var translator = new MessageTranslator<ExternalOrderEvent, OrderCreatedEvent>(
    internalOrderHandler,
    external => new OrderCreatedEvent
    {
        OrderId = Guid.Parse(external.order_id),
        CustomerId = Guid.Parse(external.customer_id),
        Items = external.line_items.Select(item => new OrderItemDto
        {
            ProductId = Guid.Parse(item.product_id),
            Quantity = item.qty,
            UnitPrice = item.unit_price
        }).ToList(),
        TotalAmount = external.total_amount
    });
```

### Message Enricher

Add additional information to messages.

```csharp
public class MessageEnricher<T> : IMessageHandler<T> where T : class, IEnrichableMessage
{
    private readonly IMessageHandler<T> _innerHandler;
    private readonly IEnrichmentService _enrichmentService;

    public async Task HandleAsync(T message)
    {
        // Enrich the message with additional data
        await _enrichmentService.EnrichAsync(message);
        
        // Pass enriched message to next handler
        await _innerHandler.HandleAsync(message);
    }
}

public interface IEnrichableMessage
{
    Dictionary<string, object> Metadata { get; set; }
}

public class OrderEnrichmentService : IEnrichmentService
{
    private readonly ICustomerRepository _customerRepository;
    private readonly IProductRepository _productRepository;

    public async Task EnrichAsync(IEnrichableMessage message)
    {
        if (message is OrderCreatedEvent orderEvent)
        {
            // Add customer information
            var customer = await _customerRepository.GetByIdAsync(orderEvent.CustomerId);
            orderEvent.Metadata["customer_tier"] = customer.Tier;
            orderEvent.Metadata["customer_country"] = customer.Address.Country;

            // Add product categories
            var productIds = orderEvent.Items.Select(i => i.ProductId).ToList();
            var products = await _productRepository.GetByIdsAsync(productIds);
            var categories = products.Select(p => p.Category).Distinct().ToList();
            orderEvent.Metadata["product_categories"] = categories;
        }
    }
}
```

## 🎯 Implementation Best Practices

### Message Design

```csharp
// Good: Self-contained message with all necessary information
public class OrderShippedEvent
{
    public Guid OrderId { get; set; }
    public Guid CustomerId { get; set; }
    public string CustomerEmail { get; set; } // Included for notification service
    public string TrackingNumber { get; set; }
    public string CarrierName { get; set; }
    public DateTime ShippedDate { get; set; }
    public Address ShippingAddress { get; set; }
    public List<ShippedItem> Items { get; set; } = new();
}

// Avoid: Message that requires additional lookups
public class BadOrderShippedEvent
{
    public Guid OrderId { get; set; } // Consumers must look up order details
}
```

### Message Versioning

```csharp
[MessageVersion("v1")]
public class OrderCreatedEventV1
{
    public Guid OrderId { get; set; }
    public Guid CustomerId { get; set; }
    public decimal TotalAmount { get; set; }
}

[MessageVersion("v2")]
public class OrderCreatedEventV2
{
    public Guid OrderId { get; set; }
    public Guid CustomerId { get; set; }
    public decimal TotalAmount { get; set; }
    public string Currency { get; set; } = "USD"; // New field with default
    public List<OrderItemDto> Items { get; set; } = new(); // New field
}

public class VersionedMessageHandler
{
    public async Task HandleAsync(string messageType, string version, string payload)
    {
        switch ($"{messageType}:{version}")
        {
            case "OrderCreatedEvent:v1":
                var v1Event = JsonSerializer.Deserialize<OrderCreatedEventV1>(payload);
                await HandleV1Async(v1Event);
                break;
                
            case "OrderCreatedEvent:v2":
                var v2Event = JsonSerializer.Deserialize<OrderCreatedEventV2>(payload);
                await HandleV2Async(v2Event);
                break;
                
            default:
                throw new UnsupportedMessageVersionException(messageType, version);
        }
    }
}
```

### Dead Letter Queue Handling

```csharp
public class DeadLetterQueueProcessor
{
    private readonly ILogger<DeadLetterQueueProcessor> _logger;
    private readonly IAlertingService _alertingService;

    public async Task ProcessDeadLetterAsync(DeadLetterMessage deadLetter)
    {
        _logger.LogError("Processing dead letter message: {MessageType} - {Reason}", 
            deadLetter.OriginalMessageType, deadLetter.FailureReason);

        // Analyze failure reason
        if (IsRetryableFailure(deadLetter.FailureReason))
        {
            // Attempt to fix and retry
            await AttemptRetryAsync(deadLetter);
        }
        else
        {
            // Log for manual investigation
            await LogForManualInvestigationAsync(deadLetter);
        }

        // Alert operations team for critical messages
        if (IsCriticalMessage(deadLetter))
        {
            await _alertingService.SendAlertAsync(
                $"Critical message failed: {deadLetter.OriginalMessageType}",
                deadLetter.ToString());
        }
    }

    private bool IsRetryableFailure(string failureReason)
    {
        return failureReason.Contains("timeout") || 
               failureReason.Contains("connection") ||
               failureReason.Contains("temporary");
    }
}
```

## 📊 Monitoring and Observability

### Message Metrics

```csharp
public class InstrumentedMessageHandler<T> : IMessageHandler<T> where T : class
{
    private readonly IMessageHandler<T> _innerHandler;
    private readonly IMetricsCollector _metrics;
    private readonly ILogger<InstrumentedMessageHandler<T>> _logger;

    public async Task HandleAsync(T message)
    {
        var stopwatch = Stopwatch.StartNew();
        var messageType = typeof(T).Name;
        var success = false;

        try
        {
            _metrics.Increment("messages_received_total", 
                new[] { ("message_type", messageType) });

            await _innerHandler.HandleAsync(message);
            success = true;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error processing message {MessageType}", messageType);
            _metrics.Increment("message_processing_errors_total", 
                new[] { ("message_type", messageType), ("error_type", ex.GetType().Name) });
            throw;
        }
        finally
        {
            stopwatch.Stop();
            _metrics.Histogram("message_processing_duration_ms", stopwatch.ElapsedMilliseconds,
                new[] { ("message_type", messageType), ("success", success.ToString()) });

            if (success)
            {
                _metrics.Increment("messages_processed_total", 
                    new[] { ("message_type", messageType) });
            }
        }
    }
}
```

### Distributed Tracing

```csharp
public class TracingMessageHandler<T> : IMessageHandler<T> where T : class
{
    private readonly IMessageHandler<T> _innerHandler;

    public async Task HandleAsync(T message)
    {
        using var activity = Activity.StartActivity($"Process {typeof(T).Name}");
        
        // Extract trace context from message if available
        if (message is ITraceableMessage traceable)
        {
            if (!string.IsNullOrEmpty(traceable.TraceId))
            {
                activity?.SetTag("trace.id", traceable.TraceId);
                activity?.SetTag("span.parent_id", traceable.SpanId);
            }
        }

        activity?.SetTag("message.type", typeof(T).Name);
        activity?.SetTag("message.id", GetMessageId(message));

        try
        {
            await _innerHandler.HandleAsync(message);
            activity?.SetTag("outcome", "success");
        }
        catch (Exception ex)
        {
            activity?.SetTag("outcome", "failure");
            activity?.SetTag("error.type", ex.GetType().Name);
            activity?.SetTag("error.message", ex.Message);
            throw;
        }
    }
}
```

## 🔗 Technology Implementations

### RabbitMQ Advanced Patterns

```csharp
public class RabbitMQPatterns
{
    // Dead Letter Exchange setup
    public void SetupDeadLetterExchange(IModel channel)
    {
        // Main exchange and queue
        channel.ExchangeDeclare("orders", ExchangeType.Topic, durable: true);
        
        var queueArgs = new Dictionary<string, object>
        {
            {"x-dead-letter-exchange", "orders.dlx"},
            {"x-dead-letter-routing-key", "failed"},
            {"x-message-ttl", 60000} // 1 minute TTL
        };
        
        channel.QueueDeclare("orders.processing", durable: true, arguments: queueArgs);
        channel.QueueBind("orders.processing", "orders", "order.created");

        // Dead letter exchange and queue
        channel.ExchangeDeclare("orders.dlx", ExchangeType.Direct, durable: true);
        channel.QueueDeclare("orders.dead_letters", durable: true);
        channel.QueueBind("orders.dead_letters", "orders.dlx", "failed");
    }

    // Priority queue setup
    public void SetupPriorityQueue(IModel channel)
    {
        var queueArgs = new Dictionary<string, object>
        {
            {"x-max-priority", 10}
        };
        
        channel.QueueDeclare("priority.orders", durable: true, arguments: queueArgs);
    }

    // Delayed message setup (requires rabbitmq-delayed-message-exchange plugin)
    public void SetupDelayedMessage(IModel channel)
    {
        var exchangeArgs = new Dictionary<string, object>
        {
            {"x-delayed-type", "direct"}
        };
        
        channel.ExchangeDeclare("delayed.exchange", "x-delayed-message", durable: true, arguments: exchangeArgs);
        
        // Send delayed message
        var properties = channel.CreateBasicProperties();
        properties.Headers = new Dictionary<string, object>
        {
            {"x-delay", 30000} // 30 second delay
        };
        
        channel.BasicPublish("delayed.exchange", "routing.key", properties, messageBody);
    }
}
```

### Azure Service Bus Patterns

```csharp
public class ServiceBusPatterns
{
    private readonly ServiceBusClient _client;

    // Session-based message ordering
    public async Task SendSessionMessageAsync<T>(T message, string sessionId) where T : class
    {
        var sender = _client.CreateSender("orders");
        
        var serviceBusMessage = new ServiceBusMessage(JsonSerializer.Serialize(message))
        {
            SessionId = sessionId,
            MessageId = Guid.NewGuid().ToString()
        };
        
        await sender.SendMessageAsync(serviceBusMessage);
    }

    // Scheduled message delivery
    public async Task ScheduleMessageAsync<T>(T message, DateTimeOffset scheduleTime) where T : class
    {
        var sender = _client.CreateSender("scheduled.orders");
        
        var serviceBusMessage = new ServiceBusMessage(JsonSerializer.Serialize(message));
        
        await sender.ScheduleMessageAsync(serviceBusMessage, scheduleTime);
    }

    // Message deferral pattern
    public async Task ProcessWithDeferralAsync()
    {
        var processor = _client.CreateProcessor("orders");
        
        processor.ProcessMessageAsync += async args =>
        {
            var message = args.Message;
            
            if (!CanProcessNow(message))
            {
                // Defer message for later processing
                await args.DeferMessageAsync(message);
                return;
            }
            
            // Process message normally
            await ProcessMessageAsync(message);
            await args.CompleteMessageAsync(message);
        };
        
        await processor.StartProcessingAsync();
    }
}
```

## 🎯 Summary

Effective messaging patterns are essential for building robust microservices architectures. Key takeaways:

1. **Choose the Right Pattern** - Match patterns to your specific use cases
2. **Design for Idempotency** - Messages should be safe to process multiple times
3. **Handle Failures Gracefully** - Implement retry logic and dead letter queues
4. **Monitor Everything** - Track message flow, processing times, and error rates
5. **Version Your Messages** - Plan for schema evolution from the start
6. **Consider Ordering Requirements** - Use sessions or partitioning when order matters

Remember: Start simple and add complexity as needed. Not every message needs complex routing or transformation logic.

---

*For more microservices patterns, see the [Microservices Design Patterns](./microservices-design-patterns.md) guide.*