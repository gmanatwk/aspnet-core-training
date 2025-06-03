import { useState, useEffect } from 'react'
import './App.css'

interface WeatherForecast {
  date: string
  temperatureC: number
  temperatureF: number
  summary: string
}

function App() {
  const [forecasts, setForecasts] = useState<WeatherForecast[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    fetchWeatherData()
  }, [])

  const fetchWeatherData = async () => {
    try {
      setLoading(true)
      const response = await fetch('/api/weatherforecast')
      
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`)
      }
      
      const data = await response.json()
      setForecasts(data)
      setError(null)
    } catch (err) {
      setError(err instanceof Error ? err.message : 'An error occurred')
    } finally {
      setLoading(false)
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

  return (
    <>
      <div className="container">
        <h1>React + ASP.NET Core</h1>
        <div className="card">
          <h2>Weather Forecast</h2>
          <button onClick={fetchWeatherData}>
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
    </>
  )
}

export default App