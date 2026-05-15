using Microsoft.AspNetCore.Mvc;
using System.ComponentModel.DataAnnotations;
using CardsProject.Services.Players;

namespace CardsProject.Controllers.Players;

[ApiController]
[Route("api/players")]
[Microsoft.AspNetCore.Authorization.AllowAnonymous]
public class PlayerController : ControllerBase
{
    private readonly PlayerService _svc;

    public PlayerController(PlayerService svc) => _svc = svc;

    [HttpGet]
    public async Task<IActionResult> List()
    {
        var items = await _svc.GetAllAsync();
        return Ok(items);
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] PlayerDto dto)
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
    public async Task<IActionResult> Update(int id, [FromBody] PlayerDto dto)
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

    [HttpPost("{id:int}/promote")]
    public async System.Threading.Tasks.Task<IActionResult> Promote(int id)
    {
        try
        {
            var result = await _svc.PromoteAsync(id);
            return Ok(result);
        }
        catch (KeyNotFoundException) { return NotFound(); }
    }

    [HttpPost("{id:int}/demote")]
    public async System.Threading.Tasks.Task<IActionResult> Demote(int id)
    {
        try
        {
            var result = await _svc.DemoteAsync(id);
            return Ok(result);
        }
        catch (KeyNotFoundException) { return NotFound(); }
    }

    [HttpPost("{id:int}/win")]
    public async System.Threading.Tasks.Task<IActionResult> RecordWin(int id)
    {
        try
        {
            await _svc.RecordWinAsync(id);
            return NoContent();
        }
        catch (KeyNotFoundException) { return NotFound(); }
    }

    [HttpPost("{id:int}/loss")]
    public async System.Threading.Tasks.Task<IActionResult> RecordLoss(int id)
    {
        try
        {
            await _svc.RecordLossAsync(id);
            return NoContent();
        }
        catch (KeyNotFoundException) { return NotFound(); }
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

    [HttpPost("{id:int}/verify")]
    public async System.Threading.Tasks.Task<IActionResult> Verify(int id)
    {
        try
        {
            await _svc.VerifyAsync(id);
            return NoContent();
        }
        catch (KeyNotFoundException) { return NotFound(); }
    }

    [HttpPatch("{id:int}/rating")]
    public async System.Threading.Tasks.Task<IActionResult> UpdateRating(int id, [FromBody] System.Collections.Generic.Dictionary<string, object> body)
    {
        try
        {
            var delta = (int)body["delta"];
            await _svc.UpdateRatingAsync(id, delta);
            return NoContent();
        }
        catch (KeyNotFoundException) { return NotFound(); }
    }
}
