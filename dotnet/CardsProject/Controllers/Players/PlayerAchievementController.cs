using Microsoft.AspNetCore.Mvc;
using System.ComponentModel.DataAnnotations;
using CardsProject.Services.Players;

namespace CardsProject.Controllers.Players;

[ApiController]
[Route("api/player_achievements")]
[Microsoft.AspNetCore.Authorization.AllowAnonymous]
public class PlayerAchievementController : ControllerBase
{
    private readonly PlayerAchievementService _svc;

    public PlayerAchievementController(PlayerAchievementService svc) => _svc = svc;

    [HttpGet]
    public async Task<IActionResult> List()
    {
        var items = await _svc.GetAllAsync();
        return Ok(items);
    }

    [HttpGet("{id:int}")]
    public async Task<IActionResult> Show(int id)
    {
        var entity = await _svc.GetByIdAsync(id);
        if (entity is null) return NotFound();
        return Ok(entity);
    }

    [HttpPatch("{id:int}/progress")]
    public async System.Threading.Tasks.Task<IActionResult> IncrementProgress(int id, [FromBody] System.Collections.Generic.Dictionary<string, object> body)
    {
        try
        {
            var amount = (int)body["amount"];
            await _svc.IncrementProgressAsync(id, amount);
            return NoContent();
        }
        catch (ArgumentException ex) { return UnprocessableEntity(new { error = ex.Message }); }
        catch (KeyNotFoundException) { return NotFound(); }
    }

    [HttpPost("{id:int}/complete")]
    public async System.Threading.Tasks.Task<IActionResult> Complete(int id)
    {
        try
        {
            await _svc.CompleteAsync(id);
            return NoContent();
        }
        catch (ArgumentException ex) { return UnprocessableEntity(new { error = ex.Message }); }
        catch (KeyNotFoundException) { return NotFound(); }
    }
}
