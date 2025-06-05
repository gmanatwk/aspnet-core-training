import React, { useState, useEffect } from 'react';
import { TodoStats as TodoStatsType } from '../types/Todo';
import { todoService } from '../services/todoService';

const TodoStats: React.FC = () => {
  const [stats, setStats] = useState<TodoStatsType | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    loadStats();
  }, []);

  const loadStats = async () => {
    try {
      setLoading(true);
      setError(null);
      const data = await todoService.getStats();
      setStats(data);
    } catch (err) {
      setError('Failed to load statistics. Please try again.');
      console.error('Error loading stats:', err);
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return <div className="loading">Loading statistics...</div>;
  }

  if (error) {
    return (
      <div className="error">
        {error}
        <button
          type="button"
          onClick={loadStats}
          className="retry-button"
          aria-label="Retry loading statistics"
        >
          Retry
        </button>
      </div>
    );
  }

  if (!stats) {
    return <div className="error">No statistics available.</div>;
  }

  return (
    <div className="stats-container">
      <div className="stats-card">
        <h3>📊 Overview</h3>
        <div className="stat-item">
          <span>Total Todos</span>
          <span className="stat-value">{stats.total}</span>
        </div>
        <div className="stat-item">
          <span>Completed</span>
          <span className="stat-value">{stats.completed}</span>
        </div>
        <div className="stat-item">
          <span>Pending</span>
          <span className="stat-value">{stats.pending}</span>
        </div>
        <div className="stat-item">
          <span>Completion Rate</span>
          <span className="stat-value">{stats.completionRate}%</span>
        </div>
      </div>

      <div className="stats-card">
        <h3>🎯 By Priority</h3>
        {Object.entries(stats.byPriority).map(([priority, count]) => (
          <div key={priority} className="stat-item">
            <span>{priority}</span>
            <span className="stat-value">{count}</span>
          </div>
        ))}
      </div>

      <div className="stats-card">
        <h3>📁 By Category</h3>
        {Object.keys(stats.byCategory).length > 0 ? (
          Object.entries(stats.byCategory).map(([category, count]) => (
            <div key={category} className="stat-item">
              <span>{category}</span>
              <span className="stat-value">{count}</span>
            </div>
          ))
        ) : (
          <p className="no-categories-message">
            No categories assigned yet
          </p>
        )}
      </div>

      <div className="stats-card">
        <h3>🔄 Actions</h3>
        <button
          type="button"
          onClick={loadStats}
          className="add-button refresh-stats-button"
          aria-label="Refresh statistics"
        >
          Refresh Statistics
        </button>
        <p className="stats-description">
          Statistics are updated in real-time as you manage your todos.
        </p>
      </div>
    </div>
  );
};

export default TodoStats;
