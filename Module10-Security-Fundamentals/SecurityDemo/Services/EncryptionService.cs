using Microsoft.AspNetCore.DataProtection;
using System.Security.Cryptography;
using System.Text;

namespace SecurityDemo.Services;

public interface IEncryptionService
{
    string EncryptString(string plainText);
    string DecryptString(string cipherText);
    string HashPassword(string password);
    bool VerifyPassword(string password, string hash);
    string GenerateSecureToken();
}

public class EncryptionService : IEncryptionService
{
    private readonly IDataProtector _dataProtector;
    private readonly ILogger<EncryptionService> _logger;

    public EncryptionService(IDataProtectionProvider dataProtectionProvider, ILogger<EncryptionService> logger)
    {
        _dataProtector = dataProtectionProvider.CreateProtector("SecurityDemo.EncryptionService");
        _logger = logger;
    }

    public string EncryptString(string plainText)
    {
        try
        {
            return _dataProtector.Protect(plainText);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error encrypting string");
            throw;
        }
    }

    public string DecryptString(string cipherText)
    {
        try
        {
            return _dataProtector.Unprotect(cipherText);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error decrypting string");
            throw;
        }
    }

    public string HashPassword(string password)
    {
        using var rng = RandomNumberGenerator.Create();
        var salt = new byte[32];
        rng.GetBytes(salt);

        using var pbkdf2 = new Rfc2898DeriveBytes(password, salt, 100000, HashAlgorithmName.SHA256);
        var hash = pbkdf2.GetBytes(32);

        var hashBytes = new byte[64];
        Array.Copy(salt, 0, hashBytes, 0, 32);
        Array.Copy(hash, 0, hashBytes, 32, 32);

        return Convert.ToBase64String(hashBytes);
    }

    public bool VerifyPassword(string password, string hash)
    {
        try
        {
            var hashBytes = Convert.FromBase64String(hash);
            var salt = new byte[32];
            Array.Copy(hashBytes, 0, salt, 0, 32);

            using var pbkdf2 = new Rfc2898DeriveBytes(password, salt, 100000, HashAlgorithmName.SHA256);
            var computedHash = pbkdf2.GetBytes(32);

            for (int i = 0; i < 32; i++)
            {
                if (hashBytes[i + 32] != computedHash[i])
                    return false;
            }

            return true;
        }
        catch
        {
            return false;
        }
    }

    public string GenerateSecureToken()
    {
        using var rng = RandomNumberGenerator.Create();
        var tokenBytes = new byte[32];
        rng.GetBytes(tokenBytes);
        return Convert.ToBase64String(tokenBytes);
    }
}
