import axios from 'axios';

const API_BASE_URL = '/api/todo';

export interface Todo {
  id?: number;
  title: string;
  isCompleted: boolean;
  createdAt?: string;
}

export const todoService = {
  getAll: async (): Promise<Todo[]> => {
    const response = await axios.get<Todo[]>(API_BASE_URL);
    return response.data;
  },

  getById: async (id: number): Promise<Todo> => {
    const response = await axios.get<Todo>(`${API_BASE_URL}/${id}`);
    return response.data;
  },

  create: async (todo: Todo): Promise<Todo> => {
    const response = await axios.post<Todo>(API_BASE_URL, todo);
    return response.data;
  },

  update: async (id: number, todo: Todo): Promise<void> => {
    await axios.put(`${API_BASE_URL}/${id}`, todo);
  },

  delete: async (id: number): Promise<void> => {
    await axios.delete(`${API_BASE_URL}/${id}`);
  }
};
