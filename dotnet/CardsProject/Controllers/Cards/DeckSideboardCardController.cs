using Microsoft.AspNetCore.Mvc;
using System.ComponentModel.DataAnnotations;
using CardsProject.Services.Cards;

namespace CardsProject.Controllers.Cards;

[ApiController]
[Route("api/deck_sideboard_cards")]
[Microsoft.AspNetCore.Authorization.AllowAnonymous]
public class DeckSideboardCardController : ControllerBase
{
    private readonly DeckSideboardCardService _svc;

    public DeckSideboardCardController(DeckSideboardCardService svc) => _svc = svc;

    [HttpGet]
    public async Task<IActionResult> List()
    {
        var items = await _svc.GetAllAsync();
        return Ok(items);
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] DeckSideboardCardDto dto)
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
    public async Task<IActionResult> Update(int id, [FromBody] DeckSideboardCardDto dto)
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

    [HttpPatch("{id:int}/increment")]
    public async System.Threading.Tasks.Task<IActionResult> Increment(int id, [FromBody] System.Collections.Generic.Dictionary<string, object> body)
    {
        try
        {
            var amount = (int)body["amount"];
            await _svc.IncrementAsync(id, amount);
            return NoContent();
        }
        catch (KeyNotFoundException) { return NotFound(); }
    }

    [HttpPatch("{id:int}/decrement")]
    public async System.Threading.Tasks.Task<IActionResult> Decrement(int id, [FromBody] System.Collections.Generic.Dictionary<string, object> body)
    {
        try
        {
            var amount = (int)body["amount"];
            await _svc.DecrementAsync(id, amount);
            return NoContent();
        }
        catch (KeyNotFoundException) { return NotFound(); }
    }
}
