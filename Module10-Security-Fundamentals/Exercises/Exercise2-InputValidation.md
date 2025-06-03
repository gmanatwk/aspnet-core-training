# Exercise 2: Input Validation & Sanitization

## 🎯 Objective
Learn to implement comprehensive input validation and sanitization to prevent injection attacks and ensure data integrity.

## ⏱️ Duration
60 minutes

## 📋 Prerequisites
- Basic understanding of ASP.NET Core MVC
- .NET 8.0 SDK installed
- Knowledge of common web vulnerabilities (XSS, SQL Injection)
- Basic HTML and JavaScript knowledge

## 🎓 Learning Outcomes
By completing this exercise, you will:
- ✅ Implement server-side input validation
- ✅ Create custom validation attributes
- ✅ Implement HTML sanitization
- ✅ Prevent SQL injection attacks
- ✅ Use model binding validation
- ✅ Handle file upload validation

## 📝 Background
Input validation is the first line of defense against malicious data. Without proper validation, applications are vulnerable to:
- **SQL Injection** - Malicious SQL commands in input
- **Cross-Site Scripting (XSS)** - Malicious scripts in input
- **Path Traversal** - Unauthorized file system access
- **Buffer Overflow** - Excessive input data
- **Business Logic Bypass** - Invalid business data

## 🚀 Getting Started

### Step 1: Create a New ASP.NET Core MVC Project
```bash
  - Updated dotnet new command
  - Updated dotnet new command with existing flags
dotnet new   --framework net8.0
cd InputValidationDemo
```

### Step 2: Install Required Packages
```bash
dotnet add package HtmlSanitizer
dotnet add package System.ComponentModel.Annotations
dotnet add package Microsoft.EntityFrameworkCore.SqlServer
dotnet add package Microsoft.EntityFrameworkCore.Tools
```

## 🛠️ Task 1: Basic Model Validation

Create models with comprehensive validation attributes.

### Instructions:

1. **Create Models/UserRegistrationModel.cs**:

```csharp
using System.ComponentModel.DataAnnotations;

namespace InputValidationDemo.Models
{
    public class UserRegistrationModel
    {
        [Required(ErrorMessage = "Username is required")]
        [StringLength(50, MinimumLength = 3, ErrorMessage = "Username must be between 3 and 50 characters")]
        [RegularExpression(@"^[a-zA-Z0-9_]+$", ErrorMessage = "Username can only contain letters, numbers, and underscores")]
        public string Username { get; set; } = string.Empty;

        [Required(ErrorMessage = "Email is required")]
        [EmailAddress(ErrorMessage = "Invalid email format")]
        [StringLength(100, ErrorMessage = "Email cannot exceed 100 characters")]
        public string Email { get; set; } = string.Empty;

        [Required(ErrorMessage = "Password is required")]
        [StringLength(100, MinimumLength = 8, ErrorMessage = "Password must be at least 8 characters")]
        [RegularExpression(@"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]",
            ErrorMessage = "Password must contain at least one lowercase letter, one uppercase letter, one digit, and one special character")]
        public string Password { get; set; } = string.Empty;

        [Required(ErrorMessage = "Please confirm your password")]
        [Compare("Password", ErrorMessage = "Passwords do not match")]
        public string ConfirmPassword { get; set; } = string.Empty;

        [Required(ErrorMessage = "Age is required")]
        [Range(13, 120, ErrorMessage = "Age must be between 13 and 120")]
        public int Age { get; set; }

        [Phone(ErrorMessage = "Invalid phone number format")]
        public string? PhoneNumber { get; set; }

        [Url(ErrorMessage = "Invalid URL format")]
        public string? Website { get; set; }
    }
}
```

2. **Create Models/CommentModel.cs**:

```csharp
using System.ComponentModel.DataAnnotations;

namespace InputValidationDemo.Models
{
    public class CommentModel
    {
        [Required(ErrorMessage = "Name is required")]
        [StringLength(100, MinimumLength = 2, ErrorMessage = "Name must be between 2 and 100 characters")]
        public string Name { get; set; } = string.Empty;

        [Required(ErrorMessage = "Comment content is required")]
        [StringLength(1000, MinimumLength = 10, ErrorMessage = "Comment must be between 10 and 1000 characters")]
        public string Content { get; set; } = string.Empty;

        [Required(ErrorMessage = "Rating is required")]
        [Range(1, 5, ErrorMessage = "Rating must be between 1 and 5")]
        public int Rating { get; set; }
    }
}
```

## 🛠️ Task 2: Custom Validation Attributes

Create custom validation attributes for specific business rules.

### Instructions:

1. **Create Validation/NoScriptTagAttribute.cs**:

```csharp
using System.ComponentModel.DataAnnotations;

namespace InputValidationDemo.Validation
{
    public class NoScriptTagAttribute : ValidationAttribute
    {
        protected override ValidationResult? IsValid(object? value, ValidationContext validationContext)
        {
            if (value is string stringValue && !string.IsNullOrEmpty(stringValue))
            {
                if (stringValue.ToLower().Contains("<script") || 
                    stringValue.ToLower().Contains("javascript:") ||
                    stringValue.ToLower().Contains("onload=") ||
                    stringValue.ToLower().Contains("onerror="))
                {
                    return new ValidationResult("Input cannot contain script tags or JavaScript code");
                }
            }
            
            return ValidationResult.Success;
        }
    }
}
```

2. **Create Validation/SafeFileNameAttribute.cs**:

```csharp
using System.ComponentModel.DataAnnotations;
using System.Text.RegularExpressions;

namespace InputValidationDemo.Validation
{
    public class SafeFileNameAttribute : ValidationAttribute
    {
        private static readonly Regex FileNameRegex = new Regex(@"^[a-zA-Z0-9_\-\.]+$", RegexOptions.Compiled);
        private static readonly string[] DangerousExtensions = { ".exe", ".bat", ".cmd", ".com", ".scr", ".vbs", ".js" };

        protected override ValidationResult? IsValid(object? value, ValidationContext validationContext)
        {
            if (value is string fileName && !string.IsNullOrEmpty(fileName))
            {
                // Check for invalid characters
                if (!FileNameRegex.IsMatch(fileName))
                {
                    return new ValidationResult("File name contains invalid characters");
                }

                // Check for dangerous extensions
                var extension = Path.GetExtension(fileName).ToLower();
                if (DangerousExtensions.Contains(extension))
                {
                    return new ValidationResult($"File extension '{extension}' is not allowed");
                }

                // Check for path traversal attempts
                if (fileName.Contains("..") || fileName.Contains("/") || fileName.Contains("\\"))
                {
                    return new ValidationResult("File name cannot contain path traversal characters");
                }
            }

            return ValidationResult.Success;
        }
    }
}
```

3. **Update CommentModel to use custom validation**:

```csharp
using InputValidationDemo.Validation;

public class CommentModel
{
    [Required(ErrorMessage = "Name is required")]
    [StringLength(100, MinimumLength = 2, ErrorMessage = "Name must be between 2 and 100 characters")]
    [NoScriptTag]
    public string Name { get; set; } = string.Empty;

    [Required(ErrorMessage = "Comment content is required")]
    [StringLength(1000, MinimumLength = 10, ErrorMessage = "Comment must be between 10 and 1000 characters")]
    [NoScriptTag]
    public string Content { get; set; } = string.Empty;

    [Required(ErrorMessage = "Rating is required")]
    [Range(1, 5, ErrorMessage = "Rating must be between 1 and 5")]
    public int Rating { get; set; }
}
```

## 🛠️ Task 3: HTML Sanitization Service

Create a service for sanitizing HTML input.

### Instructions:

1. **Create Services/IHtmlSanitizationService.cs**:

```csharp
namespace InputValidationDemo.Services
{
    public interface IHtmlSanitizationService
    {
        string SanitizeHtml(string html);
        string StripHtml(string html);
        bool ContainsMaliciousContent(string content);
    }
}
```

2. **Create Services/HtmlSanitizationService.cs**:

```csharp
using Ganss.Xss;
using System.Text.RegularExpressions;

namespace InputValidationDemo.Services
{
    public class HtmlSanitizationService : IHtmlSanitizationService
    {
        private readonly HtmlSanitizer _sanitizer;
        private static readonly Regex ScriptRegex = new Regex(@"<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>", RegexOptions.IgnoreCase);
        private static readonly Regex JavaScriptRegex = new Regex(@"javascript:", RegexOptions.IgnoreCase);
        private static readonly Regex EventHandlerRegex = new Regex(@"on\w+\s*=", RegexOptions.IgnoreCase);

        public HtmlSanitizationService()
        {
            _sanitizer = new HtmlSanitizer();
            
            // Configure allowed tags and attributes
            _sanitizer.AllowedTags.Clear();
            _sanitizer.AllowedTags.UnionWith(new[] { "p", "br", "strong", "em", "ul", "ol", "li", "a" });
            
            _sanitizer.AllowedAttributes.Clear();
            _sanitizer.AllowedAttributes.Add("href");
            _sanitizer.AllowedAttributes.Add("title");
            
            // Configure allowed protocols for links
            _sanitizer.AllowedSchemes.Clear();
            _sanitizer.AllowedSchemes.UnionWith(new[] { "http", "https", "mailto" });
        }

        public string SanitizeHtml(string html)
        {
            if (string.IsNullOrEmpty(html))
                return string.Empty;

            return _sanitizer.Sanitize(html);
        }

        public string StripHtml(string html)
        {
            if (string.IsNullOrEmpty(html))
                return string.Empty;

            return _sanitizer.Sanitize(html, allowedTags: new string[0]);
        }

        public bool ContainsMaliciousContent(string content)
        {
            if (string.IsNullOrEmpty(content))
                return false;

            return ScriptRegex.IsMatch(content) ||
                   JavaScriptRegex.IsMatch(content) ||
                   EventHandlerRegex.IsMatch(content);
        }
    }
}
```

3. **Register the service in Program.cs**:

```csharp
builder.Services.AddScoped<IHtmlSanitizationService, HtmlSanitizationService>();
```

## 🛠️ Task 4: File Upload Validation

Create secure file upload functionality.

### Instructions:

1. **Create Models/FileUploadModel.cs**:

```csharp
using InputValidationDemo.Validation;
using System.ComponentModel.DataAnnotations;

namespace InputValidationDemo.Models
{
    public class FileUploadModel
    {
        [Required(ErrorMessage = "Please select a file")]
        public IFormFile File { get; set; } = null!;

        [Required(ErrorMessage = "Description is required")]
        [StringLength(200, MinimumLength = 5, ErrorMessage = "Description must be between 5 and 200 characters")]
        [NoScriptTag]
        public string Description { get; set; } = string.Empty;
    }
}
```

2. **Create Services/FileValidationService.cs**:

```csharp
namespace InputValidationDemo.Services
{
    public class FileValidationService
    {
        private static readonly string[] AllowedExtensions = { ".jpg", ".jpeg", ".png", ".gif", ".pdf", ".txt", ".docx" };
        private static readonly string[] AllowedMimeTypes = { 
            "image/jpeg", "image/png", "image/gif", 
            "application/pdf", "text/plain", 
            "application/vnd.openxmlformats-officedocument.wordprocessingml.document" 
        };
        private const long MaxFileSize = 5 * 1024 * 1024; // 5MB

        public (bool IsValid, string ErrorMessage) ValidateFile(IFormFile file)
        {
            if (file == null || file.Length == 0)
                return (false, "No file selected");

            // Check file size
            if (file.Length > MaxFileSize)
                return (false, $"File size cannot exceed {MaxFileSize / (1024 * 1024)}MB");

            // Check file extension
            var extension = Path.GetExtension(file.FileName).ToLower();
            if (!AllowedExtensions.Contains(extension))
                return (false, $"File extension '{extension}' is not allowed");

            // Check MIME type
            if (!AllowedMimeTypes.Contains(file.ContentType.ToLower()))
                return (false, $"File type '{file.ContentType}' is not allowed");

            // Check file name for dangerous characters
            var fileName = Path.GetFileName(file.FileName);
            if (string.IsNullOrEmpty(fileName) || fileName.Contains("..") || 
                fileName.IndexOfAny(Path.GetInvalidFileNameChars()) >= 0)
                return (false, "Invalid file name");

            return (true, string.Empty);
        }
    }
}
```

## 🛠️ Task 5: Create Controllers and Views

Implement controllers that use the validation.

### Instructions:

1. **Create Controllers/ValidationController.cs**:

```csharp
using InputValidationDemo.Models;
using InputValidationDemo.Services;
using Microsoft.AspNetCore.Mvc;

namespace InputValidationDemo.Controllers
{
    public class ValidationController : Controller
    {
        private readonly IHtmlSanitizationService _htmlSanitizer;
        private readonly FileValidationService _fileValidator;

        public ValidationController(IHtmlSanitizationService htmlSanitizer, FileValidationService fileValidator)
        {
            _htmlSanitizer = htmlSanitizer;
            _fileValidator = fileValidator;
        }

        public IActionResult Registration()
        {
            return View(new UserRegistrationModel());
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public IActionResult Registration(UserRegistrationModel model)
        {
            if (!ModelState.IsValid)
            {
                return View(model);
            }

            // Additional server-side validation
            if (_htmlSanitizer.ContainsMaliciousContent(model.Username))
            {
                ModelState.AddModelError("Username", "Username contains potentially malicious content");
                return View(model);
            }

            // In real application, save to database
            TempData["SuccessMessage"] = "Registration successful!";
            return RedirectToAction("Success");
        }

        public IActionResult Comment()
        {
            return View(new CommentModel());
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public IActionResult Comment(CommentModel model)
        {
            if (!ModelState.IsValid)
            {
                return View(model);
            }

            // Sanitize the content
            model.Content = _htmlSanitizer.SanitizeHtml(model.Content);
            model.Name = _htmlSanitizer.StripHtml(model.Name);

            // In real application, save to database
            TempData["SuccessMessage"] = "Comment added successfully!";
            return RedirectToAction("Success");
        }

        public IActionResult FileUpload()
        {
            return View(new FileUploadModel());
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> FileUpload(FileUploadModel model)
        {
            if (!ModelState.IsValid)
            {
                return View(model);
            }

            var (isValid, errorMessage) = _fileValidator.ValidateFile(model.File);
            if (!isValid)
            {
                ModelState.AddModelError("File", errorMessage);
                return View(model);
            }

            // Sanitize description
            model.Description = _htmlSanitizer.StripHtml(model.Description);

            // In real application, save file securely
            var fileName = Guid.NewGuid().ToString() + Path.GetExtension(model.File.FileName);
            var filePath = Path.Combine("wwwroot/uploads", fileName);
            
            Directory.CreateDirectory(Path.GetDirectoryName(filePath)!);
            
            using (var stream = new FileStream(filePath, FileMode.Create))
            {
                await model.File.CopyToAsync(stream);
            }

            TempData["SuccessMessage"] = "File uploaded successfully!";
            return RedirectToAction("Success");
        }

        public IActionResult Success()
        {
            return View();
        }
    }
}
```

2. **Register FileValidationService in Program.cs**:

```csharp
builder.Services.AddScoped<FileValidationService>();
```

## 🛠️ Task 6: Create Razor Views

Create views for testing the validation.

### Instructions:

1. **Create Views/Validation/Registration.cshtml**:

```html
@model UserRegistrationModel
@{
    ViewData["Title"] = "User Registration";
}

<h2>User Registration</h2>

<div class="row">
    <div class="col-md-6">
        <form asp-action="Registration" method="post">
            <div asp-validation-summary="ModelOnly" class="text-danger"></div>
            
            <div class="form-group mb-3">
                <label asp-for="Username" class="form-label"></label>
                <input asp-for="Username" class="form-control" />
                <span asp-validation-for="Username" class="text-danger"></span>
            </div>

            <div class="form-group mb-3">
                <label asp-for="Email" class="form-label"></label>
                <input asp-for="Email" type="email" class="form-control" />
                <span asp-validation-for="Email" class="text-danger"></span>
            </div>

            <div class="form-group mb-3">
                <label asp-for="Password" class="form-label"></label>
                <input asp-for="Password" type="password" class="form-control" />
                <span asp-validation-for="Password" class="text-danger"></span>
            </div>

            <div class="form-group mb-3">
                <label asp-for="ConfirmPassword" class="form-label"></label>
                <input asp-for="ConfirmPassword" type="password" class="form-control" />
                <span asp-validation-for="ConfirmPassword" class="text-danger"></span>
            </div>

            <div class="form-group mb-3">
                <label asp-for="Age" class="form-label"></label>
                <input asp-for="Age" type="number" class="form-control" />
                <span asp-validation-for="Age" class="text-danger"></span>
            </div>

            <div class="form-group mb-3">
                <label asp-for="PhoneNumber" class="form-label"></label>
                <input asp-for="PhoneNumber" type="tel" class="form-control" />
                <span asp-validation-for="PhoneNumber" class="text-danger"></span>
            </div>

            <div class="form-group mb-3">
                <label asp-for="Website" class="form-label"></label>
                <input asp-for="Website" type="url" class="form-control" />
                <span asp-validation-for="Website" class="text-danger"></span>
            </div>

            <button type="submit" class="btn btn-primary">Register</button>
        </form>
    </div>
    <div class="col-md-6">
        <div class="card">
            <div class="card-header">
                <h5>Validation Rules</h5>
            </div>
            <div class="card-body">
                <ul>
                    <li>Username: 3-50 chars, alphanumeric + underscore only</li>
                    <li>Email: Valid email format, max 100 chars</li>
                    <li>Password: Min 8 chars, must include upper, lower, digit, special</li>
                    <li>Age: Between 13 and 120</li>
                    <li>Phone: Valid phone format (optional)</li>
                    <li>Website: Valid URL format (optional)</li>
                </ul>
            </div>
        </div>
    </div>
</div>

@section Scripts {
    @{await Html.RenderPartialAsync("_ValidationScriptsPartial");}
}
```

## ✅ Testing Scenarios

Test your validation with these malicious inputs:

### XSS Attempts:
- `<script>alert('XSS')</script>`
- `javascript:alert('XSS')`
- `<img src="x" onerror="alert('XSS')">`

### SQL Injection Attempts:
- `'; DROP TABLE Users; --`
- `admin' OR '1'='1`
- `1'; UPDATE Users SET password='hacked' WHERE id=1; --`

### Path Traversal Attempts:
- `../../../etc/passwd`
- `..\\..\\windows\\system32\\config\\sam`

## 📊 Expected Results

After implementing proper validation:
- ✅ All malicious inputs should be rejected
- ✅ Error messages should be user-friendly
- ✅ HTML content should be sanitized
- ✅ File uploads should be restricted to safe types
- ✅ File names should be validated and sanitized

## 🔧 Troubleshooting

### Common Issues:

1. **Validation Not Working**
   - Ensure `ModelState.IsValid` is checked
   - Verify validation attributes are applied correctly
   - Check that client-side validation scripts are included

2. **HTML Sanitization Issues**
   - Configure HtmlSanitizer properly for your needs
   - Be careful not to over-sanitize legitimate content
   - Test with various HTML inputs

## 📚 Additional Security Measures

Consider implementing:
- **Rate Limiting** for form submissions
- **CAPTCHA** for public forms
- **Input Length Limits** at network level
- **Parameterized Queries** for database operations
- **Output Encoding** for display

## 🎯 Assessment Questions

1. What is the difference between validation and sanitization?
2. Why is server-side validation essential even with client-side validation?
3. How does parameterized queries prevent SQL injection?
4. What are the security considerations for file uploads?

---

**Excellent work!** You've implemented comprehensive input validation and sanitization. This forms a crucial layer of defense against injection attacks.

**Next Exercise**: [Exercise 3: Encryption Implementation](Exercise3-EncryptionImplementation.md)
