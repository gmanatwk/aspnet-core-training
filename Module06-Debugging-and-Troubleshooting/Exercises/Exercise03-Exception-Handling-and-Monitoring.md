# Exercise 3: Exception Handling and Monitoring

## 🎯 Objective
Create robust exception handling with monitoring capabilities, implement global exception middleware, and establish comprehensive error tracking.

## ⏱️ Estimated Time
25 minutes

## 📚 Prerequisites
- Completed Exercise 1 & 2
- Understanding of ASP.NET Core middleware
- Basic knowledge of HTTP status codes

## 🔧 Setup
Continue with the DebuggingDemo project which includes global exception handling middleware.

## 📋 Tasks

### Task 1: Understanding Global Exception Handling (5 minutes)
1. **Examine the `ExceptionHandlingMiddleware`** in the project
2. **Review the `ErrorResponse` model** and RFC 7807 compliance
3. **Study the error mapping logic** for different exception types
4. **Test the middleware** by calling error endpoints

### Task 2: Testing Different Exception Types (10 minutes)
Test each exception type and observe the responses:

#### Basic Exception Testing
```http
GET /api/test/error/argument
```
**Expected Response**:
```json
{
  "type": "ArgumentException",
  "title": "Invalid Argument",
  "status": 400,
  "detail": "Test argument exception triggered at...",
  "instance": "/api/test/error/argument",
  "requestId": "...",
  "timestamp": "2023-12-01T10:00:00Z"
}
```

#### Test All Exception Types
1. **ArgumentException**: `GET /api/test/error/argument` → 400 Bad Request
2. **KeyNotFoundException**: `GET /api/test/error/notfound` → 404 Not Found
3. **UnauthorizedAccessException**: `GET /api/test/error/unauthorized` → 401 Unauthorized
4. **TimeoutException**: `GET /api/test/error/timeout` → 408 Request Timeout
5. **InvalidOperationException**: `GET /api/test/error/invalid` → 400 Bad Request
6. **HttpRequestException**: `GET /api/test/error/http` → 502 Bad Gateway
7. **Generic Exception**: `GET /api/test/error/generic` → 500 Internal Server Error

### Task 3: Exception Context and Correlation (5 minutes)
1. **Track exceptions across requests** using correlation IDs
2. **Test exception logging** with context:
   ```http
   GET /api/test/error/argument
   ```
3. **Check logs** for correlation information:
   - Request ID matching
   - Exception details
   - Stack trace information
4. **Verify error response** includes proper correlation data

### Task 4: Custom Exception Handling (5 minutes)
1. **Create a custom exception class**:
   ```csharp
   public class BusinessRuleException : Exception
   {
       public string RuleName { get; }
       public BusinessRuleException(string ruleName, string message) : base(message)
       {
           RuleName = ruleName;
       }
   }
   ```

2. **Add a test endpoint** that throws your custom exception:
   ```csharp
   [HttpGet("business-rule-error")]
   public ActionResult TestBusinessRuleError()
   {
       throw new BusinessRuleException("MaxOrderLimit", "Order exceeds maximum allowed amount");
   }
   ```

3. **Update the exception middleware** to handle your custom exception
4. **Test the new exception handling**

## 🧪 Advanced Exception Scenarios

### Scenario 1: External Service Failures
Test external API failures and observe how they're handled:
```http
GET /api/test/external/999999
```
**Observe**:
- HTTP request exception handling
- Timeout scenarios
- Error response formatting

### Scenario 2: Database Connection Issues
Simulate database connection problems:
```http
GET /api/test/database
```
**Note**: In this demo with InMemory database, you might need to simulate by temporarily breaking the context.

### Scenario 3: Validation Errors
Create validation scenarios and observe error handling:
```http
GET /api/test/slow/-100
```
**Expected**: Validation error with appropriate HTTP status code

## 🔍 Exception Monitoring and Analytics

### Task 5: Exception Metrics Collection
1. **Monitor exception frequency** by reviewing logs
2. **Identify patterns** in exception occurrence
3. **Track response times** for error scenarios
4. **Analyze correlation** between exceptions and performance

### Exception Analysis Questions
1. **Which exceptions occur most frequently?**
2. **Are there patterns in exception timing?**
3. **Do certain endpoints have higher error rates?**
4. **How do exceptions affect application performance?**

## 📊 Health Monitoring Integration

### Task 6: Health Checks and Exception Correlation
1. **Test health check endpoints**:
   ```http
   GET /health
   GET /health/ready
   GET /health/live
   ```

2. **Trigger exceptions** and observe health check responses
3. **Correlate health status** with exception rates
4. **Review health check details** for exception impact

### Health Check Analysis
- **Database Health**: Does it correlate with database exceptions?
- **External API Health**: Does it predict external service exceptions?
- **Custom Health**: How do business rule violations affect overall health?

## 🛠️ Exception Handling Best Practices

### ✅ Exception Handling Checklist
- [ ] **Global Exception Handling**: All unhandled exceptions caught
- [ ] **Appropriate HTTP Status Codes**: Match exception types to status codes
- [ ] **Consistent Error Format**: RFC 7807 Problem Details compliance
- [ ] **Correlation IDs**: Track exceptions across requests
- [ ] **Security**: Don't expose sensitive information in error messages
- [ ] **Logging**: Comprehensive exception logging with context
- [ ] **Performance**: Exception handling doesn't significantly impact performance

### ✅ Error Response Guidelines
- [ ] **Consistent Structure**: Same format for all error responses
- [ ] **Helpful Messages**: Clear, actionable error descriptions
- [ ] **Request Correlation**: Include request ID for tracking
- [ ] **Environment-Specific**: Different detail levels for dev/prod
- [ ] **Timestamp**: Include when the error occurred
- [ ] **Instance Path**: Show which endpoint caused the error

## 🚨 Common Exception Handling Mistakes

### Mistake 1: Swallowing Exceptions
```csharp
// ❌ Bad - Exception disappears
try
{
    riskyOperation();
}
catch (Exception)
{
    // Silent failure - very bad!
}

// ✅ Good - Exception handled properly
try
{
    riskyOperation();
}
catch (Exception ex)
{
    _logger.LogError(ex, "Risky operation failed");
    throw; // Re-throw or handle appropriately
}
```

### Mistake 2: Generic Exception Catching
```csharp
// ❌ Bad - Catches everything
try
{
    await externalApiCall();
}
catch (Exception ex)
{
    return BadRequest("Something went wrong");
}

// ✅ Good - Specific exception handling
try
{
    await externalApiCall();
}
catch (HttpRequestException ex)
{
    _logger.LogError(ex, "External API call failed");
    return StatusCode(502, "External service unavailable");
}
catch (TimeoutException ex)
{
    _logger.LogError(ex, "External API timeout");
    return StatusCode(408, "Request timeout");
}
```

### Mistake 3: Exposing Internal Details
```csharp
// ❌ Bad - Exposes internal information
catch (SqlException ex)
{
    return BadRequest(ex.Message); // Might expose database schema
}

// ✅ Good - Safe error message
catch (SqlException ex)
{
    _logger.LogError(ex, "Database operation failed");
    return StatusCode(500, "A database error occurred");
}
```

## 📈 Exception Monitoring Dashboard

### Key Metrics to Track
1. **Exception Rate**: Exceptions per minute/hour
2. **Exception Types**: Distribution of different exception types
3. **Error Endpoints**: Which endpoints have the highest error rates
4. **Response Times**: How exceptions affect performance
5. **Recovery Rate**: How quickly the system recovers from errors

### Creating Simple Monitoring
```csharp
// Add to your controller or service
public class ExceptionMetrics
{
    private static readonly Dictionary<string, int> _exceptionCounts = new();
    
    public static void RecordException(string exceptionType)
    {
        _exceptionCounts.TryGetValue(exceptionType, out var count);
        _exceptionCounts[exceptionType] = count + 1;
    }
    
    public static Dictionary<string, int> GetCounts() => _exceptionCounts;
}
```

## 📊 Expected Outcomes
After completing this exercise, you should be able to:
- ✅ Implement comprehensive global exception handling
- ✅ Create consistent error responses following RFC 7807
- ✅ Track and correlate exceptions across requests
- ✅ Handle different exception types appropriately
- ✅ Monitor exception patterns and frequency
- ✅ Integrate exception handling with health monitoring
- ✅ Apply exception handling best practices

## 🎓 Bonus Challenges

### Challenge 1: Circuit Breaker Pattern
Implement a circuit breaker for external API calls that opens after consecutive failures.

### Challenge 2: Exception Aggregation
Create a service that aggregates exception data and provides analytics.

### Challenge 3: Retry Logic
Implement automatic retry logic for transient exceptions with exponential backoff.

### Challenge 4: Custom Error Pages
Create custom error pages for different types of exceptions in web applications.

## 📝 Reflection Questions
1. How does consistent exception handling improve API usability?
2. What information should be included in error responses for effective debugging?
3. How can exception monitoring help predict and prevent system failures?
4. When should you retry failed operations vs. fail fast?

## 🔄 Next Steps
After mastering exception handling and monitoring, you're ready for:
- **Advanced error recovery patterns**
- **Integration with external monitoring systems**
- **Module 7**: Testing Applications (testing error scenarios)
- **Production-ready exception handling strategies**

---

**💡 Pro Tip**: Exception handling is not just about catching errors—it's about providing a great developer experience, maintaining system stability, and enabling effective troubleshooting. Invest in comprehensive exception handling early in your project lifecycle.
