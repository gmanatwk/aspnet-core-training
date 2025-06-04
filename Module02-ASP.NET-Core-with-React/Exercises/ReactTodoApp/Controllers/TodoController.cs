using Microsoft.AspNetCore.Mvc;
using ReactTodoApp.Models;

namespace ReactTodoApp.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class TodoController : ControllerBase
    {
        private static readonly List<Todo> _todos = new()
        {
            new Todo { Id = 1, Title = "Learn React", IsCompleted = false, CreatedAt = DateTime.Now },
            new Todo { Id = 2, Title = "Build API", IsCompleted = true, CreatedAt = DateTime.Now }
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
            if (todo == null)
                return NotFound();

            return Ok(todo);
        }

        [HttpPost]
        public ActionResult<Todo> CreateTodo(Todo todo)
        {
            todo.Id = _todos.Count > 0 ? _todos.Max(t => t.Id) + 1 : 1;
            todo.CreatedAt = DateTime.Now;
            _todos.Add(todo);

            return CreatedAtAction(nameof(GetTodo), new { id = todo.Id }, todo);
        }

        [HttpPut("{id}")]
        public ActionResult UpdateTodo(int id, Todo todo)
        {
            var existingTodo = _todos.FirstOrDefault(t => t.Id == id);
            if (existingTodo == null)
                return NotFound();

            existingTodo.Title = todo.Title;
            existingTodo.IsCompleted = todo.IsCompleted;

            return NoContent();
        }

        [HttpDelete("{id}")]
        public ActionResult DeleteTodo(int id)
        {
            var todo = _todos.FirstOrDefault(t => t.Id == id);
            if (todo == null)
                return NotFound();

            _todos.Remove(todo);
            return NoContent();
        }

        [HttpGet("stats")]
        public ActionResult<TodoStatsDto> GetStats()
        {
            var stats = new TodoStatsDto
            {
                Total = _todos.Count,
                Completed = _todos.Count(t => t.IsCompleted),
                Active = _todos.Count(t => !t.IsCompleted)
            };

            return Ok(stats);
        }

        [HttpPost("bulk-delete")]
        public ActionResult BulkDelete([FromBody] BulkOperationDto dto)
        {
            _todos.RemoveAll(t => dto.Ids.Contains(t.Id));
            return NoContent();
        }

        [HttpPost("bulk-complete")]
        public ActionResult BulkComplete([FromBody] BulkOperationDto dto)
        {
            foreach (var todo in _todos.Where(t => dto.Ids.Contains(t.Id)))
            {
                todo.IsCompleted = true;
            }

            return NoContent();
        }

        // DTOs
        public class TodoStatsDto
        {
            public int Total { get; set; }
            public int Completed { get; set; }
            public int Active { get; set; }
        }

        public class BulkOperationDto
        {
            public List<int> Ids { get; set; } = new();
        }
    }
}