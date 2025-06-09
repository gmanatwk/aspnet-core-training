using Microsoft.AspNetCore.Mvc;
using SecurityDemo.Services;

namespace SecurityDemo.Controllers;

[ApiController]
[Route("api/[controller]")]
public class EncryptionController : ControllerBase
{
    private readonly IEncryptionService _encryptionService;
    private readonly ILogger<EncryptionController> _logger;

    public EncryptionController(IEncryptionService encryptionService, ILogger<EncryptionController> logger)
    {
        _encryptionService = encryptionService;
        _logger = logger;
    }

    /// <summary>
    /// Encrypt sensitive data
    /// </summary>
    [HttpPost("encrypt")]
    public IActionResult EncryptData([FromBody] EncryptionRequest request)
    {
        _logger.LogInformation("Encryption requested for data");

        try
        {
            var encryptedData = _encryptionService.Encrypt(request.PlainText, request.Key);

            return Ok(new
            {
                Message = "Data encrypted successfully",
                EncryptedData = encryptedData,
                Timestamp = DateTime.UtcNow,
                SecurityNote = "Data encrypted using AES-256"
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Encryption failed");
            return BadRequest(new { Message = "Encryption failed", Error = ex.Message });
        }
    }

    /// <summary>
    /// Decrypt sensitive data
    /// </summary>
    [HttpPost("decrypt")]
    public IActionResult DecryptData([FromBody] DecryptionRequest request)
    {
        _logger.LogInformation("Decryption requested");

        try
        {
            var decryptedData = _encryptionService.Decrypt(request.CipherText, request.Key);

            return Ok(new
            {
                Message = "Data decrypted successfully",
                DecryptedData = decryptedData,
                Timestamp = DateTime.UtcNow,
                SecurityNote = "Data decrypted using AES-256"
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Decryption failed");
            return BadRequest(new { Message = "Decryption failed", Error = ex.Message });
        }
    }

    /// <summary>
    /// Hash password securely
    /// </summary>
    [HttpPost("hash-password")]
    public IActionResult HashPassword([FromBody] PasswordRequest request)
    {
        _logger.LogInformation("Password hashing requested");

        try
        {
            var hashedPassword = _encryptionService.HashPassword(request.Password);

            return Ok(new
            {
                Message = "Password hashed successfully",
                HashedPassword = hashedPassword,
                Timestamp = DateTime.UtcNow,
                SecurityNote = "Password hashed using PBKDF2 with SHA-256"
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Password hashing failed");
            return BadRequest(new { Message = "Password hashing failed", Error = ex.Message });
        }
    }

    /// <summary>
    /// Verify password against hash
    /// </summary>
    [HttpPost("verify-password")]
    public IActionResult VerifyPassword([FromBody] PasswordVerificationRequest request)
    {
        _logger.LogInformation("Password verification requested");

        try
        {
            var isValid = _encryptionService.VerifyPassword(request.Password, request.Hash);

            return Ok(new
            {
                Message = "Password verification completed",
                IsValid = isValid,
                Timestamp = DateTime.UtcNow,
                SecurityNote = "Password verified using secure comparison"
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Password verification failed");
            return BadRequest(new { Message = "Password verification failed", Error = ex.Message });
        }
    }
}

public class EncryptionRequest
{
    public string PlainText { get; set; } = string.Empty;
    public string Key { get; set; } = string.Empty;
}

public class DecryptionRequest
{
    public string CipherText { get; set; } = string.Empty;
    public string Key { get; set; } = string.Empty;
}

public class PasswordRequest
{
    public string Password { get; set; } = string.Empty;
}

public class PasswordVerificationRequest
{
    public string Password { get; set; } = string.Empty;
    public string Hash { get; set; } = string.Empty;
}
