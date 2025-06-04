using System.Net.Http;
using System.Net.Http.Headers;
using System.Text;
using System.Text.Json;
using RestfulAPI.Models;

namespace RestfulAPI.Tests.Helpers;

public static class TestAuthHelper
{
    public static async Task<string> GetTokenAsync(HttpClient client, string email, string password)
    {
        var loginRequest = new LoginRequest
        {
            Email = email,
            Password = password
        };

        var content = new StringContent(
            JsonSerializer.Serialize(loginRequest),
            Encoding.UTF8,
            "application/json");

        var response = await client.PostAsync("/api/auth/login", content);
        response.EnsureSuccessStatusCode();

        var responseContent = await response.Content.ReadAsStringAsync();
        var authResponse = JsonSerializer.Deserialize<AuthResponse>(responseContent, new JsonSerializerOptions
        {
            PropertyNameCaseInsensitive = true
        });

        return authResponse?.Token ?? throw new InvalidOperationException("Token not found in response");
    }

    public static void AddAuthorizationHeader(HttpClient client, string token)
    {
        client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", token);
    }

    public static async Task<HttpClient> GetAuthenticatedClient(HttpClient client, string email, string password)
    {
        var token = await GetTokenAsync(client, email, password);
        AddAuthorizationHeader(client, token);
        return client;
    }
}