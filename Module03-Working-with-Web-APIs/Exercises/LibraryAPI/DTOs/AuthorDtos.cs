using System.ComponentModel.DataAnnotations;

namespace LibraryAPI.DTOs
{
    public record AuthorDto(
        int Id,
        string FirstName,
        string LastName,
        string Biography,
        DateTime DateOfBirth,
        string Nationality,
        int BookCount
    );

    public record CreateAuthorDto(
        [Required] [StringLength(100, MinimumLength = 1)] string FirstName,
        [Required] [StringLength(100, MinimumLength = 1)] string LastName,
        [StringLength(2000)] string Biography,
        [Required] DateTime DateOfBirth
    )
    {
        public IEnumerable<ValidationResult> Validate(ValidationContext validationContext)
        {
            if (DateOfBirth > DateTime.Now)
            {
                yield return new ValidationResult(
                    "Date of birth cannot be in the future",
                    new[] { nameof(DateOfBirth) }
                );
            }
        }
    }
}