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