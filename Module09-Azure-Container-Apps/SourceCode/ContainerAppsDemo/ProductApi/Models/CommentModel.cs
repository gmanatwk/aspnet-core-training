using System.ComponentModel.DataAnnotations;

namespace InputValidation.Models
{
    public class CommentModel
    {
        public int Id { get; set; }

        [Required(ErrorMessage = "Author name is required")]
        [StringLength(50, MinimumLength = 2, ErrorMessage = "Author name must be between 2 and 50 characters")]
        [RegularExpression(@"^[a-zA-Z\s\-']+$", ErrorMessage = "Author name contains invalid characters")]
        public string Author { get; set; }

        [Required(ErrorMessage = "Email is required")]
        [EmailAddress(ErrorMessage = "Invalid email format")]
        [StringLength(100, ErrorMessage = "Email cannot exceed 100 characters")]
        public string Email { get; set; }

        [Required(ErrorMessage = "Comment content is required")]
        [StringLength(1000, MinimumLength = 10, ErrorMessage = "Comment must be between 10 and 1000 characters")]
        public string Content { get; set; }

        [Range(1, 5, ErrorMessage = "Rating must be between 1 and 5")]
        public int? Rating { get; set; }

        [Url(ErrorMessage = "Invalid website URL format")]
        [StringLength(200, ErrorMessage = "Website URL cannot exceed 200 characters")]
        public string Website { get; set; }

        [Required(ErrorMessage = "Product ID is required")]
        [Range(1, int.MaxValue, ErrorMessage = "Invalid product ID")]
        public int ProductId { get; set; }

        [Required(ErrorMessage = "Comment status is required")]
        [RegularExpression(@"^(Pending|Approved|Rejected|Spam)$", ErrorMessage = "Invalid comment status")]
        public string Status { get; set; }

        public DateTime CreatedDate { get; set; }
        
        [RegularExpression(@"^(\d{1,3}\.){3}\d{1,3}$", ErrorMessage = "Invalid IP address format")]
        public string IpAddress { get; set; }

        // For nested replies
        public int? ParentCommentId { get; set; }
    }
}