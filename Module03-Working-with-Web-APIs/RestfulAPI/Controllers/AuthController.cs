using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using RestfulAPI.Data;
using RestfulAPI.Models.Auth;
using RestfulAPI.Services;

namespace RestfulAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Produces("application/json")]
    public class AuthController : ControllerBase
    {
        private readonly UserManager<User> _userManager;
        private readonly SignInManager<User> _signInManager;
        private readonly IJwtService _jwtService;
        private readonly ApplicationDbContext _context;
        private readonly ILogger<AuthController> _logger;

        public AuthController(
            UserManager<User> userManager,
            SignInManager<User> signInManager,
            IJwtService jwtService,
            ApplicationDbContext context,
            ILogger<AuthController> logger)
        {
            _userManager = userManager;
            _signInManager = signInManager;
            _jwtService = jwtService;
            _context = context;
            _logger = logger;
        }

        /// <summary>
        /// Register a new user
        /// </summary>
        [HttpPost("register")]
        [ProducesResponseType(typeof(TokenResponse), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(ValidationProblemDetails), StatusCodes.Status400BadRequest)]
        public async Task<ActionResult<TokenResponse>> Register([FromBody] RegisterModel model)
        {
            _logger.LogInformation("New user registration attempt for {Email}", model.Email);

            var user = new User
            {
                UserName = model.Email,
                Email = model.Email,
                FirstName = model.FirstName,
                LastName = model.LastName,
                CreatedAt = DateTime.UtcNow
            };

            var result = await _userManager.CreateAsync(user, model.Password);

            if (!result.Succeeded)
            {
                _logger.LogWarning("Registration failed for {Email}: {Errors}", 
                    model.Email, string.Join(", ", result.Errors.Select(e => e.Description)));
                
                return BadRequest(new ValidationProblemDetails
                {
                    Errors = result.Errors.ToDictionary(
                        e => e.Code,
                        e => new[] { e.Description })
                });
            }

            // Assign default role
            await _userManager.AddToRoleAsync(user, "User");

            // Generate token
            var tokenResponse = await _jwtService.GenerateTokenAsync(user);

            // Save refresh token
            var refreshToken = new RefreshToken
            {
                Token = tokenResponse.RefreshToken,
                UserId = user.Id,
                Created = DateTime.UtcNow,
                Expires = DateTime.UtcNow.AddDays(7)
            };

            _context.RefreshTokens.Add(refreshToken);
            await _context.SaveChangesAsync();

            _logger.LogInformation("User {Email} registered successfully", model.Email);

            return Ok(tokenResponse);
        }

        /// <summary>
        /// Login with email and password
        /// </summary>
        [HttpPost("login")]
        [ProducesResponseType(typeof(TokenResponse), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        public async Task<ActionResult<TokenResponse>> Login([FromBody] LoginModel model)
        {
            _logger.LogInformation("Login attempt for {Email}", model.Email);

            var user = await _userManager.FindByEmailAsync(model.Email);
            if (user == null || !user.IsActive)
            {
                _logger.LogWarning("Login failed - user not found or inactive: {Email}", model.Email);
                return Unauthorized(new { message = "Invalid email or password" });
            }

            var result = await _signInManager.CheckPasswordSignInAsync(user, model.Password, false);
            if (!result.Succeeded)
            {
                _logger.LogWarning("Login failed - invalid password for: {Email}", model.Email);
                return Unauthorized(new { message = "Invalid email or password" });
            }

            // Update last login
            user.LastLoginAt = DateTime.UtcNow;
            await _userManager.UpdateAsync(user);

            // Generate token
            var tokenResponse = await _jwtService.GenerateTokenAsync(user);

            // Save refresh token
            var refreshToken = new RefreshToken
            {
                Token = tokenResponse.RefreshToken,
                UserId = user.Id,
                Created = DateTime.UtcNow,
                Expires = DateTime.UtcNow.AddDays(7)
            };

            _context.RefreshTokens.Add(refreshToken);
            await _context.SaveChangesAsync();

            _logger.LogInformation("User {Email} logged in successfully", model.Email);

            return Ok(tokenResponse);
        }

        /// <summary>
        /// Refresh access token
        /// </summary>
        [HttpPost("refresh")]
        [ProducesResponseType(typeof(TokenResponse), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        public async Task<ActionResult<TokenResponse>> Refresh([FromBody] RefreshTokenModel model)
        {
            var principal = _jwtService.ValidateToken(model.Token);
            if (principal == null)
            {
                return Unauthorized(new { message = "Invalid token" });
            }

            var userId = principal.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (string.IsNullOrEmpty(userId))
            {
                return Unauthorized(new { message = "Invalid token" });
            }

            // Validate refresh token
            var storedToken = await _context.RefreshTokens
                .Include(rt => rt.User)
                .FirstOrDefaultAsync(rt => 
                    rt.Token == model.RefreshToken && 
                    rt.UserId == userId &&
                    !rt.IsRevoked);

            if (storedToken == null || storedToken.Expires < DateTime.UtcNow)
            {
                return Unauthorized(new { message = "Invalid or expired refresh token" });
            }

            // Revoke old refresh token
            storedToken.IsRevoked = true;

            // Generate new tokens
            var tokenResponse = await _jwtService.GenerateTokenAsync(storedToken.User);

            // Save new refresh token
            var newRefreshToken = new RefreshToken
            {
                Token = tokenResponse.RefreshToken,
                UserId = userId,
                Created = DateTime.UtcNow,
                Expires = DateTime.UtcNow.AddDays(7)
            };

            _context.RefreshTokens.Add(newRefreshToken);
            await _context.SaveChangesAsync();

            return Ok(tokenResponse);
        }

        /// <summary>
        /// Get current user profile
        /// </summary>
        [HttpGet("profile")]
        [Authorize]
        [ProducesResponseType(typeof(UserInfo), StatusCodes.Status200OK)]
        public async Task<ActionResult<UserInfo>> GetProfile()
        {
            var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            var user = await _userManager.FindByIdAsync(userId!);
            
            if (user == null)
            {
                return NotFound();
            }

            var roles = await _userManager.GetRolesAsync(user);

            return Ok(new UserInfo
            {
                Id = user.Id,
                Email = user.Email!,
                FullName = $"{user.FirstName} {user.LastName}",
                Roles = roles.ToList()
            });
        }

        /// <summary>
        /// Change password
        /// </summary>
        [HttpPost("change-password")]
        [Authorize]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(ValidationProblemDetails), StatusCodes.Status400BadRequest)]
        public async Task<IActionResult> ChangePassword([FromBody] ChangePasswordModel model)
        {
            var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            var user = await _userManager.FindByIdAsync(userId!);

            if (user == null)
            {
                return NotFound();
            }

            var result = await _userManager.ChangePasswordAsync(user, model.CurrentPassword, model.NewPassword);

            if (!result.Succeeded)
            {
                return BadRequest(new ValidationProblemDetails
                {
                    Errors = result.Errors.ToDictionary(
                        e => e.Code,
                        e => new[] { e.Description })
                });
            }

            return Ok(new { message = "Password changed successfully" });
        }

        /// <summary>
        /// Logout (revoke refresh tokens)
        /// </summary>
        [HttpPost("logout")]
        [Authorize]
        [ProducesResponseType(StatusCodes.Status200OK)]
        public async Task<IActionResult> Logout()
        {
            var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            
            // Revoke all user's refresh tokens
            var tokens = await _context.RefreshTokens
                .Where(rt => rt.UserId == userId && !rt.IsRevoked)
                .ToListAsync();

            foreach (var token in tokens)
            {
                token.IsRevoked = true;
            }

            await _context.SaveChangesAsync();

            return Ok(new { message = "Logged out successfully" });
        }
    }
}