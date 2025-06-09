# Module 07 - Testing Applications Source Code

This directory contains the complete source code for the Testing Applications module.

## Database Setup

This project uses **SQLite** for data persistence, which is:
- Cross-platform (Windows, Mac, Linux)
- No installation required
- Perfect for development and training
- File-based database

## Getting Started

1. **Build the solution:**
   ```bash
   dotnet build
   ```

2. **Set up the database (optional):**
   ```bash
   # If you want to use migrations
   ./migrate-to-sqlite.ps1
   ```
   
   Or manually:
   ```bash
   cd ProductCatalog.API
   dotnet ef migrations add InitialCreate
   dotnet ef database update
   ```

3. **Run the API:**
   ```bash
   cd ProductCatalog.API
   dotnet run
   ```

4. **Run tests:**
   ```bash
   # Unit tests
   dotnet test ProductCatalog.UnitTests

   # Integration tests
   dotnet test ProductCatalog.IntegrationTests

   # All tests
   dotnet test
   ```

## Database Location

The SQLite database file `products.db` will be created in the `ProductCatalog.API` directory when you first run the application.

## Testing Strategy

- **Unit Tests**: Test individual components in isolation using mocks
- **Integration Tests**: Test the full API pipeline using WebApplicationFactory
- **Performance Tests**: Benchmark critical operations using BenchmarkDotNet

## Configuration

The application uses different database configurations based on environment:
- **Development/Testing**: In-memory database
- **Production**: SQLite database file

This is configured in `Program.cs` and can be customized in `appsettings.json`.