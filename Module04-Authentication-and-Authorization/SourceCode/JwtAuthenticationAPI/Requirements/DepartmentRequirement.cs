using Microsoft.AspNetCore.Authorization;

namespace JwtAuthenticationAPI.Requirements;

public class DepartmentRequirement : IAuthorizationRequirement
{
    public string[] AllowedDepartments { get; }
    
    public DepartmentRequirement(params string[] departments)
    {
        AllowedDepartments = departments;
    }
}