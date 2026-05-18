using Microsoft.AspNetCore.Mvc;
using System.ComponentModel.DataAnnotations;
using CardsProject.Services.Players;

namespace CardsProject.Controllers.Players;

[ApiController]
[Route("api/player_season_statses")]
[Microsoft.AspNetCore.Authorization.AllowAnonymous]
public class PlayerSeasonStatsController : ControllerBase
{
    private readonly PlayerSeasonStatsService _svc;

    public PlayerSeasonStatsController(PlayerSeasonStatsService svc) => _svc = svc;

    [HttpGet]
    public async Task<IActionResult> List()
    {
        var items = await _svc.GetAllAsync();
        return Ok(items);
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] PlayerSeasonStatsDto dto)
    {
        if (!ModelState.IsValid) return BadRequest(ModelState);
        try
        {
            var entity = await _svc.CreateAsync(dto);
            return CreatedAtAction(nameof(Show), new { id = entity.Id }, entity);
        }
        catch (ValidationException ex) { return BadRequest(new { error = ex.Message }); }
        catch (InvalidOperationException ex) { return BadRequest(new { error = ex.Message }); }
    }

    [HttpGet("{id:int}")]
    public async Task<IActionResult> Show(int id)
    {
        var entity = await _svc.GetByIdAsync(id);
        if (entity is null) return NotFound();
        return Ok(entity);
    }

    [HttpPut("{id:int}")]
    [HttpPatch("{id:int}")]
    public async Task<IActionResult> Update(int id, [FromBody] PlayerSeasonStatsDto dto)
    {
        try
        {
            var entity = await _svc.UpdateAsync(id, dto);
            if (entity is null) return NotFound();
            return Ok(entity);
        }
        catch (ValidationException ex) { return BadRequest(new { error = ex.Message }); }
        catch (InvalidOperationException ex) { return BadRequest(new { error = ex.Message }); }
    }

    [HttpDelete("{id:int}")]
    public async Task<IActionResult> Delete(int id)
    {
        var deleted = await _svc.DeleteAsync(id);
        if (!deleted) return NotFound();
        return NoContent();
    }

    [HttpGet("{id:int}/win-rate")]
    public async System.Threading.Tasks.Task<IActionResult> WinRate(int id)
    {
        try
        {
            var result = await _svc.WinRateAsync(id);
            return Ok(result);
        }
        catch (KeyNotFoundException) { return NotFound(); }
    }

    [HttpPatch("{id:int}/points")]
    public async System.Threading.Tasks.Task<IActionResult> AddPoints(int id, [FromBody] System.Collections.Generic.Dictionary<string, object> body)
    {
        try
        {
            var points = (int)body["points"];
            await _svc.AddPointsAsync(id, points);
            return NoContent();
        }
        catch (KeyNotFoundException) { return NotFound(); }
    }

    [HttpPost("{id:int}/tournament-win")]
    public async System.Threading.Tasks.Task<IActionResult> RecordTournamentWin(int id)
    {
        try
        {
            await _svc.RecordTournamentWinAsync(id);
            return NoContent();
        }
        catch (KeyNotFoundException) { return NotFound(); }
    }
}
