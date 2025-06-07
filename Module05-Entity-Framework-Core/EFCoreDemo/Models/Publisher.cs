using System.ComponentModel.DataAnnotations;

namespace EFCoreDemo.Models;

/// <summary>
/// Publisher entity for one-to-many relationship with Books
/// </summary>
public class Publisher
{
    [Key]
    public int Id { get; set; }

    [Required]
    [StringLength(100)]
    public string Name { get; set; } = string.Empty;

    [StringLength(200)]
    public string Address { get; set; } = string.Empty;

    [StringLength(100)]
    public string Website { get; set; } = string.Empty;

    public int FoundedYear { get; set; }

    // Navigation properties
    public virtual ICollection<Book> Books { get; set; } = new List<Book>();
}
