using Microsoft.AspNetCore.Mvc;
using System.ComponentModel.DataAnnotations;
using CardsProject.Services.Tournaments;

namespace CardsProject.Controllers.Tournaments;

[ApiController]
[Route("api/awarded_prizes")]
[Microsoft.AspNetCore.Authorization.AllowAnonymous]
public class AwardedPrizeController : ControllerBase
{
    private readonly AwardedPrizeService _svc;

    public AwardedPrizeController(AwardedPrizeService svc) => _svc = svc;

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

    [HttpPost("{id:int}/claim")]
    public async System.Threading.Tasks.Task<IActionResult> Claim(int id)
    {
        try
        {
            await _svc.ClaimAsync(id);
            return NoContent();
        }
        catch (ArgumentException ex) { return UnprocessableEntity(new { error = ex.Message }); }
        catch (KeyNotFoundException) { return NotFound(); }
    }
}
