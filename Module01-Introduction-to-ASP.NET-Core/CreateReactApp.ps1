param (
    [string]$backendName = "ReactAppBackend",
    [string]$frontendName = "reactappfrontend"
)

# Ensure frontend name is lowercase
$frontendName = $frontendName.ToLower()

# Create .NET Web API project
dotnet new webapi -n $backendName --framework net8.0
cd $backendName

# Trust development certificate
dotnet dev-certs https --trust

# Create Models folder and Todo model
New-Item -Path ".\Models" -ItemType Directory -Force
$todoModel = @"
namespace $backendName.Models
{
    public class Todo
    {
        public int Id { get; set; }
        public string TodoItem { get; set; }
        public string TodoState { get; set; }
    }
}
"@
$todoModel | Out-File -FilePath ".\Models\Todo.cs" -Encoding utf8

# Create Controllers folder and Todo controller
New-Item -Path ".\Controllers" -ItemType Directory -Force
$todoController = @"
using Microsoft.AspNetCore.Mvc;
using $backendName.Models;

namespace $backendName.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class TodoController : ControllerBase
    {
        private static readonly List<Todo> Todos = new()
        {
            new Todo { Id = 1, TodoItem = "Learn PowerShell", TodoState = "InProgress" },
            new Todo { Id = 2, TodoItem = "Build .NET API", TodoState = "Completed" }
        };

        [HttpGet]
        public IEnumerable<Todo> Get() => Todos;
    }
}
"@
$todoController | Out-File -FilePath ".\Controllers\TodoController.cs" -Encoding utf8

# Build and run the backend
dotnet build

Start-Process "dotnet" "run" -NoNewWindow
Start-Process "dotnet" "watch" "run" 

cd ..

# Create React frontend
npx create-react-app $frontendName
cd $frontendName

# Update App.js to fetch and display Todos
$appJsPath = ".\src\App.js"
$appJsContent = @"
import React, { useEffect, useState } from 'react';

function App() {
  const [todos, setTodos] = useState([]);

  useEffect(() => {
    fetch('https://localhost:5001/api/todo')
      .then(response => response.json())
      .then(data => setTodos(data));
  }, []);

  return (
    <div>
      <h1>Todo List</h1>
      <ul>
        {todos.map(todo => (
          <li key={todo.id}>
            <strong>{todo.todoItem}</strong> - {todo.todoState}
          </li>
        ))}
      </ul>
    </div>
  );
}

export default App;
"@
$appJsContent | Out-File -FilePath $appJsPath -Encoding utf8

# Install dependencies and run frontend
npm install

# Start frontend using cmd to avoid Win32 error
Start-Process "cmd.exe" "/c npm start" -WorkingDirectory "." -NoNewWindow

Write-Host "✅ Backend and frontend are now running."

