using FluentValidation;
using InputValidation.Models;
using System.Text.RegularExpressions;

namespace InputValidation.Validators
{
    public class CommentValidator : AbstractValidator<CommentModel>
    {
        private readonly string[] _spamKeywords = { "viagra", "casino", "lottery", "prize", "winner", "click here", "buy now", "free money" };
        private readonly string[] _allowedStatuses = { "Pending", "Approved", "Rejected", "Spam" };

        public CommentValidator()
        {
            RuleFor(x => x.Author)
                .NotEmpty().WithMessage("Author name is required")
                .Length(2, 50).WithMessage("Author name must be between 2 and 50 characters")
                .Matches(@"^[a-zA-Z\s\-'\.]+$").WithMessage("Author name contains invalid characters")
                .Must(NotContainScriptTags).WithMessage("Author name contains invalid content");

            RuleFor(x => x.Email)
                .NotEmpty().WithMessage("Email is required")
                .EmailAddress().WithMessage("Invalid email format")
                .MaximumLength(100).WithMessage("Email cannot exceed 100 characters")
                .Must(NotBeDisposableEmail).WithMessage("Disposable email addresses are not allowed");

            RuleFor(x => x.Content)
                .NotEmpty().WithMessage("Comment content is required")
                .Length(10, 1000).WithMessage("Comment must be between 10 and 1000 characters")
                .Must(NotContainScriptTags).WithMessage("Comment contains potentially harmful content")
                .Must(NotContainExcessiveLinks).WithMessage("Comment contains too many links")
                .Must(NotContainSpam).WithMessage("Comment appears to contain spam")
                .Must(NotBeAllCaps).WithMessage("Please don't use all capital letters")
                .Must(NotContainExcessiveEmojis).WithMessage("Too many emojis detected");

            RuleFor(x => x.Rating)
                .InclusiveBetween(1, 5).When(x => x.Rating.HasValue)
                .WithMessage("Rating must be between 1 and 5");

            RuleFor(x => x.Website)
                .Must(BeValidUrl).When(x => !string.IsNullOrEmpty(x.Website))
                .WithMessage("Invalid website URL format")
                .Must(NotBeBlacklistedDomain).When(x => !string.IsNullOrEmpty(x.Website))
                .WithMessage("This website domain is not allowed");

            RuleFor(x => x.ProductId)
                .NotEmpty().WithMessage("Product ID is required")
                .GreaterThan(0).WithMessage("Invalid product ID");

            RuleFor(x => x.Status)
                .NotEmpty().WithMessage("Comment status is required")
                .Must(BeValidStatus).WithMessage($"Status must be one of: {string.Join(", ", _allowedStatuses)}");

            RuleFor(x => x.IpAddress)
                .Matches(@"^(\d{1,3}\.){3}\d{1,3}$").When(x => !string.IsNullOrEmpty(x.IpAddress))
                .WithMessage("Invalid IP address format")
                .Must(BeValidIpAddress).When(x => !string.IsNullOrEmpty(x.IpAddress))
                .WithMessage("Invalid IP address");

            RuleFor(x => x.ParentCommentId)
                .GreaterThan(0).When(x => x.ParentCommentId.HasValue)
                .WithMessage("Invalid parent comment ID");

            // Nested comment validation
            When(x => x.ParentCommentId.HasValue, () =>
            {
                RuleFor(x => x.Content)
                    .MaximumLength(500)
                    .WithMessage("Reply comments cannot exceed 500 characters");
            });
        }

        private bool NotContainScriptTags(string input)
        {
            if (string.IsNullOrEmpty(input)) return true;
            
            var dangerousPatterns = new[]
            {
                @"<script.*?>.*?</script>",
                @"javascript:",
                @"on\w+\s*=",
                @"eval\(",
                @"expression\(",
                @"vbscript:",
                @"onload\s*=",
                @"onerror\s*=",
                @"onclick\s*="
            };
            
            return !dangerousPatterns.Any(pattern => 
                Regex.IsMatch(input, pattern, RegexOptions.IgnoreCase));
        }

        private bool NotBeDisposableEmail(string email)
        {
            if (string.IsNullOrEmpty(email)) return true;
            
            var disposableDomains = new[] 
            { 
                "tempmail.com", "throwaway.email", "guerrillamail.com", 
                "10minutemail.com", "mailinator.com", "trashmail.com" 
            };
            
            var domain = email.Split('@').LastOrDefault()?.ToLower();
            return !disposableDomains.Contains(domain);
        }

        private bool NotContainExcessiveLinks(string content)
        {
            if (string.IsNullOrEmpty(content)) return true;
            
            var linkPattern = @"https?://|www\.";
            var matches = Regex.Matches(content, linkPattern, RegexOptions.IgnoreCase);
            return matches.Count <= 2; // Allow maximum 2 links
        }

        private bool NotContainSpam(string content)
        {
            if (string.IsNullOrEmpty(content)) return true;
            
            var lowerContent = content.ToLower();
            return !_spamKeywords.Any(keyword => lowerContent.Contains(keyword));
        }

        private bool NotBeAllCaps(string content)
        {
            if (string.IsNullOrEmpty(content) || content.Length < 10) return true;
            
            var upperCount = content.Count(char.IsUpper);
            var letterCount = content.Count(char.IsLetter);
            
            return letterCount == 0 || (double)upperCount / letterCount < 0.8;
        }

        private bool NotContainExcessiveEmojis(string content)
        {
            if (string.IsNullOrEmpty(content)) return true;
            
            // Simple emoji detection (can be expanded)
            var emojiPattern = @"[\u{1F600}-\u{1F64F}]|[\u{1F300}-\u{1F5FF}]|[\u{1F680}-\u{1F6FF}]|[\u{2600}-\u{26FF}]|[\u{2700}-\u{27BF}]";
            var matches = Regex.Matches(content, emojiPattern);
            
            return matches.Count <= 5; // Allow maximum 5 emojis
        }

        private bool BeValidUrl(string url)
        {
            return Uri.TryCreate(url, UriKind.Absolute, out var result) &&
                   (result.Scheme == Uri.UriSchemeHttp || result.Scheme == Uri.UriSchemeHttps);
        }

        private bool NotBeBlacklistedDomain(string url)
        {
            if (string.IsNullOrEmpty(url)) return true;
            
            var blacklistedDomains = new[] { "spam.com", "malware.com", "phishing.com" };
            
            if (Uri.TryCreate(url, UriKind.Absolute, out var uri))
            {
                return !blacklistedDomains.Contains(uri.Host.ToLower());
            }
            
            return true;
        }

        private bool BeValidStatus(string status)
        {
            return _allowedStatuses.Contains(status);
        }

        private bool BeValidIpAddress(string ipAddress)
        {
            if (string.IsNullOrEmpty(ipAddress)) return true;
            
            var parts = ipAddress.Split('.');
            if (parts.Length != 4) return false;
            
            return parts.All(part => byte.TryParse(part, out var num) && num >= 0 && num <= 255);
        }
    }
}