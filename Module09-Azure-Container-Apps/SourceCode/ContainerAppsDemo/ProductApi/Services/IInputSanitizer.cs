namespace InputValidation.Services
{
    public interface IInputSanitizer
    {
        string SanitizeHtml(string input);
        string SanitizeForDisplay(string input);
        string SanitizeForDatabase(string input);
        string SanitizeFileName(string fileName);
        string SanitizeUrl(string url);
        string RemoveScriptTags(string input);
        string EncodeForJavaScript(string input);
        string SanitizeForJson(string input);
        string StripNonAlphanumeric(string input);
        string SanitizePhoneNumber(string phoneNumber);
    }
}