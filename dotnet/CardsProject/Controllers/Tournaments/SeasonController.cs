using Microsoft.AspNetCore.Mvc;
using System.ComponentModel.DataAnnotations;
using CardsProject.Services.Tournaments;

namespace CardsProject.Controllers.Tournaments;

[ApiController]
[Route("api/seasons")]
[Microsoft.AspNetCore.Authorization.AllowAnonymous]
public class SeasonController : ControllerBase
{
    private readonly SeasonService _svc;

    public SeasonController(SeasonService svc) => _svc = svc;

    [HttpGet]
    public async Task<IActionResult> List([FromQuery] string? q = null)
    {
        var items = await _svc.SearchAsync(q);
        return Ok(items);
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] SeasonDto dto)
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
        return Ok(entity);
    }

    [HttpPut("{id:int}")]
    [HttpPatch("{id:int}")]
    public async Task<IActionResult> Update(int id, [FromBody] SeasonDto dto)
    {
        var existing = await _svc.GetByIdAsync(id);
        if (existing is null) return NotFound();
        try
        {
            var entity = await _svc.UpdateAsync(id, dto);
            if (entity is null) return NotFound();
            return Ok(entity);
        }
        catch (ValidationException ex) { return BadRequest(new { error = ex.Message }); }
        catch (InvalidOperationException ex) { return BadRequest(new { error = ex.Message }); }
        catch (Microsoft.EntityFrameworkCore.DbUpdateException ex) { return BadRequest(new { error = ex.InnerException?.Message ?? ex.Message }); }
    }

    [Microsoft.AspNetCore.Authorization.Authorize(Roles = "admin")]
    [HttpPost("{id:int}/activate")]
    public async System.Threading.Tasks.Task<IActionResult> Activate(int id)
    {
        try
        {
            await _svc.ActivateAsync(id);
            return NoContent();
        }
        catch (ArgumentException ex) { return UnprocessableEntity(new { error = ex.Message }); }
        catch (KeyNotFoundException) { return NotFound(); }
    }

    [Microsoft.AspNetCore.Authorization.Authorize(Roles = "admin")]
    [HttpPost("{id:int}/deactivate")]
    public async System.Threading.Tasks.Task<IActionResult> Deactivate(int id)
    {
        try
        {
            await _svc.DeactivateAsync(id);
            return NoContent();
        }
        catch (ArgumentException ex) { return UnprocessableEntity(new { error = ex.Message }); }
        catch (KeyNotFoundException) { return NotFound(); }
    }

    [Microsoft.AspNetCore.Authorization.Authorize(Roles = "admin")]
    [HttpPost("{id:int}/finalize")]
    public async System.Threading.Tasks.Task<IActionResult> FinalizeRewards(int id)
    {
        try
        {
            await _svc.FinalizeRewardsAsync(id);
            return NoContent();
        }
        catch (ArgumentException ex) { return UnprocessableEntity(new { error = ex.Message }); }
        catch (KeyNotFoundException) { return NotFound(); }
    }

    [HttpGet("{id:int}/ongoing")]
    public async System.Threading.Tasks.Task<IActionResult> IsOngoing(int id)
    {
        try
        {
            var result = await _svc.IsOngoingAsync(id);
            return Ok(result);
        }
        catch (ArgumentException ex) { return UnprocessableEntity(new { error = ex.Message }); }
        catch (KeyNotFoundException) { return NotFound(); }
    }
}
