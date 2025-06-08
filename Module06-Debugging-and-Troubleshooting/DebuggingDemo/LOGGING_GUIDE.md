# Exercise 2: Comprehensive Logging Implementation

## 🎯 Objective
Implement multi-provider logging with different log levels, structured logging, and best practices using Serilog.

## ⏱️ Time Allocation
**Total Time**: 30 minutes
- Serilog Setup: 10 minutes
- Structured Logging: 10 minutes
- Advanced Patterns: 10 minutes

## 🚀 Getting Started

### Step 1: Understanding Serilog Configuration
1. Review `appsettings.json` for Serilog settings
2. Note the different sinks (Console, File)
3. Understand log levels and overrides
4. Check enrichers for automatic context

### Step 2: Test Different Log Levels
1. Run the application: `dotnet run`
2. Call: `GET /api/loggingtest/test-levels`
3. Observe console output with different colors
4. Check `Logs/` directory for file output

### Step 3: Structured Logging
1. Call: `GET /api/loggingtest/test-structured/123?name=John`
2. Note how parameters are captured as properties
3. Check JSON structure in logs
4. Compare with string interpolation anti-pattern

### Step 4: Performance Logging
1. Call: `GET /api/loggingtest/test-performance`
2. Observe method entry/exit logging
3. Check performance warnings for slow operations
4. Note the elapsed time tracking

### Step 5: Exception Logging
1. Call: `GET /api/loggingtest/test-exception`
2. See full exception details in logs
3. Note stack trace preservation
4. Check correlation with request context

## 📊 Logging Best Practices

### 1. Use Structured Logging
```csharp
// Good: Structured parameters
_logger.LogInformation("User {UserId} purchased {ProductName} for {Price:C}", 
    userId, productName, price);

// Bad: String concatenation
_logger.LogInformation($"User {userId} purchased {productName} for ${price}");
```

### 2. Choose Appropriate Log Levels
- **Trace**: Method entry/exit, detailed flow
- **Debug**: Detailed debugging information
- **Information**: General informational messages
- **Warning**: Unusual but handled situations
- **Error**: Errors that dont stop the app
- **Critical**: Serious errors requiring immediate attention

### 3. Use Scopes for Context
```csharp
using (_logger.BeginScope(new { UserId = userId, OrderId = orderId }))
{
    // All logs within this scope will include UserId and OrderId
    _logger.LogInformation("Processing order");
    _logger.LogInformation("Order validated");
}
```

### 4. Enrich Logs Automatically
- Request ID / Correlation ID
- User information
- Machine name
- Environment details
- Performance metrics

## 🧪 Logging Exercises

### Exercise A: Analyze Log Output
1. Make several API calls
2. Find specific requests in the log files
3. Trace a request through multiple log entries
4. Use correlation IDs to group related logs

### Exercise B: Add Custom Enrichment
1. Create a custom enricher for user context
2. Add request headers to logs
3. Include custom application metrics
4. Test with different scenarios

### Exercise C: Configure Log Filtering
1. Change log levels in appsettings.json
2. Filter out specific namespaces
3. Create environment-specific configurations
4. Test verbose vs. production logging

### Exercise D: Implement Business Event Logging
1. Create an order: `POST /api/loggingtest/test-business-event`
2. Review the business event structure
3. Add more business events
4. Create a business event dashboard

## 📈 Monitoring and Analysis

### Log File Analysis
1. Navigate to the `Logs/` directory
2. Open the latest log file
3. Search for specific patterns:
   - Errors: `[ERR]`
   - Warnings: `[WRN]`
   - Slow requests: "Slow operation"
   - Exceptions: "Exception"

### Performance Metrics
1. Look for requests over 1000ms
2. Identify frequent warnings
3. Find error patterns
4. Track business events

## ✅ Success Criteria
- [ ] Serilog is properly configured with multiple sinks
- [ ] Structured logging is used throughout
- [ ] Different log levels are appropriately applied
- [ ] Performance metrics are captured
- [ ] Exceptions are logged with full context
- [ ] Business events are tracked
- [ ] Log files are properly formatted and rotated

## 🔄 Next Steps
After mastering logging, proceed to Exercise 3 for exception handling and monitoring.

## 💡 Pro Tips
1. **Avoid over-logging**: Too many logs can hide important information
2. **Be consistent**: Use the same property names across your application
3. **Think about the reader**: Write logs that help diagnose issues
4. **Secure sensitive data**: Never log passwords, tokens, or PII
5. **Use correlation**: Always include request/correlation IDs
6. **Monitor log size**: Implement retention policies
7. **Test your logs**: Ensure they work when you need them most

