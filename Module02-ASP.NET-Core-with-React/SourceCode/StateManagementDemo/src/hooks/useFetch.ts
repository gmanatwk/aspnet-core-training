import { useState, useEffect, useCallback } from 'react';

interface FetchState<T> {
  data: T | null;
  loading: boolean;
  error: string | null;
}

interface UseFetchOptions {
  immediate?: boolean;
}

export function useFetch<T>(url: string, options: UseFetchOptions = {}) {
  const { immediate = true } = options;
  
  const [state, setState] = useState<FetchState<T>>({
    data: null,
    loading: false,
    error: null,
  });

  const fetchData = useCallback(async () => {
    setState(prev => ({ ...prev, loading: true, error: null }));
    
    try {
      // Simulate API delay for demonstration
      await new Promise(resolve => setTimeout(resolve, 1000));
      
      // Simulate different responses based on URL
      let mockData: any;
      
      if (url.includes('users')) {
        mockData = [
          { id: 1, name: 'John Doe', email: 'john@example.com' },
          { id: 2, name: 'Jane Smith', email: 'jane@example.com' },
          { id: 3, name: 'Bob Johnson', email: 'bob@example.com' },
        ];
      } else if (url.includes('posts')) {
        mockData = [
          { id: 1, title: 'First Post', content: 'This is the first post' },
          { id: 2, title: 'Second Post', content: 'This is the second post' },
          { id: 3, title: 'Third Post', content: 'This is the third post' },
        ];
      } else {
        mockData = { message: 'Mock data for ' + url };
      }

      setState({
        data: mockData,
        loading: false,
        error: null,
      });
    } catch (error) {
      setState({
        data: null,
        loading: false,
        error: error instanceof Error ? error.message : 'An error occurred',
      });
    }
  }, [url]);

  const refetch = useCallback(() => {
    fetchData();
  }, [fetchData]);

  useEffect(() => {
    if (immediate) {
      fetchData();
    }
  }, [fetchData, immediate]);

  return {
    ...state,
    refetch,
  };
}
