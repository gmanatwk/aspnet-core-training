import axios from 'axios';
import { Todo, TodoFilters, TodoStats } from '@/types/todo';

// API base URL - different for server-side and client-side
const getApiBaseUrl = () => {
  // Server-side rendering: use full URL
  if (typeof window === 'undefined') {
    return process.env.API_BASE_URL || 'http://localhost:5000';
  }
  // Client-side: use relative URL (handled by Next.js proxy)
  return '';
};

const api = axios.create({
  baseURL: `${getApiBaseUrl()}/api/todo`,
  headers: {
    'Content-Type': 'application/json',
  },
  timeout: 10000,
});

// Request interceptor for logging
api.interceptors.request.use(
  (config) => {
    console.log(`[API] ${config.method?.toUpperCase()} ${config.url}`);
    return config;
  },
  (error) => {
    console.error('[API] Request error:', error);
    return Promise.reject(error);
  }
);

// Response interceptor for error handling
api.interceptors.response.use(
  (response) => {
    console.log(`[API] Response: ${response.status}`);
    return response;
  },
  (error) => {
    console.error('[API] Response error:', error.response?.data || error.message);
    return Promise.reject(error);
  }
);

export const todoApi = {
  /**
   * Get all todos with optional filters
   */
  async getAll(filters?: TodoFilters): Promise<Todo[]> {
    const params = new URLSearchParams();
    
    if (filters?.completed !== undefined) {
      params.append('completed', filters.completed.toString());
    }
    if (filters?.category) {
      params.append('category', filters.category);
    }
    if (filters?.priority !== undefined) {
      params.append('priority', filters.priority.toString());
    }

    const response = await api.get(`?${params.toString()}`);
    return response.data;
  },

  /**
   * Get todo by ID
   */
  async getById(id: number): Promise<Todo> {
    const response = await api.get(`/${id}`);
    return response.data;
  },

  /**
   * Create a new todo
   */
  async create(todo: Omit<Todo, 'id' | 'createdAt' | 'completedAt' | 'status' | 'daysOld'>): Promise<Todo> {
    const response = await api.post('', todo);
    return response.data;
  },

  /**
   * Update an existing todo
   */
  async update(id: number, todo: Todo): Promise<Todo> {
    const response = await api.put(`/${id}`, todo);
    return response.data;
  },

  /**
   * Delete a todo
   */
  async delete(id: number): Promise<void> {
    await api.delete(`/${id}`);
  },

  /**
   * Toggle todo completion status
   */
  async toggle(id: number): Promise<Todo> {
    const response = await api.patch(`/${id}/toggle`);
    return response.data;
  },

  /**
   * Get todo statistics
   */
  async getStats(): Promise<TodoStats> {
    const response = await api.get('/stats');
    return response.data;
  }
};
