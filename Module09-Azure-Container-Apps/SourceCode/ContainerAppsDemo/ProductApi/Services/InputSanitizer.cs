using System.Text;
using System.Text.RegularExpressions;
using System.Web;

namespace InputValidation.Services
{
    public class InputSanitizer : IInputSanitizer
    {
        private readonly Regex _scriptTagRegex = new(@"<script.*?>.*?</script>", RegexOptions.IgnoreCase | RegexOptions.Singleline);
        private readonly Regex _htmlTagRegex = new(@"<[^>]+>");
        private readonly Regex _sqlKeywordRegex = new(@"\b(select|insert|update|delete|drop|union|exec|execute)\b", RegexOptions.IgnoreCase);
        private readonly Regex _whitespaceRegex = new(@"\s+");

        public string SanitizeHtml(string input)
        {
            if (string.IsNullOrEmpty(input)) return input;

            // Remove script tags
            input = RemoveScriptTags(input);

            // Remove event handlers
            input = Regex.Replace(input, @"on\w+\s*=\s*""[^""]*""", "", RegexOptions.IgnoreCase);
            input = Regex.Replace(input, @"on\w+\s*=\s*'[^']*'", "", RegexOptions.IgnoreCase);
            
            // Remove javascript: protocol
            input = Regex.Replace(input, @"javascript\s*:", "", RegexOptions.IgnoreCase);
            
            // Remove dangerous HTML elements
            var dangerousTags = new[] { "iframe", "object", "embed", "form", "input", "button" };
            foreach (var tag in dangerousTags)
            {
                input = Regex.Replace(input, $@"<{tag}.*?>.*?</{tag}>", "", RegexOptions.IgnoreCase | RegexOptions.Singleline);
                input = Regex.Replace(input, $@"<{tag}.*?/?>", "", RegexOptions.IgnoreCase);
            }

            return input.Trim();
        }

        public string SanitizeForDisplay(string input)
        {
            if (string.IsNullOrEmpty(input)) return input;

            // HTML encode for safe display
            input = HttpUtility.HtmlEncode(input);
            
            // Convert newlines to <br> for display
            input = input.Replace("\n", "<br>");
            
            return input;
        }

        public string SanitizeForDatabase(string input)
        {
            if (string.IsNullOrEmpty(input)) return input;

            // Remove any potential SQL injection attempts
            input = _sqlKeywordRegex.Replace(input, match => $"[{match.Value}]");
            
            // Escape single quotes
            input = input.Replace("'", "''");
            
            // Remove null bytes
            input = input.Replace("\0", "");
            
            // Normalize whitespace
            input = _whitespaceRegex.Replace(input, " ");
            
            return input.Trim();
        }

        public string SanitizeFileName(string fileName)
        {
            if (string.IsNullOrEmpty(fileName)) return fileName;

            // Remove path traversal attempts
            fileName = fileName.Replace("..", "");
            fileName = fileName.Replace("/", "");
            fileName = fileName.Replace("\\", "");
            
            // Remove invalid characters
            var invalidChars = Path.GetInvalidFileNameChars();
            foreach (var c in invalidChars)
            {
                fileName = fileName.Replace(c.ToString(), "");
            }
            
            // Limit length
            if (fileName.Length > 255)
            {
                var extension = Path.GetExtension(fileName);
                var nameWithoutExtension = Path.GetFileNameWithoutExtension(fileName);
                fileName = nameWithoutExtension.Substring(0, 255 - extension.Length) + extension;
            }
            
            // Ensure it doesn't start with a dot (hidden file on Unix)
            if (fileName.StartsWith("."))
            {
                fileName = "_" + fileName.Substring(1);
            }
            
            return fileName;
        }

        public string SanitizeUrl(string url)
        {
            if (string.IsNullOrEmpty(url)) return url;

            // Remove javascript: and data: protocols
            url = Regex.Replace(url, @"^(javascript|data|vbscript):", "", RegexOptions.IgnoreCase);
            
            // Ensure it's a valid URL
            if (Uri.TryCreate(url, UriKind.Absolute, out var uri))
            {
                // Only allow http and https
                if (uri.Scheme == Uri.UriSchemeHttp || uri.Scheme == Uri.UriSchemeHttps)
                {
                    return uri.ToString();
                }
            }
            
            return "";
        }

        public string RemoveScriptTags(string input)
        {
            if (string.IsNullOrEmpty(input)) return input;

            // Remove script tags and their content
            input = _scriptTagRegex.Replace(input, "");
            
            // Remove style tags that might contain javascript
            input = Regex.Replace(input, @"<style.*?>.*?</style>", "", RegexOptions.IgnoreCase | RegexOptions.Singleline);
            
            return input;
        }

        public string EncodeForJavaScript(string input)
        {
            if (string.IsNullOrEmpty(input)) return input;

            var sb = new StringBuilder();
            foreach (char c in input)
            {
                switch (c)
                {
                    case '"':
                        sb.Append("\\\"");
                        break;
                    case '\'':
                        sb.Append("\\'");
                        break;
                    case '\\':
                        sb.Append("\\\\");
                        break;
                    case '\n':
                        sb.Append("\\n");
                        break;
                    case '\r':
                        sb.Append("\\r");
                        break;
                    case '\t':
                        sb.Append("\\t");
                        break;
                    case '<':
                        sb.Append("\\u003C");
                        break;
                    case '>':
                        sb.Append("\\u003E");
                        break;
                    case '&':
                        sb.Append("\\u0026");
                        break;
                    default:
                        if (c < 32 || c > 126)
                        {
                            sb.AppendFormat("\\u{0:X4}", (int)c);
                        }
                        else
                        {
                            sb.Append(c);
                        }
                        break;
                }
            }
            return sb.ToString();
        }

        public string SanitizeForJson(string input)
        {
            if (string.IsNullOrEmpty(input)) return input;

            // Escape JSON special characters
            input = input.Replace("\\", "\\\\");
            input = input.Replace("\"", "\\\"");
            input = input.Replace("\n", "\\n");
            input = input.Replace("\r", "\\r");
            input = input.Replace("\t", "\\t");
            input = input.Replace("\b", "\\b");
            input = input.Replace("\f", "\\f");
            
            // Remove control characters
            input = Regex.Replace(input, @"[\x00-\x1F\x7F]", "");
            
            return input;
        }

        public string StripNonAlphanumeric(string input)
        {
            if (string.IsNullOrEmpty(input)) return input;

            return Regex.Replace(input, @"[^a-zA-Z0-9\s]", "");
        }

        public string SanitizePhoneNumber(string phoneNumber)
        {
            if (string.IsNullOrEmpty(phoneNumber)) return phoneNumber;

            // Keep only digits, spaces, hyphens, parentheses, and plus sign
            return Regex.Replace(phoneNumber, @"[^\d\s\-\+\(\)]", "");
        }
    }
}