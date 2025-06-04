using System.ComponentModel.DataAnnotations;

namespace LibraryAPI.DTOs
{
    public record BookDto(
        int Id,
        string Title,
        string ISBN,
        int PublicationYear,
        int NumberOfPages,
        string Summary,
        string AuthorName,
        string CategoryName,
        DateTime CreatedAt,
        DateTime? UpdatedAt
    );

    public record CreateBookDto(
        [Required] [StringLength(200, MinimumLength = 1)] string Title,
        [Required] [RegularExpression(@"^\d{3}-\d{10}$", ErrorMessage = "ISBN must be in format XXX-XXXXXXXXXX")] string ISBN,
        [Range(1450, 2100, ErrorMessage = "Publication year must be between 1450 and current year + 5")] int PublicationYear,
        [Range(1, 10000, ErrorMessage = "Number of pages must be between 1 and 10000")] int NumberOfPages,
        [StringLength(2000)] string Summary,
        [Required] int AuthorId,
        [Required] int CategoryId
    );

    public record UpdateBookDto(
        [Required] [StringLength(200, MinimumLength = 1)] string Title,
        [Required] [RegularExpression(@"^\d{3}-\d{10}$")] string ISBN,
        [Range(1450, 2100)] int PublicationYear,
        [Range(1, 10000)] int NumberOfPages,
        [StringLength(2000)] string Summary,
        [Required] int AuthorId,
        [Required] int CategoryId
    );
}