using Microsoft.Extensions.Logging;
using System.Text.Json;

namespace TrainingShared.Utilities
{
    public static class LoggerExtensions
    {
        public static void LogStructured<T>(this ILogger logger, LogLevel level, string message, T data)
        {
            var jsonData = JsonSerializer.Serialize(data, new JsonSerializerOptions { WriteIndented = true });
            logger.Log(level, "{Message} | Data: {Data}", message, jsonData);
        }

        public static void LogError(this ILogger logger, Exception ex, string message, params object[] args)
        {
            logger.LogError(ex, message, args);
        }

        public static void LogAPICall(this ILogger logger, string method, string endpoint, object? requestData = null)
        {
            var logMessage = $"API Call: {method} {endpoint}";
            if (requestData != null)
            {
                var jsonData = JsonSerializer.Serialize(requestData);
                logger.LogInformation("{LogMessage} | Request: {RequestData}", logMessage, jsonData);
            }
            else
            {
                logger.LogInformation(logMessage);
            }
        }
    }

    public static class ValidationHelper
    {
        public static bool IsValidEmail(string email)
        {
            if (string.IsNullOrWhiteSpace(email))
                return false;

            try
            {
                var addr = new System.Net.Mail.MailAddress(email);
                return addr.Address == email;
            }
            catch
            {
                return false;
            }
        }

        public static bool IsValidPhoneNumber(string phoneNumber)
        {
            if (string.IsNullOrWhiteSpace(phoneNumber))
                return false;

            // Remove all non-digit characters
            var digits = new string(phoneNumber.Where(char.IsDigit).ToArray());
            
            // Check if it has 10-15 digits (common range for phone numbers)
            return digits.Length >= 10 && digits.Length <= 15;
        }

        public static bool IsStrongPassword(string password)
        {
            if (string.IsNullOrWhiteSpace(password) || password.Length < 8)
                return false;

            var hasUpper = password.Any(char.IsUpper);
            var hasLower = password.Any(char.IsLower);
            var hasDigit = password.Any(char.IsDigit);
            var hasSpecial = password.Any(ch => !char.IsLetterOrDigit(ch));

            return hasUpper && hasLower && hasDigit && hasSpecial;
        }
    }

    public static class DateTimeHelper
    {
        public static string ToFriendlyString(this DateTime dateTime)
        {
            var timeSpan = DateTime.UtcNow - dateTime;

            if (timeSpan <= TimeSpan.FromSeconds(60))
                return "just now";
            if (timeSpan <= TimeSpan.FromMinutes(60))
                return $"{timeSpan.Minutes} minute{(timeSpan.Minutes > 1 ? "s" : "")} ago";
            if (timeSpan <= TimeSpan.FromHours(24))
                return $"{timeSpan.Hours} hour{(timeSpan.Hours > 1 ? "s" : "")} ago";
            if (timeSpan <= TimeSpan.FromDays(30))
                return $"{timeSpan.Days} day{(timeSpan.Days > 1 ? "s" : "")} ago";

            return dateTime.ToString("MMM dd, yyyy");
        }

        public static bool IsBusinessDay(this DateTime date)
        {
            return date.DayOfWeek != DayOfWeek.Saturday && date.DayOfWeek != DayOfWeek.Sunday;
        }

        public static DateTime StartOfDay(this DateTime date)
        {
            return new DateTime(date.Year, date.Month, date.Day, 0, 0, 0, date.Kind);
        }

        public static DateTime EndOfDay(this DateTime date)
        {
            return new DateTime(date.Year, date.Month, date.Day, 23, 59, 59, 999, date.Kind);
        }
    }

    public static class StringExtensions
    {
        public static string ToTitleCase(this string input)
        {
            if (string.IsNullOrWhiteSpace(input))
                return string.Empty;

            var words = input.Split(' ', StringSplitOptions.RemoveEmptyEntries);
            for (int i = 0; i < words.Length; i++)
            {
                if (words[i].Length > 0)
                {
                    words[i] = char.ToUpper(words[i][0]) + words[i][1..].ToLower();
                }
            }
            return string.Join(' ', words);
        }

        public static string Truncate(this string input, int maxLength, string suffix = "...")
        {
            if (string.IsNullOrWhiteSpace(input) || input.Length <= maxLength)
                return input;

            return input[..(maxLength - suffix.Length)] + suffix;
        }

        public static bool IsNullOrEmpty(this string? input)
        {
            return string.IsNullOrEmpty(input);
        }

        public static bool IsNullOrWhiteSpace(this string? input)
        {
            return string.IsNullOrWhiteSpace(input);
        }
    }

    public class ConfigurationHelper
    {
        public static string GetConnectionString(IConfiguration configuration, string name = "DefaultConnection")
        {
            return configuration.GetConnectionString(name) 
                ?? throw new InvalidOperationException($"Connection string '{name}' not found.");
        }

        public static T GetRequiredSection<T>(IConfiguration configuration, string sectionName) where T : new()
        {
            var section = new T();
            configuration.GetSection(sectionName).Bind(section);
            return section;
        }

        public static string GetRequiredValue(IConfiguration configuration, string key)
        {
            return configuration[key] 
                ?? throw new InvalidOperationException($"Configuration value '{key}' not found.");
        }
    }
}