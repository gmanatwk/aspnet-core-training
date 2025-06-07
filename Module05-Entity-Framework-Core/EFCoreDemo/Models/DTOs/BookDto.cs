using System.ComponentModel.DataAnnotations;

namespace EFCoreDemo.Models.DTOs;

/// <summary>
/// Book DTO for API responses without circular references
/// </summary>
public class BookDto
{
    public int Id { get; set; }
    public string Title { get; set; } = string.Empty;
    public string Author { get; set; } = string.Empty;
    public string ISBN { get; set; } = string.Empty;
    public decimal Price { get; set; }
    public DateTime PublishedDate { get; set; }
    public bool IsAvailable { get; set; }
    public string? PublisherName { get; set; }
    public List<string> Authors { get; set; } = new List<string>();
}

/// <summary>
/// Create Book DTO for API requests
/// </summary>
/// <example>
/// {
///   "title": "Learning ASP.NET Core",
///   "author": "John Developer",
///   "isbn": "978-1234567890",
///   "price": 29.99,
///   "publishedDate": "2024-01-15T00:00:00",
///   "isAvailable": true,
///   "publisherId": 1
/// }
/// </example>
public class CreateBookDto
{
    /// <summary>Book title</summary>
    /// <example>Learning ASP.NET Core</example>
    [Required(ErrorMessage = "Title is required")]
    [StringLength(200, ErrorMessage = "Title cannot exceed 200 characters")]
    public string Title { get; set; } = string.Empty;

    /// <summary>Author name</summary>
    /// <example>John Developer</example>
    [Required(ErrorMessage = "Author is required")]
    [StringLength(100, ErrorMessage = "Author name cannot exceed 100 characters")]
    public string Author { get; set; } = string.Empty;

    /// <summary>ISBN number</summary>
    /// <example>978-1234567890</example>
    [Required(ErrorMessage = "ISBN is required")]
    [StringLength(20, ErrorMessage = "ISBN cannot exceed 20 characters")]
    public string ISBN { get; set; } = string.Empty;

    /// <summary>Book price</summary>
    /// <example>29.99</example>
    [Range(0.01, 9999.99, ErrorMessage = "Price must be between 0.01 and 9999.99")]
    public decimal Price { get; set; }

    /// <summary>Publication date</summary>
    /// <example>2024-01-15T00:00:00</example>
    [Required(ErrorMessage = "Published date is required")]
    public DateTime PublishedDate { get; set; }

    /// <summary>Whether the book is available</summary>
    /// <example>true</example>
    public bool IsAvailable { get; set; } = true;

    /// <summary>Publisher ID (optional)</summary>
    /// <example>1</example>
    public int? PublisherId { get; set; }
}

/// <summary>
/// Update Book DTO for API requests
/// </summary>
/// <example>
/// {
///   "title": "Advanced ASP.NET Core",
///   "author": "Jane Developer",
///   "isbn": "978-0987654321",
///   "price": 39.99,
///   "publishedDate": "2024-02-20T00:00:00",
///   "isAvailable": true,
///   "publisherId": 2
/// }
/// </example>
public class UpdateBookDto
{
    /// <summary>Book title</summary>
    /// <example>Advanced ASP.NET Core</example>
    [Required(ErrorMessage = "Title is required")]
    [StringLength(200, ErrorMessage = "Title cannot exceed 200 characters")]
    public string Title { get; set; } = string.Empty;

    /// <summary>Author name</summary>
    /// <example>Jane Developer</example>
    [Required(ErrorMessage = "Author is required")]
    [StringLength(100, ErrorMessage = "Author name cannot exceed 100 characters")]
    public string Author { get; set; } = string.Empty;

    /// <summary>ISBN number</summary>
    /// <example>978-0987654321</example>
    [Required(ErrorMessage = "ISBN is required")]
    [StringLength(20, ErrorMessage = "ISBN cannot exceed 20 characters")]
    public string ISBN { get; set; } = string.Empty;

    /// <summary>Book price</summary>
    /// <example>39.99</example>
    [Range(0.01, 9999.99, ErrorMessage = "Price must be between 0.01 and 9999.99")]
    public decimal Price { get; set; }

    /// <summary>Publication date</summary>
    /// <example>2024-02-20T00:00:00</example>
    [Required(ErrorMessage = "Published date is required")]
    public DateTime PublishedDate { get; set; }

    /// <summary>Whether the book is available</summary>
    /// <example>true</example>
    public bool IsAvailable { get; set; }

    /// <summary>Publisher ID (optional)</summary>
    /// <example>2</example>
    public int? PublisherId { get; set; }
}
