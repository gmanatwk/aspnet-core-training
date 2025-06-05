using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;

namespace BasicWebApp.Pages
{
    public class IndexModel : PageModel
    {
        public string UserName { get; set; } = "ASP.NET Core Developer";

        public void OnGet()
        {
            // This method runs when the page is requested
        }
    }
}
