using FluentValidation;
using InputValidation.Models;
using System.Text.RegularExpressions;

namespace InputValidation.Validators
{
    public class UserRegistrationValidator : AbstractValidator<UserRegistrationModel>
    {
        private readonly List<string> _bannedUsernames = new() { "admin", "root", "administrator", "system", "test" };
        private readonly List<string> _commonPasswords = new() { "password", "123456", "qwerty", "abc123", "password123" };

        public UserRegistrationValidator()
        {
            RuleFor(x => x.Username)
                .NotEmpty().WithMessage("Username is required")
                .Length(3, 50).WithMessage("Username must be between 3 and 50 characters")
                .Matches(@"^[a-zA-Z0-9_]+$").WithMessage("Username can only contain letters, numbers, and underscores")
                .Must(NotBeBannedUsername).WithMessage("This username is not allowed")
                .Must(NotContainSqlKeywords).WithMessage("Username contains invalid keywords");

            RuleFor(x => x.Email)
                .NotEmpty().WithMessage("Email is required")
                .EmailAddress().WithMessage("Invalid email format")
                .MaximumLength(100).WithMessage("Email cannot exceed 100 characters")
                .Must(BeValidEmailDomain).WithMessage("Email domain is not allowed");

            RuleFor(x => x.Password)
                .NotEmpty().WithMessage("Password is required")
                .Length(8, 100).WithMessage("Password must be between 8 and 100 characters")
                .Must(BeStrongPassword).WithMessage("Password must contain at least one uppercase letter, one lowercase letter, one number, and one special character")
                .Must(NotBeCommonPassword).WithMessage("This password is too common. Please choose a stronger password")
                .Must((model, password) => !ContainsUserInfo(password, model)).WithMessage("Password should not contain your personal information");

            RuleFor(x => x.ConfirmPassword)
                .NotEmpty().WithMessage("Password confirmation is required")
                .Equal(x => x.Password).WithMessage("Passwords do not match");

            RuleFor(x => x.FirstName)
                .NotEmpty().WithMessage("First name is required")
                .MaximumLength(50).WithMessage("First name cannot exceed 50 characters")
                .Matches(@"^[a-zA-Z\s'-]+$").WithMessage("First name contains invalid characters")
                .Must(NotContainScriptTags).WithMessage("First name contains invalid content");

            RuleFor(x => x.LastName)
                .NotEmpty().WithMessage("Last name is required")
                .MaximumLength(50).WithMessage("Last name cannot exceed 50 characters")
                .Matches(@"^[a-zA-Z\s'-]+$").WithMessage("Last name contains invalid characters")
                .Must(NotContainScriptTags).WithMessage("Last name contains invalid content");

            RuleFor(x => x.PhoneNumber)
                .Matches(@"^[\d\s\-\+\(\)]+$").When(x => !string.IsNullOrEmpty(x.PhoneNumber))
                .WithMessage("Invalid phone number format");

            RuleFor(x => x.Age)
                .InclusiveBetween(13, 120).When(x => x.Age.HasValue)
                .WithMessage("Age must be between 13 and 120");

            RuleFor(x => x.AcceptTerms)
                .Equal(true).WithMessage("You must accept the terms and conditions");
        }

        private bool NotBeBannedUsername(string username)
        {
            return !_bannedUsernames.Contains(username?.ToLower() ?? string.Empty);
        }

        private bool NotContainSqlKeywords(string input)
        {
            if (string.IsNullOrEmpty(input)) return true;
            
            var sqlKeywords = new[] { "select", "insert", "update", "delete", "drop", "union", "exec", "execute" };
            var lowerInput = input.ToLower();
            return !sqlKeywords.Any(keyword => lowerInput.Contains(keyword));
        }

        private bool BeValidEmailDomain(string email)
        {
            if (string.IsNullOrEmpty(email)) return true;
            
            var blockedDomains = new[] { "tempmail.com", "throwaway.email", "guerrillamail.com" };
            var domain = email.Split('@').LastOrDefault()?.ToLower();
            return !blockedDomains.Contains(domain);
        }

        private bool BeStrongPassword(string password)
        {
            if (string.IsNullOrEmpty(password)) return false;
            
            var hasUpperCase = Regex.IsMatch(password, @"[A-Z]");
            var hasLowerCase = Regex.IsMatch(password, @"[a-z]");
            var hasDigit = Regex.IsMatch(password, @"\d");
            var hasSpecialChar = Regex.IsMatch(password, @"[@$!%*?&#]");
            
            return hasUpperCase && hasLowerCase && hasDigit && hasSpecialChar;
        }

        private bool NotBeCommonPassword(string password)
        {
            return !_commonPasswords.Contains(password?.ToLower() ?? string.Empty);
        }

        private bool ContainsUserInfo(string password, UserRegistrationModel model)
        {
            if (string.IsNullOrEmpty(password)) return false;
            
            var lowerPassword = password.ToLower();
            return lowerPassword.Contains(model.Username?.ToLower() ?? "") ||
                   lowerPassword.Contains(model.FirstName?.ToLower() ?? "") ||
                   lowerPassword.Contains(model.LastName?.ToLower() ?? "") ||
                   lowerPassword.Contains(model.Email?.Split('@')[0].ToLower() ?? "");
        }

        private bool NotContainScriptTags(string input)
        {
            if (string.IsNullOrEmpty(input)) return true;
            
            var scriptPattern = @"<script.*?>.*?</script>|javascript:|on\w+\s*=";
            return !Regex.IsMatch(input, scriptPattern, RegexOptions.IgnoreCase);
        }
    }
}