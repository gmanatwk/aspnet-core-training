using System.ComponentModel.DataAnnotations;

namespace SharedLibrary.Models;

public class CustomerDto
{
    public int Id { get; set; }
    
    [Required]
    [StringLength(100)]
    public string FirstName { get; set; } = string.Empty;
    
    [Required]
    [StringLength(100)]
    public string LastName { get; set; } = string.Empty;
    
    [Required]
    [EmailAddress]
    public string Email { get; set; } = string.Empty;
    
    [Phone]
    public string? Phone { get; set; }
    
    public string? Address { get; set; }
    
    public string? City { get; set; }
    
    public string? Country { get; set; }
    
    public string? PostalCode { get; set; }
    
    public DateTime CreatedAt { get; set; }
    
    public DateTime? UpdatedAt { get; set; }
}

public class CreateCustomerDto
{
    [Required]
    [StringLength(100)]
    public string FirstName { get; set; } = string.Empty;
    
    [Required]
    [StringLength(100)]
    public string LastName { get; set; } = string.Empty;
    
    [Required]
    [EmailAddress]
    public string Email { get; set; } = string.Empty;
    
    [Phone]
    public string? Phone { get; set; }
    
    public string? Address { get; set; }
    
    public string? City { get; set; }
    
    public string? Country { get; set; }
    
    public string? PostalCode { get; set; }
}

public class UpdateCustomerDto
{
    [StringLength(100)]
    public string? FirstName { get; set; }
    
    [StringLength(100)]
    public string? LastName { get; set; }
    
    [EmailAddress]
    public string? Email { get; set; }
    
    [Phone]
    public string? Phone { get; set; }
    
    public string? Address { get; set; }
    
    public string? City { get; set; }
    
    public string? Country { get; set; }
    
    public string? PostalCode { get; set; }
}