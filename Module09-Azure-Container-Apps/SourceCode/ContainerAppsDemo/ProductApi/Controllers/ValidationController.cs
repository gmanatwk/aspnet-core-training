using Microsoft.AspNetCore.Mvc;
using InputValidation.Models;
using InputValidation.Services;
using FluentValidation;
using Microsoft.Extensions.Logging;

namespace InputValidation.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class ValidationController : ControllerBase
    {
        private readonly IValidationService _validationService;
        private readonly IInputSanitizer _sanitizer;
        private readonly ILogger<ValidationController> _logger;

        public ValidationController(
            IValidationService validationService,
            IInputSanitizer sanitizer,
            ILogger<ValidationController> logger)
        {
            _validationService = validationService;
            _sanitizer = sanitizer;
            _logger = logger;
        }

        [HttpPost("register")]
        public async Task<IActionResult> Register([FromBody] UserRegistrationModel model)
        {
            try
            {
                // Sanitize input before validation
                model.Username = _sanitizer.StripNonAlphanumeric(model.Username);
                model.FirstName = _sanitizer.SanitizeForDisplay(model.FirstName);
                model.LastName = _sanitizer.SanitizeForDisplay(model.LastName);
                
                if (!string.IsNullOrEmpty(model.PhoneNumber))
                {
                    model.PhoneNumber = _sanitizer.SanitizePhoneNumber(model.PhoneNumber);
                }

                // Validate the model
                var (isValid, errors) = await _validationService.ValidateWithErrorsAsync(model);

                if (!isValid)
                {
                    _logger.LogInformation("User registration validation failed for username: {Username}", model.Username);
                    return BadRequest(new
                    {
                        Message = "Validation failed",
                        Errors = errors
                    });
                }

                // Log successful validation
                _logger.LogInformation("User registration validated successfully for username: {Username}", model.Username);

                // Here you would normally save to database
                return Ok(new
                {
                    Message = "Registration successful",
                    Data = new
                    {
                        Username = model.Username,
                        Email = model.Email,
                        FullName = $"{model.FirstName} {model.LastName}"
                    }
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error during user registration");
                return StatusCode(500, new { Message = "An error occurred during registration" });
            }
        }

        [HttpPost("product")]
        public async Task<IActionResult> CreateProduct([FromBody] ProductModel model)
        {
            try
            {
                // Sanitize input
                model.Name = _sanitizer.SanitizeForDisplay(model.Name);
                model.Description = _sanitizer.SanitizeHtml(model.Description);
                
                if (!string.IsNullOrEmpty(model.ImageUrl))
                {
                    model.ImageUrl = _sanitizer.SanitizeUrl(model.ImageUrl);
                }

                // Validate including business rules
                var validator = HttpContext.RequestServices.GetService<IValidator<ProductModel>>();
                var result = await validator.ValidateAsync(model, options => options.IncludeRuleSets("BusinessRules"));

                if (!result.IsValid)
                {
                    var errors = _validationService.GetValidationErrors(result);
                    _logger.LogInformation("Product validation failed for: {ProductName}", model.Name);
                    
                    return BadRequest(new
                    {
                        Message = "Product validation failed",
                        Errors = errors
                    });
                }

                // Set timestamps
                model.CreatedDate = DateTime.UtcNow;

                _logger.LogInformation("Product created successfully: {ProductName}", model.Name);

                return Ok(new
                {
                    Message = "Product created successfully",
                    Data = model
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error during product creation");
                return StatusCode(500, new { Message = "An error occurred during product creation" });
            }
        }

        [HttpPost("comment")]
        public async Task<IActionResult> PostComment([FromBody] CommentModel model)
        {
            try
            {
                // Sanitize all input fields
                model.Author = _sanitizer.SanitizeForDisplay(model.Author);
                model.Content = _sanitizer.SanitizeHtml(model.Content);
                
                if (!string.IsNullOrEmpty(model.Website))
                {
                    model.Website = _sanitizer.SanitizeUrl(model.Website);
                }

                // Get client IP
                model.IpAddress = HttpContext.Connection.RemoteIpAddress?.ToString() ?? "Unknown";
                model.CreatedDate = DateTime.UtcNow;
                model.Status = "Pending"; // All comments start as pending

                // Validate
                var validationResult = await _validationService.ValidateAsync(model);

                if (!validationResult.IsValid)
                {
                    var errors = _validationService.GetValidationErrors(validationResult);
                    _logger.LogInformation("Comment validation failed from IP: {IpAddress}", model.IpAddress);
                    
                    return BadRequest(new
                    {
                        Message = "Comment validation failed",
                        Errors = errors
                    });
                }

                // Additional spam check
                if (await IsLikelySpam(model))
                {
                    model.Status = "Spam";
                    _logger.LogWarning("Comment flagged as spam from IP: {IpAddress}", model.IpAddress);
                }

                _logger.LogInformation("Comment posted successfully from IP: {IpAddress}", model.IpAddress);

                return Ok(new
                {
                    Message = "Comment posted successfully",
                    Data = new
                    {
                        CommentId = new Random().Next(1000, 9999), // Mock ID
                        Author = model.Author,
                        Status = model.Status,
                        PostedAt = model.CreatedDate
                    }
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error during comment posting");
                return StatusCode(500, new { Message = "An error occurred while posting the comment" });
            }
        }

        [HttpPost("validate-email")]
        public IActionResult ValidateEmail([FromBody] EmailValidationRequest request)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(request.Email))
                {
                    return BadRequest(new { IsValid = false, Message = "Email is required" });
                }

                // Basic email validation
                var emailValidator = new EmailValidator();
                var result = emailValidator.Validate(request.Email);

                return Ok(new
                {
                    IsValid = result.IsValid,
                    Message = result.IsValid ? "Email is valid" : result.Errors.FirstOrDefault()?.ErrorMessage
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error during email validation");
                return StatusCode(500, new { Message = "An error occurred during validation" });
            }
        }

        [HttpGet("test-xss")]
        public IActionResult TestXssSanitization([FromQuery] string input)
        {
            if (string.IsNullOrEmpty(input))
            {
                return BadRequest(new { Message = "Input is required" });
            }

            var results = new
            {
                Original = input,
                SanitizedForDisplay = _sanitizer.SanitizeForDisplay(input),
                SanitizedHtml = _sanitizer.SanitizeHtml(input),
                SanitizedForDatabase = _sanitizer.SanitizeForDatabase(input),
                ScriptTagsRemoved = _sanitizer.RemoveScriptTags(input),
                EncodedForJavaScript = _sanitizer.EncodeForJavaScript(input),
                AlphanumericOnly = _sanitizer.StripNonAlphanumeric(input)
            };

            return Ok(results);
        }

        private async Task<bool> IsLikelySpam(CommentModel comment)
        {
            // Simple spam detection logic
            var spamIndicators = 0;

            // Check for excessive links
            var linkCount = System.Text.RegularExpressions.Regex.Matches(comment.Content, @"https?://").Count;
            if (linkCount > 2) spamIndicators++;

            // Check for all caps
            if (comment.Content.Length > 10 && comment.Content.ToUpper() == comment.Content)
                spamIndicators++;

            // Check for repeated characters
            if (System.Text.RegularExpressions.Regex.IsMatch(comment.Content, @"(.)\1{4,}"))
                spamIndicators++;

            // Check if email is from a suspicious domain
            var domain = comment.Email.Split('@').LastOrDefault()?.ToLower();
            var suspiciousDomains = new[] { "tempmail.com", "guerrillamail.com", "mailinator.com" };
            if (suspiciousDomains.Contains(domain))
                spamIndicators++;

            return spamIndicators >= 2;
        }
    }

    public class EmailValidationRequest
    {
        public string Email { get; set; }
    }

    public class EmailValidator : AbstractValidator<string>
    {
        public EmailValidator()
        {
            RuleFor(email => email)
                .NotEmpty().WithMessage("Email is required")
                .EmailAddress().WithMessage("Invalid email format")
                .Must(NotBeDisposableEmail).WithMessage("Disposable email addresses are not allowed");
        }

        private bool NotBeDisposableEmail(string email)
        {
            if (string.IsNullOrEmpty(email)) return true;
            
            var disposableDomains = new[] { "tempmail.com", "throwaway.email", "guerrillamail.com" };
            var domain = email.Split('@').LastOrDefault()?.ToLower();
            return !disposableDomains.Contains(domain);
        }
    }
}