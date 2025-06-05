using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace EFCoreDemo.Models;

/// <summary>
/// Book entity from Exercise 01
/// </summary>
public class Book
{
    [Key]
    public int Id { get; set; }

    [Required]
    [StringLength(200)]
    public string Title { get; set; } = string.Empty;

    [Required]
    [StringLength(20)]
    public string ISBN { get; set; } = string.Empty;

    [Column(TypeName = "decimal(18,2)")]
    public decimal Price { get; set; }

    public DateTime PublishedDate { get; set; }

    public bool IsAvailable { get; set; } = true;

    // Foreign Key for Exercise 02
    public int? PublisherId { get; set; }

    // Navigation properties
    public virtual Publisher? Publisher { get; set; }
    public virtual ICollection<BookAuthor> BookAuthors { get; set; } = new List<BookAuthor>();
}

/// <summary>
/// Author entity from Exercise 02
/// </summary>
public class Author
{
    [Key]
    public int Id { get; set; }

    [Required]
    [StringLength(100)]
    public string FirstName { get; set; } = string.Empty;

    [Required]
    [StringLength(100)]
    public string LastName { get; set; } = string.Empty;

    [Required]
    [EmailAddress]
    [StringLength(200)]
    public string Email { get; set; } = string.Empty;

    public DateTime? BirthDate { get; set; }

    [StringLength(100)]
    public string? Country { get; set; }

    // Navigation properties
    public virtual ICollection<BookAuthor> BookAuthors { get; set; } = new List<BookAuthor>();

    // Computed property
    [NotMapped]
    public string FullName => $"{FirstName} {LastName}";
}

/// <summary>
/// Publisher entity from Exercise 02
/// </summary>
public class Publisher
{
    [Key]
    public int Id { get; set; }

    [Required]
    [StringLength(200)]
    public string Name { get; set; } = string.Empty;

    [StringLength(500)]
    public string? Address { get; set; }

    [StringLength(200)]
    public string? Website { get; set; }

    public int FoundedYear { get; set; }

    // Navigation properties
    public virtual ICollection<Book> Books { get; set; } = new List<Book>();
}

/// <summary>
/// BookAuthor junction table from Exercise 02
/// </summary>
public class BookAuthor
{
    public int BookId { get; set; }
    public int AuthorId { get; set; }

    [StringLength(50)]
    public string Role { get; set; } = "Primary Author"; // Primary Author, Co-Author, Editor

    // Navigation properties
    public virtual Book Book { get; set; } = null!;
    public virtual Author Author { get; set; } = null!;
}