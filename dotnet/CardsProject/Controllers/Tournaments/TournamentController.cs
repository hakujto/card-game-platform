using Microsoft.AspNetCore.Mvc;
using System.ComponentModel.DataAnnotations;
using CardsProject.Services.Tournaments;

namespace CardsProject.Controllers.Tournaments;

[ApiController]
[Route("api/tournaments")]
[Microsoft.AspNetCore.Authorization.AllowAnonymous]
public class TournamentController : ControllerBase
{
    private readonly TournamentService _svc;

    public TournamentController(TournamentService svc) => _svc = svc;

    [HttpGet]
    public async Task<IActionResult> List()
    {
        var items = await _svc.GetAllAsync();
        return Ok(items);
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] TournamentDto dto)
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
    public async Task<IActionResult> Update(int id, [FromBody] TournamentDto dto)
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

    [HttpPost("{id:int}/start")]
    public async System.Threading.Tasks.Task<IActionResult> Start(int id)
    {
        try
        {
            await _svc.StartAsync(id);
            return NoContent();
        }
        catch (KeyNotFoundException) { return NotFound(); }
    }

    [HttpPost("{id:int}/cancel")]
    public async System.Threading.Tasks.Task<IActionResult> Cancel(int id)
    {
        try
        {
            await _svc.CancelAsync(id);
            return NoContent();
        }
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
        catch (KeyNotFoundException) { return NotFound(); }
    }

    [HttpPost("{id:int}/rounds")]
    public async System.Threading.Tasks.Task<IActionResult> GenerateRound(int id)
    {
        try
        {
            await _svc.GenerateRoundAsync(id);
            return NoContent();
        }
        catch (KeyNotFoundException) { return NotFound(); }
    }

    [HttpGet("{id:int}/prizes")]
    public async System.Threading.Tasks.Task<IActionResult> CalculatePrizeDistribution(int id)
    {
        try
        {
            var result = await _svc.CalculatePrizeDistributionAsync(id);
            return Ok(result);
        }
        catch (KeyNotFoundException) { return NotFound(); }
    }

    [HttpPost("{id:int}/register")]
    public async System.Threading.Tasks.Task<IActionResult> RegisterPlayer(int id, [FromBody] System.Collections.Generic.Dictionary<string, object> body)
    {
        try
        {
            var playerId = (int)body["player_id"];
            var deckId = (int)body["deck_id"];
            await _svc.RegisterPlayerAsync(id, playerId, deckId);
            return NoContent();
        }
        catch (KeyNotFoundException) { return NotFound(); }
    }

    [HttpGet("{id:int}/full")]
    public async System.Threading.Tasks.Task<IActionResult> IsFull(int id)
    {
        try
        {
            var result = await _svc.IsFullAsync(id);
            return Ok(result);
        }
        catch (KeyNotFoundException) { return NotFound(); }
    }
}
