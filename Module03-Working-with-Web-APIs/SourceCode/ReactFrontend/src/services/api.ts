import axios from 'axios';
import { Product, CreateProductDto, UpdateProductDto, PagedResponse } from '../types/Product';

const API_BASE_URL = import.meta.env.PROD
  ? '/api'
  : 'http://localhost:5001/api';

const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Add request interceptor for auth token
api.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('authToken');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// Add response interceptor for error handling
api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      // Handle unauthorized access
      localStorage.removeItem('authToken');
      window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);

export const productApi = {
  // Get all products with pagination and filtering
  async getProducts(params?: {
    category?: string;
    minPrice?: number;
    maxPrice?: number;
    pageNumber?: number;
    pageSize?: number;
  }): Promise<PagedResponse<Product>> {
    const response = await api.get('/v1/products', { params });
    return response.data;
  },

  // Get product by ID
  async getProduct(id: number): Promise<Product> {
    const response = await api.get(`/v1/products/${id}`);
    return response.data;
  },

  // Create new product
  async createProduct(product: CreateProductDto): Promise<Product> {
    const response = await api.post('/v1/products', product);
    return response.data;
  },

  // Update existing product
  async updateProduct(id: number, product: UpdateProductDto): Promise<Product> {
    const response = await api.put(`/v1/products/${id}`, product);
    return response.data;
  },

  // Delete product
  async deleteProduct(id: number): Promise<void> {
    await api.delete(`/v1/products/${id}`);
  },

  // Get product categories
  async getCategories(): Promise<string[]> {
    const response = await api.get('/v1/products/categories');
    return response.data;
  },
};

export const authApi = {
  // Login
  async login(email: string, password: string): Promise<{ token: string; user: any }> {
    const response = await api.post('/auth/login', { email, password });
    const { token, user } = response.data;
    localStorage.setItem('authToken', token);
    return response.data;
  },

  // Register
  async register(email: string, password: string, name: string): Promise<{ token: string; user: any }> {
    const response = await api.post('/auth/register', { email, password, name });
    const { token } = response.data;
    localStorage.setItem('authToken', token);
    return response.data;
  },

  // Logout
  logout(): void {
    localStorage.removeItem('authToken');
  },

  // Check if authenticated
  isAuthenticated(): boolean {
    return !!localStorage.getItem('authToken');
  },
};

export default api;