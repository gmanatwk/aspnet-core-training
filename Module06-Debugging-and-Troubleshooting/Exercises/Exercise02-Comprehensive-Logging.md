# Exercise 2: Comprehensive Logging Implementation

## 🎯 Objective
Implement multi-provider logging with different log levels, structured logging, and best practices using Serilog.

## ⏱️ Estimated Time
30 minutes

## 📚 Prerequisites
- Completed Exercise 1 (Debugging Fundamentals)
- Understanding of logging concepts
- Basic knowledge of structured logging

## 🔧 Setup
Continue using the DebuggingDemo project which already has Serilog configured.

## 📋 Tasks

### Task 1: Understanding Current Logging Setup (5 minutes)
1. **Examine `Program.cs`** to understand the Serilog configuration
2. **Review log output locations**:
   - Console output
   - File output in `/logs` folder
   - (Optional) Database logging
3. **Check `appsettings.json`** for logging configuration

### Task 2: Test Different Log Levels (10 minutes)
1. **Use the logging test endpoint** to generate different log levels:
   ```http
   POST /api/test/logging/trace
   Content-Type: application/json
   "This is a trace message"
   ```
2. **Test each log level**:
   - Trace
   - Debug
   - Information
   - Warning
   - Error
   - Critical

3. **Observe log output**:
   - Check console output
   - Check log files in `/logs` folder
   - Notice which levels appear based on configuration

### Task 3: Structured Logging Practice (10 minutes)
1. **Create a custom controller method** with structured logging:
   ```csharp
   [HttpPost("custom-log")]
   public ActionResult CustomLogExample([FromBody] UserRequest request)
   {
       _logger.LogInformation("User {UserId} requested {Action} at {Timestamp}", 
           request.UserId, request.Action, DateTime.UtcNow);
       
       // Your implementation here
       
       return Ok();
   }
   ```

2. **Add context to logs** using the logging extensions:
   ```csharp
   _logger.LogMethodEntry(nameof(CustomLogExample), request);
   // ... method logic
   _logger.LogMethodExit(nameof(CustomLogExample), result);
   ```

3. **Test your custom endpoint** and observe structured log output

### Task 4: Exception Logging (5 minutes)
1. **Trigger an exception** using the error endpoint:
   ```http
   GET /api/test/error/argument
   ```
2. **Examine exception logs**:
   - Check how exceptions are logged
   - Review the stack trace information
   - Notice correlation with request IDs

3. **Add custom exception handling**:
   ```csharp
   try
   {
       // Some risky operation
       throw new InvalidOperationException("Custom test exception");
   }
   catch (Exception ex)
   {
       _logger.LogError(ex, "Custom exception occurred for user {UserId}", userId);
       throw;
   }
   ```

## 🧪 Test Cases

### Test Case 1: Log Level Filtering
**Environment**: Development vs Production
```bash
# Development - should show Debug and above
POST /api/test/logging/debug

# Production - should show Information and above
POST /api/test/logging/debug  # This should not appear in production logs
```

### Test Case 2: Structured Logging
```json
POST /api/test/logging/information
{
  "User 12345 completed order 67890 with total $123.45"
}
```
**Expected**: Structured log entry with extractable fields

### Test Case 3: Performance Logging
```http
GET /api/test/slow/2000
```
**Expected**: Performance warning log due to slow response

## 📊 Log Analysis Exercises

### Exercise A: Log Correlation
1. **Make multiple requests** with different parameters
2. **Use Request IDs** to trace requests through logs
3. **Identify patterns** in log correlation

### Exercise B: Performance Monitoring
1. **Call various endpoints** with different response times
2. **Review performance logs** in the middleware
3. **Identify slow requests** in the log output

### Exercise C: Error Tracking
1. **Trigger different types of errors**
2. **Track error propagation** through the application layers
3. **Verify error handling** and logging consistency

## 🔧 Advanced Logging Configurations

### Task 5: Custom Log Enrichment
Add custom properties to all log entries:
```csharp
// In Program.cs
Log.Logger = new LoggerConfiguration()
    .Enrich.WithProperty("ApplicationName", "DebuggingDemo")
    .Enrich.WithProperty("Version", Assembly.GetExecutingAssembly().GetName().Version)
    // ... other configuration
```

### Task 6: Conditional Logging
Implement conditional logging based on user roles or request types:
```csharp
public void LogUserAction(string userId, string action, bool isAdmin = false)
{
    if (isAdmin)
    {
        _logger.LogInformation("Admin {UserId} performed {Action}", userId, action);
    }
    else
    {
        _logger.LogDebug("User {UserId} performed {Action}", userId, action);
    }
}
```

## 📋 Logging Best Practices Checklist

### ✅ Structured Logging
- [ ] Use parameterized log messages
- [ ] Include relevant context in log entries
- [ ] Use consistent property names across the application
- [ ] Avoid string interpolation in log messages

### ✅ Log Levels
- [ ] Use appropriate log levels for different scenarios
- [ ] Configure different log levels for different environments
- [ ] Use Debug for development-only information
- [ ] Use Information for general application flow
- [ ] Use Warning for unexpected but recoverable situations
- [ ] Use Error for errors that don't crash the application
- [ ] Use Critical for errors that might crash the application

### ✅ Performance
- [ ] Use conditional logging for expensive operations
- [ ] Implement asynchronous logging for high-throughput scenarios
- [ ] Configure appropriate log retention policies
- [ ] Avoid logging sensitive information

### ✅ Context
- [ ] Include correlation IDs for request tracking
- [ ] Add user context when available
- [ ] Include timing information for performance monitoring
- [ ] Provide sufficient detail for troubleshooting

## 🔍 Log Analysis Tools

### Using Log Files
1. **Navigate to `/logs` folder**
2. **Open recent log files** in a text editor
3. **Search for specific patterns**:
   - Error messages
   - Slow requests
   - User actions

### Using grep/findstr
```bash
# Find all error logs
grep "Error" logs/app-20231201.txt

# Find logs for specific user
grep "User 12345" logs/app-20231201.txt

# Find slow requests
grep "Slow request" logs/app-20231201.txt
```

### Log Aggregation (Advanced)
If using log aggregation tools:
1. **Send logs to centralized system**
2. **Create dashboards** for monitoring
3. **Set up alerts** for critical issues

## 📊 Expected Outcomes
After completing this exercise, you should be able to:
- ✅ Configure multi-provider logging with Serilog
- ✅ Use appropriate log levels for different scenarios
- ✅ Implement structured logging with parameterized messages
- ✅ Add context and correlation to log entries
- ✅ Analyze logs for troubleshooting and monitoring
- ✅ Apply logging best practices in real applications

## 🚨 Common Logging Pitfalls

### Pitfall 1: String Interpolation
```csharp
// ❌ Bad - Doesn't support structured logging
_logger.LogInformation($"User {userId} created order {orderId}");

// ✅ Good - Supports structured logging
_logger.LogInformation("User {UserId} created order {OrderId}", userId, orderId);
```

### Pitfall 2: Inappropriate Log Levels
```csharp
// ❌ Bad - Using wrong log level
_logger.LogError("User clicked button"); // This is not an error!

// ✅ Good - Using appropriate log level
_logger.LogDebug("User clicked button");
```

### Pitfall 3: Logging Sensitive Information
```csharp
// ❌ Bad - Logging sensitive data
_logger.LogInformation("User logged in with password {Password}", password);

// ✅ Good - Avoiding sensitive data
_logger.LogInformation("User {UserId} logged in successfully", userId);
```

## 🎓 Bonus Challenges

### Challenge 1: Custom Log Sink
Create a custom Serilog sink that sends critical errors to a notification system.

### Challenge 2: Log Sampling
Implement log sampling for high-volume endpoints to reduce log noise.

### Challenge 3: Contextual Logging
Create a logging context that automatically includes user information in all log entries within a request scope.

## 📝 Reflection Questions
1. How does structured logging improve log analysis compared to plain text logging?
2. When would you use different log levels, and how do they help in production monitoring?
3. What information should always be included in error logs for effective troubleshooting?
4. How can logging help with performance monitoring and optimization?

## 🔄 Next Steps
After mastering comprehensive logging, proceed to:
- **Exercise 3**: Exception Handling and Monitoring
- **Advanced log analysis** with aggregation tools
- **Integration with monitoring systems** like Application Insights

---

**💡 Pro Tip**: Good logging is essential for production applications. Invest time in setting up proper logging infrastructure early in your project to save significant debugging time later.
