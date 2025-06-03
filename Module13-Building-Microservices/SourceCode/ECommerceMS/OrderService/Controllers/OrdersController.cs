using Microsoft.AspNetCore.Mvc;
using OrderService.Models;
using OrderService.Services;
using SharedLibrary.Models;

namespace OrderService.Controllers;

[ApiController]
[Route("api/[controller]")]
public class OrdersController : ControllerBase
{
    private readonly IOrderRepository _orderRepository;
    private readonly IProductService _productService;
    private readonly ILogger<OrdersController> _logger;

    public OrdersController(
        IOrderRepository orderRepository,
        IProductService productService,
        ILogger<OrdersController> logger)
    {
        _orderRepository = orderRepository;
        _productService = productService;
        _logger = logger;
    }

    [HttpGet]
    public async Task<ActionResult<ApiResponse<IEnumerable<OrderDto>>>> GetAll()
    {
        try
        {
            var orders = await _orderRepository.GetAllAsync();
            var orderDtos = orders.Select(o => MapToDto(o));
            return Ok(ApiResponse<IEnumerable<OrderDto>>.SuccessResponse(orderDtos));
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving orders");
            return StatusCode(500, ApiResponse<IEnumerable<OrderDto>>.ErrorResponse("Error retrieving orders"));
        }
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<ApiResponse<OrderDto>>> GetById(int id)
    {
        try
        {
            var order = await _orderRepository.GetByIdAsync(id);
            if (order == null)
            {
                return NotFound(ApiResponse<OrderDto>.ErrorResponse($"Order with ID {id} not found"));
            }

            return Ok(ApiResponse<OrderDto>.SuccessResponse(MapToDto(order)));
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving order {OrderId}", id);
            return StatusCode(500, ApiResponse<OrderDto>.ErrorResponse("Error retrieving order"));
        }
    }

    [HttpGet("customer/{customerId}")]
    public async Task<ActionResult<ApiResponse<IEnumerable<OrderDto>>>> GetByCustomer(int customerId)
    {
        try
        {
            var orders = await _orderRepository.GetByCustomerIdAsync(customerId);
            var orderDtos = orders.Select(o => MapToDto(o));
            return Ok(ApiResponse<IEnumerable<OrderDto>>.SuccessResponse(orderDtos));
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving orders for customer {CustomerId}", customerId);
            return StatusCode(500, ApiResponse<IEnumerable<OrderDto>>.ErrorResponse("Error retrieving orders"));
        }
    }

    [HttpGet("number/{orderNumber}")]
    public async Task<ActionResult<ApiResponse<OrderDto>>> GetByOrderNumber(string orderNumber)
    {
        try
        {
            var order = await _orderRepository.GetByOrderNumberAsync(orderNumber);
            if (order == null)
            {
                return NotFound(ApiResponse<OrderDto>.ErrorResponse($"Order with number {orderNumber} not found"));
            }

            return Ok(ApiResponse<OrderDto>.SuccessResponse(MapToDto(order)));
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving order {OrderNumber}", orderNumber);
            return StatusCode(500, ApiResponse<OrderDto>.ErrorResponse("Error retrieving order"));
        }
    }

    [HttpPost]
    public async Task<ActionResult<ApiResponse<OrderDto>>> Create(CreateOrderDto createDto)
    {
        try
        {
            var order = new Order
            {
                CustomerId = createDto.CustomerId,
                ShippingAddress = createDto.ShippingAddress,
                Items = new List<OrderItem>()
            };

            // Validate and add items
            foreach (var itemDto in createDto.Items)
            {
                var product = await _productService.GetProductAsync(itemDto.ProductId);
                if (product == null)
                {
                    return BadRequest(ApiResponse<OrderDto>.ErrorResponse($"Product with ID {itemDto.ProductId} not found"));
                }

                // Check stock availability
                if (!await _productService.CheckStockAsync(itemDto.ProductId, itemDto.Quantity))
                {
                    return BadRequest(ApiResponse<OrderDto>.ErrorResponse($"Insufficient stock for product {product.Name}"));
                }

                var orderItem = new OrderItem
                {
                    ProductId = itemDto.ProductId,
                    ProductName = product.Name,
                    Quantity = itemDto.Quantity,
                    UnitPrice = product.Price,
                    TotalPrice = product.Price * itemDto.Quantity
                };

                order.Items.Add(orderItem);
            }

            var created = await _orderRepository.CreateAsync(order);

            // Update stock levels
            foreach (var item in order.Items)
            {
                var product = await _productService.GetProductAsync(item.ProductId);
                if (product != null)
                {
                    await _productService.UpdateStockAsync(item.ProductId, product.StockQuantity - item.Quantity);
                }
            }

            var dto = MapToDto(created);
            return CreatedAtAction(
                nameof(GetById),
                new { id = created.Id },
                ApiResponse<OrderDto>.SuccessResponse(dto, "Order created successfully"));
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error creating order");
            return StatusCode(500, ApiResponse<OrderDto>.ErrorResponse("Error creating order"));
        }
    }

    [HttpPatch("{id}/status")]
    public async Task<ActionResult<ApiResponse<OrderDto>>> UpdateStatus(int id, UpdateOrderStatusDto updateDto)
    {
        try
        {
            var updated = await _orderRepository.UpdateStatusAsync(id, updateDto.Status);
            if (updated == null)
            {
                return NotFound(ApiResponse<OrderDto>.ErrorResponse($"Order with ID {id} not found"));
            }

            return Ok(ApiResponse<OrderDto>.SuccessResponse(MapToDto(updated), "Order status updated successfully"));
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error updating order status {OrderId}", id);
            return StatusCode(500, ApiResponse<OrderDto>.ErrorResponse("Error updating order status"));
        }
    }

    [HttpDelete("{id}")]
    public async Task<ActionResult<ApiResponse<bool>>> Delete(int id)
    {
        try
        {
            var order = await _orderRepository.GetByIdAsync(id);
            if (order == null)
            {
                return NotFound(ApiResponse<bool>.ErrorResponse($"Order with ID {id} not found"));
            }

            // Only allow deletion of pending or cancelled orders
            if (order.Status != OrderStatus.Pending && order.Status != OrderStatus.Cancelled)
            {
                return BadRequest(ApiResponse<bool>.ErrorResponse("Can only delete pending or cancelled orders"));
            }

            var deleted = await _orderRepository.DeleteAsync(id);
            return Ok(ApiResponse<bool>.SuccessResponse(deleted, "Order deleted successfully"));
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error deleting order {OrderId}", id);
            return StatusCode(500, ApiResponse<bool>.ErrorResponse("Error deleting order"));
        }
    }

    private static OrderDto MapToDto(Order order)
    {
        return new OrderDto
        {
            Id = order.Id,
            CustomerId = order.CustomerId,
            OrderNumber = order.OrderNumber,
            OrderDate = order.OrderDate,
            Status = order.Status,
            TotalAmount = order.TotalAmount,
            ShippingAddress = order.ShippingAddress,
            CreatedAt = order.CreatedAt,
            UpdatedAt = order.UpdatedAt,
            Items = order.Items.Select(item => new OrderItemDto
            {
                Id = item.Id,
                ProductId = item.ProductId,
                ProductName = item.ProductName,
                Quantity = item.Quantity,
                UnitPrice = item.UnitPrice,
                TotalPrice = item.TotalPrice
            }).ToList()
        };
    }
}