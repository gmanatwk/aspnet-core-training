using System.Net.Http.Json;
using System.Text.Json;
using SharedLibrary.Models;

namespace SharedLibrary.Utilities;

public static class HttpClientExtensions
{
    private static readonly JsonSerializerOptions JsonOptions = new()
    {
        PropertyNameCaseInsensitive = true
    };

    public static async Task<ApiResponse<T>> GetFromApiAsync<T>(
        this HttpClient httpClient,
        string requestUri)
    {
        try
        {
            var response = await httpClient.GetAsync(requestUri);
            
            if (response.IsSuccessStatusCode)
            {
                var content = await response.Content.ReadFromJsonAsync<T>(JsonOptions);
                return ApiResponse<T>.SuccessResponse(content!);
            }
            
            var error = await response.Content.ReadAsStringAsync();
            return ApiResponse<T>.ErrorResponse($"API call failed: {response.StatusCode}", error);
        }
        catch (Exception ex)
        {
            return ApiResponse<T>.ErrorResponse("Error calling API", ex.Message);
        }
    }

    public static async Task<ApiResponse<T>> PostToApiAsync<T>(
        this HttpClient httpClient,
        string requestUri,
        object content)
    {
        try
        {
            var response = await httpClient.PostAsJsonAsync(requestUri, content);
            
            if (response.IsSuccessStatusCode)
            {
                var result = await response.Content.ReadFromJsonAsync<T>(JsonOptions);
                return ApiResponse<T>.SuccessResponse(result!);
            }
            
            var error = await response.Content.ReadAsStringAsync();
            return ApiResponse<T>.ErrorResponse($"API call failed: {response.StatusCode}", error);
        }
        catch (Exception ex)
        {
            return ApiResponse<T>.ErrorResponse("Error calling API", ex.Message);
        }
    }

    public static async Task<ApiResponse<T>> PutToApiAsync<T>(
        this HttpClient httpClient,
        string requestUri,
        object content)
    {
        try
        {
            var response = await httpClient.PutAsJsonAsync(requestUri, content);
            
            if (response.IsSuccessStatusCode)
            {
                var result = await response.Content.ReadFromJsonAsync<T>(JsonOptions);
                return ApiResponse<T>.SuccessResponse(result!);
            }
            
            var error = await response.Content.ReadAsStringAsync();
            return ApiResponse<T>.ErrorResponse($"API call failed: {response.StatusCode}", error);
        }
        catch (Exception ex)
        {
            return ApiResponse<T>.ErrorResponse("Error calling API", ex.Message);
        }
    }

    public static async Task<ApiResponse<bool>> DeleteFromApiAsync(
        this HttpClient httpClient,
        string requestUri)
    {
        try
        {
            var response = await httpClient.DeleteAsync(requestUri);
            
            if (response.IsSuccessStatusCode)
            {
                return ApiResponse<bool>.SuccessResponse(true, "Deleted successfully");
            }
            
            var error = await response.Content.ReadAsStringAsync();
            return ApiResponse<bool>.ErrorResponse($"API call failed: {response.StatusCode}", error);
        }
        catch (Exception ex)
        {
            return ApiResponse<bool>.ErrorResponse("Error calling API", ex.Message);
        }
    }
}