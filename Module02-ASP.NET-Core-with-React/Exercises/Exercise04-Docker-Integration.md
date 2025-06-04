# Exercise 4: Docker Integration for React + ASP.NET Core

## 🎯 Objective
Learn how to containerize React and ASP.NET Core applications using Docker, create development and production environments, and implement best practices for containerized full-stack applications.

## ⏱️ Estimated Time
40 minutes

## 📋 Prerequisites
- Completed Exercises 1, 2, and 3
- Docker Desktop installed and running
- Basic understanding of Docker concepts
- .NET 8.0 SDK installed
- Node.js 18+ installed

## 📝 Instructions

### Part 1: Create Development Docker Setup (15 minutes)

1. **Create project structure** for the exercise:
   ```bash
   mkdir TodoAppDocker
   cd TodoAppDocker
   ```

2. **Create ASP.NET Core Web API**:
   ```bash
   dotnet new webapi -n TodoApi
   cd TodoApi
   ```

3. **Add necessary packages**:
   ```bash
   dotnet add package Microsoft.AspNetCore.SpaServices.Extensions
   dotnet add package Swashbuckle.AspNetCore
   ```

4. **Create Todo model and controller** in `Models/Todo.cs`:
   ```csharp
   namespace TodoApi.Models
   {
       public class Todo
       {
           public int Id { get; set; }
           public string Title { get; set; } = string.Empty;
           public bool IsCompleted { get; set; }
           public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
       }
   }
   ```

5. **Create TodoController** in `Controllers/TodoController.cs`:
   ```csharp
   using Microsoft.AspNetCore.Mvc;
   using TodoApi.Models;

   namespace TodoApi.Controllers
   {
       [ApiController]
       [Route("api/[controller]")]
       public class TodoController : ControllerBase
       {
           private static List<Todo> _todos = new()
           {
               new Todo { Id = 1, Title = "Learn Docker", IsCompleted = false },
               new Todo { Id = 2, Title = "Build React App", IsCompleted = true }
           };

           [HttpGet]
           public ActionResult<IEnumerable<Todo>> GetTodos()
           {
               return Ok(_todos);
           }

           [HttpGet("{id}")]
           public ActionResult<Todo> GetTodo(int id)
           {
               var todo = _todos.FirstOrDefault(t => t.Id == id);
               return todo == null ? NotFound() : Ok(todo);
           }

           [HttpPost]
           public ActionResult<Todo> CreateTodo(Todo todo)
           {
               todo.Id = _todos.Max(t => t.Id) + 1;
               todo.CreatedAt = DateTime.UtcNow;
               _todos.Add(todo);
               return CreatedAtAction(nameof(GetTodo), new { id = todo.Id }, todo);
           }

           [HttpPut("{id}")]
           public IActionResult UpdateTodo(int id, Todo todo)
           {
               var existingTodo = _todos.FirstOrDefault(t => t.Id == id);
               if (existingTodo == null) return NotFound();

               existingTodo.Title = todo.Title;
               existingTodo.IsCompleted = todo.IsCompleted;
               return NoContent();
           }

           [HttpDelete("{id}")]
           public IActionResult DeleteTodo(int id)
           {
               var todo = _todos.FirstOrDefault(t => t.Id == id);
               if (todo == null) return NotFound();

               _todos.Remove(todo);
               return NoContent();
           }
       }
   }
   ```

6. **Update Program.cs**:
   ```csharp
   var builder = WebApplication.CreateBuilder(args);

   // Add services
   builder.Services.AddControllers();
   builder.Services.AddEndpointsApiExplorer();
   builder.Services.AddSwaggerGen();

   // Add CORS for development
   builder.Services.AddCors(options =>
   {
       options.AddPolicy("AllowReactApp",
           policy => policy
               .WithOrigins("http://localhost:3000", "http://localhost:5173")
               .AllowAnyHeader()
               .AllowAnyMethod());
   });

   var app = builder.Build();

   // Configure pipeline
   if (app.Environment.IsDevelopment())
   {
       app.UseSwagger();
       app.UseSwaggerUI();
   }

   app.UseCors("AllowReactApp");
   app.UseHttpsRedirection();
   app.UseAuthorization();
   app.MapControllers();

   app.Run();
   ```

7. **Create Dockerfile for API** in `TodoApi/Dockerfile`:
   ```dockerfile
   # Development Dockerfile for ASP.NET Core API
   FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
   WORKDIR /app
   EXPOSE 80
   EXPOSE 443

   # Create non-root user for security
   RUN addgroup --system --gid 1000 appgroup \
       && adduser --system --uid 1000 --ingroup appgroup --shell /bin/false appuser

   FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
   WORKDIR /src

   # Copy project file and restore dependencies
   COPY ["TodoApi.csproj", "."]
   RUN dotnet restore "./TodoApi.csproj"

   # Copy source code
   COPY . .
   RUN dotnet build "TodoApi.csproj" -c Release -o /app/build

   FROM build AS publish
   RUN dotnet publish "TodoApi.csproj" -c Release -o /app/publish /p:UseAppHost=false

   FROM base AS final
   WORKDIR /app
   USER appuser
   COPY --from=publish /app/publish .
   ENTRYPOINT ["dotnet", "TodoApi.dll"]
   ```

8. **Create .dockerignore** in `TodoApi/.dockerignore`:
   ```
   **/.dockerignore
   **/.git
   **/.gitignore
   **/.vs
   **/.vscode
   **/bin
   **/obj
   **/.env
   **/node_modules
   README.md
   Dockerfile*
   .dockerignore
   ```

### Part 2: Create React Application with Docker (10 minutes)

1. **Navigate back to project root and create React app**:
   ```bash
   cd ..
   npm create vite@latest todo-frontend -- --template react-ts
   cd todo-frontend
   npm install axios
   ```

2. **Create Todo service** in `src/services/todoService.ts`:
   ```typescript
   import axios from 'axios';

   const API_BASE_URL = process.env.NODE_ENV === 'production' 
     ? '/api/todo' 
     : 'http://localhost:5000/api/todo';

   export interface Todo {
     id?: number;
     title: string;
     isCompleted: boolean;
     createdAt?: string;
   }

   const api = axios.create({
     baseURL: API_BASE_URL,
     headers: {
       'Content-Type': 'application/json',
     },
   });

   export const todoService = {
     async getAll(): Promise<Todo[]> {
       const response = await api.get('');
       return response.data;
     },

     async create(todo: Omit<Todo, 'id'>): Promise<Todo> {
       const response = await api.post('', todo);
       return response.data;
     },

     async update(id: number, todo: Partial<Todo>): Promise<void> {
       await api.put(`/${id}`, todo);
     },

     async delete(id: number): Promise<void> {
       await api.delete(`/${id}`);
     },
   };
   ```

3. **Create main Todo component** in `src/components/TodoApp.tsx`:
   ```typescript
   import React, { useState, useEffect } from 'react';
   import { Todo, todoService } from '../services/todoService';

   const TodoApp: React.FC = () => {
     const [todos, setTodos] = useState<Todo[]>([]);
     const [newTodo, setNewTodo] = useState('');
     const [loading, setLoading] = useState(true);
     const [error, setError] = useState<string | null>(null);

     useEffect(() => {
       loadTodos();
     }, []);

     const loadTodos = async () => {
       try {
         setLoading(true);
         const data = await todoService.getAll();
         setTodos(data);
         setError(null);
       } catch (err) {
         setError('Failed to load todos');
         console.error('Error loading todos:', err);
       } finally {
         setLoading(false);
       }
     };

     const handleAddTodo = async (e: React.FormEvent) => {
       e.preventDefault();
       if (!newTodo.trim()) return;

       try {
         const todo = await todoService.create({
           title: newTodo,
           isCompleted: false,
         });
         setTodos([...todos, todo]);
         setNewTodo('');
       } catch (err) {
         setError('Failed to add todo');
         console.error('Error adding todo:', err);
       }
     };

     const handleToggleTodo = async (id: number) => {
       const todo = todos.find(t => t.id === id);
       if (!todo) return;

       try {
         await todoService.update(id, { isCompleted: !todo.isCompleted });
         setTodos(todos.map(t => 
           t.id === id ? { ...t, isCompleted: !t.isCompleted } : t
         ));
       } catch (err) {
         setError('Failed to update todo');
         console.error('Error updating todo:', err);
       }
     };

     const handleDeleteTodo = async (id: number) => {
       try {
         await todoService.delete(id);
         setTodos(todos.filter(t => t.id !== id));
       } catch (err) {
         setError('Failed to delete todo');
         console.error('Error deleting todo:', err);
       }
     };

     if (loading) return <div className="loading">Loading todos...</div>;

     return (
       <div className="todo-app">
         <h1>Docker Todo App</h1>
         
         {error && <div className="error">{error}</div>}
         
         <form onSubmit={handleAddTodo} className="add-todo-form">
           <input
             type="text"
             value={newTodo}
             onChange={(e) => setNewTodo(e.target.value)}
             placeholder="Add a new todo..."
             className="todo-input"
           />
           <button type="submit" className="add-button">Add Todo</button>
         </form>

         <div className="todo-list">
           {todos.map(todo => (
             <div key={todo.id} className={`todo-item ${todo.isCompleted ? 'completed' : ''}`}>
               <input
                 type="checkbox"
                 checked={todo.isCompleted}
                 onChange={() => handleToggleTodo(todo.id!)}
               />
               <span className="todo-title">{todo.title}</span>
               <button 
                 onClick={() => handleDeleteTodo(todo.id!)}
                 className="delete-button"
               >
                 Delete
               </button>
             </div>
           ))}
         </div>

         <div className="stats">
           <p>Total: {todos.length} | Completed: {todos.filter(t => t.isCompleted).length}</p>
         </div>
       </div>
     );
   };

   export default TodoApp;
   ```

4. **Update App.tsx**:
   ```typescript
   import TodoApp from './components/TodoApp'
   import './App.css'

   function App() {
     return <TodoApp />
   }

   export default App
   ```

5. **Add basic styles** in `src/App.css`:
   ```css
   .todo-app {
     max-width: 600px;
     margin: 0 auto;
     padding: 20px;
     font-family: Arial, sans-serif;
   }

   .add-todo-form {
     display: flex;
     gap: 10px;
     margin-bottom: 20px;
   }

   .todo-input {
     flex: 1;
     padding: 10px;
     border: 1px solid #ddd;
     border-radius: 4px;
   }

   .add-button {
     padding: 10px 20px;
     background: #007bff;
     color: white;
     border: none;
     border-radius: 4px;
     cursor: pointer;
   }

   .todo-item {
     display: flex;
     align-items: center;
     gap: 10px;
     padding: 10px;
     border: 1px solid #eee;
     margin-bottom: 5px;
     border-radius: 4px;
   }

   .todo-item.completed .todo-title {
     text-decoration: line-through;
     color: #888;
   }

   .delete-button {
     background: #dc3545;
     color: white;
     border: none;
     padding: 5px 10px;
     border-radius: 4px;
     cursor: pointer;
   }

   .loading, .error {
     text-align: center;
     padding: 20px;
   }

   .error {
     color: #dc3545;
     background: #f8d7da;
     border-radius: 4px;
   }

   .stats {
     margin-top: 20px;
     text-align: center;
     color: #666;
   }
   ```

6. **Create Dockerfile for React** in `todo-frontend/Dockerfile`:
   ```dockerfile
   # Multi-stage build for React app
   FROM node:18.18.0-alpine AS build

   # Set working directory
   WORKDIR /app

   # Copy package files
   COPY package*.json ./

   # Install dependencies
   RUN npm ci --only=production

   # Copy source code
   COPY . .

   # Build the app
   RUN npm run build

   # Production stage with nginx
   FROM nginx:alpine AS production

   # Copy built app to nginx
   COPY --from=build /app/dist /usr/share/nginx/html

   # Copy nginx configuration
   COPY nginx.conf /etc/nginx/conf.d/default.conf

   # Expose port
   EXPOSE 80

   # Start nginx
   CMD ["nginx", "-g", "daemon off;"]
   ```

7. **Create nginx configuration** in `todo-frontend/nginx.conf`:
   ```nginx
   server {
       listen 80;
       server_name localhost;
       root /usr/share/nginx/html;
       index index.html;

       # Handle React Router
       location / {
           try_files $uri $uri/ /index.html;
       }

       # API proxy for production
       location /api/ {
           proxy_pass http://todo-api:80/api/;
           proxy_set_header Host $host;
           proxy_set_header X-Real-IP $remote_addr;
           proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
           proxy_set_header X-Forwarded-Proto $scheme;
       }

       # Security headers
       add_header X-Frame-Options "SAMEORIGIN" always;
       add_header X-Content-Type-Options "nosniff" always;
       add_header X-XSS-Protection "1; mode=block" always;

       # Gzip compression
       gzip on;
       gzip_vary on;
       gzip_min_length 1024;
       gzip_types text/plain text/css text/xml text/javascript application/javascript application/xml+rss application/json;
   }
   ```

8. **Create .dockerignore** in `todo-frontend/.dockerignore`:
   ```
   node_modules
   npm-debug.log
   .git
   .gitignore
   README.md
   .env
   .nyc_output
   coverage
   .vscode
   .DS_Store
   dist
   ```

### Part 3: Create Docker Compose Setup (10 minutes)

1. **Navigate back to project root** and create `docker-compose.yml`:
   ```yaml
   version: '3.8'

   networks:
     todo-network:
       driver: bridge

   services:
     # ASP.NET Core API
     todo-api:
       build:
         context: ./TodoApi
         dockerfile: Dockerfile
       container_name: todo-api
       environment:
         - ASPNETCORE_ENVIRONMENT=Development
         - ASPNETCORE_URLS=http://+:80
       ports:
         - "5000:80"
       networks:
         - todo-network
       healthcheck:
         test: ["CMD", "curl", "-f", "http://localhost/api/todo"]
         interval: 30s
         timeout: 10s
         retries: 3
         start_period: 40s

     # React Frontend
     todo-frontend:
       build:
         context: ./todo-frontend
         dockerfile: Dockerfile
       container_name: todo-frontend
       ports:
         - "3000:80"
       networks:
         - todo-network
       depends_on:
         todo-api:
           condition: service_healthy
       environment:
         - NODE_ENV=production
   ```

2. **Create development docker-compose** in `docker-compose.dev.yml`:
   ```yaml
   version: '3.8'

   networks:
     todo-network:
       driver: bridge

   services:
     # ASP.NET Core API (Development)
     todo-api:
       build:
         context: ./TodoApi
         dockerfile: Dockerfile
       container_name: todo-api-dev
       environment:
         - ASPNETCORE_ENVIRONMENT=Development
         - ASPNETCORE_URLS=http://+:80
       ports:
         - "5000:80"
       networks:
         - todo-network
       volumes:
         - ./TodoApi:/app/src
       command: ["dotnet", "watch", "run", "--project", "/app/src"]

     # React Frontend (Development with hot reload)
     todo-frontend-dev:
       image: node:18.18.0-alpine
       container_name: todo-frontend-dev
       working_dir: /app
       environment:
         - NODE_ENV=development
       ports:
         - "3000:3000"
       networks:
         - todo-network
       volumes:
         - ./todo-frontend:/app
         - /app/node_modules
       command: sh -c "npm install && npm run dev -- --host 0.0.0.0"
       depends_on:
         - todo-api
   ```

3. **Create production docker-compose** in `docker-compose.prod.yml`:
   ```yaml
   version: '3.8'

   networks:
     todo-network:
       driver: bridge

   services:
     # ASP.NET Core API (Production)
     todo-api:
       build:
         context: ./TodoApi
         dockerfile: Dockerfile
       container_name: todo-api-prod
       environment:
         - ASPNETCORE_ENVIRONMENT=Production
         - ASPNETCORE_URLS=http://+:80
       networks:
         - todo-network
       restart: unless-stopped
       healthcheck:
         test: ["CMD", "curl", "-f", "http://localhost/api/todo"]
         interval: 30s
         timeout: 10s
         retries: 3

     # React Frontend (Production)
     todo-frontend:
       build:
         context: ./todo-frontend
         dockerfile: Dockerfile
       container_name: todo-frontend-prod
       ports:
         - "80:80"
       networks:
         - todo-network
       depends_on:
         todo-api:
           condition: service_healthy
       restart: unless-stopped

     # Nginx Load Balancer (Optional)
     nginx-lb:
       image: nginx:alpine
       container_name: nginx-lb
       ports:
         - "8080:80"
       volumes:
         - ./nginx-lb.conf:/etc/nginx/conf.d/default.conf
       networks:
         - todo-network
       depends_on:
         - todo-frontend
       restart: unless-stopped
   ```

### Part 4: Testing and Running the Application (5 minutes)

1. **Build and run the application**:
   ```bash
   # Build and run in production mode
   docker-compose up --build

   # Or run in development mode with hot reload
   docker-compose -f docker-compose.dev.yml up --build

   # Run in background
   docker-compose up -d --build
   ```

2. **Test the application**:
   - Frontend: http://localhost:3000
   - API: http://localhost:5000/api/todo
   - Swagger: http://localhost:5000/swagger

3. **Verify Docker containers**:
   ```bash
   # Check running containers
   docker ps

   # Check logs
   docker-compose logs todo-api
   docker-compose logs todo-frontend

   # Check container health
   docker inspect todo-api | grep Health -A 10
   ```

4. **Test API endpoints**:
   ```bash
   # Get all todos
   curl http://localhost:5000/api/todo

   # Create a new todo
   curl -X POST http://localhost:5000/api/todo \
     -H "Content-Type: application/json" \
     -d '{"title":"Test Docker Todo","isCompleted":false}'
   ```

5. **Clean up**:
   ```bash
   # Stop containers
   docker-compose down

   # Remove volumes and images
   docker-compose down -v --rmi all

   # Clean up Docker system
   docker system prune -f
   ```

## ✅ Success Criteria

- [ ] ASP.NET Core API runs in Docker container
- [ ] React frontend runs in Docker container with nginx
- [ ] Both containers communicate successfully
- [ ] Development setup supports hot reload
- [ ] Production setup is optimized and secure
- [ ] Health checks work correctly
- [ ] API endpoints respond correctly
- [ ] Frontend can perform CRUD operations

## 🚀 Bonus Challenges

1. **Add Database Container**:
   - Add PostgreSQL or SQL Server container
   - Update API to use real database
   - Add database migrations

2. **Implement CI/CD Pipeline**:
   - Create GitHub Actions workflow
   - Build and push Docker images
   - Deploy to container registry

3. **Add Monitoring**:
   - Add Prometheus and Grafana containers
   - Implement application metrics
   - Create monitoring dashboards

4. **Security Enhancements**:
   - Add HTTPS with SSL certificates
   - Implement authentication with JWT
   - Add rate limiting and security headers

## 🤔 Reflection Questions

1. What are the benefits of containerizing both frontend and backend?
2. How does Docker Compose simplify multi-container applications?
3. What are the differences between development and production Docker setups?
4. How would you handle secrets and environment variables in production?
5. What strategies would you use for container orchestration at scale?

## 🆘 Troubleshooting

**Issue**: Containers can't communicate
**Solution**: Ensure both containers are on the same Docker network and use service names for communication.

**Issue**: React app can't reach API
**Solution**: Check CORS configuration in ASP.NET Core and verify proxy settings in nginx.conf.

**Issue**: Hot reload not working in development
**Solution**: Ensure volumes are correctly mounted and the development server is configured to watch for changes.

**Issue**: Build fails due to missing dependencies
**Solution**: Check Dockerfile COPY commands and ensure all necessary files are included.

**Issue**: Health checks failing
**Solution**: Verify the health check endpoint exists and is accessible within the container.

## 📚 Additional Resources

- [Docker Best Practices](https://docs.docker.com/develop/best-practices/)
- [Multi-stage Docker Builds](https://docs.docker.com/develop/dev-best-practices/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [ASP.NET Core in Docker](https://docs.microsoft.com/en-us/aspnet/core/host-and-deploy/docker/)
- [React Production Deployment](https://create-react-app.dev/docs/deployment/)

---

**🐳 Congratulations! You've successfully containerized a full-stack React + ASP.NET Core application! 🎉**
