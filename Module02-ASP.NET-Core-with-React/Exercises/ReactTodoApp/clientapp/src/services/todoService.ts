import apiClient from './apiClient';

export interface Todo {
  id?: number;
  title: string;
  isCompleted: boolean;
  createdAt?: string;
  updatedAt?: string;
}

export interface TodoStats {
  total: number;
  completed: number;
  active: number;
}

class TodoService {
  private readonly baseUrl = '/todo';

  async getAll(): Promise<Todo[]> {
    return apiClient.get<Todo[]>(this.baseUrl);
  }

  async getById(id: number): Promise<Todo> {
    return apiClient.get<Todo>(`${this.baseUrl}/${id}`);
  }

  async create(todo: Omit<Todo, 'id'>): Promise<Todo> {
    return apiClient.post<Todo>(this.baseUrl, todo);
  }

  async update(id: number, todo: Partial<Todo>): Promise<Todo> {
    return apiClient.put<Todo>(`${this.baseUrl}/${id}`, todo);
  }

  async delete(id: number): Promise<void> {
    return apiClient.delete<void>(`${this.baseUrl}/${id}`);
  }

  async getStats(): Promise<TodoStats> {
    return apiClient.get<TodoStats>(`${this.baseUrl}/stats`);
  }

  async bulkDelete(ids: number[]): Promise<void> {
    return apiClient.post<void>(`${this.baseUrl}/bulk-delete`, { ids });
  }

  async bulkComplete(ids: number[]): Promise<void> {
    return apiClient.post<void>(`${this.baseUrl}/bulk-complete`, { ids });
  }
}

export const todoService = new TodoService();