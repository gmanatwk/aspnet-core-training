using System.ComponentModel.DataAnnotations;

namespace RestfulAPI.Models
{
    public class Author
    {
        public int Id { get; set; }

        [Required]
        [StringLength(100)]
        public string FirstName { get; set; } = string.Empty;

        [Required]
        [StringLength(100)]
        public string LastName { get; set; } = string.Empty;

        [StringLength(100)]
        public string? Nationality { get; set; }

        public DateTime? DateOfBirth { get; set; }

        [StringLength(1000)]
        public string? Biography { get; set; }

        // Navigation property
        public ICollection<Book> Books { get; set; } = new List<Book>();
    }
}