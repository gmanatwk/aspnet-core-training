using EFCoreDemo.Services;
using Microsoft.AspNetCore.Mvc;

namespace EFCoreDemo.Controllers;

/// <summary>
/// Query Test Controller from Exercise 02 - Advanced LINQ Queries
/// </summary>
[ApiController]
[Route("api/[controller]")]
public class QueryTestController : ControllerBase
{
    private readonly BookQueryService _queryService;
    private readonly ILogger<QueryTestController> _logger;

    public QueryTestController(BookQueryService queryService, ILogger<QueryTestController> logger)
    {
        _queryService = queryService;
        _logger = logger;
    }

    /// <summary>
    /// Get books with publishers
    /// </summary>
    [HttpGet("books-with-publishers")]
    public async Task<IActionResult> GetBooksWithPublishers()
    {
        try
        {
            var result = await _queryService.GetBooksWithPublishersAsync();
            return Ok(result);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting books with publishers");
            return StatusCode(500, "Internal server error");
        }
    }

    /// <summary>
    /// Get books by author
    /// </summary>
    [HttpGet("books-by-author/{authorId}")]
    public async Task<IActionResult> GetBooksByAuthor(int authorId)
    {
        try
        {
            var result = await _queryService.GetBooksByAuthorAsync(authorId);
            return Ok(result);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting books by author {AuthorId}", authorId);
            return StatusCode(500, "Internal server error");
        }
    }

    /// <summary>
    /// Get authors with book count
    /// </summary>
    [HttpGet("authors-with-book-count")]
    public async Task<IActionResult> GetAuthorsWithBookCount()
    {
        try
        {
            var result = await _queryService.GetAuthorsWithBookCountAsync();
            return Ok(result);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting authors with book count");
            return StatusCode(500, "Internal server error");
        }
    }

    /// <summary>
    /// Get books by year
    /// </summary>
    [HttpGet("books-by-year/{year}")]
    public async Task<IActionResult> GetBooksByYear(int year)
    {
        try
        {
            var result = await _queryService.GetBooksByYearAsync(year);
            return Ok(result);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting books by year {Year}", year);
            return StatusCode(500, "Internal server error");
        }
    }

    /// <summary>
    /// Get top expensive books
    /// </summary>
    [HttpGet("top-expensive-books")]
    public async Task<IActionResult> GetTopExpensiveBooks([FromQuery] int count = 5)
    {
        try
        {
            var result = await _queryService.GetTopExpensiveBooksAsync(count);
            return Ok(result);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting top expensive books");
            return StatusCode(500, "Internal server error");
        }
    }

    /// <summary>
    /// Get books with full details (authors and publisher)
    /// </summary>
    [HttpGet("books-with-full-details")]
    public async Task<IActionResult> GetBooksWithAuthorAndPublisher()
    {
        try
        {
            var result = await _queryService.GetBooksWithAuthorAndPublisherAsync();
            return Ok(result);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting books with full details");
            return StatusCode(500, "Internal server error");
        }
    }

    /// <summary>
    /// Get average price by publisher
    /// </summary>
    [HttpGet("average-price-by-publisher")]
    public async Task<IActionResult> GetAveragePriceByPublisher()
    {
        try
        {
            var result = await _queryService.GetAveragePriceByPublisherAsync();
            return Ok(result);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting average price by publisher");
            return StatusCode(500, "Internal server error");
        }
    }

    /// <summary>
    /// Get authors with expensive books
    /// </summary>
    [HttpGet("authors-with-expensive-books")]
    public async Task<IActionResult> GetAuthorsWithExpensiveBooks([FromQuery] decimal priceThreshold = 50)
    {
        try
        {
            var result = await _queryService.GetAuthorsWithExpensiveBooksAsync(priceThreshold);
            return Ok(result);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting authors with expensive books");
            return StatusCode(500, "Internal server error");
        }
    }

    /// <summary>
    /// Get books statistics by year
    /// </summary>
    [HttpGet("books-by-year-statistics")]
    public async Task<IActionResult> GetBooksByYearStatistics()
    {
        try
        {
            var result = await _queryService.GetBooksByYearStatisticsAsync();
            return Ok(result);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting books by year statistics");
            return StatusCode(500, "Internal server error");
        }
    }

    /// <summary>
    /// Search books across multiple fields
    /// </summary>
    [HttpGet("search")]
    public async Task<IActionResult> SearchBooks([FromQuery] string term)
    {
        try
        {
            if (string.IsNullOrWhiteSpace(term))
            {
                return BadRequest("Search term is required");
            }

            var result = await _queryService.SearchBooksAsync(term);
            return Ok(result);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error searching books with term: {Term}", term);
            return StatusCode(500, "Internal server error");
        }
    }
}