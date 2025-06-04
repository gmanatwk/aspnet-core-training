// Logger utility for development
export class Logger {
  private prefix: string
  private enabled: boolean

  constructor(prefix: string = 'App') {
    this.prefix = prefix
    this.enabled = import.meta.env.DEV
  }

  private formatMessage(level: string, message: string): string {
    const timestamp = new Date().toLocaleTimeString()
    return `[${timestamp}] [${this.prefix}] [${level}] ${message}`
  }

  info(message: string, ...args: any[]) {
    if (!this.enabled) return
    console.log(
      `%c${this.formatMessage('INFO', message)}`,
      'color: #4CAF50; font-weight: bold',
      ...args
    )
  }

  error(message: string, ...args: any[]) {
    if (!this.enabled) return
    console.error(
      `%c${this.formatMessage('ERROR', message)}`,
      'color: #f44336; font-weight: bold',
      ...args
    )
  }

  debug(message: string, ...args: any[]) {
    if (!this.enabled) return
    console.log(
      `%c${this.formatMessage('DEBUG', message)}`,
      'color: #2196F3',
      ...args
    )
  }

  warn(message: string, ...args: any[]) {
    if (!this.enabled) return
    console.warn(
      `%c${this.formatMessage('WARN', message)}`,
      'color: #ff9800; font-weight: bold',
      ...args
    )
  }

  group(label: string) {
    if (!this.enabled) return
    console.group(`%c${this.prefix}: ${label}`, 'color: #9C27B0; font-weight: bold')
  }

  groupEnd() {
    if (!this.enabled) return
    console.groupEnd()
  }

  table(data: any) {
    if (!this.enabled) return
    console.table(data)
  }

  time(label: string) {
    if (!this.enabled) return
    console.time(`${this.prefix}: ${label}`)
  }

  timeEnd(label: string) {
    if (!this.enabled) return
    console.timeEnd(`${this.prefix}: ${label}`)
  }
}

// Create default logger instance
export const logger = new Logger()

// Network request logger
export const networkLogger = new Logger('Network')

// Component lifecycle logger
export const lifecycleLogger = new Logger('Lifecycle')