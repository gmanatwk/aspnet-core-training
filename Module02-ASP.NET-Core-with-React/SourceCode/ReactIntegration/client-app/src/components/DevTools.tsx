import { useState } from 'react'
import { logger } from '../utils/logger'

export function DevTools() {
  const [isOpen, setIsOpen] = useState(false)
  const [showNetworkInfo, setShowNetworkInfo] = useState(false)

  if (!import.meta.env.DEV) {
    return null
  }

  const logTestMessages = () => {
    logger.group('Test Log Messages')
    logger.info('This is an info message')
    logger.debug('This is a debug message with data:', { test: 123, array: [1, 2, 3] })
    logger.warn('This is a warning message')
    logger.error('This is an error message')
    logger.table([
      { name: 'Product 1', price: 100 },
      { name: 'Product 2', price: 200 }
    ])
    logger.groupEnd()
  }

  const showEnvironmentInfo = () => {
    logger.group('Environment Information')
    logger.info('React Version:', import.meta.env.VITE_REACT_VERSION || 'Unknown')
    logger.info('API URL:', window.location.origin)
    logger.info('Browser:', navigator.userAgent)
    logger.table({
      'Screen Resolution': `${window.screen.width}x${window.screen.height}`,
      'Window Size': `${window.innerWidth}x${window.innerHeight}`,
      'Pixel Ratio': window.devicePixelRatio,
      'Online Status': navigator.onLine ? 'Online' : 'Offline',
      'Language': navigator.language,
      'Cookies Enabled': navigator.cookieEnabled
    })
    logger.groupEnd()
  }

  const testApiCall = async () => {
    logger.time('Test API Call')
    try {
      const response = await fetch('/api/weatherforecast')
      const data = await response.json()
      logger.info('Test API Response:', data)
    } catch (error) {
      logger.error('Test API Error:', error)
    }
    logger.timeEnd('Test API Call')
  }

  return (
    <div style={{
      position: 'fixed',
      bottom: 20,
      right: 20,
      backgroundColor: '#1a1a1a',
      color: 'white',
      padding: isOpen ? 20 : 10,
      borderRadius: 8,
      boxShadow: '0 4px 6px rgba(0,0,0,0.3)',
      zIndex: 9999,
      fontFamily: 'monospace',
      fontSize: 12
    }}>
      <button
        onClick={() => setIsOpen(!isOpen)}
        style={{
          background: 'none',
          border: 'none',
          color: 'white',
          cursor: 'pointer',
          fontSize: 14,
          padding: 0
        }}
      >
        {isOpen ? '🔽 Dev Tools' : '🔧 Dev Tools'}
      </button>

      {isOpen && (
        <div style={{ marginTop: 10 }}>
          <h4 style={{ margin: '10px 0' }}>Console Logging Tools</h4>
          
          <button onClick={logTestMessages} style={buttonStyle}>
            📝 Log Test Messages
          </button>
          
          <button onClick={showEnvironmentInfo} style={buttonStyle}>
            🌍 Show Environment Info
          </button>
          
          <button onClick={testApiCall} style={buttonStyle}>
            🔌 Test API Call
          </button>
          
          <button onClick={() => console.clear()} style={buttonStyle}>
            🗑️ Clear Console
          </button>

          <div style={{ marginTop: 10 }}>
            <label style={{ display: 'block', margin: '5px 0' }}>
              <input
                type="checkbox"
                checked={showNetworkInfo}
                onChange={(e) => setShowNetworkInfo(e.target.checked)}
                style={{ marginRight: 5 }}
              />
              Show Network Info in Console
            </label>
          </div>

          <div style={{ marginTop: 10, fontSize: 10, opacity: 0.7 }}>
            Open browser DevTools (F12) to see logs
          </div>
        </div>
      )}
    </div>
  )
}

const buttonStyle: React.CSSProperties = {
  display: 'block',
  width: '100%',
  padding: '5px 10px',
  margin: '5px 0',
  backgroundColor: '#333',
  color: 'white',
  border: '1px solid #555',
  borderRadius: 4,
  cursor: 'pointer',
  fontSize: 12,
  textAlign: 'left'
}