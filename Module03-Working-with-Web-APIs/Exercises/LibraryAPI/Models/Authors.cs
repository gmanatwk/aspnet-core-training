namespace LibraryAPI.Models
{
    public class Author
    {
        public int Id { get; set; }
        public string FirstName { get; set; } = string.Empty;
        public string LastName { get; set; } = string.Empty;
        public string Biography { get; set; } = string.Empty;
        public DateTime DateOfBirth { get; set; }
        
        // Navigation property
        public List<Book> Books { get; set; } = new();
        public string Nationality { get; internal set; }
    }
}