using FluentValidation.Results;

namespace InputValidation.Services
{
    public interface IValidationService
    {
        Task<ValidationResult> ValidateAsync<T>(T model);
        ValidationResult Validate<T>(T model);
        Task<bool> IsValidAsync<T>(T model);
        bool IsValid<T>(T model);
        Dictionary<string, List<string>> GetValidationErrors(ValidationResult result);
        string GetFirstError(ValidationResult result);
        Task<(bool IsValid, Dictionary<string, List<string>> Errors)> ValidateWithErrorsAsync<T>(T model);
    }
}