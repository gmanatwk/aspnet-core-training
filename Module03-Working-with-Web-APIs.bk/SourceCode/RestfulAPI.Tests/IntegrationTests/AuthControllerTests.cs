using System.Net;
using System.Net.Http;
using System.Text;
using System.Text.Json;
using FluentAssertions;
using Microsoft.AspNetCore.Mvc.Testing;
using RestfulAPI.Models;
using RestfulAPI.Tests.Fixtures;
using RestfulAPI.Tests.Helpers;
using Xunit;

namespace RestfulAPI.Tests.IntegrationTests;

public class AuthControllerTests : IClassFixture<CustomWebApplicationFactory<Program>>
{
    private readonly CustomWebApplicationFactory<Program> _factory;
    private readonly HttpClient _client;
    private readonly JsonSerializerOptions _jsonOptions;

    public AuthControllerTests(CustomWebApplicationFactory<Program> factory)
    {
        _factory = factory;
        _client = _factory.CreateClient(new WebApplicationFactoryClientOptions
        {
            AllowAutoRedirect = false
        });
        _jsonOptions = new JsonSerializerOptions
        {
            PropertyNameCaseInsensitive = true
        };
    }

    [Fact]
    public async Task Register_WithValidData_ReturnsSuccessAndToken()
    {
        // Arrange
        var registerRequest = new RegisterRequest
        {
            Email = "newuser@test.com",
            Password = "NewUser123!",
            ConfirmPassword = "NewUser123!",
            FullName = "New Test User"
        };

        var json = JsonSerializer.Serialize(registerRequest);
        var content = new StringContent(json, Encoding.UTF8, "application/json");

        // Act
        var response = await _client.PostAsync("/api/auth/register", content);

        // Assert
        response.EnsureSuccessStatusCode();
        var responseContent = await response.Content.ReadAsStringAsync();
        var authResponse = JsonSerializer.Deserialize<AuthResponse>(responseContent, _jsonOptions);

        authResponse.Should().NotBeNull();
        authResponse!.Token.Should().NotBeNullOrWhiteSpace();
        authResponse.User.Should().NotBeNull();
        authResponse.User.Email.Should().Be(registerRequest.Email);
        authResponse.User.FullName.Should().Be(registerRequest.FullName);
        authResponse.User.Roles.Should().Contain("User");
    }

    [Fact]
    public async Task Register_WithExistingEmail_ReturnsBadRequest()
    {
        // Arrange
        var registerRequest = new RegisterRequest
        {
            Email = "admin@test.com", // Already exists
            Password = "Password123!",
            ConfirmPassword = "Password123!",
            FullName = "Duplicate User"
        };

        var json = JsonSerializer.Serialize(registerRequest);
        var content = new StringContent(json, Encoding.UTF8, "application/json");

        // Act
        var response = await _client.PostAsync("/api/auth/register", content);

        // Assert
        response.StatusCode.Should().Be(HttpStatusCode.BadRequest);
    }

    [Fact]
    public async Task Register_WithInvalidData_ReturnsBadRequest()
    {
        // Arrange
        var registerRequest = new RegisterRequest
        {
            Email = "invalidemail", // Invalid email format
            Password = "weak", // Weak password
            ConfirmPassword = "weak",
            FullName = "" // Empty full name
        };

        var json = JsonSerializer.Serialize(registerRequest);
        var content = new StringContent(json, Encoding.UTF8, "application/json");

        // Act
        var response = await _client.PostAsync("/api/auth/register", content);

        // Assert
        response.StatusCode.Should().Be(HttpStatusCode.BadRequest);
    }

    [Fact]
    public async Task Login_WithValidCredentials_ReturnsSuccessAndToken()
    {
        // Arrange
        var loginRequest = new LoginRequest
        {
            Email = "admin@test.com",
            Password = "Admin123!"
        };

        var json = JsonSerializer.Serialize(loginRequest);
        var content = new StringContent(json, Encoding.UTF8, "application/json");

        // Act
        var response = await _client.PostAsync("/api/auth/login", content);

        // Assert
        response.EnsureSuccessStatusCode();
        var responseContent = await response.Content.ReadAsStringAsync();
        var authResponse = JsonSerializer.Deserialize<AuthResponse>(responseContent, _jsonOptions);

        authResponse.Should().NotBeNull();
        authResponse!.Token.Should().NotBeNullOrWhiteSpace();
        authResponse.User.Should().NotBeNull();
        authResponse.User.Email.Should().Be(loginRequest.Email);
        authResponse.User.Roles.Should().Contain("Admin");
    }

    [Fact]
    public async Task Login_WithInvalidPassword_ReturnsUnauthorized()
    {
        // Arrange
        var loginRequest = new LoginRequest
        {
            Email = "admin@test.com",
            Password = "WrongPassword!"
        };

        var json = JsonSerializer.Serialize(loginRequest);
        var content = new StringContent(json, Encoding.UTF8, "application/json");

        // Act
        var response = await _client.PostAsync("/api/auth/login", content);

        // Assert
        response.StatusCode.Should().Be(HttpStatusCode.Unauthorized);
    }

    [Fact]
    public async Task Login_WithNonExistentEmail_ReturnsUnauthorized()
    {
        // Arrange
        var loginRequest = new LoginRequest
        {
            Email = "nonexistent@test.com",
            Password = "Password123!"
        };

        var json = JsonSerializer.Serialize(loginRequest);
        var content = new StringContent(json, Encoding.UTF8, "application/json");

        // Act
        var response = await _client.PostAsync("/api/auth/login", content);

        // Assert
        response.StatusCode.Should().Be(HttpStatusCode.Unauthorized);
    }

    [Fact]
    public async Task GetProfile_WithValidToken_ReturnsUserProfile()
    {
        // Arrange
        await TestAuthHelper.GetAuthenticatedClient(_client, "admin@test.com", "Admin123!");

        // Act
        var response = await _client.GetAsync("/api/auth/profile");

        // Assert
        response.EnsureSuccessStatusCode();
        var responseContent = await response.Content.ReadAsStringAsync();
        var userInfo = JsonSerializer.Deserialize<UserInfo>(responseContent, _jsonOptions);

        userInfo.Should().NotBeNull();
        userInfo!.Email.Should().Be("admin@test.com");
        userInfo.FullName.Should().Be("Admin User");
        userInfo.Roles.Should().Contain("Admin");
    }

    [Fact]
    public async Task GetProfile_WithoutToken_ReturnsUnauthorized()
    {
        // Act
        var response = await _client.GetAsync("/api/auth/profile");

        // Assert
        response.StatusCode.Should().Be(HttpStatusCode.Unauthorized);
    }

    [Fact]
    public async Task ChangePassword_WithValidCurrentPassword_ReturnsSuccess()
    {
        // Arrange
        await TestAuthHelper.GetAuthenticatedClient(_client, "user@test.com", "User123!");

        var changePasswordRequest = new ChangePasswordRequest
        {
            CurrentPassword = "User123!",
            NewPassword = "NewUser123!"
        };

        var json = JsonSerializer.Serialize(changePasswordRequest);
        var content = new StringContent(json, Encoding.UTF8, "application/json");

        // Act
        var response = await _client.PostAsync("/api/auth/change-password", content);

        // Assert
        response.EnsureSuccessStatusCode();
        var responseContent = await response.Content.ReadAsStringAsync();
        responseContent.Should().Contain("Password changed successfully");
    }

    [Fact]
    public async Task ChangePassword_WithInvalidCurrentPassword_ReturnsBadRequest()
    {
        // Arrange
        await TestAuthHelper.GetAuthenticatedClient(_client, "user@test.com", "User123!");

        var changePasswordRequest = new ChangePasswordRequest
        {
            CurrentPassword = "WrongPassword!",
            NewPassword = "NewUser123!"
        };

        var json = JsonSerializer.Serialize(changePasswordRequest);
        var content = new StringContent(json, Encoding.UTF8, "application/json");

        // Act
        var response = await _client.PostAsync("/api/auth/change-password", content);

        // Assert
        response.StatusCode.Should().Be(HttpStatusCode.BadRequest);
    }

    [Fact]
    public async Task ChangePassword_WithoutAuth_ReturnsUnauthorized()
    {
        // Arrange
        var changePasswordRequest = new ChangePasswordRequest
        {
            CurrentPassword = "User123!",
            NewPassword = "NewUser123!"
        };

        var json = JsonSerializer.Serialize(changePasswordRequest);
        var content = new StringContent(json, Encoding.UTF8, "application/json");

        // Act
        var response = await _client.PostAsync("/api/auth/change-password", content);

        // Assert
        response.StatusCode.Should().Be(HttpStatusCode.Unauthorized);
    }

    [Fact]
    public async Task ValidateToken_WithValidToken_ReturnsValid()
    {
        // Arrange
        var token = await TestAuthHelper.GetTokenAsync(_client, "admin@test.com", "Admin123!");
        
        var json = JsonSerializer.Serialize(token);
        var content = new StringContent(json, Encoding.UTF8, "application/json");

        // Act
        var response = await _client.PostAsync("/api/auth/validate-token", content);

        // Assert
        response.EnsureSuccessStatusCode();
        var responseContent = await response.Content.ReadAsStringAsync();
        responseContent.Should().Contain("\"valid\":true");
        responseContent.Should().Contain("admin@test.com");
        responseContent.Should().Contain("Admin");
    }

    [Fact]
    public async Task ValidateToken_WithInvalidToken_ReturnsUnauthorized()
    {
        // Arrange
        var invalidToken = "invalid.token.here";
        
        var json = JsonSerializer.Serialize(invalidToken);
        var content = new StringContent(json, Encoding.UTF8, "application/json");

        // Act
        var response = await _client.PostAsync("/api/auth/validate-token", content);

        // Assert
        response.StatusCode.Should().Be(HttpStatusCode.Unauthorized);
    }

    [Fact]
    public async Task ValidateToken_WithEmptyToken_ReturnsBadRequest()
    {
        // Arrange
        var emptyToken = "";
        
        var json = JsonSerializer.Serialize(emptyToken);
        var content = new StringContent(json, Encoding.UTF8, "application/json");

        // Act
        var response = await _client.PostAsync("/api/auth/validate-token", content);

        // Assert
        response.StatusCode.Should().Be(HttpStatusCode.BadRequest);
    }

    [Fact]
    public async Task TestAuth_WithValidToken_ReturnsSuccess()
    {
        // Arrange
        await TestAuthHelper.GetAuthenticatedClient(_client, "manager@test.com", "Manager123!");

        // Act
        var response = await _client.GetAsync("/api/auth/test");

        // Assert
        response.EnsureSuccessStatusCode();
        var responseContent = await response.Content.ReadAsStringAsync();
        responseContent.Should().Contain("Authentication successful");
        responseContent.Should().Contain("manager@test.com");
        responseContent.Should().Contain("Manager");
    }

    [Fact]
    public async Task TestAuth_WithoutToken_ReturnsUnauthorized()
    {
        // Act
        var response = await _client.GetAsync("/api/auth/test");

        // Assert
        response.StatusCode.Should().Be(HttpStatusCode.Unauthorized);
    }

    [Fact]
    public async Task AdminTest_WithAdminToken_ReturnsSuccess()
    {
        // Arrange
        await TestAuthHelper.GetAuthenticatedClient(_client, "admin@test.com", "Admin123!");

        // Act
        var response = await _client.GetAsync("/api/auth/admin-test");

        // Assert
        response.EnsureSuccessStatusCode();
        var responseContent = await response.Content.ReadAsStringAsync();
        responseContent.Should().Contain("Admin access granted");
    }

    [Fact]
    public async Task AdminTest_WithManagerToken_ReturnsForbidden()
    {
        // Arrange
        await TestAuthHelper.GetAuthenticatedClient(_client, "manager@test.com", "Manager123!");

        // Act
        var response = await _client.GetAsync("/api/auth/admin-test");

        // Assert
        response.StatusCode.Should().Be(HttpStatusCode.Forbidden);
    }

    [Fact]
    public async Task AdminTest_WithUserToken_ReturnsForbidden()
    {
        // Arrange
        await TestAuthHelper.GetAuthenticatedClient(_client, "user@test.com", "User123!");

        // Act
        var response = await _client.GetAsync("/api/auth/admin-test");

        // Assert
        response.StatusCode.Should().Be(HttpStatusCode.Forbidden);
    }

    [Fact]
    public async Task AdminTest_WithoutToken_ReturnsUnauthorized()
    {
        // Act
        var response = await _client.GetAsync("/api/auth/admin-test");

        // Assert
        response.StatusCode.Should().Be(HttpStatusCode.Unauthorized);
    }
}