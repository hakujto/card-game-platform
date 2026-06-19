using Microsoft.AspNetCore.Mvc;
using System.ComponentModel.DataAnnotations;
using CardsProject.Services.Cards;

namespace CardsProject.Controllers.Cards;

[ApiController]
[Route("api/card_rulings")]
[Microsoft.AspNetCore.Authorization.AllowAnonymous]
public class CardRulingController : ControllerBase
{
    private readonly CardRulingService _svc;

    public CardRulingController(CardRulingService svc) => _svc = svc;

    [HttpGet]
    public async Task<IActionResult> List()
    {
        var items = await _svc.GetAllAsync();
        return Ok(items);
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CardRulingDto dto)
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

    [HttpDelete("{id:int}")]
    public async Task<IActionResult> Delete(int id)
    {
        var entity = await _svc.GetByIdAsync(id);
        if (entity is null) return NotFound();
        var deleted = await _svc.DeleteAsync(id);
        if (!deleted) return NotFound();
        return NoContent();
    }

    [HttpGet("{id:int}/current")]
    public async System.Threading.Tasks.Task<IActionResult> IsCurrent(int id)
    {
        try
        {
            var result = await _svc.IsCurrentAsync(id);
            return Ok(result);
        }
        catch (ArgumentException ex) { return UnprocessableEntity(new { error = ex.Message }); }
        catch (KeyNotFoundException) { return NotFound(); }
    }

    [HttpGet("{id:int}/supersedes")]
    public async System.Threading.Tasks.Task<IActionResult> SupersedesPrevious(int id)
    {
        try
        {
            var result = await _svc.SupersedesPreviousAsync(id);
            return Ok(result);
        }
        catch (ArgumentException ex) { return UnprocessableEntity(new { error = ex.Message }); }
        catch (KeyNotFoundException) { return NotFound(); }
    }
}
