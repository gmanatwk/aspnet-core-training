export enum TodoPriority {
  Low = 0,
  Medium = 1,
  High = 2,
  Urgent = 3
}

export interface Todo {
  id: number;
  title: string;
  description?: string;
  isCompleted: boolean;
  priority: TodoPriority;
  category?: string;
  createdAt: string;
  completedAt?: string;
  status: string;
  daysOld: number;
}

export interface TodoFilters {
  completed?: boolean;
  category?: string;
  priority?: TodoPriority;
}

export interface TodoStats {
  total: number;
  completed: number;
  pending: number;
  byPriority: {
    low: number;
    medium: number;
    high: number;
    urgent: number;
  };
  byCategory: Record<string, number>;
  averageCompletionTime: number;
}
