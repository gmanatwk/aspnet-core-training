using Asp.Versioning;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using RestfulAPI.Middleware;

namespace RestfulAPI.Controllers
{
    [ApiController]
    [ApiVersion("1.0")]
    [Route("api/v{version:apiVersion}/[controller]")]
    [Authorize(Roles = "Admin")]
    public class AnalyticsController : ControllerBase
    {
        /// <summary>
        /// Get API usage metrics
        /// </summary>
        [HttpGet("metrics")]
        public ActionResult<IEnumerable<ApiMetrics>> GetMetrics()
        {
            var metrics = ApiAnalyticsMiddleware.GetMetrics()
                .Values
                .OrderByDescending(m => m.Count)
                .Take(50);
            
            return Ok(metrics);
        }

        /// <summary>
        /// Get API statistics summary
        /// </summary>
        [HttpGet("summary")]
        public ActionResult<ApiSummary> GetSummary()
        {
            var metrics = ApiAnalyticsMiddleware.GetMetrics().Values;
            
            var summary = new ApiSummary
            {
                TotalRequests = metrics.Sum(m => m.Count),
                UniqueEndpoints = metrics.Select(m => m.Path).Distinct().Count(),
                AverageResponseTime = metrics.Any() 
                    ? metrics.Average(m => m.AverageDuration) 
                    : 0,
                ErrorRate = metrics.Any() 
                    ? (double)metrics.Where(m => m.StatusCode >= 400).Sum(m => m.Count) / metrics.Sum(m => m.Count) * 100 
                    : 0,
                MostUsedEndpoints = metrics
                    .GroupBy(m => m.Path)
                    .Select(g => new EndpointUsage
                    {
                        Path = g.Key,
                        Count = g.Sum(m => m.Count),
                        AverageResponseTime = g.Average(m => m.AverageDuration)
                    })
                    .OrderByDescending(e => e.Count)
                    .Take(10)
                    .ToList()
            };
            
            return Ok(summary);
        }
    }

    public class ApiSummary
    {
        public int TotalRequests { get; set; }
        public int UniqueEndpoints { get; set; }
        public double AverageResponseTime { get; set; }
        public double ErrorRate { get; set; }
        public List<EndpointUsage> MostUsedEndpoints { get; set; } = new();
    }

    public class EndpointUsage
    {
        public string Path { get; set; } = string.Empty;
        public int Count { get; set; }
        public double AverageResponseTime { get; set; }
    }
}