# RestfulAPI React Frontend

A modern React TypeScript frontend for the Module 03 RestfulAPI, demonstrating best practices for integrating a SPA with ASP.NET Core Web API.

## Features

- **React 18** with TypeScript
- **Vite** for fast development and optimized builds
- **React Query** for efficient data fetching and caching
- **Docker** support for both development and production
- **Nginx** for production deployment
- Full CRUD operations for Product management
- Responsive design
- Error handling and loading states

## Prerequisites

- Node.js 18+ (for local development)
- Docker and Docker Compose (for containerized deployment)
- The RestfulAPI backend running on port 5001

## Getting Started

### Local Development

1. Install dependencies:
   ```bash
   npm install
   ```

2. Start the development server:
   ```bash
   npm run dev
   ```

3. Open [http://localhost:3000](http://localhost:3000) in your browser

### Docker Development

Use the Docker setup with hot reload:

```bash
# From the SourceCode directory
docker-compose up --build

# Or run in background
docker-compose up -d --build
```

### Production Build

Build for production locally:
```bash
npm run build
```

## Project Structure

```
src/
├── components/          # React components
│   ├── ProductList.tsx # Main product list component
│   └── ProductForm.tsx # Product create/edit form
├── services/           # API services
│   └── api.ts         # Axios API client
├── types/             # TypeScript type definitions
│   └── Product.ts     # Product-related types
├── App.tsx            # Main app component
└── main.tsx          # Entry point
```

## Available Scripts

- `npm run dev` - Start development server
- `npm run build` - Build for production
- `npm run preview` - Preview production build locally
- `npm run lint` - Run ESLint

## API Integration

The frontend expects the RestfulAPI to be available at:
- Development: `http://localhost:5001`
- Docker: Automatically proxied to the `restfulapi` container

## Docker Configuration

The project uses `Dockerfile.dev` for development with:
- Hot reload support via Vite
- Source code mounted as volume for live updates
- Runs on port 3000
- Automatic API proxy to backend container

## Environment Variables

The API URL is automatically configured:
- Local development: `http://localhost:5001`
- Docker development: Proxied through Vite to the backend container

## Security Features

- Content Security Policy headers
- XSS protection
- CORS properly configured
- Secure proxy configuration

## Performance Optimizations

- Code splitting with React.lazy
- React Query for efficient data caching
- Gzip compression in production
- Static asset caching

## Troubleshooting

### CORS Issues
Ensure the RestfulAPI has CORS configured to allow requests from `http://localhost:3000`

### API Connection Failed
1. Check if the RestfulAPI is running on port 5001
2. Verify Docker network connectivity
3. Check browser console for specific errors

### Docker Build Issues
```bash
# Clean rebuild
docker-compose down -v
docker-compose up --build
```

## Contributing

1. Follow the existing code style
2. Add TypeScript types for all new code
3. Test both development and production builds
4. Update documentation as needed