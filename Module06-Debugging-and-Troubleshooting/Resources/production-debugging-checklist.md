# Production Debugging Checklist

## 🎯 Before Production Deployment

### ✅ Logging Infrastructure
- [ ] **Multi-level logging configured** (Trace, Debug, Info, Warning, Error, Critical)
- [ ] **Structured logging implemented** with parameterized messages
- [ ] **Log aggregation service configured** (e.g., ELK stack, Splunk, Azure Monitor)
- [ ] **Log retention policies defined** (storage duration, archival strategy)
- [ ] **Sensitive data exclusion verified** (no passwords, PII in logs)
- [ ] **Performance impact assessed** (async logging, appropriate log levels)

### ✅ Exception Handling
- [ ] **Global exception handler implemented** and tested
- [ ] **Custom exception types defined** for business scenarios
- [ ] **Error response format standardized** (RFC 7807 compliance)
- [ ] **Environment-specific error details** (detailed in dev, safe in prod)
- [ ] **Exception correlation IDs** for request tracking
- [ ] **Retry logic implemented** for transient failures

### ✅ Health Monitoring
- [ ] **Health check endpoints configured** (/health, /health/ready, /health/live)
- [ ] **Dependency health checks implemented** (database, external APIs)
- [ ] **Custom health checks created** (business logic, resource usage)
- [ ] **Health check UI configured** for monitoring dashboard
- [ ] **Alert thresholds defined** for health check failures
- [ ] **Health check security considered** (authentication, rate limiting)

### ✅ Performance Monitoring
- [ ] **Application insights configured** (or equivalent APM tool)
- [ ] **Custom telemetry tracking** for business metrics
- [ ] **Performance counters monitored** (CPU, memory, requests/sec)
- [ ] **Slow query detection enabled** with appropriate thresholds
- [ ] **Memory leak detection implemented** 
- [ ] **Resource usage alerts configured**

---

## 🚨 Production Incident Response

### 🔍 Initial Assessment (First 5 minutes)
- [ ] **Identify scope of impact** (all users, specific features, geographic regions)
- [ ] **Check health endpoints** for system status overview
- [ ] **Review recent deployments** (correlation with incident timing)
- [ ] **Examine error rates** in monitoring dashboards
- [ ] **Verify external dependencies** (third-party services, databases)

### 📊 Data Gathering (Next 10 minutes)
- [ ] **Collect correlation IDs** from user reports or error logs
- [ ] **Query log aggregation system** for error patterns
- [ ] **Check performance metrics** for anomalies
- [ ] **Review application insights** for dependency failures
- [ ] **Examine server resources** (CPU, memory, disk, network)
- [ ] **Validate configuration changes** (app settings, connection strings)

### 🔧 Debugging Steps
- [ ] **Trace request flow** using correlation IDs
- [ ] **Analyze exception patterns** for common root causes
- [ ] **Review slow query logs** for database performance issues
- [ ] **Check external service health** and response times
- [ ] **Examine memory usage trends** for potential leaks
- [ ] **Validate business logic flows** using detailed logs

### 📝 Documentation During Incident
- [ ] **Record timeline of events** with timestamps
- [ ] **Document investigation steps** and findings
- [ ] **Capture relevant log excerpts** and error messages
- [ ] **Note correlation IDs** for further analysis
- [ ] **Track attempted solutions** and their outcomes

---

## 🔍 Common Production Issues Playbook

### Issue: Application Unresponsive

#### Quick Checks
- [ ] **CPU usage**: Check if CPU is maxed out
- [ ] **Memory usage**: Look for memory leaks or OutOfMemoryException
- [ ] **Thread pool starvation**: Check active thread count
- [ ] **Database connections**: Verify connection pool availability
- [ ] **External dependencies**: Confirm third-party service availability

#### Diagnostic Commands
```bash
# Check application logs for errors
grep -i "error\|exception\|timeout" /var/log/myapp/app.log | tail -50

# Monitor resource usage
top -p $(pidof myapp)

# Check database connections
netstat -an | grep :5432 | wc -l  # PostgreSQL example

# Review recent deployments
git log --oneline --since="2 hours ago"
```

### Issue: High Error Rate

#### Investigation Steps
- [ ] **Error categorization**: Group errors by type and frequency
- [ ] **Correlation analysis**: Link errors to specific user actions or features
- [ ] **Timeline analysis**: Identify when error rate increased
- [ ] **Dependency mapping**: Check if errors originate from external services
- [ ] **Code path analysis**: Trace failing requests through application layers

#### Sample Log Queries
```bash
# Find most common errors
grep "ERROR" app.log | awk '{print $NF}' | sort | uniq -c | sort -nr

# Track specific user's issues
grep "UserId:12345" app.log | grep "ERROR"

# Analyze error trends by hour
grep "ERROR" app.log | awk '{print $1, $2}' | uniq -c
```

### Issue: Performance Degradation

#### Performance Checklist
- [ ] **Response time trends**: Compare current vs. historical response times
- [ ] **Database query performance**: Identify slow or blocked queries
- [ ] **Memory pressure**: Check garbage collection frequency and duration
- [ ] **External service latency**: Measure dependency response times
- [ ] **Cache hit rates**: Verify caching effectiveness
- [ ] **Connection pool usage**: Monitor database and HTTP connection pools

#### Monitoring Queries
```sql
-- Find slow queries (SQL Server example)
SELECT TOP 10 
    total_elapsed_time / execution_count AS avg_time,
    text,
    execution_count
FROM sys.dm_exec_query_stats 
CROSS APPLY sys.dm_exec_sql_text(sql_handle)
ORDER BY avg_time DESC;
```

---

## 🛠️ Debugging Tools and Techniques

### Log Analysis Tools

#### Grep/PowerShell Patterns
```bash
# Find all errors in last hour
grep "$(date -d '1 hour ago' '+%Y-%m-%d %H:')" app.log | grep ERROR

# Track request through multiple log files
grep "RequestId:abc123" *.log

# Analyze response times
grep "ResponseTime" app.log | awk '{sum+=$3; count++} END {print "Avg:", sum/count}'
```

#### PowerShell (Windows)
```powershell
# Find errors in Event Log
Get-EventLog -LogName Application -EntryType Error -After (Get-Date).AddHours(-1)

# Search log files
Select-String -Path "*.log" -Pattern "ERROR" | Group-Object Line | Sort-Object Count -Desc

# Monitor real-time logs
Get-Content app.log -Wait -Tail 50
```

### Remote Debugging

#### Safe Production Debugging
```csharp
// Feature flag controlled debugging
if (_featureFlags.IsEnabled("DetailedLogging") && IsAuthorizedUser(userId))
{
    _logger.LogDebug("Detailed debug info: {@DebugData}", debugData);
}

// Time-limited debug logging
if (DateTime.UtcNow < _config.GetValue<DateTime>("Debug:EndTime"))
{
    _logger.LogInformation("Temporary debug: {Info}", debugInfo);
}
```

#### Debug Endpoints (Secure)
```csharp
[ApiController]
[Route("api/debug")]
[Authorize(Roles = "Admin")]
public class DebugController : ControllerBase
{
    [HttpGet("logs")]
    public async Task<IActionResult> GetRecentLogs([FromQuery] int minutes = 60)
    {
        // Return recent logs for authorized users only
    }
    
    [HttpGet("performance")]
    public IActionResult GetPerformanceMetrics()
    {
        // Return current performance data
    }
}
```

---

## 📊 Monitoring and Alerting

### Key Metrics to Monitor

#### Application Metrics
- [ ] **Request rate** (requests per second)
- [ ] **Response time** (95th percentile)
- [ ] **Error rate** (percentage of failed requests)
- [ ] **Throughput** (successful requests per second)

#### System Metrics
- [ ] **CPU utilization** (average and peak)
- [ ] **Memory usage** (working set, private bytes)
- [ ] **Disk I/O** (read/write operations per second)
- [ ] **Network I/O** (bytes sent/received)

#### Business Metrics
- [ ] **User registrations** (per minute/hour)
- [ ] **Order processing** (success rate, processing time)
- [ ] **Payment transactions** (success rate, amounts)
- [ ] **Feature usage** (active users, feature adoption)

### Alert Thresholds

#### Critical Alerts (Immediate Response)
- **Error rate > 5%** in any 5-minute window
- **Response time > 10 seconds** for 95th percentile
- **Health check failures** for critical dependencies
- **CPU usage > 90%** for more than 5 minutes
- **Memory usage > 85%** of available memory
- **Database connection pool exhaustion**

#### Warning Alerts (Monitor Closely)
- **Error rate > 1%** in any 15-minute window
- **Response time > 5 seconds** for 95th percentile
- **CPU usage > 70%** for more than 10 minutes
- **Memory usage > 70%** of available memory
- **Slow query count** exceeding threshold

---

## 🎓 Best Practices Summary

### Development Phase
1. **Build in observability** from the start
2. **Use structured logging** consistently
3. **Implement health checks** for all dependencies
4. **Create diagnostic endpoints** for troubleshooting
5. **Test error scenarios** thoroughly
6. **Document troubleshooting procedures**

### Deployment Phase
1. **Verify monitoring setup** before go-live
2. **Test alert notifications** to ensure they work
3. **Establish baseline metrics** for normal operation
4. **Prepare incident response procedures**
5. **Train team members** on debugging tools and processes

### Operations Phase
1. **Monitor proactively** rather than reactively
2. **Investigate warnings** before they become critical
3. **Maintain debug tooling** and keep it updated
4. **Regular health assessments** of monitoring systems
5. **Post-incident reviews** to improve processes
6. **Knowledge sharing** of debugging techniques and solutions

---

## 📞 Emergency Contacts and Escalation

### Incident Severity Levels

#### Severity 1 (Critical)
- **Definition**: Complete service outage or data loss
- **Response Time**: Immediate (within 15 minutes)
- **Escalation**: On-call engineer → Team lead → Management
- **Communication**: Status page update, customer notification

#### Severity 2 (High)
- **Definition**: Significant feature degradation affecting multiple users
- **Response Time**: Within 1 hour
- **Escalation**: On-call engineer → Team lead (if not resolved in 2 hours)
- **Communication**: Internal stakeholders notification

#### Severity 3 (Medium)
- **Definition**: Minor feature issues or performance degradation
- **Response Time**: Within 4 hours (during business hours)
- **Escalation**: Assigned engineer → Team lead (if needed)
- **Communication**: Track in issue management system

### Contact Information Template
```
On-Call Engineer: [Phone/Slack]
Team Lead: [Phone/Email]
Database Admin: [Phone/Email]
DevOps/Infrastructure: [Phone/Slack]
Product Owner: [Email]
Customer Support: [Phone/Email]

Escalation Chain:
1. On-Call Engineer (0-15 min)
2. Team Lead (15-60 min)
3. Engineering Manager (60-120 min)
4. CTO/VP Engineering (120+ min)
```

---

**🚨 Remember**: In production debugging, speed and accuracy are crucial. Having a well-prepared checklist and following established procedures can mean the difference between a quick resolution and extended downtime. Always prioritize service restoration over root cause analysis during active incidents.
