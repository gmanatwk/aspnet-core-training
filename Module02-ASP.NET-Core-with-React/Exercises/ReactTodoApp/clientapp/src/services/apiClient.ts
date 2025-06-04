import axios, { type AxiosInstance, type AxiosRequestConfig, AxiosError } from 'axios';

interface ApiError {
  message: string;
  statusCode: number;
  details?: any;
}

class ApiClient {
  private client: AxiosInstance;
  private requestInterceptor: number | null = null;
  private responseInterceptor: number | null = null;

  constructor() {
    this.client = axios.create({
      baseURL: '/api',
      timeout: 10000,
      headers: {
        'Content-Type': 'application/json',
      },
    });

    this.setupInterceptors();
  }

  private setupInterceptors(): void {
    // Request interceptor for auth token
    this.requestInterceptor = this.client.interceptors.request.use(
      (config) => {
        const token = localStorage.getItem('authToken');
        if (token) {
          config.headers.Authorization = `Bearer ${token}`;
        }
        
        // Add request ID for tracking
        config.headers['X-Request-ID'] = this.generateRequestId();
        
        return config;
      },
      (error) => {
        return Promise.reject(error);
      }
    );

    // Response interceptor for error handling
    this.responseInterceptor = this.client.interceptors.response.use(
      (response) => {
        // Log successful requests in development
        if (process.env.NODE_ENV === 'development') {
          console.log(`API Success: ${response.config.method?.toUpperCase()} ${response.config.url}`, response.data);
        }
        return response;
      },
      async (error: AxiosError) => {
        const apiError: ApiError = {
          message: 'An unexpected error occurred',
          statusCode: error.response?.status || 0,
          details: error.response?.data,
        };

        // Handle specific error cases
        switch (error.response?.status) {
          case 401:
            apiError.message = 'Authentication required';
            // Redirect to login
            window.location.href = '/login';
            break;
          case 403:
            apiError.message = 'You do not have permission to perform this action';
            break;
          case 404:
            apiError.message = 'The requested resource was not found';
            break;
          case 429:
            apiError.message = 'Too many requests. Please try again later';
            break;
          case 500:
            apiError.message = 'Server error. Please try again later';
            break;
        }

        // Network error
        if (!error.response) {
          apiError.message = 'Network error. Please check your connection';
        }

        return Promise.reject(apiError);
      }
    );
  }

  private generateRequestId(): string {
    return `${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;
  }

  // Generic request methods with retry logic
  async get<T>(url: string, config?: AxiosRequestConfig): Promise<T> {
    const response = await this.retryRequest(() => this.client.get<T>(url, config));
    return response.data;
  }

  async post<T>(url: string, data?: any, config?: AxiosRequestConfig): Promise<T> {
    const response = await this.retryRequest(() => this.client.post<T>(url, data, config));
    return response.data;
  }

  async put<T>(url: string, data?: any, config?: AxiosRequestConfig): Promise<T> {
    const response = await this.retryRequest(() => this.client.put<T>(url, data, config));
    return response.data;
  }

  async delete<T>(url: string, config?: AxiosRequestConfig): Promise<T> {
    const response = await this.retryRequest(() => this.client.delete<T>(url, config));
    return response.data;
  }

  // Retry logic for failed requests
  private async retryRequest<T>(
    requestFn: () => Promise<T>,
    maxRetries: number = 3,
    delay: number = 1000
  ): Promise<T> {
    let lastError: any;

    for (let i = 0; i < maxRetries; i++) {
      try {
        return await requestFn();
      } catch (error: any) {
        lastError = error;
        
        // Don't retry on client errors (4xx)
        if (error.statusCode && error.statusCode >= 400 && error.statusCode < 500) {
          throw error;
        }

        // Wait before retrying
        if (i < maxRetries - 1) {
          await new Promise(resolve => setTimeout(resolve, delay * Math.pow(2, i)));
        }
      }
    }

    throw lastError;
  }

  // Cleanup method
  cleanup(): void {
    if (this.requestInterceptor !== null) {
      this.client.interceptors.request.eject(this.requestInterceptor);
    }
    if (this.responseInterceptor !== null) {
      this.client.interceptors.response.eject(this.responseInterceptor);
    }
  }
}

export default new ApiClient();