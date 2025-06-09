using System.ComponentModel.DataAnnotations;
using System.Text.RegularExpressions;

namespace SecurityDemo.Models;

/// <summary>
/// Model demonstrating comprehensive input validation
/// </summary>
public class UserInputModel
{
    [Required(ErrorMessage = "Name is required")]
    [StringLength(100, MinimumLength = 2, ErrorMessage = "Name must be between 2 and 100 characters")]
    [RegularExpression(@"^[a-zA-Z\s]+$", ErrorMessage = "Name can only contain letters and spaces")]
    public string Name { get; set; } = string.Empty;

    [Required(ErrorMessage = "Email is required")]
    [EmailAddress(ErrorMessage = "Invalid email format")]
    [StringLength(255, ErrorMessage = "Email cannot exceed 255 characters")]
    public string Email { get; set; } = string.Empty;

    [Required(ErrorMessage = "Age is required")]
    [Range(1, 120, ErrorMessage = "Age must be between 1 and 120")]
    public int Age { get; set; }

    [Phone(ErrorMessage = "Invalid phone number format")]
    public string? PhoneNumber { get; set; }

    [Url(ErrorMessage = "Invalid URL format")]
    public string? Website { get; set; }

    [StringLength(1000, ErrorMessage = "Comments cannot exceed 1000 characters")]
    [DataType(DataType.MultilineText)]
    public string? Comments { get; set; }

    [CreditCard(ErrorMessage = "Invalid credit card format")]
    public string? CreditCardNumber { get; set; }
}

/// <summary>
/// Custom validation attribute for safe HTML content
/// </summary>
public class SafeHtmlAttribute : ValidationAttribute
{
    protected override ValidationResult? IsValid(object? value, ValidationContext validationContext)
    {
        if (value is string htmlContent && !string.IsNullOrEmpty(htmlContent))
        {
            // Check for potentially dangerous HTML tags and scripts
            var dangerousPatterns = new[]
            {
                @"<script[^>]*>.*?</script>",
                @"<iframe[^>]*>.*?</iframe>",
                @"<object[^>]*>.*?</object>",
                @"<embed[^>]*>.*?</embed>",
                @"<form[^>]*>.*?</form>",
                @"javascript:",
                @"vbscript:",
                @"onload=",
                @"onerror=",
                @"onclick="
            };

            foreach (var pattern in dangerousPatterns)
            {
                if (Regex.IsMatch(htmlContent, pattern, RegexOptions.IgnoreCase))
                {
                    return new ValidationResult("Content contains potentially dangerous HTML or scripts");
                }
            }
        }

        return ValidationResult.Success;
    }
}
