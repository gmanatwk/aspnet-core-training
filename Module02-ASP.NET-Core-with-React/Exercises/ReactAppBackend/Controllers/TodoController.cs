using Microsoft.AspNetCore.Mvc;
using ReactAppBackend.Models;

namespace ReactAppBackend.Controllers
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
