using System.ComponentModel.DataAnnotations;

namespace LibraryAPI.Models.DTOs
{
    /// <summary>
    /// Book data transfer object for API responses
    /// </summary>
    public class BookDto
    {
        /// <summary>
        /// Unique identifier for the book
        /// </summary>
        public int Id { get; set; }

        /// <summary>
        /// Book title
        /// </summary>
        public string Title { get; set; } = string.Empty;

        /// <summary>
        /// Book author
        /// </summary>
        public string Author { get; set; } = string.Empty;

        /// <summary>
        /// Book category/genre
        /// </summary>
        public string Category { get; set; } = string.Empty;

        /// <summary>
        /// Publication year
        /// </summary>
        public int PublicationYear { get; set; }

        /// <summary>
        /// ISBN number
        /// </summary>
        public string ISBN { get; set; } = string.Empty;

        /// <summary>
        /// Number of available copies
        /// </summary>
        public int AvailableCopies { get; set; }
    }

    /// <summary>
    /// Enhanced book DTO for API version 2
    /// </summary>
    public class BookDtoV2 : BookDto
    {
        /// <summary>
        /// Book description
        /// </summary>
        public string Description { get; set; } = string.Empty;

        /// <summary>
        /// Publisher information
        /// </summary>
        public string Publisher { get; set; } = string.Empty;

        /// <summary>
        /// Book rating (1-5 stars)
        /// </summary>
        public decimal Rating { get; set; }

        /// <summary>
        /// Number of pages
        /// </summary>
        public int PageCount { get; set; }

        /// <summary>
        /// Book language
        /// </summary>
        public string Language { get; set; } = "English";

        /// <summary>
        /// Tags associated with the book
        /// </summary>
        public List<string> Tags { get; set; } = new();
    }

    /// <summary>
    /// DTO for creating new books
    /// </summary>
    public class CreateBookDto
    {
        /// <summary>
        /// Book title
        /// </summary>
        [Required]
        [StringLength(200)]
        public string Title { get; set; } = string.Empty;

        /// <summary>
        /// Book author
        /// </summary>
        [Required]
        [StringLength(100)]
        public string Author { get; set; } = string.Empty;

        /// <summary>
        /// Book category
        /// </summary>
        [Required]
        [StringLength(50)]
        public string Category { get; set; } = string.Empty;

        /// <summary>
        /// Publication year
        /// </summary>
        [Range(1000, 2030)]
        public int PublicationYear { get; set; }

        /// <summary>
        /// ISBN number
        /// </summary>
        [Required]
        [RegularExpression(@"^(?:ISBN(?:-1[03])?:? )?(?=[0-9X]{10}$|(?=(?:[0-9]+[- ]){3})[- 0-9X]{13}$|97[89][0-9]{10}$|(?=(?:[0-9]+[- ]){4})[- 0-9]{17}$)(?:97[89][- ]?)?[0-9]{1,5}[- ]?[0-9]+[- ]?[0-9]+[- ]?[0-9X]$")]
        public string ISBN { get; set; } = string.Empty;

        /// <summary>
        /// Number of copies
        /// </summary>
        [Range(0, 1000)]
        public int AvailableCopies { get; set; }

        /// <summary>
        /// Author ID (for database relationship)
        /// </summary>
        [Required]
        public int AuthorId { get; set; }

        /// <summary>
        /// Category ID (for database relationship)
        /// </summary>
        [Required]
        public int CategoryId { get; set; }
    }

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