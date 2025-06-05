export interface Todo {
  id?: number;
  title: string;
  description?: string;
  isCompleted: boolean;
  createdAt?: string;
  completedAt?: string;
  priority: TodoPriority;
  category?: string;
  status?: string;
  daysOld?: number;
}

export enum TodoPriority {
  Low = 1,
  Medium = 2,
  High = 3,
  Urgent = 4
}

export interface TodoStats {
  total: number;
  completed: number;
  pending: number;
  byPriority: Record<string, number>;
  byCategory: Record<string, number>;
  completionRate: number;
}

export interface TodoFilters {
  completed?: boolean;
  category?: string;
  priority?: TodoPriority;
}
