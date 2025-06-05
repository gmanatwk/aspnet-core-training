using System.ComponentModel.DataAnnotations;

namespace RestfulAPI.Models.DTOs
{
    /// <summary>
    /// Pagination parameters for API requests
    /// </summary>
    public class PaginationParams
    {
        /// <summary>
        /// Page number (1-based)
        /// </summary>
        [Range(1, int.MaxValue)]
        public int PageNumber { get; set; } = 1;

        /// <summary>
        /// Number of items per page
        /// </summary>
        [Range(1, 100)]
        public int PageSize { get; set; } = 10;
    }

    /// <summary>
    /// Paginated response wrapper
    /// </summary>
    /// <typeparam name="T">Type of data being paginated</typeparam>
    public class PaginatedResponse<T>
    {
        /// <summary>
        /// Current page number
        /// </summary>
        public int PageNumber { get; set; }

        /// <summary>
        /// Number of items per page
        /// </summary>
        public int PageSize { get; set; }

        /// <summary>
        /// Total number of items
        /// </summary>
        public int TotalCount { get; set; }

        /// <summary>
        /// Total number of pages
        /// </summary>
        public int TotalPages { get; set; }

        /// <summary>
        /// Whether there is a previous page
        /// </summary>
        public bool HasPreviousPage { get; set; }

        /// <summary>
        /// Whether there is a next page
        /// </summary>
        public bool HasNextPage { get; set; }

        /// <summary>
        /// The actual data items
        /// </summary>
        public List<T> Data { get; set; } = new();

        /// <summary>
        /// Create a paginated response
        /// </summary>
        public static PaginatedResponse<T> Create(List<T> data, int pageNumber, int pageSize, int totalCount)
        {
            var totalPages = (int)Math.Ceiling(totalCount / (double)pageSize);

            return new PaginatedResponse<T>
            {
                PageNumber = pageNumber,
                PageSize = pageSize,
                TotalCount = totalCount,
                TotalPages = totalPages,
                HasPreviousPage = pageNumber > 1,
                HasNextPage = pageNumber < totalPages,
                Data = data
            };
        }
    }

    /// <summary>
    /// Filter parameters for book searches
    /// </summary>
    public class BookFilterDto
    {
        /// <summary>
        /// Filter by category
        /// </summary>
        public string? Category { get; set; }

        /// <summary>
        /// Filter by author
        /// </summary>
        public string? Author { get; set; }

        /// <summary>
        /// Filter by publication year
        /// </summary>
        public int? Year { get; set; }

        /// <summary>
        /// Search in title and description
        /// </summary>
        public string? SearchTerm { get; set; }

        /// <summary>
        /// Minimum rating filter
        /// </summary>
        [Range(1, 5)]
        public decimal? MinRating { get; set; }

        /// <summary>
        /// Filter by language
        /// </summary>
        public string? Language { get; set; }

        /// <summary>
        /// Filter by tags
        /// </summary>
        public List<string>? Tags { get; set; }
    }

    /// <summary>
    /// Result of bulk operations
    /// </summary>
    public class BulkOperationResult
    {
        /// <summary>
        /// Number of items successfully processed
        /// </summary>
        public int SuccessCount { get; set; }

        /// <summary>
        /// Number of items that failed processing
        /// </summary>
        public int FailureCount { get; set; }

        /// <summary>
        /// Total number of items processed
        /// </summary>
        public int TotalCount { get; set; }

        /// <summary>
        /// List of errors that occurred
        /// </summary>
        public List<BulkOperationError> Errors { get; set; } = new();

        /// <summary>
        /// IDs of successfully created items
        /// </summary>
        public List<int> CreatedIds { get; set; } = new();
    }

    /// <summary>
    /// Error information for bulk operations
    /// </summary>
    public class BulkOperationError
    {
        /// <summary>
        /// Index of the item that failed
        /// </summary>
        public int Index { get; set; }

        /// <summary>
        /// Error message
        /// </summary>
        public string Message { get; set; } = string.Empty;

        /// <summary>
        /// The item that failed (optional)
        /// </summary>
        public object? Item { get; set; }
    }
}