import React from 'react'
import ReactDOM from 'react-dom/client'
import App from './App.tsx'
import './index.css'
import { logger } from './utils/logger'

// Log application startup information
logger.group('Application Startup')
logger.info('React + ASP.NET Core Module Starting...')
logger.debug('Environment:', import.meta.env.MODE)
logger.debug('Development mode:', import.meta.env.DEV)
logger.debug('Base URL:', import.meta.env.BASE_URL)
logger.debug('React version:', React.version)
logger.table({
  'API URL': window.location.origin,
  'App URL': window.location.href,
  'User Agent': navigator.userAgent,
  'Language': navigator.language,
  'Platform': navigator.platform,
  'Vite Mode': import.meta.env.MODE
})
logger.groupEnd()

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>,
)

logger.info('React app rendered successfully')