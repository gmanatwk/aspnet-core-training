using Microsoft.AspNetCore.Mvc;
using CustomerService.Models;
using CustomerService.Services;
using SharedLibrary.Models;

namespace CustomerService.Controllers;

[ApiController]
[Route("api/[controller]")]
public class CustomersController : ControllerBase
{
    private readonly ICustomerRepository _repository;
    private readonly ILogger<CustomersController> _logger;

    public CustomersController(ICustomerRepository repository, ILogger<CustomersController> logger)
    {
        _repository = repository;
        _logger = logger;
    }

    [HttpGet]
    public async Task<ActionResult<ApiResponse<IEnumerable<CustomerDto>>>> GetAll()
    {
        try
        {
            var customers = await _repository.GetAllAsync();
            var customerDtos = customers.Select(c => MapToDto(c));
            return Ok(ApiResponse<IEnumerable<CustomerDto>>.SuccessResponse(customerDtos));
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving customers");
            return StatusCode(500, ApiResponse<IEnumerable<CustomerDto>>.ErrorResponse("Error retrieving customers"));
        }
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<ApiResponse<CustomerDto>>> GetById(int id)
    {
        try
        {
            var customer = await _repository.GetByIdAsync(id);
            if (customer == null)
            {
                return NotFound(ApiResponse<CustomerDto>.ErrorResponse($"Customer with ID {id} not found"));
            }

            return Ok(ApiResponse<CustomerDto>.SuccessResponse(MapToDto(customer)));
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving customer {CustomerId}", id);
            return StatusCode(500, ApiResponse<CustomerDto>.ErrorResponse("Error retrieving customer"));
        }
    }

    [HttpGet("email/{email}")]
    public async Task<ActionResult<ApiResponse<CustomerDto>>> GetByEmail(string email)
    {
        try
        {
            var customer = await _repository.GetByEmailAsync(email);
            if (customer == null)
            {
                return NotFound(ApiResponse<CustomerDto>.ErrorResponse($"Customer with email {email} not found"));
            }

            return Ok(ApiResponse<CustomerDto>.SuccessResponse(MapToDto(customer)));
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving customer by email {Email}", email);
            return StatusCode(500, ApiResponse<CustomerDto>.ErrorResponse("Error retrieving customer"));
        }
    }

    [HttpPost]
    public async Task<ActionResult<ApiResponse<CustomerDto>>> Create(CreateCustomerDto createDto)
    {
        try
        {
            // Check if email already exists
            if (await _repository.EmailExistsAsync(createDto.Email))
            {
                return BadRequest(ApiResponse<CustomerDto>.ErrorResponse($"Customer with email {createDto.Email} already exists"));
            }

            var customer = new Customer
            {
                FirstName = createDto.FirstName,
                LastName = createDto.LastName,
                Email = createDto.Email,
                Phone = createDto.Phone,
                Address = createDto.Address,
                City = createDto.City,
                Country = createDto.Country,
                PostalCode = createDto.PostalCode
            };

            var created = await _repository.CreateAsync(customer);
            var dto = MapToDto(created);
            
            return CreatedAtAction(
                nameof(GetById), 
                new { id = created.Id }, 
                ApiResponse<CustomerDto>.SuccessResponse(dto, "Customer created successfully"));
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error creating customer");
            return StatusCode(500, ApiResponse<CustomerDto>.ErrorResponse("Error creating customer"));
        }
    }

    [HttpPut("{id}")]
    public async Task<ActionResult<ApiResponse<CustomerDto>>> Update(int id, UpdateCustomerDto updateDto)
    {
        try
        {
            var existing = await _repository.GetByIdAsync(id);
            if (existing == null)
            {
                return NotFound(ApiResponse<CustomerDto>.ErrorResponse($"Customer with ID {id} not found"));
            }

            // Check if email is being changed and if new email already exists
            if (updateDto.Email != null && 
                updateDto.Email.ToLower() != existing.Email.ToLower() && 
                await _repository.EmailExistsAsync(updateDto.Email))
            {
                return BadRequest(ApiResponse<CustomerDto>.ErrorResponse($"Customer with email {updateDto.Email} already exists"));
            }

            existing.FirstName = updateDto.FirstName ?? existing.FirstName;
            existing.LastName = updateDto.LastName ?? existing.LastName;
            existing.Email = updateDto.Email ?? existing.Email;
            existing.Phone = updateDto.Phone ?? existing.Phone;
            existing.Address = updateDto.Address ?? existing.Address;
            existing.City = updateDto.City ?? existing.City;
            existing.Country = updateDto.Country ?? existing.Country;
            existing.PostalCode = updateDto.PostalCode ?? existing.PostalCode;

            var updated = await _repository.UpdateAsync(id, existing);
            if (updated == null)
            {
                return NotFound(ApiResponse<CustomerDto>.ErrorResponse($"Customer with ID {id} not found"));
            }

            return Ok(ApiResponse<CustomerDto>.SuccessResponse(MapToDto(updated), "Customer updated successfully"));
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error updating customer {CustomerId}", id);
            return StatusCode(500, ApiResponse<CustomerDto>.ErrorResponse("Error updating customer"));
        }
    }

    [HttpDelete("{id}")]
    public async Task<ActionResult<ApiResponse<bool>>> Delete(int id)
    {
        try
        {
            var deleted = await _repository.DeleteAsync(id);
            if (!deleted)
            {
                return NotFound(ApiResponse<bool>.ErrorResponse($"Customer with ID {id} not found"));
            }

            return Ok(ApiResponse<bool>.SuccessResponse(true, "Customer deleted successfully"));
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error deleting customer {CustomerId}", id);
            return StatusCode(500, ApiResponse<bool>.ErrorResponse("Error deleting customer"));
        }
    }

    [HttpGet("{id}/exists")]
    public async Task<ActionResult<ApiResponse<bool>>> Exists(int id)
    {
        try
        {
            var exists = await _repository.CustomerExistsAsync(id);
            return Ok(ApiResponse<bool>.SuccessResponse(exists));
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error checking if customer exists {CustomerId}", id);
            return StatusCode(500, ApiResponse<bool>.ErrorResponse("Error checking customer existence"));
        }
    }

    private static CustomerDto MapToDto(Customer customer)
    {
        return new CustomerDto
        {
            Id = customer.Id,
            FirstName = customer.FirstName,
            LastName = customer.LastName,
            Email = customer.Email,
            Phone = customer.Phone,
            Address = customer.Address,
            City = customer.City,
            Country = customer.Country,
            PostalCode = customer.PostalCode,
            CreatedAt = customer.CreatedAt,
            UpdatedAt = customer.UpdatedAt
        };
    }
}