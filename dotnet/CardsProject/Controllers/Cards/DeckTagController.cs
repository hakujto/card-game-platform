using Microsoft.AspNetCore.Mvc;
using System.ComponentModel.DataAnnotations;
using CardsProject.Services.Cards;

namespace CardsProject.Controllers.Cards;

[ApiController]
[Route("api/deck_tags")]
[Microsoft.AspNetCore.Authorization.AllowAnonymous]
public class DeckTagController : ControllerBase
{
    private readonly DeckTagService _svc;

    public DeckTagController(DeckTagService svc) => _svc = svc;

    [HttpGet]
    public async Task<IActionResult> List([FromQuery] string? q = null)
    {
        var items = await _svc.SearchAsync(q);
        return Ok(items);
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] DeckTagDto dto)
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

    [HttpPatch("{id:int}")]
    public async Task<IActionResult> Update(int id, [FromBody] DeckTagDto dto)
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

    [HttpDelete("{id:int}")]
    public async Task<IActionResult> Delete(int id)
    {
        var entity = await _svc.GetByIdAsync(id);
        if (entity is null) return NotFound();
        var deleted = await _svc.DeleteAsync(id);
        if (!deleted) return NotFound();
        return NoContent();
    }

    [HttpPatch("{id:int}/rename")]
    public async System.Threading.Tasks.Task<IActionResult> Rename(int id, [FromBody] System.Collections.Generic.Dictionary<string, object> body)
    {
        try
        {
            var newName = (string)body["new_name"];
            await _svc.RenameAsync(id, newName);
            return NoContent();
        }
        catch (ArgumentException ex) { return UnprocessableEntity(new { error = ex.Message }); }
        catch (KeyNotFoundException) { return NotFound(); }
    }

    [HttpPost("{id:int}/merge")]
    public async System.Threading.Tasks.Task<IActionResult> MergeInto(int id, [FromBody] System.Collections.Generic.Dictionary<string, object> body)
    {
        try
        {
            var targetTagId = (int)body["target_tag_id"];
            await _svc.MergeIntoAsync(id, targetTagId);
            return NoContent();
        }
        catch (ArgumentException ex) { return UnprocessableEntity(new { error = ex.Message }); }
        catch (KeyNotFoundException) { return NotFound(); }
    }
}
