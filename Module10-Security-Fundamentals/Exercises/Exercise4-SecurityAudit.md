# Exercise 4: Security Audit

## 🎯 Objective
Perform a comprehensive security audit of an ASP.NET Core application to identify vulnerabilities and implement remediation strategies.

## ⏱️ Duration
90 minutes

## 📋 Prerequisites
- Completed Exercises 1-3
- .NET 8.0 SDK installed
- Understanding of OWASP Top 10
- Basic knowledge of security scanning tools
- Access to application source code

## 🎓 Learning Outcomes
By completing this exercise, you will:
- ✅ Conduct systematic security assessments
- ✅ Use automated security scanning tools
- ✅ Identify common vulnerabilities
- ✅ Create security remediation plans
- ✅ Implement security monitoring
- ✅ Document security findings

## 📝 Background
Security audits are systematic evaluations of an application's security posture. They help identify vulnerabilities before attackers do and ensure compliance with security standards.

### Audit Categories:
1. **Static Code Analysis** - Analyzing source code for vulnerabilities
2. **Dynamic Testing** - Testing running applications for security issues
3. **Configuration Review** - Examining server and application configurations
4. **Dependency Scanning** - Checking third-party libraries for known vulnerabilities
5. **Penetration Testing** - Simulating real-world attacks

## 🚀 Getting Started

### Step 1: Set Up Security Scanning Tools

Install required security scanning tools:

```bash
# Install OWASP dependency checker
dotnet tool install --global Security-Scan

# Install SonarScanner for .NET
dotnet tool install --global dotnet-sonarscanner

# Install OWASP ZAP (Download from https://zaproxy.org/)
```

### Step 2: Create Sample Vulnerable Application

We'll audit a deliberately vulnerable application to practice identifying security issues.

## 🛠️ Task 1: Static Code Analysis

Perform static analysis to identify code-level vulnerabilities.

### Instructions:

1. **Create SecurityAuditService.cs**:

```csharp
using System.Security.Cryptography;
using System.Text;
using System.Text.RegularExpressions;

namespace SecurityAudit.Services
{
    public class SecurityAuditService
    {
        private readonly List<SecurityFinding> _findings = new();

        public class SecurityFinding
        {
            public string Id { get; set; } = Guid.NewGuid().ToString();
            public string Title { get; set; } = string.Empty;
            public string Description { get; set; } = string.Empty;
            public SecuritySeverity Severity { get; set; }
            public string Category { get; set; } = string.Empty;
            public string FilePath { get; set; } = string.Empty;
            public int LineNumber { get; set; }
            public string CodeSnippet { get; set; } = string.Empty;
            public string Recommendation { get; set; } = string.Empty;
            public DateTime FoundAt { get; set; } = DateTime.UtcNow;
        }

        public enum SecuritySeverity
        {
            Low = 1,
            Medium = 2,
            High = 3,
            Critical = 4
        }

        public async Task<List<SecurityFinding>> PerformCodeAuditAsync(string projectPath)
        {
            _findings.Clear();

            await AnalyzeSourceCodeAsync(projectPath);
            await AnalyzeConfigurationAsync(projectPath);
            await AnalyzeDependenciesAsync(projectPath);

            return _findings.OrderByDescending(f => f.Severity).ToList();
        }

        private async Task AnalyzeSourceCodeAsync(string projectPath)
        {
            var csharpFiles = Directory.GetFiles(projectPath, "*.cs", SearchOption.AllDirectories);

            foreach (var file in csharpFiles)
            {
                var content = await File.ReadAllTextAsync(file);
                var lines = content.Split('\n');

                for (int i = 0; i < lines.Length; i++)
                {
                    var line = lines[i];
                    await AnalyzeCodeLine(file, i + 1, line);
                }
            }
        }

        private async Task AnalyzeCodeLine(string filePath, int lineNumber, string line)
        {
            // Check for hardcoded secrets
            await CheckForHardcodedSecrets(filePath, lineNumber, line);

            // Check for SQL injection vulnerabilities
            await CheckForSqlInjection(filePath, lineNumber, line);

            // Check for XSS vulnerabilities
            await CheckForXssVulnerabilities(filePath, lineNumber, line);

            // Check for insecure cryptography
            await CheckForInsecureCrypto(filePath, lineNumber, line);

            // Check for insecure deserialization
            await CheckForInsecureDeserialization(filePath, lineNumber, line);
        }

        private async Task CheckForHardcodedSecrets(string filePath, int lineNumber, string line)
        {
            var patterns = new Dictionary<string, string>
            {
                { @"password\s*=\s*[""']([^""']{3,})[""']", "Hardcoded Password" },
                { @"connectionstring\s*=\s*[""']([^""']{10,})[""']", "Hardcoded Connection String" },
                { @"apikey\s*=\s*[""']([^""']{10,})[""']", "Hardcoded API Key" },
                { @"secret\s*=\s*[""']([^""']{10,})[""']", "Hardcoded Secret" },
                { @"token\s*=\s*[""']([^""']{10,})[""']", "Hardcoded Token" }
            };

            foreach (var pattern in patterns)
            {
                if (Regex.IsMatch(line, pattern.Key, RegexOptions.IgnoreCase))
                {
                    _findings.Add(new SecurityFinding
                    {
                        Title = pattern.Value + " Detected",
                        Description = $"Hardcoded secret found in source code: {pattern.Value}",
                        Severity = SecuritySeverity.High,
                        Category = "Cryptographic Failures",
                        FilePath = filePath,
                        LineNumber = lineNumber,
                        CodeSnippet = line.Trim(),
                        Recommendation = "Move secrets to secure configuration (Azure Key Vault, User Secrets, Environment Variables)"
                    });
                }
            }
        }

        private async Task CheckForSqlInjection(string filePath, int lineNumber, string line)
        {
            var patterns = new[]
            {
                @"new\s+SqlCommand\s*\(\s*[""'].*?\+.*?[""']",
                @"CommandText\s*=\s*[""'].*?\+.*?[""']",
                @"ExecuteReader\s*\(\s*[""'].*?\+.*?[""']",
                @"ExecuteScalar\s*\(\s*[""'].*?\+.*?[""']"
            };

            foreach (var pattern in patterns)
            {
                if (Regex.IsMatch(line, pattern, RegexOptions.IgnoreCase))
                {
                    _findings.Add(new SecurityFinding
                    {
                        Title = "Potential SQL Injection Vulnerability",
                        Description = "SQL query appears to use string concatenation which may lead to SQL injection",
                        Severity = SecuritySeverity.Critical,
                        Category = "Injection",
                        FilePath = filePath,
                        LineNumber = lineNumber,
                        CodeSnippet = line.Trim(),
                        Recommendation = "Use parameterized queries or Entity Framework to prevent SQL injection"
                    });
                }
            }
        }

        private async Task CheckForXssVulnerabilities(string filePath, int lineNumber, string line)
        {
            var patterns = new[]
            {
                @"Html\.Raw\s*\(",
                @"@Html\.Raw\s*\(",
                @"Response\.Write\s*\(",
                @"innerHTML\s*=",
                @"document\.write\s*\("
            };

            foreach (var pattern in patterns)
            {
                if (Regex.IsMatch(line, pattern, RegexOptions.IgnoreCase))
                {
                    _findings.Add(new SecurityFinding
                    {
                        Title = "Potential XSS Vulnerability",
                        Description = "Code may output user input without proper encoding",
                        Severity = SecuritySeverity.High,
                        Category = "Cross-Site Scripting",
                        FilePath = filePath,
                        LineNumber = lineNumber,
                        CodeSnippet = line.Trim(),
                        Recommendation = "Use proper output encoding (Html.Encode, @Html.Display) or HTML sanitization"
                    });
                }
            }
        }

        private async Task CheckForInsecureCrypto(string filePath, int lineNumber, string line)
        {
            var patterns = new Dictionary<string, string>
            {
                { @"new\s+MD5CryptoServiceProvider", "MD5 is cryptographically broken" },
                { @"new\s+SHA1CryptoServiceProvider", "SHA1 is cryptographically weak" },
                { @"DESCryptoServiceProvider", "DES is cryptographically broken" },
                { @"RC2CryptoServiceProvider", "RC2 is cryptographically weak" },
                { @"ECBMode", "ECB mode is insecure" }
            };

            foreach (var pattern in patterns)
            {
                if (Regex.IsMatch(line, pattern.Key, RegexOptions.IgnoreCase))
                {
                    _findings.Add(new SecurityFinding
                    {
                        Title = "Insecure Cryptographic Algorithm",
                        Description = pattern.Value,
                        Severity = SecuritySeverity.High,
                        Category = "Cryptographic Failures",
                        FilePath = filePath,
                        LineNumber = lineNumber,
                        CodeSnippet = line.Trim(),
                        Recommendation = "Use secure algorithms: AES-256 with GCM mode, SHA-256 or higher, RSA-2048 or higher"
                    });
                }
            }
        }

        private async Task CheckForInsecureDeserialization(string filePath, int lineNumber, string line)
        {
            var patterns = new[]
            {
                @"BinaryFormatter\s*\(\s*\)\.Deserialize",
                @"JavaScriptSerializer\s*\(\s*\)\.Deserialize",
                @"JsonConvert\.DeserializeObject\s*<\s*object\s*>",
                @"XmlSerializer\s*\(\s*typeof\s*\(\s*object\s*\)\s*\)"
            };

            foreach (var pattern in patterns)
            {
                if (Regex.IsMatch(line, pattern, RegexOptions.IgnoreCase))
                {
                    _findings.Add(new SecurityFinding
                    {
                        Title = "Potential Insecure Deserialization",
                        Description = "Deserializing untrusted data can lead to remote code execution",
                        Severity = SecuritySeverity.Critical,
                        Category = "Insecure Deserialization",
                        FilePath = filePath,
                        LineNumber = lineNumber,
                        CodeSnippet = line.Trim(),
                        Recommendation = "Validate input, use safe serializers, implement type binding"
                    });
                }
            }
        }

        private async Task AnalyzeConfigurationAsync(string projectPath)
        {
            // Check appsettings.json files
            var configFiles = Directory.GetFiles(projectPath, "appsettings*.json", SearchOption.AllDirectories);

            foreach (var configFile in configFiles)
            {
                var content = await File.ReadAllTextAsync(configFile);
                await AnalyzeConfiguration(configFile, content);
            }

            // Check web.config files
            var webConfigFiles = Directory.GetFiles(projectPath, "web.config", SearchOption.AllDirectories);

            foreach (var webConfigFile in webConfigFiles)
            {
                var content = await File.ReadAllTextAsync(webConfigFile);
                await AnalyzeWebConfig(webConfigFile, content);
            }
        }

        private async Task AnalyzeConfiguration(string filePath, string content)
        {
            // Check for exposed connection strings
            if (content.Contains("ConnectionStrings") && content.Contains("Password="))
            {
                _findings.Add(new SecurityFinding
                {
                    Title = "Connection String with Password in Configuration",
                    Description = "Database password is stored in plain text in configuration file",
                    Severity = SecuritySeverity.High,
                    Category = "Cryptographic Failures",
                    FilePath = filePath,
                    LineNumber = 0,
                    CodeSnippet = "ConnectionStrings section contains passwords",
                    Recommendation = "Use Windows Authentication, Azure Managed Identity, or Azure Key Vault"
                });
            }

            // Check for debug mode
            if (content.Contains("\"Development\"") || content.Contains("\"Debug\""))
            {
                _findings.Add(new SecurityFinding
                {
                    Title = "Debug Mode Enabled",
                    Description = "Application may be running in debug mode which can expose sensitive information",
                    Severity = SecuritySeverity.Medium,
                    Category = "Security Misconfiguration",
                    FilePath = filePath,
                    LineNumber = 0,
                    CodeSnippet = "Environment set to Development/Debug",
                    Recommendation = "Ensure production environment uses 'Production' setting"
                });
            }
        }

        private async Task AnalyzeWebConfig(string filePath, string content)
        {
            // Check for debug compilation
            if (content.Contains("debug=\"true\""))
            {
                _findings.Add(new SecurityFinding
                {
                    Title = "Debug Compilation Enabled",
                    Description = "Debug compilation is enabled which can expose sensitive information",
                    Severity = SecuritySeverity.Medium,
                    Category = "Security Misconfiguration",
                    FilePath = filePath,
                    LineNumber = 0,
                    CodeSnippet = "debug=\"true\"",
                    Recommendation = "Set debug=\"false\" in production"
                });
            }

            // Check for custom errors disabled
            if (content.Contains("customErrors mode=\"Off\""))
            {
                _findings.Add(new SecurityFinding
                {
                    Title = "Custom Errors Disabled",
                    Description = "Detailed error messages may be exposed to users",
                    Severity = SecuritySeverity.Medium,
                    Category = "Security Misconfiguration",
                    FilePath = filePath,
                    LineNumber = 0,
                    CodeSnippet = "customErrors mode=\"Off\"",
                    Recommendation = "Enable custom errors in production"
                });
            }
        }

        private async Task AnalyzeDependenciesAsync(string projectPath)
        {
            var projectFiles = Directory.GetFiles(projectPath, "*.csproj", SearchOption.AllDirectories);

            foreach (var projectFile in projectFiles)
            {
                var content = await File.ReadAllTextAsync(projectFile);
                await AnalyzeProjectDependencies(projectFile, content);
            }
        }

        private async Task AnalyzeProjectDependencies(string filePath, string content)
        {
            // This is a simplified check - in practice, you'd use tools like
            // OWASP Dependency Check or Snyk to check for known vulnerabilities

            var knownVulnerablePackages = new Dictionary<string, string>
            {
                { "Newtonsoft.Json", "Known deserialization vulnerabilities in older versions" },
                { "System.Net.Http", "Potential SSL/TLS issues in older versions" },
                { "Microsoft.AspNetCore.Mvc", "Various security fixes in newer versions" }
            };

            foreach (var package in knownVulnerablePackages)
            {
                if (content.Contains($"PackageReference Include=\"{package.Key}\""))
                {
                    _findings.Add(new SecurityFinding
                    {
                        Title = $"Potentially Vulnerable Package: {package.Key}",
                        Description = package.Value,
                        Severity = SecuritySeverity.Medium,
                        Category = "Vulnerable and Outdated Components",
                        FilePath = filePath,
                        LineNumber = 0,
                        CodeSnippet = $"Package: {package.Key}",
                        Recommendation = "Update to latest stable version and review security advisories"
                    });
                }
            }
        }
    }
}
```

## 🛠️ Task 2: Dynamic Security Testing

Create automated tests to check runtime security issues.

### Instructions:

1. **Create SecurityTestService.cs**:

```csharp
using Microsoft.AspNetCore.Mvc.Testing;
using System.Net.Http;
using System.Text;

namespace SecurityAudit.Testing
{
    public class SecurityTestService
    {
        private readonly HttpClient _httpClient;
        private readonly List<SecurityTestResult> _results = new();

        public class SecurityTestResult
        {
            public string TestName { get; set; } = string.Empty;
            public bool Passed { get; set; }
            public string Description { get; set; } = string.Empty;
            public string Details { get; set; } = string.Empty;
            public SecuritySeverity Severity { get; set; }
        }

        public enum SecuritySeverity
        {
            Low = 1,
            Medium = 2,
            High = 3,
            Critical = 4
        }

        public SecurityTestService(HttpClient httpClient)
        {
            _httpClient = httpClient;
        }

        public async Task<List<SecurityTestResult>> RunSecurityTestsAsync()
        {
            _results.Clear();

            await TestSecurityHeaders();
            await TestHttpsRedirection();
            await TestXssProtection();
            await TestSqlInjection();
            await TestCsrfProtection();
            await TestFileUploadSecurity();
            await TestAuthenticationBypass();

            return _results;
        }

        private async Task TestSecurityHeaders()
        {
            try
            {
                var response = await _httpClient.GetAsync("/");
                var headers = response.Headers;

                // Test X-Content-Type-Options
                TestHeader("X-Content-Type-Options", headers.Contains("X-Content-Type-Options"), 
                    "Prevents MIME type confusion attacks", SecuritySeverity.Medium);

                // Test X-Frame-Options
                TestHeader("X-Frame-Options", headers.Contains("X-Frame-Options"), 
                    "Prevents clickjacking attacks", SecuritySeverity.Medium);

                // Test X-XSS-Protection
                TestHeader("X-XSS-Protection", headers.Contains("X-XSS-Protection"), 
                    "Enables browser XSS filtering", SecuritySeverity.Medium);

                // Test Strict-Transport-Security
                TestHeader("Strict-Transport-Security", headers.Contains("Strict-Transport-Security"), 
                    "Enforces HTTPS connections", SecuritySeverity.High);

                // Test Content-Security-Policy
                TestHeader("Content-Security-Policy", headers.Contains("Content-Security-Policy"), 
                    "Prevents XSS and data injection attacks", SecuritySeverity.High);
            }
            catch (Exception ex)
            {
                _results.Add(new SecurityTestResult
                {
                    TestName = "Security Headers Test",
                    Passed = false,
                    Description = "Failed to test security headers",
                    Details = ex.Message,
                    Severity = SecuritySeverity.High
                });
            }
        }

        private void TestHeader(string headerName, bool isPresent, string description, SecuritySeverity severity)
        {
            _results.Add(new SecurityTestResult
            {
                TestName = $"{headerName} Header",
                Passed = isPresent,
                Description = description,
                Details = isPresent ? "Header is present" : "Header is missing",
                Severity = isPresent ? SecuritySeverity.Low : severity
            });
        }

        private async Task TestHttpsRedirection()
        {
            try
            {
                // Test if HTTP redirects to HTTPS
                var httpClient = new HttpClient(new HttpClientHandler
                {
                    AllowAutoRedirect = false
                });

                var response = await httpClient.GetAsync("http://localhost/");
                var redirectsToHttps = response.StatusCode == System.Net.HttpStatusCode.Redirect &&
                                     response.Headers.Location?.Scheme == "https";

                _results.Add(new SecurityTestResult
                {
                    TestName = "HTTPS Redirection",
                    Passed = redirectsToHttps,
                    Description = "HTTP requests should redirect to HTTPS",
                    Details = redirectsToHttps ? "HTTP redirects to HTTPS" : "HTTP does not redirect to HTTPS",
                    Severity = redirectsToHttps ? SecuritySeverity.Low : SecuritySeverity.High
                });
            }
            catch (Exception ex)
            {
                _results.Add(new SecurityTestResult
                {
                    TestName = "HTTPS Redirection",
                    Passed = false,
                    Description = "Failed to test HTTPS redirection",
                    Details = ex.Message,
                    Severity = SecuritySeverity.Medium
                });
            }
        }

        private async Task TestXssProtection()
        {
            try
            {
                var xssPayloads = new[]
                {
                    "<script>alert('XSS')</script>",
                    "javascript:alert('XSS')",
                    "<img src='x' onerror='alert(\"XSS\")'>",
                    "'\"><script>alert('XSS')</script>"
                };

                bool allProtected = true;
                var details = new StringBuilder();

                foreach (var payload in xssPayloads)
                {
                    var response = await _httpClient.GetAsync($"/search?q={Uri.EscapeDataString(payload)}");
                    var content = await response.Content.ReadAsStringAsync();

                    if (content.Contains(payload))
                    {
                        allProtected = false;
                        details.AppendLine($"XSS payload reflected: {payload}");
                    }
                }

                _results.Add(new SecurityTestResult
                {
                    TestName = "XSS Protection",
                    Passed = allProtected,
                    Description = "Application should protect against XSS attacks",
                    Details = allProtected ? "No XSS vulnerabilities found" : details.ToString(),
                    Severity = allProtected ? SecuritySeverity.Low : SecuritySeverity.Critical
                });
            }
            catch (Exception ex)
            {
                _results.Add(new SecurityTestResult
                {
                    TestName = "XSS Protection",
                    Passed = false,
                    Description = "Failed to test XSS protection",
                    Details = ex.Message,
                    Severity = SecuritySeverity.Medium
                });
            }
        }

        private async Task TestSqlInjection()
        {
            try
            {
                var sqlInjectionPayloads = new[]
                {
                    "'; DROP TABLE Users; --",
                    "' OR '1'='1",
                    "1'; UPDATE Users SET Password='hacked'; --",
                    "' UNION SELECT * FROM Users --"
                };

                bool allProtected = true;
                var details = new StringBuilder();

                foreach (var payload in sqlInjectionPayloads)
                {
                    var response = await _httpClient.GetAsync($"/user/{Uri.EscapeDataString(payload)}");
                    
                    // Check for SQL error messages
                    var content = await response.Content.ReadAsStringAsync();
                    if (content.Contains("SQL") || content.Contains("syntax error") || 
                        content.Contains("OleDb") || content.Contains("SqlException"))
                    {
                        allProtected = false;
                        details.AppendLine($"SQL error exposed for payload: {payload}");
                    }
                }

                _results.Add(new SecurityTestResult
                {
                    TestName = "SQL Injection Protection",
                    Passed = allProtected,
                    Description = "Application should protect against SQL injection",
                    Details = allProtected ? "No SQL injection vulnerabilities found" : details.ToString(),
                    Severity = allProtected ? SecuritySeverity.Low : SecuritySeverity.Critical
                });
            }
            catch (Exception ex)
            {
                _results.Add(new SecurityTestResult
                {
                    TestName = "SQL Injection Protection",
                    Passed = false,
                    Description = "Failed to test SQL injection protection",
                    Details = ex.Message,
                    Severity = SecuritySeverity.Medium
                });
            }
        }

        private async Task TestCsrfProtection()
        {
            try
            {
                // Test if forms include anti-forgery tokens
                var response = await _httpClient.GetAsync("/Account/Login");
                var content = await response.Content.ReadAsStringAsync();

                var hasAntiForgeryToken = content.Contains("__RequestVerificationToken") ||
                                        content.Contains("data-antiforgery");

                _results.Add(new SecurityTestResult
                {
                    TestName = "CSRF Protection",
                    Passed = hasAntiForgeryToken,
                    Description = "Forms should include anti-forgery tokens",
                    Details = hasAntiForgeryToken ? "Anti-forgery tokens found" : "Anti-forgery tokens missing",
                    Severity = hasAntiForgeryToken ? SecuritySeverity.Low : SecuritySeverity.High
                });
            }
            catch (Exception ex)
            {
                _results.Add(new SecurityTestResult
                {
                    TestName = "CSRF Protection",
                    Passed = false,
                    Description = "Failed to test CSRF protection",
                    Details = ex.Message,
                    Severity = SecuritySeverity.Medium
                });
            }
        }

        private async Task TestFileUploadSecurity()
        {
            try
            {
                // Test file upload with dangerous file types
                var dangerousFiles = new[]
                {
                    ("test.exe", "application/x-msdownload"),
                    ("test.bat", "application/x-bat"),
                    ("test.asp", "application/x-asp"),
                    ("test.php", "application/x-php")
                };

                bool allBlocked = true;
                var details = new StringBuilder();

                foreach (var (fileName, contentType) in dangerousFiles)
                {
                    var content = new MultipartFormDataContent();
                    var fileContent = new ByteArrayContent(Encoding.UTF8.GetBytes("test content"));
                    fileContent.Headers.ContentType = new System.Net.Http.Headers.MediaTypeHeaderValue(contentType);
                    content.Add(fileContent, "file", fileName);

                    var response = await _httpClient.PostAsync("/upload", content);
                    
                    if (response.IsSuccessStatusCode)
                    {
                        allBlocked = false;
                        details.AppendLine($"Dangerous file type allowed: {fileName}");
                    }
                }

                _results.Add(new SecurityTestResult
                {
                    TestName = "File Upload Security",
                    Passed = allBlocked,
                    Description = "Application should block dangerous file types",
                    Details = allBlocked ? "All dangerous file types blocked" : details.ToString(),
                    Severity = allBlocked ? SecuritySeverity.Low : SecuritySeverity.High
                });
            }
            catch (Exception ex)
            {
                _results.Add(new SecurityTestResult
                {
                    TestName = "File Upload Security",
                    Passed = false,
                    Description = "Failed to test file upload security",
                    Details = ex.Message,
                    Severity = SecuritySeverity.Medium
                });
            }
        }

        private async Task TestAuthenticationBypass()
        {
            try
            {
                // Test access to protected resources without authentication
                var protectedEndpoints = new[]
                {
                    "/Admin",
                    "/User/Profile",
                    "/Account/Settings",
                    "/API/Users"
                };

                bool allProtected = true;
                var details = new StringBuilder();

                foreach (var endpoint in protectedEndpoints)
                {
                    var response = await _httpClient.GetAsync(endpoint);
                    
                    if (response.IsSuccessStatusCode)
                    {
                        allProtected = false;
                        details.AppendLine($"Protected endpoint accessible without authentication: {endpoint}");
                    }
                }

                _results.Add(new SecurityTestResult
                {
                    TestName = "Authentication Bypass",
                    Passed = allProtected,
                    Description = "Protected resources should require authentication",
                    Details = allProtected ? "All protected endpoints require authentication" : details.ToString(),
                    Severity = allProtected ? SecuritySeverity.Low : SecuritySeverity.Critical
                });
            }
            catch (Exception ex)
            {
                _results.Add(new SecurityTestResult
                {
                    TestName = "Authentication Bypass",
                    Passed = false,
                    Description = "Failed to test authentication bypass",
                    Details = ex.Message,
                    Severity = SecuritySeverity.Medium
                });
            }
        }
    }
}
```

## 🛠️ Task 3: Create Security Audit Report

Generate comprehensive security audit reports.

### Instructions:

1. **Create SecurityReportGenerator.cs**:

```csharp
using System.Text.Json;

namespace SecurityAudit.Reporting
{
    public class SecurityReportGenerator
    {
        public class SecurityAuditReport
        {
            public string ProjectName { get; set; } = string.Empty;
            public DateTime AuditDate { get; set; } = DateTime.UtcNow;
            public string AuditorName { get; set; } = string.Empty;
            public SecuritySummary Summary { get; set; } = new();
            public List<SecurityFinding> StaticAnalysisFindings { get; set; } = new();
            public List<SecurityTestResult> DynamicTestResults { get; set; } = new();
            public List<Recommendation> Recommendations { get; set; } = new();
            public ComplianceStatus ComplianceStatus { get; set; } = new();
        }

        public class SecuritySummary
        {
            public int TotalFindings { get; set; }
            public int CriticalFindings { get; set; }
            public int HighFindings { get; set; }
            public int MediumFindings { get; set; }
            public int LowFindings { get; set; }
            public double OverallSecurityScore { get; set; }
            public string RiskLevel { get; set; } = string.Empty;
        }

        public class Recommendation
        {
            public string Title { get; set; } = string.Empty;
            public string Description { get; set; } = string.Empty;
            public string Priority { get; set; } = string.Empty;
            public string EstimatedEffort { get; set; } = string.Empty;
            public List<string> Steps { get; set; } = new();
        }

        public class ComplianceStatus
        {
            public bool OwaspCompliant { get; set; }
            public bool PciDssCompliant { get; set; }
            public bool GdprCompliant { get; set; }
            public bool Iso27001Compliant { get; set; }
            public List<string> ComplianceGaps { get; set; } = new();
        }

        public async Task<SecurityAuditReport> GenerateReportAsync(
            string projectName,
            List<SecurityAuditService.SecurityFinding> staticFindings,
            List<SecurityTestService.SecurityTestResult> dynamicResults)
        {
            var report = new SecurityAuditReport
            {
                ProjectName = projectName,
                AuditDate = DateTime.UtcNow,
                AuditorName = "Security Audit Tool",
                StaticAnalysisFindings = staticFindings,
                DynamicTestResults = dynamicResults
            };

            // Generate summary
            report.Summary = GenerateSummary(staticFindings, dynamicResults);

            // Generate recommendations
            report.Recommendations = GenerateRecommendations(staticFindings, dynamicResults);

            // Assess compliance
            report.ComplianceStatus = AssessCompliance(staticFindings, dynamicResults);

            return report;
        }

        private SecuritySummary GenerateSummary(
            List<SecurityAuditService.SecurityFinding> staticFindings,
            List<SecurityTestService.SecurityTestResult> dynamicResults)
        {
            var allFindings = staticFindings.Count + dynamicResults.Count(r => !r.Passed);

            var summary = new SecuritySummary
            {
                TotalFindings = allFindings,
                CriticalFindings = staticFindings.Count(f => f.Severity == SecurityAuditService.SecuritySeverity.Critical) +
                                 dynamicResults.Count(r => !r.Passed && r.Severity == SecurityTestService.SecuritySeverity.Critical),
                HighFindings = staticFindings.Count(f => f.Severity == SecurityAuditService.SecuritySeverity.High) +
                             dynamicResults.Count(r => !r.Passed && r.Severity == SecurityTestService.SecuritySeverity.High),
                MediumFindings = staticFindings.Count(f => f.Severity == SecurityAuditService.SecuritySeverity.Medium) +
                               dynamicResults.Count(r => !r.Passed && r.Severity == SecurityTestService.SecuritySeverity.Medium),
                LowFindings = staticFindings.Count(f => f.Severity == SecurityAuditService.SecuritySeverity.Low) +
                            dynamicResults.Count(r => !r.Passed && r.Severity == SecurityTestService.SecuritySeverity.Low)
            };

            // Calculate security score (0-100)
            var maxPossibleScore = 100.0;
            var deductions = (summary.CriticalFindings * 25) + (summary.HighFindings * 15) + 
                           (summary.MediumFindings * 5) + (summary.LowFindings * 1);
            
            summary.OverallSecurityScore = Math.Max(0, maxPossibleScore - deductions);

            // Determine risk level
            summary.RiskLevel = summary.OverallSecurityScore switch
            {
                >= 90 => "Low",
                >= 70 => "Medium",
                >= 50 => "High",
                _ => "Critical"
            };

            return summary;
        }

        private List<Recommendation> GenerateRecommendations(
            List<SecurityAuditService.SecurityFinding> staticFindings,
            List<SecurityTestService.SecurityTestResult> dynamicResults)
        {
            var recommendations = new List<Recommendation>();

            // Group findings by category
            var categories = staticFindings.GroupBy(f => f.Category).ToList();

            foreach (var category in categories)
            {
                var categoryFindings = category.ToList();
                var highestSeverity = categoryFindings.Max(f => f.Severity);

                var recommendation = new Recommendation
                {
                    Title = $"Address {category.Key} Issues",
                    Description = $"Found {categoryFindings.Count} issues in {category.Key} category",
                    Priority = highestSeverity.ToString(),
                    EstimatedEffort = EstimateEffort(categoryFindings.Count, highestSeverity),
                    Steps = GenerateStepsForCategory(category.Key, categoryFindings)
                };

                recommendations.Add(recommendation);
            }

            return recommendations.OrderByDescending(r => r.Priority).ToList();
        }

        private string EstimateEffort(int findingsCount, SecurityAuditService.SecuritySeverity severity)
        {
            var baseHours = severity switch
            {
                SecurityAuditService.SecuritySeverity.Critical => 8,
                SecurityAuditService.SecuritySeverity.High => 4,
                SecurityAuditService.SecuritySeverity.Medium => 2,
                SecurityAuditService.SecuritySeverity.Low => 1,
                _ => 1
            };

            var totalHours = baseHours * findingsCount;
            return totalHours switch
            {
                <= 8 => "Small (1 day)",
                <= 24 => "Medium (1-3 days)",
                <= 40 => "Large (1 week)",
                _ => "Extra Large (2+ weeks)"
            };
        }

        private List<string> GenerateStepsForCategory(string category, List<SecurityAuditService.SecurityFinding> findings)
        {
            return category switch
            {
                "Injection" => new List<string>
                {
                    "Review all database queries and use parameterized queries",
                    "Implement input validation for all user inputs",
                    "Use ORM frameworks like Entity Framework",
                    "Implement output encoding"
                },
                "Cryptographic Failures" => new List<string>
                {
                    "Move secrets to Azure Key Vault or secure configuration",
                    "Update cryptographic algorithms to current standards",
                    "Implement proper key management",
                    "Use TLS 1.2 or higher for all communications"
                },
                "Cross-Site Scripting" => new List<string>
                {
                    "Implement output encoding for all user-generated content",
                    "Use Content Security Policy (CSP)",
                    "Validate and sanitize all user inputs",
                    "Use safe DOM manipulation methods"
                },
                "Security Misconfiguration" => new List<string>
                {
                    "Review and harden server configurations",
                    "Disable debug mode in production",
                    "Implement proper error handling",
                    "Configure security headers"
                },
                _ => new List<string>
                {
                    "Review findings and implement appropriate fixes",
                    "Follow OWASP guidelines for remediation",
                    "Test fixes thoroughly",
                    "Document changes for audit trail"
                }
            };
        }

        private ComplianceStatus AssessCompliance(
            List<SecurityAuditService.SecurityFinding> staticFindings,
            List<SecurityTestService.SecurityTestResult> dynamicResults)
        {
            var compliance = new ComplianceStatus();
            var gaps = new List<string>();

            // OWASP Top 10 compliance check
            var owaspCategories = new[]
            {
                "Broken Access Control", "Cryptographic Failures", "Injection",
                "Insecure Design", "Security Misconfiguration",
                "Vulnerable and Outdated Components", "Identification and Authentication Failures",
                "Software and Data Integrity Failures", "Security Logging and Monitoring Failures",
                "Server-Side Request Forgery"
            };

            var foundCategories = staticFindings.Select(f => f.Category).Distinct().ToList();
            var missingOwaspControls = owaspCategories.Except(foundCategories).ToList();

            compliance.OwaspCompliant = !staticFindings.Any(f => f.Severity >= SecurityAuditService.SecuritySeverity.High);
            if (!compliance.OwaspCompliant)
            {
                gaps.Add("High or Critical OWASP Top 10 vulnerabilities found");
            }

            // Basic compliance checks
            compliance.PciDssCompliant = !staticFindings.Any(f => f.Category == "Cryptographic Failures" && 
                                                                f.Severity >= SecurityAuditService.SecuritySeverity.High);
            if (!compliance.PciDssCompliant)
            {
                gaps.Add("Cryptographic failures that violate PCI DSS requirements");
            }

            compliance.GdprCompliant = !staticFindings.Any(f => f.Description.Contains("personal data") ||
                                                              f.Description.Contains("PII"));
            if (!compliance.GdprCompliant)
            {
                gaps.Add("Personal data handling issues that may violate GDPR");
            }

            compliance.Iso27001Compliant = staticFindings.Count(f => f.Severity >= SecurityAuditService.SecuritySeverity.Medium) < 5;
            if (!compliance.Iso27001Compliant)
            {
                gaps.Add("Too many medium+ severity findings for ISO 27001 compliance");
            }

            compliance.ComplianceGaps = gaps;

            return compliance;
        }

        public async Task SaveReportAsync(SecurityAuditReport report, string outputPath)
        {
            // Save as JSON
            var jsonOptions = new JsonSerializerOptions
            {
                WriteIndented = true,
                PropertyNamingPolicy = JsonNamingPolicy.CamelCase
            };

            var jsonReport = JsonSerializer.Serialize(report, jsonOptions);
            await File.WriteAllTextAsync(Path.Combine(outputPath, "security-audit-report.json"), jsonReport);

            // Save as HTML
            var htmlReport = GenerateHtmlReport(report);
            await File.WriteAllTextAsync(Path.Combine(outputPath, "security-audit-report.html"), htmlReport);

            // Save as CSV for Excel
            var csvReport = GenerateCsvReport(report);
            await File.WriteAllTextAsync(Path.Combine(outputPath, "security-audit-findings.csv"), csvReport);
        }

        private string GenerateHtmlReport(SecurityAuditReport report)
        {
            var html = $@"
<!DOCTYPE html>
<html>
<head>
    <title>Security Audit Report - {report.ProjectName}</title>
    <style>
        body {{ font-family: Arial, sans-serif; margin: 20px; }}
        .header {{ background-color: #f4f4f4; padding: 20px; border-radius: 5px; }}
        .summary {{ background-color: #e8f5e8; padding: 15px; margin: 20px 0; border-radius: 5px; }}
        .critical {{ color: #d32f2f; }}
        .high {{ color: #f57c00; }}
        .medium {{ color: #fbc02d; }}
        .low {{ color: #388e3c; }}
        table {{ width: 100%; border-collapse: collapse; margin: 20px 0; }}
        th, td {{ border: 1px solid #ddd; padding: 8px; text-align: left; }}
        th {{ background-color: #f2f2f2; }}
        .finding {{ margin: 10px 0; padding: 10px; border-left: 4px solid #ccc; }}
    </style>
</head>
<body>
    <div class='header'>
        <h1>Security Audit Report</h1>
        <p><strong>Project:</strong> {report.ProjectName}</p>
        <p><strong>Audit Date:</strong> {report.AuditDate:yyyy-MM-dd HH:mm}</p>
        <p><strong>Auditor:</strong> {report.AuditorName}</p>
    </div>

    <div class='summary'>
        <h2>Executive Summary</h2>
        <p><strong>Overall Security Score:</strong> {report.Summary.OverallSecurityScore:F1}/100</p>
        <p><strong>Risk Level:</strong> {report.Summary.RiskLevel}</p>
        <p><strong>Total Findings:</strong> {report.Summary.TotalFindings}</p>
        <ul>
            <li class='critical'>Critical: {report.Summary.CriticalFindings}</li>
            <li class='high'>High: {report.Summary.HighFindings}</li>
            <li class='medium'>Medium: {report.Summary.MediumFindings}</li>
            <li class='low'>Low: {report.Summary.LowFindings}</li>
        </ul>
    </div>

    <h2>Static Analysis Findings</h2>
    {string.Join("", report.StaticAnalysisFindings.Select(f => $@"
    <div class='finding'>
        <h4 class='{f.Severity.ToString().ToLower()}'>{f.Title}</h4>
        <p><strong>Description:</strong> {f.Description}</p>
        <p><strong>File:</strong> {f.FilePath}:{f.LineNumber}</p>
        <p><strong>Code:</strong> <code>{f.CodeSnippet}</code></p>
        <p><strong>Recommendation:</strong> {f.Recommendation}</p>
    </div>"))}

    <h2>Dynamic Test Results</h2>
    <table>
        <tr>
            <th>Test Name</th>
            <th>Status</th>
            <th>Description</th>
            <th>Details</th>
        </tr>
        {string.Join("", report.DynamicTestResults.Select(r => $@"
        <tr>
            <td>{r.TestName}</td>
            <td class='{(r.Passed ? "low" : r.Severity.ToString().ToLower())}'>{(r.Passed ? "PASS" : "FAIL")}</td>
            <td>{r.Description}</td>
            <td>{r.Details}</td>
        </tr>"))}
    </table>

    <h2>Recommendations</h2>
    {string.Join("", report.Recommendations.Select(r => $@"
    <div class='finding'>
        <h4>{r.Title} (Priority: {r.Priority})</h4>
        <p><strong>Description:</strong> {r.Description}</p>
        <p><strong>Estimated Effort:</strong> {r.EstimatedEffort}</p>
        <p><strong>Steps:</strong></p>
        <ul>
            {string.Join("", r.Steps.Select(s => $"<li>{s}</li>"))}
        </ul>
    </div>"))}

</body>
</html>";

            return html;
        }

        private string GenerateCsvReport(SecurityAuditReport report)
        {
            var csv = new StringBuilder();
            csv.AppendLine("Type,Title,Severity,Category,File,Line,Description,Recommendation");

            foreach (var finding in report.StaticAnalysisFindings)
            {
                csv.AppendLine($"Static,\"{finding.Title}\",{finding.Severity},\"{finding.Category}\",\"{finding.FilePath}\",{finding.LineNumber},\"{finding.Description}\",\"{finding.Recommendation}\"");
            }

            foreach (var result in report.DynamicTestResults.Where(r => !r.Passed))
            {
                csv.AppendLine($"Dynamic,\"{result.TestName}\",{result.Severity},\"Runtime Test\",\"\",0,\"{result.Description}\",\"{result.Details}\"");
            }

            return csv.ToString();
        }
    }
}
```

## ✅ Running the Complete Security Audit

Create a controller to orchestrate the complete audit:

```csharp
[ApiController]
[Route("api/[controller]")]
public class SecurityAuditController : ControllerBase
{
    private readonly SecurityAuditService _auditService;
    private readonly SecurityTestService _testService;
    private readonly SecurityReportGenerator _reportGenerator;

    public SecurityAuditController(
        SecurityAuditService auditService,
        SecurityTestService testService,
        SecurityReportGenerator reportGenerator)
    {
        _auditService = auditService;
        _testService = testService;
        _reportGenerator = reportGenerator;
    }

    [HttpPost("run-audit")]
    public async Task<IActionResult> RunCompleteAudit([FromBody] AuditRequest request)
    {
        try
        {
            // Run static analysis
            var staticFindings = await _auditService.PerformCodeAuditAsync(request.ProjectPath);

            // Run dynamic tests
            var dynamicResults = await _testService.RunSecurityTestsAsync();

            // Generate report
            var report = await _reportGenerator.GenerateReportAsync(
                request.ProjectName, staticFindings, dynamicResults);

            // Save report
            await _reportGenerator.SaveReportAsync(report, request.OutputPath);

            return Ok(new
            {
                message = "Security audit completed successfully",
                summary = report.Summary,
                reportPath = request.OutputPath
            });
        }
        catch (Exception ex)
        {
            return BadRequest(new { error = ex.Message });
        }
    }

    public class AuditRequest
    {
        public string ProjectName { get; set; } = string.Empty;
        public string ProjectPath { get; set; } = string.Empty;
        public string OutputPath { get; set; } = string.Empty;
    }
}
```

## 📊 Assessment Criteria

Your security audit should identify:
- ✅ **Critical Vulnerabilities** (SQL Injection, XSS, etc.)
- ✅ **Configuration Issues** (Debug mode, missing headers)
- ✅ **Cryptographic Problems** (Weak algorithms, hardcoded secrets)
- ✅ **Access Control Issues** (Missing authentication/authorization)
- ✅ **Input Validation Problems** (Unvalidated inputs)

## 🎯 Next Steps

After completing this exercise:
1. **Review all findings** with development team
2. **Prioritize remediation** based on risk assessment
3. **Implement fixes** following security best practices
4. **Repeat audit** to verify fixes
5. **Establish regular** security audit schedule

---

**Congratulations!** You've completed a comprehensive security audit. Use these findings to improve your application's security posture.

**Next Exercise**: [Exercise 5: Penetration Testing](Exercise5-PenetrationTesting.md)
