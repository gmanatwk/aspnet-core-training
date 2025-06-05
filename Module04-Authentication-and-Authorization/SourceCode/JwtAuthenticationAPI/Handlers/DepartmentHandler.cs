using Microsoft.AspNetCore.Authorization;
using JwtAuthenticationAPI.Requirements;

namespace JwtAuthenticationAPI.Handlers;

public class DepartmentHandler : AuthorizationHandler<DepartmentRequirement>
{
    protected override Task HandleRequirementAsync(
        AuthorizationHandlerContext context,
        DepartmentRequirement requirement)
    {
        var departmentClaim = context.User.FindFirst("department");
        
        if (departmentClaim != null && requirement.AllowedDepartments.Contains(departmentClaim.Value))
        {
            context.Succeed(requirement);
        }
        
        return Task.CompletedTask;
    }
}