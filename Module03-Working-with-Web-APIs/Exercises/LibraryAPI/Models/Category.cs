namespace LibraryAPI.Models
{
    public class Category
    {
        public int Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        
        // Navigation property
        public List<Book> Books { get; set; } = new();
    }
}