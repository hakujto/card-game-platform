using Microsoft.AspNetCore.Mvc;
using System.ComponentModel.DataAnnotations;
using CardsProject.Services.Tournaments;

namespace CardsProject.Controllers.Tournaments;

[ApiController]
[Route("api/tournament_registrations")]
[Microsoft.AspNetCore.Authorization.AllowAnonymous]
public class TournamentRegistrationController : ControllerBase
{
    private readonly TournamentRegistrationService _svc;

    public TournamentRegistrationController(TournamentRegistrationService svc) => _svc = svc;

    [HttpGet]
    public async Task<IActionResult> List()
    {
        var items = await _svc.GetAllAsync();
        return Ok(items);
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] TournamentRegistrationDto dto)
    {
        if (!ModelState.IsValid) return BadRequest(ModelState);
        try
        {
            var entity = await _svc.CreateAsync(dto);
            return CreatedAtAction(nameof(Show), new { id = entity.Id }, entity);
        }
        catch (ValidationException ex) { return BadRequest(new { error = ex.Message }); }
        catch (InvalidOperationException ex) { return BadRequest(new { error = ex.Message }); }
        catch (Microsoft.EntityFrameworkCore.DbUpdateException ex) { return BadRequest(new { error = ex.InnerException?.Message ?? ex.Message }); }
    }

    [HttpGet("{id:int}")]
    public async Task<IActionResult> Show(int id)
    {
        var entity = await _svc.GetByIdAsync(id);
        if (entity is null) return NotFound();
        var userId = User.Claims.FirstOrDefault(c => c.Type == System.Security.Claims.ClaimTypes.NameIdentifier)?.Value
            ?? HttpContext.Request.Headers["X-User-Id"].FirstOrDefault();
        if (entity.PlayerId.ToString() != userId)
            return StatusCode(403, new { error = "You do not own this resource." });
        return Ok(entity);
    }

    [HttpPost("{id:int}/withdraw")]
    public async System.Threading.Tasks.Task<IActionResult> Withdraw(int id)
    {
        try
        {
            await _svc.WithdrawAsync(id);
            return NoContent();
        }
        catch (ArgumentException ex) { return UnprocessableEntity(new { error = ex.Message }); }
        catch (KeyNotFoundException) { return NotFound(); }
    }

    [HttpPost("{id:int}/disqualify")]
    public async System.Threading.Tasks.Task<IActionResult> Disqualify(int id, [FromBody] System.Collections.Generic.Dictionary<string, object> body)
    {
        try
        {
            var reason = (string)body["reason"];
            await _svc.DisqualifyAsync(id, reason);
            return NoContent();
        }
        catch (ArgumentException ex) { return UnprocessableEntity(new { error = ex.Message }); }
        catch (KeyNotFoundException) { return NotFound(); }
    }

    [HttpPost("{id:int}/promote")]
    public async System.Threading.Tasks.Task<IActionResult> PromoteFromWaitlist(int id)
    {
        try
        {
            await _svc.PromoteFromWaitlistAsync(id);
            return NoContent();
        }
        catch (ArgumentException ex) { return UnprocessableEntity(new { error = ex.Message }); }
        catch (KeyNotFoundException) { return NotFound(); }
    }
}
