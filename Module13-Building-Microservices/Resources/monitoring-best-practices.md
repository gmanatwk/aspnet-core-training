# Monitoring Best Practices for Microservices (Continued)

```csharp
// Custom enrichers (continued)
public class ServiceNameEnricher : ILogEventEnricher
{
    public void Enrich(LogEvent logEvent, ILogEventPropertyFactory propertyFactory)
    {
        var serviceName = Environment.GetEnvironmentVariable("SERVICE_NAME") ?? "unknown-service";
        logEvent.AddPropertyIfAbsent(propertyFactory.CreateProperty("ServiceName", serviceName));
    }
}

public class CorrelationIdEnricher : ILogEventEnricher
{
    private readonly IHttpContextAccessor _httpContextAccessor;

    public CorrelationIdEnricher(IHttpContextAccessor httpContextAccessor)
    {
        _httpContextAccessor = httpContextAccessor;
    }

    public void Enrich(LogEvent logEvent, ILogEventPropertyFactory propertyFactory)
    {
        var correlationId = _httpContextAccessor.HttpContext?.Request.Headers["X-Correlation-ID"].FirstOrDefault()
                           ?? Activity.Current?.Id
                           ?? Guid.NewGuid().ToString();
        
        logEvent.AddPropertyIfAbsent(propertyFactory.CreateProperty("CorrelationId", correlationId));
    }
}
```

### Structured Logging Best Practices

```csharp
public class OrderService
{
    private readonly ILogger<OrderService> _logger;

    public async Task<Order> CreateOrderAsync(CreateOrderRequest request)
    {
        // Use structured logging with context
        using var scope = _logger.BeginScope(new Dictionary<string, object>
        {
            ["CustomerId"] = request.CustomerId,
            ["OrderId"] = request.OrderId,
            ["Operation"] = "CreateOrder"
        });

        _logger.LogInformation("Starting order creation for customer {CustomerId} with {ItemCount} items",
            request.CustomerId, request.Items.Count);

        try
        {
            // Validate order
            var validationResult = await ValidateOrderAsync(request);
            if (!validationResult.IsValid)
            {
                _logger.LogWarning("Order validation failed for customer {CustomerId}: {ValidationErrors}",
                    request.CustomerId, validationResult.Errors);
                throw new ValidationException(validationResult.Errors);
            }

            // Create order
            var order = new Order(request);
            await _repository.SaveAsync(order);

            _logger.LogInformation("Order {OrderId} created successfully for customer {CustomerId} with total amount {TotalAmount:C}",
                order.Id, order.CustomerId, order.TotalAmount);

            // Log business metrics
            _logger.LogInformation("Business metric: Order created with value {OrderValue} for customer tier {CustomerTier}",
                order.TotalAmount, order.Customer.Tier);

            return order;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to create order for customer {CustomerId}", request.CustomerId);
            throw;
        }
    }
}
```

## 🔍 Distributed Tracing

### OpenTelemetry Implementation

```csharp
public static class TracingConfiguration
{
    public static IServiceCollection AddDistributedTracing(this IServiceCollection services, IConfiguration configuration)
    {
        services.AddOpenTelemetry()
            .WithTracing(builder =>
            {
                builder
                    .SetSampler(new TraceIdRatioBasedSampler(0.1)) // Sample 10% of traces
                    .AddSource("ProductCatalog.Service")
                    .AddSource("OrderManagement.Service")
                    .AddAspNetCoreInstrumentation(options =>
                    {
                        options.RecordException = true;
                        options.EnrichWithHttpRequest = EnrichHttpRequest;
                        options.EnrichWithHttpResponse = EnrichHttpResponse;
                    })
                    .AddHttpClientInstrumentation(options =>
                    {
                        options.RecordException = true;
                        options.EnrichWithHttpRequestMessage = EnrichHttpClientRequest;
                        options.EnrichWithHttpResponseMessage = EnrichHttpClientResponse;
                    })
                    .AddEntityFrameworkCoreInstrumentation(options =>
                    {
                        options.SetDbStatementForText = true;
                        options.RecordException = true;
                    })
                    .AddJaegerExporter(options =>
                    {
                        options.AgentHost = configuration["Jaeger:AgentHost"];
                        options.AgentPort = int.Parse(configuration["Jaeger:AgentPort"]);
                    });
            });

        return services;
    }

    private static void EnrichHttpRequest(Activity activity, HttpRequest request)
    {
        activity.SetTag("http.request.user_agent", request.Headers["User-Agent"].ToString());
        activity.SetTag("http.request.correlation_id", request.Headers["X-Correlation-ID"].ToString());
    }

    private static void EnrichHttpResponse(Activity activity, HttpResponse response)
    {
        activity.SetTag("http.response.status_code", response.StatusCode);
        activity.SetTag("http.response.content_length", response.ContentLength);
    }
}

// Custom activity source for business operations
public class BusinessActivitySource
{
    private static readonly ActivitySource _activitySource = new("BusinessOperations");

    public static Activity? StartActivity(string name, ActivityKind kind = ActivityKind.Internal)
    {
        return _activitySource.StartActivity(name, kind);
    }

    public static void SetBusinessTags(Activity? activity, Dictionary<string, object> businessContext)
    {
        if (activity == null) return;

        foreach (var (key, value) in businessContext)
        {
            activity.SetTag($"business.{key}", value?.ToString());
        }
    }
}

// Usage in service methods
public class OrderProcessingService
{
    public async Task ProcessOrderAsync(Guid orderId)
    {
        using var activity = BusinessActivitySource.StartActivity("ProcessOrder");
        activity?.SetTag("order.id", orderId.ToString());

        try
        {
            var order = await GetOrderAsync(orderId);
            BusinessActivitySource.SetBusinessTags(activity, new Dictionary<string, object>
            {
                ["customer_id"] = order.CustomerId,
                ["order_value"] = order.TotalAmount,
                ["item_count"] = order.Items.Count
            });

            await ValidateInventoryAsync(order);
            await ProcessPaymentAsync(order);
            await FulfillOrderAsync(order);

            activity?.SetStatus(ActivityStatusCode.Ok, "Order processed successfully");
        }
        catch (Exception ex)
        {
            activity?.SetStatus(ActivityStatusCode.Error, ex.Message);
            activity?.RecordException(ex);
            throw;
        }
    }
}
```

### Correlation ID Propagation

```csharp
public class CorrelationIdMiddleware
{
    private readonly RequestDelegate _next;
    private const string CorrelationIdHeader = "X-Correlation-ID";

    public async Task InvokeAsync(HttpContext context)
    {
        var correlationId = GetOrCreateCorrelationId(context);
        
        // Add to response headers
        context.Response.Headers.Add(CorrelationIdHeader, correlationId);
        
        // Add to logging context
        using (LogContext.PushProperty("CorrelationId", correlationId))
        {
            await _next(context);
        }
    }

    private string GetOrCreateCorrelationId(HttpContext context)
    {
        if (context.Request.Headers.TryGetValue(CorrelationIdHeader, out var existingId))
        {
            return existingId.FirstOrDefault() ?? Guid.NewGuid().ToString();
        }

        return Guid.NewGuid().ToString();
    }
}

// HTTP client that propagates correlation ID
public class CorrelationIdDelegatingHandler : DelegatingHandler
{
    private readonly IHttpContextAccessor _httpContextAccessor;

    protected override async Task<HttpResponseMessage> SendAsync(
        HttpRequestMessage request, CancellationToken cancellationToken)
    {
        var correlationId = _httpContextAccessor.HttpContext?.Request.Headers["X-Correlation-ID"].FirstOrDefault()
                           ?? Activity.Current?.Id
                           ?? Guid.NewGuid().ToString();

        request.Headers.Add("X-Correlation-ID", correlationId);

        return await base.SendAsync(request, cancellationToken);
    }
}
```

## 📈 Metrics and Alerting

### Custom Metrics with Prometheus

```csharp
public class PrometheusMetrics
{
    private readonly Counter _requestsTotal = Metrics
        .CreateCounter("http_requests_total", "Total HTTP requests", new[] { "method", "endpoint", "status" });

    private readonly Histogram _requestDuration = Metrics
        .CreateHistogram("http_request_duration_seconds", "HTTP request duration", new[] { "method", "endpoint" });

    private readonly Gauge _activeConnections = Metrics
        .CreateGauge("active_connections", "Active database connections");

    private readonly Counter _businessEventsTotal = Metrics
        .CreateCounter("business_events_total", "Total business events", new[] { "event_type", "source" });

    private readonly Histogram _orderProcessingTime = Metrics
        .CreateHistogram("order_processing_duration_seconds", "Order processing time", new[] { "order_type" });

    public void RecordHttpRequest(string method, string endpoint, int statusCode, double durationSeconds)
    {
        _requestsTotal.WithLabels(method, endpoint, statusCode.ToString()).Inc();
        _requestDuration.WithLabels(method, endpoint).Observe(durationSeconds);
    }

    public void SetActiveConnections(int count)
    {
        _activeConnections.Set(count);
    }

    public void RecordBusinessEvent(string eventType, string source)
    {
        _businessEventsTotal.WithLabels(eventType, source).Inc();
    }

    public void RecordOrderProcessing(string orderType, double durationSeconds)
    {
        _orderProcessingTime.WithLabels(orderType).Observe(durationSeconds);
    }
}

// Metrics middleware
public class PrometheusMetricsMiddleware
{
    private readonly RequestDelegate _next;
    private readonly PrometheusMetrics _metrics;

    public async Task InvokeAsync(HttpContext context)
    {
        var stopwatch = Stopwatch.StartNew();
        
        try
        {
            await _next(context);
        }
        finally
        {
            stopwatch.Stop();
            var method = context.Request.Method;
            var endpoint = context.Request.Path.Value ?? "unknown";
            var statusCode = context.Response.StatusCode;
            
            _metrics.RecordHttpRequest(method, endpoint, statusCode, stopwatch.Elapsed.TotalSeconds);
        }
    }
}
```

### Alerting Rules

```yaml
# Prometheus alerting rules
groups:
  - name: microservices-alerts
    rules:
      # High error rate
      - alert: HighErrorRate
        expr: rate(http_requests_total{status=~"5.."}[5m]) / rate(http_requests_total[5m]) > 0.05
        for: 2m
        labels:
          severity: warning
        annotations:
          summary: "High error rate detected"
          description: "Error rate is {{ $value | humanizePercentage }} for {{ $labels.endpoint }}"

      # High response time
      - alert: HighResponseTime
        expr: histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m])) > 0.5
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High response time detected"
          description: "95th percentile response time is {{ $value }}s for {{ $labels.endpoint }}"

      # Service down
      - alert: ServiceDown
        expr: up == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Service is down"
          description: "{{ $labels.instance }} has been down for more than 1 minute"

      # Database connection pool exhaustion
      - alert: DatabaseConnectionPoolHigh
        expr: active_connections / database_max_connections > 0.8
        for: 2m
        labels:
          severity: warning
        annotations:
          summary: "Database connection pool usage is high"
          description: "Connection pool usage is {{ $value | humanizePercentage }}"

      # Business metric alerts
      - alert: OrderProcessingDelayed
        expr: histogram_quantile(0.95, rate(order_processing_duration_seconds_bucket[10m])) > 300
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "Order processing is delayed"
          description: "95th percentile order processing time is {{ $value }}s"

      # Low inventory alert
      - alert: LowInventory
        expr: inventory_level < 10
        for: 1m
        labels:
          severity: info
        annotations:
          summary: "Low inventory detected"
          description: "Product {{ $labels.product_sku }} has only {{ $value }} items in stock"
```

## 📊 Dashboards and Visualization

### Grafana Dashboard Configuration

```json
{
  "dashboard": {
    "title": "Microservices Overview",
    "tags": ["microservices", "overview"],
    "panels": [
      {
        "title": "Request Rate",
        "type": "stat",
        "targets": [
          {
            "expr": "sum(rate(http_requests_total[5m])) by (service)",
            "legendFormat": "{{service}}"
          }
        ],
        "fieldConfig": {
          "defaults": {
            "unit": "reqps",
            "thresholds": {
              "steps": [
                {"color": "green", "value": 0},
                {"color": "yellow", "value": 100},
                {"color": "red", "value": 500}
              ]
            }
          }
        }
      },
      {
        "title": "Error Rate",
        "type": "stat",
        "targets": [
          {
            "expr": "sum(rate(http_requests_total{status=~\"5..\"}[5m])) / sum(rate(http_requests_total[5m]))",
            "legendFormat": "Error Rate"
          }
        ],
        "fieldConfig": {
          "defaults": {
            "unit": "percentunit",
            "thresholds": {
              "steps": [
                {"color": "green", "value": 0},
                {"color": "yellow", "value": 0.01},
                {"color": "red", "value": 0.05}
              ]
            }
          }
        }
      },
      {
        "title": "Response Time Distribution",
        "type": "heatmap",
        "targets": [
          {
            "expr": "sum(rate(http_request_duration_seconds_bucket[5m])) by (le, service)",
            "format": "heatmap",
            "legendFormat": "{{le}}"
          }
        ]
      },
      {
        "title": "Service Dependencies",
        "type": "node-graph",
        "targets": [
          {
            "expr": "sum(rate(http_requests_total[5m])) by (source_service, target_service)",
            "format": "table"
          }
        ]
      }
    ]
  }
}
```

### Business Metrics Dashboard

```json
{
  "dashboard": {
    "title": "Business Metrics",
    "panels": [
      {
        "title": "Orders Created (Hourly)",
        "type": "graph",
        "targets": [
          {
            "expr": "sum(increase(orders_created_total[1h])) by (customer_tier)",
            "legendFormat": "{{customer_tier}}"
          }
        ]
      },
      {
        "title": "Revenue by Hour",
        "type": "graph",
        "targets": [
          {
            "expr": "sum(increase(order_value_total[1h])) by (currency)",
            "legendFormat": "{{currency}}"
          }
        ]
      },
      {
        "title": "Inventory Levels",
        "type": "table",
        "targets": [
          {
            "expr": "inventory_level",
            "format": "table",
            "instant": true
          }
        ]
      },
      {
        "title": "Customer Segments",
        "type": "piechart",
        "targets": [
          {
            "expr": "sum(orders_created_total) by (customer_tier)",
            "legendFormat": "{{customer_tier}}"
          }
        ]
      }
    ]
  }
}
```

## 🚨 Error Tracking and Alerting

### Exception Tracking

```csharp
public class ExceptionTrackingMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ILogger<ExceptionTrackingMiddleware> _logger;
    private readonly IMetricsCollector _metrics;

    public async Task InvokeAsync(HttpContext context)
    {
        try
        {
            await _next(context);
        }
        catch (Exception ex)
        {
            await HandleExceptionAsync(context, ex);
            throw;
        }
    }

    private async Task HandleExceptionAsync(HttpContext context, Exception ex)
    {
        var errorId = Guid.NewGuid().ToString();
        
        // Log structured exception data
        _logger.LogError(ex, "Unhandled exception {ErrorId} in {Endpoint}: {Message}",
            errorId, 
            $"{context.Request.Method} {context.Request.Path}",
            ex.Message);

        // Track metrics
        _metrics.Increment("exceptions_total", new[]
        {
            ("exception_type", ex.GetType().Name),
            ("endpoint", context.Request.Path.Value ?? "unknown"),
            ("method", context.Request.Method)
        });

        // Send to external error tracking service
        await SendToErrorTrackingServiceAsync(ex, context, errorId);

        // Add error ID to response headers for troubleshooting
        context.Response.Headers.Add("X-Error-ID", errorId);
    }

    private async Task SendToErrorTrackingServiceAsync(Exception ex, HttpContext context, string errorId)
    {
        try
        {
            var errorData = new
            {
                ErrorId = errorId,
                Exception = new
                {
                    Type = ex.GetType().Name,
                    Message = ex.Message,
                    StackTrace = ex.StackTrace
                },
                Request = new
                {
                    Method = context.Request.Method,
                    Path = context.Request.Path.Value,
                    Headers = context.Request.Headers.ToDictionary(h => h.Key, h => h.Value.ToString()),
                    QueryString = context.Request.QueryString.Value
                },
                User = new
                {
                    Id = context.User.FindFirst("sub")?.Value,
                    Email = context.User.FindFirst("email")?.Value
                },
                Environment = Environment.GetEnvironmentVariable("ENVIRONMENT") ?? "unknown",
                ServiceName = Environment.GetEnvironmentVariable("SERVICE_NAME") ?? "unknown",
                Timestamp = DateTime.UtcNow
            };

            // Send to Sentry, Bugsnag, or similar service
            // await _errorTrackingClient.CaptureAsync(errorData);
        }
        catch (Exception trackingEx)
        {
            _logger.LogError(trackingEx, "Failed to send exception to tracking service");
        }
    }
}
```

### Circuit Breaker Monitoring

```csharp
public class MonitoredCircuitBreaker
{
    private readonly IMetricsCollector _metrics;
    private readonly ILogger<MonitoredCircuitBreaker> _logger;
    private CircuitBreakerState _state = CircuitBreakerState.Closed;
    private int _failureCount = 0;
    private DateTime _lastFailureTime = DateTime.MinValue;

    public async Task<T> ExecuteAsync<T>(Func<Task<T>> operation, string operationName)
    {
        // Record current state
        _metrics.Gauge("circuit_breaker_state", (int)_state, new[]
        {
            ("operation", operationName),
            ("state", _state.ToString())
        });

        if (_state == CircuitBreakerState.Open)
        {
            _metrics.Increment("circuit_breaker_rejected_total", new[]
            {
                ("operation", operationName)
            });
            
            throw new CircuitBreakerOpenException($"Circuit breaker is open for {operationName}");
        }

        try
        {
            var result = await operation();
            OnSuccess(operationName);
            return result;
        }
        catch (Exception ex)
        {
            OnFailure(operationName, ex);
            throw;
        }
    }

    private void OnSuccess(string operationName)
    {
        if (_state == CircuitBreakerState.HalfOpen)
        {
            _logger.LogInformation("Circuit breaker closing for {Operation}", operationName);
            _metrics.Increment("circuit_breaker_state_changes_total", new[]
            {
                ("operation", operationName),
                ("from_state", "HalfOpen"),
                ("to_state", "Closed")
            });
        }

        _failureCount = 0;
        _state = CircuitBreakerState.Closed;
    }

    private void OnFailure(string operationName, Exception ex)
    {
        _failureCount++;
        _lastFailureTime = DateTime.UtcNow;

        _metrics.Increment("circuit_breaker_failures_total", new[]
        {
            ("operation", operationName),
            ("exception_type", ex.GetType().Name)
        });

        if (_failureCount >= 5 && _state == CircuitBreakerState.Closed)
        {
            _state = CircuitBreakerState.Open;
            _logger.LogWarning("Circuit breaker opening for {Operation} after {FailureCount} failures", 
                operationName, _failureCount);
            
            _metrics.Increment("circuit_breaker_state_changes_total", new[]
            {
                ("operation", operationName),
                ("from_state", "Closed"),
                ("to_state", "Open")
            });
        }
    }
}
```

## 🔍 Log Analysis and Searching

### Structured Query Examples

```csharp
// ELK Stack (Elasticsearch) queries for common scenarios

public class LogAnalysisQueries
{
    // Find all errors for a specific correlation ID
    public string GetErrorsByCorrelationId(string correlationId)
    {
        return $@"
        {{
          ""query"": {{
            ""bool"": {{
              ""must"": [
                {{""term"": {{""CorrelationId"": ""{correlationId}""}}}},
                {{""term"": {{""Level"": ""Error""}}}}
              ]
            }}
          }},
          ""sort"": [{{""@timestamp"": {{""order"": ""asc""}}}}]
        }}";
    }

    // Find slow database queries
    public string GetSlowDatabaseQueries(int thresholdMs = 1000)
    {
        return $@"
        {{
          ""query"": {{
            ""bool"": {{
              ""must"": [
                {{""term"": {{""SourceContext"": ""DatabaseQuery""}}}},
                {{""range"": {{""Duration"": {{""gte"": {thresholdMs}}}}}}}
              ]
            }}
          }},
          ""sort"": [{{""Duration"": {{""order"": ""desc""}}}}],
          ""size"": 100
        }}";
    }

    // Find authentication failures
    public string GetAuthenticationFailures(DateTime fromTime, DateTime toTime)
    {
        return $@"
        {{
          ""query"": {{
            ""bool"": {{
              ""must"": [
                {{""match"": {{""Message"": ""authentication failed""}}}},
                {{""range"": {{
                  ""@timestamp"": {{
                    ""gte"": ""{fromTime:yyyy-MM-ddTHH:mm:ss.fffZ}"",
                    ""lte"": ""{toTime:yyyy-MM-ddTHH:mm:ss.fffZ}""
                  }}
                }}}}
              ]
            }}
          }},
          ""aggs"": {{
            ""by_ip"": {{
              ""terms"": {{""field"": ""ClientIP""}}
            }},
            ""by_user"": {{
              ""terms"": {{""field"": ""UserId""}}
            }}
          }}
        }}";
    }

    // Find services with high error rates
    public string GetServiceErrorRates(string timeRange = "1h")
    {
        return $@"
        {{
          ""aggs"": {{
            ""services"": {{
              ""terms"": {{""field"": ""ServiceName""}},
              ""aggs"": {{
                ""total_requests"": {{
                  ""filter"": {{""term"": {{""RequestType"": ""HTTP""}}}}
                }},
                ""error_requests"": {{
                  ""filter"": {{
                    ""bool"": {{
                      ""must"": [
                        {{""term"": {{""RequestType"": ""HTTP""}}}},
                        {{""range"": {{""StatusCode"": {{""gte"": 500}}}}}}
                      ]
                    }}
                  }}
                }},
                ""error_rate"": {{
                  ""bucket_script"": {{
                    ""buckets_path"": {{
                      ""errors"": ""error_requests>_count"",
                      ""total"": ""total_requests>_count""
                    }},
                    ""script"": ""params.total > 0 ? params.errors / params.total : 0""
                  }}
                }}
              }}
            }}
          }},
          ""query"": {{
            ""range"": {{
              ""@timestamp"": {{""gte"": ""now-{timeRange}""}}
            }}
          }},
          ""size"": 0
        }}";
    }
}
```

### Log Aggregation and Analysis

```csharp
public class LogAnalyticsService
{
    private readonly IElasticClient _elasticClient;

    public async Task<ServiceHealthReport> GenerateHealthReportAsync(TimeSpan timeRange)
    {
        var endTime = DateTime.UtcNow;
        var startTime = endTime.Subtract(timeRange);

        // Get error rates by service
        var errorRateResponse = await _elasticClient.SearchAsync<LogEntry>(s => s
            .Index("microservices-logs-*")
            .Query(q => q
                .DateRange(r => r
                    .Field(f => f.Timestamp)
                    .GreaterThanOrEquals(startTime)
                    .LessThanOrEquals(endTime)))
            .Aggregations(a => a
                .Terms("services", t => t
                    .Field(f => f.ServiceName)
                    .Aggregations(aa => aa
                        .Filter("total_requests", f => f
                            .Filter(ff => ff.Term(fff => fff.Field("RequestType").Value("HTTP"))))
                        .Filter("error_requests", f => f
                            .Filter(ff => ff.Bool(b => b
                                .Must(
                                    m => m.Term(t => t.Field("RequestType").Value("HTTP")),
                                    m => m.Range(r => r.Field("StatusCode").GreaterThanOrEquals(500))))))
                        .BucketScript("error_rate", bs => bs
                            .BucketsPath(bp => bp
                                .Add("errors", "error_requests>_count")
                                .Add("total", "total_requests>_count"))
                            .Script("params.total > 0 ? params.errors / params.total : 0"))))));

        // Get performance metrics
        var performanceResponse = await _elasticClient.SearchAsync<LogEntry>(s => s
            .Index("microservices-logs-*")
            .Query(q => q
                .Bool(b => b
                    .Must(
                        m => m.DateRange(r => r
                            .Field(f => f.Timestamp)
                            .GreaterThanOrEquals(startTime)
                            .LessThanOrEquals(endTime)),
                        m => m.Exists(e => e.Field("Duration")))))
            .Aggregations(a => a
                .Terms("services", t => t
                    .Field(f => f.ServiceName)
                    .Aggregations(aa => aa
                        .Average("avg_duration", avg => avg.Field("Duration"))
                        .Percentiles("duration_percentiles", p => p
                            .Field("Duration")
                            .Percents(50, 95, 99))))));

        return new ServiceHealthReport
        {
            TimeRange = timeRange,
            Services = BuildServiceMetrics(errorRateResponse, performanceResponse)
        };
    }

    // Detect anomalies in logs
    public async Task<List<Anomaly>> DetectAnomaliesAsync(string serviceName, TimeSpan timeRange)
    {
        var response = await _elasticClient.SearchAsync<LogEntry>(s => s
            .Index("microservices-logs-*")
            .Query(q => q
                .Bool(b => b
                    .Must(
                        m => m.Term(t => t.Field("ServiceName").Value(serviceName)),
                        m => m.DateRange(r => r
                            .Field(f => f.Timestamp)
                            .GreaterThanOrEquals(DateTime.UtcNow.Subtract(timeRange))))))
            .Aggregations(a => a
                .DateHistogram("timeline", dh => dh
                    .Field(f => f.Timestamp)
                    .CalendarInterval(DateInterval.Minute)
                    .Aggregations(aa => aa
                        .ValueCount("request_count", vc => vc.Field("RequestId"))
                        .Filter("errors", f => f
                            .Filter(ff => ff.Term(t => t.Field("Level").Value("Error"))))
                        .Average("avg_duration", avg => avg.Field("Duration"))))));

        var anomalies = new List<Anomaly>();
        var buckets = response.Aggregations.DateHistogram("timeline").Buckets;

        // Simple anomaly detection based on statistical deviation
        var requestCounts = buckets.Select(b => (double)b.ValueCount("request_count").Value).ToList();
        var avgRequestCount = requestCounts.Average();
        var stdDev = Math.Sqrt(requestCounts.Select(x => Math.Pow(x - avgRequestCount, 2)).Average());

        foreach (var bucket in buckets)
        {
            var requestCount = bucket.ValueCount("request_count").Value ?? 0;
            var errorCount = bucket.Filter("errors").DocCount;
            var avgDuration = bucket.Average("avg_duration").Value;

            // Detect request count anomalies
            if (Math.Abs(requestCount - avgRequestCount) > 2 * stdDev)
            {
                anomalies.Add(new Anomaly
                {
                    Type = "RequestCountAnomaly",
                    Timestamp = bucket.Date,
                    ServiceName = serviceName,
                    Description = $"Unusual request count: {requestCount} (normal: {avgRequestCount:F0})",
                    Severity = requestCount > avgRequestCount + 2 * stdDev ? "High" : "Medium"
                });
            }

            // Detect high error rates
            var errorRate = requestCount > 0 ? errorCount / (double)requestCount : 0;
            if (errorRate > 0.1) // 10% error rate threshold
            {
                anomalies.Add(new Anomaly
                {
                    Type = "HighErrorRate",
                    Timestamp = bucket.Date,
                    ServiceName = serviceName,
                    Description = $"High error rate: {errorRate:P2} ({errorCount}/{requestCount})",
                    Severity = errorRate > 0.2 ? "Critical" : "High"
                });
            }
        }

        return anomalies;
    }
}
```

## 🔧 Monitoring Tools Integration

### Application Insights Integration

```csharp
public static class ApplicationInsightsConfiguration
{
    public static IServiceCollection AddApplicationInsights(this IServiceCollection services, IConfiguration configuration)
    {
        services.AddApplicationInsightsTelemetry(options =>
        {
            options.ConnectionString = configuration["ApplicationInsights:ConnectionString"];
            options.EnableAdaptiveSampling = true;
            options.EnableAuthenticationTrackingJavaScript = true;
            options.EnableDependencyTrackingTelemetryModule = true;
        });

        // Add custom telemetry initializers
        services.AddSingleton<ITelemetryInitializer, ServiceNameTelemetryInitializer>();
        services.AddSingleton<ITelemetryInitializer, EnvironmentTelemetryInitializer>();

        // Add custom telemetry processors
        services.AddApplicationInsightsTelemetryProcessor<FilteringTelemetryProcessor>();

        return services;
    }
}

public class ServiceNameTelemetryInitializer : ITelemetryInitializer
{
    public void Initialize(ITelemetry telemetry)
    {
        if (telemetry is ISupportProperties propertyTelemetry)
        {
            propertyTelemetry.Properties["ServiceName"] = Environment.GetEnvironmentVariable("SERVICE_NAME") ?? "unknown";
            propertyTelemetry.Properties["ServiceVersion"] = Environment.GetEnvironmentVariable("SERVICE_VERSION") ?? "unknown";
        }
    }
}

public class FilteringTelemetryProcessor : ITelemetryProcessor
{
    private readonly ITelemetryProcessor _next;

    public FilteringTelemetryProcessor(ITelemetryProcessor next)
    {
        _next = next;
    }

    public void Process(ITelemetry item)
    {
        // Filter out health check requests
        if (item is RequestTelemetry request && request.Url.AbsolutePath.Contains("/health"))
        {
            return;
        }

        // Filter out successful dependency calls to reduce noise
        if (item is DependencyTelemetry dependency && dependency.Success == true && dependency.Duration < TimeSpan.FromSeconds(1))
        {
            return;
        }

        _next.Process(item);
    }
}
```

### Datadog Integration

```csharp
public class DatadogMetricsCollector : IMetricsCollector
{
    private readonly DogStatsdService _dogStatsd;

    public DatadogMetricsCollector(IConfiguration configuration)
    {
        var config = new StatsdConfig
        {
            StatsdServerName = configuration["Datadog:Host"],
            StatsdPort = int.Parse(configuration["Datadog:Port"]),
            Prefix = configuration["Datadog:Prefix"]
        };

        _dogStatsd = new DogStatsdService();
        _dogStatsd.Configure(config);
    }

    public void Increment(string metricName, params (string, string)[] tags)
    {
        var datadogTags = tags.Select(t => $"{t.Item1}:{t.Item2}").ToArray();
        _dogStatsd.Increment(metricName, tags: datadogTags);
    }

    public void Gauge(string metricName, double value, params (string, string)[] tags)
    {
        var datadogTags = tags.Select(t => $"{t.Item1}:{t.Item2}").ToArray();
        _dogStatsd.Gauge(metricName, value, tags: datadogTags);
    }

    public void Histogram(string metricName, double value, params (string, string)[] tags)
    {
        var datadogTags = tags.Select(t => $"{t.Item1}:{t.Item2}").ToArray();
        _dogStatsd.Histogram(metricName, value, tags: datadogTags);
    }

    public void Timer(string metricName, TimeSpan duration, params (string, string)[] tags)
    {
        var datadogTags = tags.Select(t => $"{t.Item1}:{t.Item2}").ToArray();
        _dogStatsd.Timer(metricName, duration.TotalMilliseconds, tags: datadogTags);
    }
}
```

## 📋 Monitoring Checklist

### Essential Metrics to Monitor

#### Golden Signals (SRE)
- [ ] **Latency** - Time to process requests
- [ ] **Traffic** - Amount of demand on your system
- [ ] **Errors** - Rate of requests that fail
- [ ] **Saturation** - How "full" your service is

#### RED Method (Requests, Errors, Duration)
- [ ] **Request Rate** - Requests per second
- [ ] **Error Rate** - Percentage of failed requests
- [ ] **Duration** - Request latency distribution

#### USE Method (Utilization, Saturation, Errors)
- [ ] **Utilization** - CPU, memory, disk, network usage
- [ ] **Saturation** - Queued work (thread pool, connection pool)
- [ ] **Errors** - System errors and failures

### Application-Specific Metrics
- [ ] Business metrics (orders, revenue, user actions)
- [ ] Database performance (query time, connection pool)
- [ ] External service dependencies
- [ ] Message queue metrics (depth, processing time)
- [ ] Cache hit rates and performance

### Infrastructure Metrics
- [ ] Container metrics (CPU, memory, disk)
- [ ] Network metrics (latency, packet loss)
- [ ] Load balancer metrics
- [ ] Database server metrics

### Security Metrics
- [ ] Authentication failures
- [ ] Authorization denials
- [ ] Unusual access patterns
- [ ] Rate limiting activations

## 🎯 Best Practices Summary

### 1. Start with the Basics
- Implement the Golden Signals first
- Set up centralized logging early
- Use correlation IDs for request tracing
- Monitor business metrics alongside technical metrics

### 2. Design for Observability
- Include monitoring in your service design
- Use structured logging consistently
- Add custom metrics for business logic
- Implement comprehensive health checks

### 3. Alerting Strategy
- Alert on symptoms, not causes
- Use multiple severity levels
- Implement alert fatigue prevention
- Test your alerts regularly

### 4. Performance Considerations
- Use sampling for high-volume traces
- Aggregate metrics appropriately
- Consider storage costs for logs and metrics
- Implement retention policies

### 5. Team Practices
- Make monitoring a shared responsibility
- Create runbooks for common alerts
- Regular review of monitoring effectiveness
- Continuous improvement of observability

---

*Effective monitoring is crucial for successful microservices operations. Start simple, be consistent, and evolve your monitoring strategy as your system grows.*