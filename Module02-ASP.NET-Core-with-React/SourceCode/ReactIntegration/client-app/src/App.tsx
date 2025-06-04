import { useState, useEffect } from 'react'
import './App.css'
import { Logger, networkLogger, lifecycleLogger } from './utils/logger'
import { DevTools } from './components/DevTools'

interface WeatherForecast {
  date: string
  temperatureC: number
  temperatureF: number
  summary: string
}

const componentLogger = new Logger('WeatherApp')

function App() {
  const [forecasts, setForecasts] = useState<WeatherForecast[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    lifecycleLogger.info('WeatherApp component mounted')
    fetchWeatherData()
    
    return () => {
      lifecycleLogger.info('WeatherApp component unmounting')
    }
  }, [])

  const fetchWeatherData = async () => {
    try {
      networkLogger.info('Starting weather data fetch...')
      setLoading(true)
      
      networkLogger.time('API Call')
      const response = await fetch('/api/weatherforecast')
      networkLogger.timeEnd('API Call')
      
      networkLogger.group('Response Details')
      networkLogger.debug('Status:', response.status)
      networkLogger.debug('Status Text:', response.statusText)
      networkLogger.debug('Headers:', Object.fromEntries(response.headers.entries()))
      networkLogger.groupEnd()
      
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`)
      }
      
      const data = await response.json()
      componentLogger.info('Weather data received:')
      componentLogger.table(data)
      
      setForecasts(data)
      setError(null)
      componentLogger.info('State updated successfully')
    } catch (err) {
      const errorMessage = err instanceof Error ? err.message : 'An error occurred'
      componentLogger.error('Failed to fetch weather data:', err)
      setError(errorMessage)
    } finally {
      setLoading(false)
      lifecycleLogger.debug('Loading state set to false')
    }
  }

  const formatDate = (dateString: string) => {
    const date = new Date(dateString)
    return date.toLocaleDateString('en-US', { 
      weekday: 'long', 
      year: 'numeric', 
      month: 'long', 
      day: 'numeric' 
    })
  }

  lifecycleLogger.debug('Rendering WeatherApp', { 
    loading, 
    hasError: !!error, 
    forecastCount: forecasts.length 
  })

  return (
    <>
      <div className="container">
        <h1>React + ASP.NET Core</h1>
        <div className="card">
          <h2>Weather Forecast</h2>
          <button onClick={() => {
            componentLogger.info('Refresh button clicked by user')
            fetchWeatherData()
          }}>
            Refresh Data
          </button>
        </div>

        {loading && <p>Loading...</p>}
        
        {error && (
          <div className="error">
            <p>Error: {error}</p>
          </div>
        )}
        
        {!loading && !error && (
          <div className="forecasts">
            {forecasts.map((forecast, index) => (
              <div key={index} className="forecast-card">
                <h3>{formatDate(forecast.date)}</h3>
                <p className="temperature">
                  {forecast.temperatureC}°C ({forecast.temperatureF}°F)
                </p>
                <p className="summary">{forecast.summary}</p>
              </div>
            ))}
          </div>
        )}

        <p className="read-the-docs">
          Edit <code>src/App.tsx</code> and save to test HMR
        </p>
      </div>
      
      <DevTools />
    </>
  )
}

export default App