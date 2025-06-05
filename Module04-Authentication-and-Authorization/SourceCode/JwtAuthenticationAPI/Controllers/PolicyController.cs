using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using JwtAuthenticationAPI.Models;
using System.Security.Claims;

namespace JwtAuthenticationAPI.Controllers;

/// <summary>
/// Custom policy endpoints from Exercise 03
/// </summary>
[ApiController]
[Route("api/[controller]")]
public class PolicyController : ControllerBase
{
    /// <summary>
    /// Adult content - requires minimum age of 18
    /// </summary>
    [HttpGet("adult-content")]
    [Authorize(Policy = "Adult")]
    public IActionResult GetAdultContent()
    {
        return Ok(new ApiResponse<object>
        {
            Success = true,
            Message = "Adult content accessed",
            Data = new { Content = "This content is restricted to users 18 and older" }
        });
    }
    
    /// <summary>
    /// IT Department resources - requires IT or Development department
    /// </summary>
    [HttpGet("it-resources")]
    [Authorize(Policy = "ITDepartment")]
    public IActionResult GetITResources()
    {
        var department = User.FindFirst("department")?.Value;
        
        return Ok(new ApiResponse<object>
        {
            Success = true,
            Message = "IT Department Resources",
            Data = new
            {
                Department = department,
                Resources = new[]
                {
                    "Source Code Repository",
                    "Development Servers",
                    "CI/CD Pipeline",
                    "Technical Documentation"
                }
            }
        });
    }
    
    /// <summary>
    /// Business hours only endpoint - accessible 9 AM to 5 PM
    /// </summary>
    [HttpGet("business-hours")]
    [Authorize(Policy = "BusinessHours")]
    public IActionResult GetBusinessHoursData()
    {
        return Ok(new ApiResponse<object>
        {
            Success = true,
            Message = "Business hours data accessed",
            Data = new
            {
                CurrentTime = DateTime.Now.ToString("HH:mm"),
                BusinessData = "This data is only available during business hours (9:00 - 17:00)"
            }
        });
    }
    
    /// <summary>
    /// Senior IT Staff endpoint - combined requirements
    /// </summary>
    [HttpGet("senior-it-data")]
    [Authorize(Policy = "SeniorITStaff")]
    public IActionResult GetSeniorITData()
    {
        var username = User.FindFirst(ClaimTypes.Name)?.Value;
        var department = User.FindFirst("department")?.Value;
        
        return Ok(new ApiResponse<object>
        {
            Success = true,
            Message = "Senior IT Staff Data",
            Data = new
            {
                User = username,
                Department = department,
                AccessLevel = "Senior",
                SensitiveData = new
                {
                    ServerPasswords = "********",
                    DatabaseConnections = "Encrypted",
                    APIKeys = "Secured"
                }
            }
        });
    }
    
    /// <summary>
    /// Public info - no authentication required
    /// </summary>
    [HttpGet("public-info")]
    public IActionResult GetPublicInfo()
    {
        return Ok(new ApiResponse<object>
        {
            Success = true,
            Message = "Public information",
            Data = new
            {
                CompanyName = "Tech Corp",
                Address = "123 Tech Street",
                Phone = "555-0123",
                OpenHours = "Mon-Fri 9:00-17:00"
            }
        });
    }
}