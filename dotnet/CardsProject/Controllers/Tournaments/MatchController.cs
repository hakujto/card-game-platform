using Microsoft.AspNetCore.Mvc;
using System.ComponentModel.DataAnnotations;
using CardsProject.Services.Tournaments;

namespace CardsProject.Controllers.Tournaments;

[ApiController]
[Route("api/matches")]
[Microsoft.AspNetCore.Authorization.AllowAnonymous]
public class MatchController : ControllerBase
{
    private readonly MatchService _svc;

    public MatchController(MatchService svc) => _svc = svc;

    [HttpGet]
    public async Task<IActionResult> List()
    {
        var items = await _svc.GetAllAsync();
        return Ok(items);
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] MatchDto dto)
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
    public async Task<IActionResult> Update(int id, [FromBody] MatchDto dto)
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

    [HttpPost("{id:int}/record")]
    public async System.Threading.Tasks.Task<IActionResult> RecordResult(int id, [FromBody] System.Collections.Generic.Dictionary<string, object> body)
    {
        try
        {
            var p1Wins = (int)body["p1_wins"];
            var p2Wins = (int)body["p2_wins"];
            await _svc.RecordResultAsync(id, p1Wins, p2Wins);
            return NoContent();
        }
        catch (KeyNotFoundException) { return NotFound(); }
    }

    [HttpGet("{id:int}/winner")]
    public async System.Threading.Tasks.Task<IActionResult> DetermineWinner(int id)
    {
        try
        {
            var result = await _svc.DetermineWinnerAsync(id);
            return Ok(result);
        }
        catch (KeyNotFoundException) { return NotFound(); }
    }

    [HttpPost("{id:int}/concede")]
    public async System.Threading.Tasks.Task<IActionResult> Concede(int id, [FromBody] System.Collections.Generic.Dictionary<string, object> body)
    {
        try
        {
            var playerId = (int)body["player_id"];
            await _svc.ConcedeAsync(id, playerId);
            return NoContent();
        }
        catch (KeyNotFoundException) { return NotFound(); }
    }

    [HttpPost("{id:int}/draw")]
    public async System.Threading.Tasks.Task<IActionResult> Draw(int id)
    {
        try
        {
            await _svc.DrawAsync(id);
            return NoContent();
        }
        catch (KeyNotFoundException) { return NotFound(); }
    }
}
