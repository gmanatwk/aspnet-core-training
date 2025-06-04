import React, { useEffect, useState } from 'react';

interface PerformanceMetrics {
  renderTime: number;
  apiCallTime: number;
  memoryUsage: number;
}

const PerformanceMonitor: React.FC = () => {
  const [metrics, setMetrics] = useState<PerformanceMetrics>({
    renderTime: 0,
    apiCallTime: 0,
    memoryUsage: 0,
  });

  useEffect(() => {
    // Monitor render performance
    const observer = new PerformanceObserver((list) => {
      for (const entry of list.getEntries()) {
        if (entry.entryType === 'measure' && entry.name.startsWith('render-')) {
          setMetrics(prev => ({ ...prev, renderTime: entry.duration }));
        }
      }
    });

    observer.observe({ entryTypes: ['measure'] });

    // Monitor memory usage
    const memoryInterval = setInterval(() => {
      if ('memory' in performance) {
        const memory = (performance as any).memory;
        setMetrics(prev => ({
          ...prev,
          memoryUsage: memory.usedJSHeapSize / 1048576, // Convert to MB
        }));
      }
    }, 1000);

    return () => {
      observer.disconnect();
      clearInterval(memoryInterval);
    };
  }, []);

  if (process.env.NODE_ENV !== 'development') {
    return null;
  }

  return (
    <div className="performance-monitor">
      <h4>Performance Metrics</h4>
      <div>Render Time: {metrics.renderTime.toFixed(2)}ms</div>
      <div>Memory Usage: {metrics.memoryUsage.toFixed(2)}MB</div>
    </div>
  );
};

export default PerformanceMonitor;