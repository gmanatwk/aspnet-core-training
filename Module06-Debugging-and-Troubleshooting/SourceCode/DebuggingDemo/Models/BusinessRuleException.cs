namespace DebuggingDemo.Models;

public class BusinessRuleException : Exception
{
    public string RuleName { get; }
    public string? RuleDetails { get; }
    public object? RelatedData { get; }
    public string ErrorCode { get; }
    
    public BusinessRuleException(string ruleName, string message, string errorCode = "BUSINESS_RULE_VIOLATION") 
        : base(message)
    {
        RuleName = ruleName;
        ErrorCode = errorCode;
    }
    
    public BusinessRuleException(string ruleName, string message, string ruleDetails, string errorCode = "BUSINESS_RULE_VIOLATION") 
        : base(message)
    {
        RuleName = ruleName;
        RuleDetails = ruleDetails;
        ErrorCode = errorCode;
    }
    
    public BusinessRuleException(string ruleName, string message, object relatedData, string errorCode = "BUSINESS_RULE_VIOLATION") 
        : base(message)
    {
        RuleName = ruleName;
        RelatedData = relatedData;
        ErrorCode = errorCode;
    }
    
    public BusinessRuleException(string ruleName, string message, Exception innerException, string errorCode = "BUSINESS_RULE_VIOLATION") 
        : base(message, innerException)
    {
        RuleName = ruleName;
        ErrorCode = errorCode;
    }
}