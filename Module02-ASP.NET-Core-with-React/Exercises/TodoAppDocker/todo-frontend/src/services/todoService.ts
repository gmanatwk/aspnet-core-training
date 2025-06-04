import axios from 'axios';

const API_BASE_URL = process.env.NODE_ENV === 'production' 
  ? '/api/todo' 
  : 'http://localhost:5000/api/todo';

export interface Todo {
  id?: number;
  title: string;
  isCompleted: boolean;
  createdAt?: string;
}

const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

export const todoService = {
  async getAll(): Promise<Todo[]> {
    const response = await api.get('');
    return response.data;
  },

  async create(todo: Omit<Todo, 'id'>): Promise<Todo> {
    const response = await api.post('', todo);
    return response.data;
  },

  async update(id: number, todo: Partial<Todo>): Promise<void> {
    await api.put(`/${id}`, todo);
  },

  async delete(id: number): Promise<void> {
    await api.delete(`/${id}`);
  },
};