using Microsoft.AspNetCore.Authorization;
using JwtAuthenticationAPI.Requirements;

namespace JwtAuthenticationAPI.Handlers;

public class WorkingHoursHandler : AuthorizationHandler<WorkingHoursRequirement>
{
    protected override Task HandleRequirementAsync(
        AuthorizationHandlerContext context,
        WorkingHoursRequirement requirement)
    {
        var currentTime = DateTime.Now.TimeOfDay;
        
        if (currentTime >= requirement.StartTime && currentTime <= requirement.EndTime)
        {
            context.Succeed(requirement);
        }
        
        return Task.CompletedTask;
    }
}