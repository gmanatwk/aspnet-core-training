using Microsoft.AspNetCore.Mvc;
using ProductCatalog.API.DTOs;
using ProductCatalog.API.Models;
using ProductCatalog.API.Services;

namespace ProductCatalog.API.Controllers;

/// <summary>
/// Controller for managing orders
/// </summary>
[ApiController]
[Route("api/[controller]")]
[Produces("application/json")]
public class OrdersController : ControllerBase
{
    private readonly IOrderService _orderService;
    private readonly INotificationService _notificationService;
    private readonly ILogger<OrdersController> _logger;

    public OrdersController(
        IOrderService orderService,
        INotificationService notificationService,
        ILogger<OrdersController> logger)
    {
        _orderService = orderService;
        _notificationService = notificationService;
        _logger = logger;
    }

    /// <summary>
    /// Create a new order
    /// </summary>
    /// <param name="createDto">Order creation data</param>
    /// <returns>Created order</returns>
    [HttpPost]
    [ProducesResponseType(typeof(ApiResponse<OrderResponseDto>), 201)]
    [ProducesResponseType(typeof(ApiResponse<object>), 400)]
    public async Task<ActionResult<ApiResponse<OrderResponseDto>>> CreateOrder([FromBody] CreateOrderDto createDto)
    {
        try
        {
            _logger.LogInformation("Creating new order for customer: {CustomerEmail}", createDto.CustomerEmail);

            if (!ModelState.IsValid)
            {
                var errors = ModelState.Values
                    .SelectMany(v => v.Errors)
                    .Select(e => e.ErrorMessage)
                    .ToList();

                return BadRequest(new ApiResponse<object>
                {
                    Success = false,
                    Message = "Validation failed",
                    Errors = errors
                });
            }

            // Validate email format
            var isValidEmail = await _notificationService.IsEmailValidAsync(createDto.CustomerEmail);
            if (!isValidEmail)
            {
                return BadRequest(new ApiResponse<object>
                {
                    Success = false,
                    Message = "Invalid email address",
                    Errors = new List<string> { "Please provide a valid email address" }
                });
            }

            var order = await _orderService.CreateOrderAsync(createDto);

            // Send confirmation email
            try
            {
                await _notificationService.SendEmailAsync(
                    createDto.CustomerEmail,
                    $"Order Confirmation - #{order.Id}",
                    $"Thank you for your order! Your order #{order.Id} has been received and is being processed.");
            }
            catch (Exception emailEx)
            {
                _logger.LogWarning(emailEx, "Failed to send order confirmation email for order: {OrderId}", order.Id);
                // Don't fail the order creation if email fails
            }

            return CreatedAtAction(
                nameof(GetOrder),
                new { id = order.Id },
                new ApiResponse<OrderResponseDto>
                {
                    Success = true,
                    Message = "Order created successfully",
                    Data = order
                });
        }
        catch (ArgumentException ex)
        {
            _logger.LogWarning(ex, "Validation error creating order for customer: {CustomerEmail}", createDto.CustomerEmail);
            return BadRequest(new ApiResponse<object>
            {
                Success = false,
                Message = "Validation error",
                Errors = new List<string> { ex.Message }
            });
        }
        catch (InvalidOperationException ex)
        {
            _logger.LogWarning(ex, "Business logic error creating order for customer: {CustomerEmail}", createDto.CustomerEmail);
            return BadRequest(new ApiResponse<object>
            {
                Success = false,
                Message = "Order creation failed",
                Errors = new List<string> { ex.Message }
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error creating order for customer: {CustomerEmail}", createDto.CustomerEmail);
            return BadRequest(new ApiResponse<object>
            {
                Success = false,
                Message = "Error creating order",
                Errors = new List<string> { ex.Message }
            });
        }
    }

    /// <summary>
    /// Get order by ID
    /// </summary>
    /// <param name="id">Order ID</param>
    /// <returns>Order details</returns>
    [HttpGet("{id:int}")]
    [ProducesResponseType(typeof(ApiResponse<OrderResponseDto>), 200)]
    [ProducesResponseType(typeof(ApiResponse<object>), 404)]
    [ProducesResponseType(typeof(ApiResponse<object>), 400)]
    public async Task<ActionResult<ApiResponse<OrderResponseDto>>> GetOrder(int id)
    {
        try
        {
            _logger.LogInformation("Getting order by ID: {OrderId}", id);

            if (id <= 0)
            {
                return BadRequest(new ApiResponse<object>
                {
                    Success = false,
                    Message = "Invalid order ID",
                    Errors = new List<string> { "Order ID must be greater than 0" }
                });
            }

            var order = await _orderService.GetOrderByIdAsync(id);

            if (order == null)
            {
                return NotFound(new ApiResponse<object>
                {
                    Success = false,
                    Message = "Order not found",
                    Errors = new List<string> { $"Order with ID {id} was not found" }
                });
            }

            return Ok(new ApiResponse<OrderResponseDto>
            {
                Success = true,
                Message = "Order retrieved successfully",
                Data = order
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting order by ID: {OrderId}", id);
            return BadRequest(new ApiResponse<object>
            {
                Success = false,
                Message = "Error retrieving order",
                Errors = new List<string> { ex.Message }
            });
        }
    }

    /// <summary>
    /// Get orders with pagination
    /// </summary>
    /// <param name="pageNumber">Page number (default: 1)</param>
    /// <param name="pageSize">Page size (default: 10)</param>
    /// <returns>Paginated list of orders</returns>
    [HttpGet]
    [ProducesResponseType(typeof(ApiResponse<PagedResponse<OrderResponseDto>>), 200)]
    [ProducesResponseType(typeof(ApiResponse<object>), 400)]
    public async Task<ActionResult<ApiResponse<PagedResponse<OrderResponseDto>>>> GetOrders(
        [FromQuery] int pageNumber = 1, 
        [FromQuery] int pageSize = 10)
    {
        try
        {
            _logger.LogInformation("Getting orders - Page: {PageNumber}, Size: {PageSize}", pageNumber, pageSize);

            if (pageNumber <= 0)
            {
                return BadRequest(new ApiResponse<object>
                {
                    Success = false,
                    Message = "Invalid page number",
                    Errors = new List<string> { "Page number must be greater than 0" }
                });
            }

            if (pageSize <= 0 || pageSize > 100)
            {
                return BadRequest(new ApiResponse<object>
                {
                    Success = false,
                    Message = "Invalid page size",
                    Errors = new List<string> { "Page size must be between 1 and 100" }
                });
            }

            var result = await _orderService.GetOrdersAsync(pageNumber, pageSize);

            return Ok(new ApiResponse<PagedResponse<OrderResponseDto>>
            {
                Success = true,
                Message = "Orders retrieved successfully",
                Data = result
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting orders");
            return BadRequest(new ApiResponse<object>
            {
                Success = false,
                Message = "Error retrieving orders",
                Errors = new List<string> { ex.Message }
            });
        }
    }

    /// <summary>
    /// Get orders by customer email
    /// </summary>
    /// <param name="customerEmail">Customer email address</param>
    /// <returns>List of customer orders</returns>
    [HttpGet("customer/{customerEmail}")]
    [ProducesResponseType(typeof(ApiResponse<List<OrderResponseDto>>), 200)]
    [ProducesResponseType(typeof(ApiResponse<object>), 400)]
    public async Task<ActionResult<ApiResponse<List<OrderResponseDto>>>> GetOrdersByCustomer(string customerEmail)
    {
        try
        {
            _logger.LogInformation("Getting orders for customer: {CustomerEmail}", customerEmail);

            if (string.IsNullOrWhiteSpace(customerEmail))
            {
                return BadRequest(new ApiResponse<object>
                {
                    Success = false,
                    Message = "Invalid customer email",
                    Errors = new List<string> { "Customer email is required" }
                });
            }

            var orders = await _orderService.GetOrdersByCustomerEmailAsync(customerEmail);

            return Ok(new ApiResponse<List<OrderResponseDto>>
            {
                Success = true,
                Message = "Customer orders retrieved successfully",
                Data = orders
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting orders for customer: {CustomerEmail}", customerEmail);
            return BadRequest(new ApiResponse<object>
            {
                Success = false,
                Message = "Error retrieving customer orders",
                Errors = new List<string> { ex.Message }
            });
        }
    }

    /// <summary>
    /// Update order status
    /// </summary>
    /// <param name="id">Order ID</param>
    /// <param name="newStatus">New order status</param>
    /// <returns>Success confirmation</returns>
    [HttpPatch("{id:int}/status")]
    [ProducesResponseType(typeof(ApiResponse<object>), 200)]
    [ProducesResponseType(typeof(ApiResponse<object>), 404)]
    [ProducesResponseType(typeof(ApiResponse<object>), 400)]
    public async Task<ActionResult<ApiResponse<object>>> UpdateOrderStatus(int id, [FromBody] OrderStatus newStatus)
    {
        try
        {
            _logger.LogInformation("Updating order status: {OrderId} to {NewStatus}", id, newStatus);

            if (id <= 0)
            {
                return BadRequest(new ApiResponse<object>
                {
                    Success = false,
                    Message = "Invalid order ID",
                    Errors = new List<string> { "Order ID must be greater than 0" }
                });
            }

            if (!Enum.IsDefined(typeof(OrderStatus), newStatus))
            {
                return BadRequest(new ApiResponse<object>
                {
                    Success = false,
                    Message = "Invalid order status",
                    Errors = new List<string> { "Please provide a valid order status" }
                });
            }

            var success = await _orderService.UpdateOrderStatusAsync(id, newStatus);

            if (!success)
            {
                return NotFound(new ApiResponse<object>
                {
                    Success = false,
                    Message = "Order not found",
                    Errors = new List<string> { $"Order with ID {id} was not found" }
                });
            }

            return Ok(new ApiResponse<object>
            {
                Success = true,
                Message = "Order status updated successfully",
                Data = new { OrderId = id, NewStatus = newStatus.ToString() }
            });
        }
        catch (InvalidOperationException ex)
        {
            _logger.LogWarning(ex, "Invalid status transition for order: {OrderId}", id);
            return BadRequest(new ApiResponse<object>
            {
                Success = false,
                Message = "Invalid status transition",
                Errors = new List<string> { ex.Message }
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error updating order status: {OrderId}", id);
            return BadRequest(new ApiResponse<object>
            {
                Success = false,
                Message = "Error updating order status",
                Errors = new List<string> { ex.Message }
            });
        }
    }

    /// <summary>
    /// Cancel an order
    /// </summary>
    /// <param name="id">Order ID</param>
    /// <returns>Success confirmation</returns>
    [HttpPost("{id:int}/cancel")]
    [ProducesResponseType(typeof(ApiResponse<object>), 200)]
    [ProducesResponseType(typeof(ApiResponse<object>), 404)]
    [ProducesResponseType(typeof(ApiResponse<object>), 400)]
    public async Task<ActionResult<ApiResponse<object>>> CancelOrder(int id)
    {
        try
        {
            _logger.LogInformation("Cancelling order: {OrderId}", id);

            if (id <= 0)
            {
                return BadRequest(new ApiResponse<object>
                {
                    Success = false,
                    Message = "Invalid order ID",
                    Errors = new List<string> { "Order ID must be greater than 0" }
                });
            }

            var success = await _orderService.CancelOrderAsync(id);

            if (!success)
            {
                return NotFound(new ApiResponse<object>
                {
                    Success = false,
                    Message = "Order not found",
                    Errors = new List<string> { $"Order with ID {id} was not found" }
                });
            }

            return Ok(new ApiResponse<object>
            {
                Success = true,
                Message = "Order cancelled successfully",
                Data = new { OrderId = id, Status = "Cancelled" }
            });
        }
        catch (InvalidOperationException ex)
        {
            _logger.LogWarning(ex, "Cannot cancel order: {OrderId}", id);
            return BadRequest(new ApiResponse<object>
            {
                Success = false,
                Message = "Cannot cancel order",
                Errors = new List<string> { ex.Message }
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error cancelling order: {OrderId}", id);
            return BadRequest(new ApiResponse<object>
            {
                Success = false,
                Message = "Error cancelling order",
                Errors = new List<string> { ex.Message }
            });
        }
    }

    /// <summary>
    /// Calculate order total before creating
    /// </summary>
    /// <param name="items">Order items</param>
    /// <returns>Total amount</returns>
    [HttpPost("calculate-total")]
    [ProducesResponseType(typeof(ApiResponse<decimal>), 200)]
    [ProducesResponseType(typeof(ApiResponse<object>), 400)]
    public async Task<ActionResult<ApiResponse<decimal>>> CalculateOrderTotal([FromBody] List<CreateOrderItemDto> items)
    {
        try
        {
            _logger.LogInformation("Calculating order total for {ItemCount} items", items.Count);

            if (items == null || !items.Any())
            {
                return BadRequest(new ApiResponse<object>
                {
                    Success = false,
                    Message = "Invalid order items",
                    Errors = new List<string> { "At least one order item is required" }
                });
            }

            var total = await _orderService.CalculateOrderTotalAsync(items);

            return Ok(new ApiResponse<decimal>
            {
                Success = true,
                Message = "Order total calculated successfully",
                Data = total
            });
        }
        catch (ArgumentException ex)
        {
            _logger.LogWarning(ex, "Validation error calculating order total");
            return BadRequest(new ApiResponse<object>
            {
                Success = false,
                Message = "Validation error",
                Errors = new List<string> { ex.Message }
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error calculating order total");
            return BadRequest(new ApiResponse<object>
            {
                Success = false,
                Message = "Error calculating order total",
                Errors = new List<string> { ex.Message }
            });
        }
    }
}
