using FluentValidation;
using InputValidation.Models;
using System.Text.RegularExpressions;

namespace InputValidation.Validators
{
    public class ProductValidator : AbstractValidator<ProductModel>
    {
        private readonly string[] _allowedCategories = { "Electronics", "Clothing", "Food", "Books", "Home & Garden", "Sports", "Toys", "Other" };
        private readonly string[] _allowedStatuses = { "Active", "Inactive", "Discontinued" };

        public ProductValidator()
        {
            RuleFor(x => x.Name)
                .NotEmpty().WithMessage("Product name is required")
                .Length(3, 100).WithMessage("Product name must be between 3 and 100 characters")
                .Matches(@"^[a-zA-Z0-9\s\-\.&]+$").WithMessage("Product name contains invalid characters")
                .Must(NotContainScriptTags).WithMessage("Product name contains invalid content")
                .Must(NotContainSqlKeywords).WithMessage("Product name contains invalid keywords");

            RuleFor(x => x.Description)
                .MaximumLength(500).WithMessage("Description cannot exceed 500 characters")
                .Must(NotContainScriptTags).When(x => !string.IsNullOrEmpty(x.Description))
                .WithMessage("Description contains invalid content")
                .Must(NotContainHtmlTags).When(x => !string.IsNullOrEmpty(x.Description))
                .WithMessage("Description should not contain HTML tags");

            RuleFor(x => x.Price)
                .NotEmpty().WithMessage("Price is required")
                .GreaterThan(0).WithMessage("Price must be greater than 0")
                .LessThanOrEqualTo(999999.99m).WithMessage("Price cannot exceed 999,999.99")
                .PrecisionScale(8, 2, true).WithMessage("Price can have maximum 2 decimal places");

            RuleFor(x => x.StockQuantity)
                .NotNull().WithMessage("Stock quantity is required")
                .GreaterThanOrEqualTo(0).WithMessage("Stock quantity must be non-negative")
                .LessThanOrEqualTo(1000000).WithMessage("Stock quantity seems unrealistic");

            RuleFor(x => x.Category)
                .NotEmpty().WithMessage("Category is required")
                .MaximumLength(50).WithMessage("Category cannot exceed 50 characters")
                .Must(BeValidCategory).WithMessage($"Category must be one of: {string.Join(", ", _allowedCategories)}");

            RuleFor(x => x.ImageUrl)
                .Must(BeValidUrl).When(x => !string.IsNullOrEmpty(x.ImageUrl))
                .WithMessage("Invalid URL format")
                .Must(BeSecureUrl).When(x => !string.IsNullOrEmpty(x.ImageUrl))
                .WithMessage("Image URL should use HTTPS for security")
                .Must(BeValidImageUrl).When(x => !string.IsNullOrEmpty(x.ImageUrl))
                .WithMessage("URL must point to a valid image file");

            RuleFor(x => x.Sku)
                .Matches(@"^[A-Z0-9\-]+$").When(x => !string.IsNullOrEmpty(x.Sku))
                .WithMessage("SKU must contain only uppercase letters, numbers, and hyphens")
                .MaximumLength(20).WithMessage("SKU cannot exceed 20 characters");

            RuleFor(x => x.Status)
                .NotEmpty().WithMessage("Product status is required")
                .Must(BeValidStatus).WithMessage($"Status must be one of: {string.Join(", ", _allowedStatuses)}");

            // Business rules
            RuleSet("BusinessRules", () =>
            {
                RuleFor(x => x)
                    .Must(HaveStockForActiveProducts)
                    .WithMessage("Active products must have stock available")
                    .WithName("StockAvailability");

                RuleFor(x => x.Price)
                    .Must((model, price) => BeReasonablePriceForCategory(price, model.Category))
                    .WithMessage("Price seems unreasonable for this category");
            });
        }

        private bool NotContainScriptTags(string input)
        {
            if (string.IsNullOrEmpty(input)) return true;
            
            var scriptPattern = @"<script.*?>.*?</script>|javascript:|on\w+\s*=|eval\(|expression\(";
            return !Regex.IsMatch(input, scriptPattern, RegexOptions.IgnoreCase);
        }

        private bool NotContainHtmlTags(string input)
        {
            if (string.IsNullOrEmpty(input)) return true;
            
            var htmlPattern = @"<[^>]+>";
            return !Regex.IsMatch(input, htmlPattern);
        }

        private bool NotContainSqlKeywords(string input)
        {
            if (string.IsNullOrEmpty(input)) return true;
            
            var sqlKeywords = new[] { "select", "insert", "update", "delete", "drop", "union", "exec", "execute", "--", "/*", "*/" };
            var lowerInput = input.ToLower();
            return !sqlKeywords.Any(keyword => lowerInput.Contains(keyword));
        }

        private bool BeValidCategory(string category)
        {
            return _allowedCategories.Contains(category);
        }

        private bool BeValidStatus(string status)
        {
            return _allowedStatuses.Contains(status);
        }

        private bool BeValidUrl(string url)
        {
            return Uri.TryCreate(url, UriKind.Absolute, out var result) &&
                   (result.Scheme == Uri.UriSchemeHttp || result.Scheme == Uri.UriSchemeHttps);
        }

        private bool BeSecureUrl(string url)
        {
            return Uri.TryCreate(url, UriKind.Absolute, out var result) &&
                   result.Scheme == Uri.UriSchemeHttps;
        }

        private bool BeValidImageUrl(string url)
        {
            var validExtensions = new[] { ".jpg", ".jpeg", ".png", ".gif", ".webp", ".svg" };
            return validExtensions.Any(ext => url.ToLower().EndsWith(ext));
        }

        private bool HaveStockForActiveProducts(ProductModel product)
        {
            return product.Status != "Active" || product.StockQuantity > 0;
        }

        private bool BeReasonablePriceForCategory(decimal price, string category)
        {
            var maxPrices = new Dictionary<string, decimal>
            {
                { "Electronics", 10000 },
                { "Clothing", 1000 },
                { "Food", 100 },
                { "Books", 200 },
                { "Home & Garden", 5000 },
                { "Sports", 2000 },
                { "Toys", 500 },
                { "Other", 10000 }
            };

            return !maxPrices.ContainsKey(category) || price <= maxPrices[category];
        }
    }
}