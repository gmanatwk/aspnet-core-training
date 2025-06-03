using FluentValidation;
using FluentValidation.Results;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;

namespace InputValidation.Services
{
    public class ValidationService : IValidationService
    {
        private readonly IServiceProvider _serviceProvider;
        private readonly ILogger<ValidationService> _logger;

        public ValidationService(IServiceProvider serviceProvider, ILogger<ValidationService> logger)
        {
            _serviceProvider = serviceProvider;
            _logger = logger;
        }

        public async Task<ValidationResult> ValidateAsync<T>(T model)
        {
            if (model == null)
            {
                _logger.LogWarning("Attempted to validate null model of type {ModelType}", typeof(T).Name);
                return new ValidationResult(new[] { new ValidationFailure("", "Model cannot be null") });
            }

            var validator = _serviceProvider.GetService<IValidator<T>>();
            if (validator == null)
            {
                _logger.LogWarning("No validator found for type {ModelType}", typeof(T).Name);
                return new ValidationResult();
            }

            try
            {
                var result = await validator.ValidateAsync(model);
                
                if (!result.IsValid)
                {
                    _logger.LogInformation("Validation failed for {ModelType} with {ErrorCount} errors", 
                        typeof(T).Name, result.Errors.Count);
                }

                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error occurred during validation of {ModelType}", typeof(T).Name);
                return new ValidationResult(new[] { new ValidationFailure("", "An error occurred during validation") });
            }
        }

        public ValidationResult Validate<T>(T model)
        {
            if (model == null)
            {
                _logger.LogWarning("Attempted to validate null model of type {ModelType}", typeof(T).Name);
                return new ValidationResult(new[] { new ValidationFailure("", "Model cannot be null") });
            }

            var validator = _serviceProvider.GetService<IValidator<T>>();
            if (validator == null)
            {
                _logger.LogWarning("No validator found for type {ModelType}", typeof(T).Name);
                return new ValidationResult();
            }

            try
            {
                var result = validator.Validate(model);
                
                if (!result.IsValid)
                {
                    _logger.LogInformation("Validation failed for {ModelType} with {ErrorCount} errors", 
                        typeof(T).Name, result.Errors.Count);
                }

                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error occurred during validation of {ModelType}", typeof(T).Name);
                return new ValidationResult(new[] { new ValidationFailure("", "An error occurred during validation") });
            }
        }

        public async Task<bool> IsValidAsync<T>(T model)
        {
            var result = await ValidateAsync(model);
            return result.IsValid;
        }

        public bool IsValid<T>(T model)
        {
            var result = Validate(model);
            return result.IsValid;
        }

        public Dictionary<string, List<string>> GetValidationErrors(ValidationResult result)
        {
            var errors = new Dictionary<string, List<string>>();

            foreach (var error in result.Errors)
            {
                var propertyName = string.IsNullOrEmpty(error.PropertyName) ? "General" : error.PropertyName;
                
                if (!errors.ContainsKey(propertyName))
                {
                    errors[propertyName] = new List<string>();
                }
                
                errors[propertyName].Add(error.ErrorMessage);
            }

            return errors;
        }

        public string GetFirstError(ValidationResult result)
        {
            return result.Errors.FirstOrDefault()?.ErrorMessage ?? "Validation failed";
        }

        public async Task<(bool IsValid, Dictionary<string, List<string>> Errors)> ValidateWithErrorsAsync<T>(T model)
        {
            var result = await ValidateAsync(model);
            var errors = result.IsValid ? new Dictionary<string, List<string>>() : GetValidationErrors(result);
            
            return (result.IsValid, errors);
        }
    }
}