       public async Task<string> BundleCssAsync(params string[] files)
       {
           var bundledContent = new StringBuilder();
           
           foreach (var file in files)
           {
               var filePath = Path.Combine(_environment.WebRootPath, file.TrimStart('/'));
               
               if (File.Exists(filePath))
               {
                   var content = await File.ReadAllTextAsync(filePath);
                   var minifiedContent = _minificationService.MinifyCss(content);
                   bundledContent.AppendLine(minifiedContent);
               }
           }
           
           return bundledContent.ToString();
       }
       
       public async Task<string> BundleJavaScriptAsync(params string[] files)
       {
           var bundledContent = new StringBuilder();
           
           foreach (var file in files)
           {
               var filePath = Path.Combine(_environment.WebRootPath, file.TrimStart('/'));
               
               if (File.Exists(filePath))
               {
                   var content = await File.ReadAllTextAsync(filePath);
                   var minifiedContent = _minificationService.MinifyJavaScript(content);
                   bundledContent.AppendLine(minifiedContent);
               }
           }
           
           return bundledContent.ToString();
       }
   }
   
   // Bundle controller
   [ApiController]
   [Route("bundles")]
   public class BundleController : ControllerBase
   {
       private readonly IResourceBundler _bundler;
       
       public BundleController(IResourceBundler bundler)
       {
           _bundler = bundler;
       }
       
       [HttpGet("css/{*path}")]
       [ResponseCache(Duration = 31536000)] // Cache for 1 year
       public async Task<IActionResult> GetCssBundle(string path)
       {
           var files = path.Split(',');
           var bundledCss = await _bundler.BundleCssAsync(files);
           
           return Content(bundledCss, "text/css");
       }
       
       [HttpGet("js/{*path}")]
       [ResponseCache(Duration = 31536000)] // Cache for 1 year
       public async Task<IActionResult> GetJavaScriptBundle(string path)
       {
           var files = path.Split(',');
           var bundledJs = await _bundler.BundleJavaScriptAsync(files);
           
           return Content(bundledJs, "application/javascript");
       }
   }
   ```

### 10. Create Performance Testing Controller

1. Create endpoints to test different optimization techniques:
   ```csharp
   [ApiController]
   [Route("api/[controller]")]
   public class PerformanceTestController : ControllerBase
   {
       private readonly ILogger<PerformanceTestController> _logger;
       
       public PerformanceTestController(ILogger<PerformanceTestController> logger)
       {
           _logger = logger;
       }
       
       [HttpGet("large-json")]
       public ActionResult<object> GetLargeJsonResponse()
       {
           // Generate large JSON response for compression testing
           var data = Enumerable.Range(1, 10000).Select(i => new
           {
               Id = i,
               Name = $"Item {i}",
               Description = $"This is a detailed description for item {i} with lots of text to test compression effectiveness.",
               Value = i * 1.5m,
               CreatedAt = DateTime.UtcNow.AddDays(-i),
               Tags = new[] { $"tag{i}", $"category{i % 10}", $"type{i % 5}" },
               Properties = Enumerable.Range(1, 10).ToDictionary(j => $"prop{j}", j => $"value{i}-{j}")
           }).ToArray();
           
           return Ok(data);
       }
       
       [HttpGet("text-content")]
       [ResponseCache(Duration = 300)]
       public ActionResult<string> GetTextContent()
       {
           // Generate large text content
           var content = string.Join(" ", Enumerable.Range(1, 1000)
               .Select(i => $"This is sentence number {i} in a very long text document that contains lots of repetitive content to test text compression algorithms."));
           
           return Content(content, "text/plain");
       }
       
       [HttpGet("no-compression")]
       public ActionResult<object> GetUncompressedResponse()
       {
           Response.Headers.Add("Content-Encoding", "identity");
           
           var data = Enumerable.Range(1, 1000).Select(i => new
           {
               Id = i,
               Data = new string('A', 100) // Large string
           }).ToArray();
           
           return Ok(data);
       }
       
       [HttpGet("with-etag")]
       public ActionResult<object> GetResponseWithETag()
       {
           var data = new { Message = "This response includes ETag for caching", Timestamp = DateTime.UtcNow };
           var etag = $"\"{data.GetHashCode()}\"";
           
           // Check if client has cached version
           if (Request.Headers.IfNoneMatch == etag)
           {
               return StatusCode(304); // Not Modified
           }
           
           Response.Headers.ETag = etag;
           Response.Headers.CacheControl = "public, max-age=300";
           
           return Ok(data);
       }
   }
   ```

### 11. Create Response Size Analyzer

1. Implement middleware to analyze response sizes:
   ```csharp
   public class ResponseSizeAnalyzerMiddleware
   {
       private readonly RequestDelegate _next;
       private readonly ILogger<ResponseSizeAnalyzerMiddleware> _logger;
       
       public ResponseSizeAnalyzerMiddleware(RequestDelegate next, ILogger<ResponseSizeAnalyzerMiddleware> logger)
       {
           _next = next;
           _logger = logger;
       }
       
       public async Task InvokeAsync(HttpContext context)
       {
           var originalBodyStream = context.Response.Body;
           
           using var responseBodyStream = new MemoryStream();
           context.Response.Body = responseBodyStream;
           
           await _next(context);
           
           var responseSize = responseBodyStream.Length;
           var contentEncoding = context.Response.Headers.ContentEncoding.FirstOrDefault();
           var compressionRatio = CalculateCompressionRatio(context, responseSize);
           
           _logger.LogInformation(
               "Response: {Method} {Path} - Size: {Size} bytes, Encoding: {Encoding}, Compression: {Ratio}%",
               context.Request.Method,
               context.Request.Path,
               responseSize,
               contentEncoding ?? "none",
               compressionRatio);
           
           responseBodyStream.Seek(0, SeekOrigin.Begin);
           await responseBodyStream.CopyToAsync(originalBodyStream);
       }
       
       private double CalculateCompressionRatio(HttpContext context, long compressedSize)
       {
           if (context.Items.TryGetValue("OriginalSize", out var originalSizeObj) && 
               originalSizeObj is long originalSize && originalSize > 0)
           {
               return Math.Round((1.0 - (double)compressedSize / originalSize) * 100, 2);
           }
           
           return 0;
       }
   }
   ```

### 12. Configure the Complete Pipeline

1. Put it all together in `Program.cs`:
   ```csharp
   var builder = WebApplication.CreateBuilder(args);
   
   // Add services
   builder.Services.AddControllers();
   builder.Services.AddEndpointsApiExplorer();
   builder.Services.AddSwaggerGen();
   
   // Response optimization services
   builder.Services.AddResponseCompression(options =>
   {
       options.EnableForHttps = true;
       options.Providers.Add<BrotliCompressionProvider>();
       options.Providers.Add<GzipCompressionProvider>();
       options.MimeTypes = ResponseCompressionDefaults.MimeTypes.Concat(new[]
       {
           "application/json",
           "text/plain",
           "text/css",
           "application/javascript",
           "text/html"
       });
   });
   
   // Configure compression levels
   builder.Services.Configure<BrotliCompressionProviderOptions>(options =>
   {
       options.Level = CompressionLevel.Optimal;
   });
   
   builder.Services.Configure<GzipCompressionProviderOptions>(options =>
   {
       options.Level = CompressionLevel.Optimal;
   });
   
   // Register custom services
   builder.Services.AddScoped<IMinificationService, MinificationService>();
   builder.Services.AddScoped<ICdnService, CdnService>();
   builder.Services.AddScoped<IResourceBundler, ResourceBundler>();
   
   var app = builder.Build();
   
   // Configure pipeline
   if (app.Environment.IsDevelopment())
   {
       app.UseSwagger();
       app.UseSwaggerUI();
   }
   
   app.UseHttpsRedirection();
   
   // Response optimization middleware
   app.UseResponseCompression();
   app.UseMiddleware<ResponseSizeAnalyzerMiddleware>();
   app.UseMiddleware<CacheHeadersMiddleware>();
   app.UseMiddleware<OptimizedStaticFileMiddleware>();
   app.UseMiddleware<ProgressiveImageMiddleware>();
   
   app.UseAuthorization();
   app.MapControllers();
   
   app.Run();
   ```

## Expected Output

1. Compressed responses should show significant size reduction (60-90% for text content).
2. Appropriate cache headers should be set based on content type.
3. Static files should be minified and cached with long expiration times.
4. Bundle endpoints should combine and optimize multiple files.

## Bonus Tasks

1. Implement WebP image conversion for supported browsers.
2. Add support for HTTP/2 server push for critical resources.
3. Implement lazy loading for images and other resources.
4. Create a performance dashboard showing compression ratios and cache hit rates.
5. Add support for conditional requests (If-Modified-Since, If-None-Match).

## Testing the Implementation

Use browser developer tools and tools like Lighthouse to test:

1. **Compression Testing**:
   ```bash
   curl -H "Accept-Encoding: gzip, deflate, br" http://localhost:5000/api/performancetest/large-json
   ```

2. **Cache Testing**:
   ```bash
   curl -I http://localhost:5000/api/performancetest/with-etag
   ```

3. **Bundle Testing**:
   ```bash
   curl http://localhost:5000/bundles/css/styles.css,layout.css
   ```

## Submission

Submit your project with all optimization implementations, including before/after performance measurements.

## Evaluation Criteria

- Proper implementation of response compression
- Effective use of HTTP caching headers
- Working minification and bundling
- Measurable performance improvements
- Code quality and organization
- Demonstration of optimization benefits through testing
