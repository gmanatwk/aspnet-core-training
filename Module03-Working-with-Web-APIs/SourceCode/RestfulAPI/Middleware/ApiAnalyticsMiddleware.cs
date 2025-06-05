using System.Diagnostics;

namespace RestfulAPI.Middleware
{
    public class ApiAnalyticsMiddleware
    {
        private readonly RequestDelegate _next;
        private readonly ILogger<ApiAnalyticsMiddleware> _logger;
        private static readonly Dictionary<string, ApiMetrics> _metrics = new();

        public ApiAnalyticsMiddleware(RequestDelegate next, ILogger<ApiAnalyticsMiddleware> logger)
        {
            _next = next;
            _logger = logger;
        }

        public async Task InvokeAsync(HttpContext context)
        {
            var stopwatch = Stopwatch.StartNew();
            var path = context.Request.Path.Value ?? "";
            
            try
            {
                await _next(context);
            }
            finally
            {
                stopwatch.Stop();
                RecordMetrics(path, context.Response.StatusCode, stopwatch.ElapsedMilliseconds);
            }
        }

        private void RecordMetrics(string path, int statusCode, long elapsedMs)
        {
            var key = $"{path}:{statusCode}";
            
            lock (_metrics)
            {
                if (!_metrics.ContainsKey(key))
                {
                    _metrics[key] = new ApiMetrics { Path = path, StatusCode = statusCode };
                }
                
                var metric = _metrics[key];
                metric.Count++;
                metric.TotalDuration += elapsedMs;
                metric.LastAccessTime = DateTime.UtcNow;
                
                if (elapsedMs > metric.MaxDuration)
                    metric.MaxDuration = elapsedMs;
                
                if (metric.MinDuration == 0 || elapsedMs < metric.MinDuration)
                    metric.MinDuration = elapsedMs;
            }
            
            // Log slow requests
            if (elapsedMs > 1000)
            {
                _logger.LogWarning("Slow API request: {Path} took {ElapsedMs}ms", path, elapsedMs);
            }
        }

        public static Dictionary<string, ApiMetrics> GetMetrics()
        {
            lock (_metrics)
            {
                return new Dictionary<string, ApiMetrics>(_metrics);
            }
        }
    }

    public class ApiMetrics
    {
        public string Path { get; set; } = string.Empty;
        public int StatusCode { get; set; }
        public int Count { get; set; }
        public long TotalDuration { get; set; }
        public long MinDuration { get; set; }
        public long MaxDuration { get; set; }
        public DateTime LastAccessTime { get; set; }
        
        public double AverageDuration => Count > 0 ? (double)TotalDuration / Count : 0;
    }
}