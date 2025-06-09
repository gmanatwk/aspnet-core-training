import { GetServerSideProps } from 'next';
import Head from 'next/head';
import { todoApi } from '@/lib/api';
import { TodoStats, Todo } from '@/types/todo';

interface StatsProps {
  stats: TodoStats;
  todos: Todo[];
  renderTime: string;
}

export default function Stats({ stats, todos, renderTime }: StatsProps) {
  const completionRate = stats.total > 0 ? (stats.completed / stats.total * 100).toFixed(1) : 0;

  return (
    <>
      <Head>
        <title>Todo Statistics - SSR Demo</title>
        <meta name="description" content="Server-side rendered statistics for Todo application" />
      </Head>

      <div className="stats-container">
        <div className="ssr-info">
          <h1>📊 Todo Statistics (Server-Side Rendered)</h1>
          <p className="render-info">
            🚀 <strong>SSR:</strong> Statistics calculated on server at <strong>{renderTime}</strong>
          </p>
        </div>

        <div className="stats-grid">
          <div className="stat-card primary">
            <h3>Total Todos</h3>
            <div className="stat-value">{stats.total}</div>
          </div>

          <div className="stat-card success">
            <h3>Completed</h3>
            <div className="stat-value">{stats.completed}</div>
          </div>

          <div className="stat-card warning">
            <h3>Pending</h3>
            <div className="stat-value">{stats.pending}</div>
          </div>

          <div className="stat-card info">
            <h3>Completion Rate</h3>
            <div className="stat-value">{completionRate}%</div>
          </div>
        </div>

        <div className="detailed-stats">
          <div className="stat-section">
            <h3>📋 Priority Breakdown</h3>
            <div className="priority-stats">
              <div className="priority-item low">
                <span className="priority-label">Low Priority</span>
                <span className="priority-count">{stats.byPriority.low}</span>
              </div>
              <div className="priority-item medium">
                <span className="priority-label">Medium Priority</span>
                <span className="priority-count">{stats.byPriority.medium}</span>
              </div>
              <div className="priority-item high">
                <span className="priority-label">High Priority</span>
                <span className="priority-count">{stats.byPriority.high}</span>
              </div>
              <div className="priority-item urgent">
                <span className="priority-label">Urgent Priority</span>
                <span className="priority-count">{stats.byPriority.urgent}</span>
              </div>
            </div>
          </div>

          <div className="stat-section">
            <h3>🏷️ Category Breakdown</h3>
            <div className="category-stats">
              {Object.entries(stats.byCategory).length > 0 ? (
                Object.entries(stats.byCategory).map(([category, count]) => (
                  <div key={category} className="category-item">
                    <span className="category-label">{category || 'Uncategorized'}</span>
                    <span className="category-count">{count}</span>
                  </div>
                ))
              ) : (
                <p className="no-data">No categories found</p>
              )}
            </div>
          </div>

          <div className="stat-section">
            <h3>⏱️ Performance Metrics</h3>
            <div className="performance-stats">
              <div className="metric">
                <span className="metric-label">Average Completion Time</span>
                <span className="metric-value">
                  {stats.averageCompletionTime > 0 
                    ? `${stats.averageCompletionTime.toFixed(1)} days`
                    : 'No completed todos'
                  }
                </span>
              </div>
            </div>
          </div>
        </div>

        <div className="recent-todos">
          <h3>📝 Recent Todos</h3>
          <div className="recent-list">
            {todos.slice(0, 5).map(todo => (
              <div key={todo.id} className={`recent-item ${todo.isCompleted ? 'completed' : ''}`}>
                <span className="recent-title">{todo.title}</span>
                <span className="recent-status">
                  {todo.isCompleted ? '✅ Completed' : '⏳ Pending'}
                </span>
              </div>
            ))}
          </div>
        </div>
      </div>

      <style jsx>{`
        .stats-container {
          max-width: 1000px;
          margin: 0 auto;
        }

        .ssr-info {
          background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
          color: white;
          padding: 2rem;
          border-radius: 8px;
          margin-bottom: 2rem;
          text-align: center;
        }

        .ssr-info h1 {
          margin: 0 0 1rem 0;
          font-size: 2rem;
        }

        .render-info {
          margin: 0;
          font-size: 1rem;
        }

        .stats-grid {
          display: grid;
          grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
          gap: 1.5rem;
          margin-bottom: 2rem;
        }

        .stat-card {
          background: white;
          padding: 2rem;
          border-radius: 8px;
          text-align: center;
          border: 1px solid #e1e5e9;
          box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
        }

        .stat-card h3 {
          margin: 0 0 1rem 0;
          font-size: 1rem;
          font-weight: 600;
          text-transform: uppercase;
          letter-spacing: 0.5px;
        }

        .stat-value {
          font-size: 3rem;
          font-weight: 700;
          line-height: 1;
        }

        .stat-card.primary .stat-value { color: #007bff; }
        .stat-card.success .stat-value { color: #28a745; }
        .stat-card.warning .stat-value { color: #ffc107; }
        .stat-card.info .stat-value { color: #17a2b8; }

        .detailed-stats {
          display: grid;
          grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
          gap: 2rem;
          margin-bottom: 2rem;
        }

        .stat-section {
          background: white;
          padding: 2rem;
          border-radius: 8px;
          border: 1px solid #e1e5e9;
        }

        .stat-section h3 {
          margin: 0 0 1.5rem 0;
          color: #2c3e50;
          font-size: 1.2rem;
        }

        .priority-stats,
        .category-stats {
          display: flex;
          flex-direction: column;
          gap: 0.75rem;
        }

        .priority-item,
        .category-item {
          display: flex;
          justify-content: space-between;
          align-items: center;
          padding: 0.75rem;
          border-radius: 4px;
          background: #f8f9fa;
        }

        .priority-item.low { border-left: 4px solid #28a745; }
        .priority-item.medium { border-left: 4px solid #ffc107; }
        .priority-item.high { border-left: 4px solid #fd7e14; }
        .priority-item.urgent { border-left: 4px solid #dc3545; }

        .category-item { border-left: 4px solid #6c757d; }

        .priority-label,
        .category-label {
          font-weight: 500;
        }

        .priority-count,
        .category-count {
          font-weight: 600;
          color: #495057;
        }

        .performance-stats {
          display: flex;
          flex-direction: column;
          gap: 1rem;
        }

        .metric {
          display: flex;
          justify-content: space-between;
          align-items: center;
          padding: 1rem;
          background: #f8f9fa;
          border-radius: 4px;
        }

        .metric-label {
          font-weight: 500;
        }

        .metric-value {
          font-weight: 600;
          color: #007bff;
        }

        .recent-todos {
          background: white;
          padding: 2rem;
          border-radius: 8px;
          border: 1px solid #e1e5e9;
        }

        .recent-todos h3 {
          margin: 0 0 1.5rem 0;
          color: #2c3e50;
          font-size: 1.2rem;
        }

        .recent-list {
          display: flex;
          flex-direction: column;
          gap: 0.75rem;
        }

        .recent-item {
          display: flex;
          justify-content: space-between;
          align-items: center;
          padding: 1rem;
          background: #f8f9fa;
          border-radius: 4px;
          border-left: 4px solid #007bff;
        }

        .recent-item.completed {
          border-left-color: #28a745;
          opacity: 0.8;
        }

        .recent-title {
          font-weight: 500;
        }

        .recent-status {
          font-size: 0.9rem;
          font-weight: 500;
        }

        .no-data {
          color: #6c757d;
          font-style: italic;
          margin: 0;
        }

        @media (max-width: 768px) {
          .stats-grid {
            grid-template-columns: repeat(2, 1fr);
          }

          .detailed-stats {
            grid-template-columns: 1fr;
          }

          .stat-card {
            padding: 1.5rem;
          }

          .stat-value {
            font-size: 2.5rem;
          }
        }
      `}</style>
    </>
  );
}

export const getServerSideProps: GetServerSideProps = async () => {
  try {
    // Fetch both stats and todos on the server
    const [stats, todos] = await Promise.all([
      todoApi.getStats(),
      todoApi.getAll()
    ]);

    const renderTime = new Date().toISOString();

    return {
      props: {
        stats,
        todos,
        renderTime,
      },
    };
  } catch (error) {
    console.error('Error fetching stats:', error);
    
    // Return default stats if API fails
    return {
      props: {
        stats: {
          total: 0,
          completed: 0,
          pending: 0,
          byPriority: { low: 0, medium: 0, high: 0, urgent: 0 },
          byCategory: {},
          averageCompletionTime: 0,
        },
        todos: [],
        renderTime: new Date().toISOString(),
      },
    };
  }
};
