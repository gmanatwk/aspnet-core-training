using System.ComponentModel.DataAnnotations;

namespace RestfulAPI.Models
{
    public class Book
    {
        public int Id { get; set; }

        [Required]
        [StringLength(300)]
        public string Title { get; set; } = string.Empty;

        [Required]
        [StringLength(20)]
        public string ISBN { get; set; } = string.Empty;

        public int PublicationYear { get; set; }

        public int NumberOfPages { get; set; }

        [StringLength(2000)]
        public string Summary { get; set; } = string.Empty;

        // Foreign Keys
        public int AuthorId { get; set; }
        public Author? Author { get; set; }

        public int CategoryId { get; set; }
        public Category? Category { get; set; }

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime? UpdatedAt { get; set; }
    }
}