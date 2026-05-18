using Microsoft.AspNetCore.Mvc;
using System.ComponentModel.DataAnnotations;
using CardsProject.Services.Players;

namespace CardsProject.Controllers.Players;

[ApiController]
[Route("api/crafting_recipes")]
[Microsoft.AspNetCore.Authorization.AllowAnonymous]
public class CraftingRecipeController : ControllerBase
{
    private readonly CraftingRecipeService _svc;

    public CraftingRecipeController(CraftingRecipeService svc) => _svc = svc;

    [HttpGet]
    public async Task<IActionResult> List()
    {
        var items = await _svc.GetAllAsync();
        return Ok(items);
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CraftingRecipeDto dto)
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
    public async Task<IActionResult> Update(int id, [FromBody] CraftingRecipeDto dto)
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

    [HttpGet("{id:int}/can-craft")]
    public async System.Threading.Tasks.Task<IActionResult> CanCraft(int id, [FromQuery] int playerId)
    {
        try
        {
            var result = await _svc.CanCraftAsync(id, playerId);
            return Ok(result);
        }
        catch (KeyNotFoundException) { return NotFound(); }
    }

    [HttpPost("{id:int}/craft")]
    public async System.Threading.Tasks.Task<IActionResult> ExecuteCraft(int id, [FromBody] System.Collections.Generic.Dictionary<string, object> body)
    {
        try
        {
            var playerId = (int)body["player_id"];
            await _svc.ExecuteCraftAsync(id, playerId);
            return NoContent();
        }
        catch (KeyNotFoundException) { return NotFound(); }
    }

    [HttpPost("{id:int}/disable")]
    public async System.Threading.Tasks.Task<IActionResult> Disable(int id)
    {
        try
        {
            await _svc.DisableAsync(id);
            return NoContent();
        }
        catch (KeyNotFoundException) { return NotFound(); }
    }

    [HttpPost("{id:int}/enable")]
    public async System.Threading.Tasks.Task<IActionResult> Enable(int id)
    {
        try
        {
            await _svc.EnableAsync(id);
            return NoContent();
        }
        catch (KeyNotFoundException) { return NotFound(); }
    }
}
