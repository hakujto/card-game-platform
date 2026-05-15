using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using CardsProject.Infrastructure;
using CardsProject.Domain.Players;
using CardsProject.Services.Players;

namespace CardsProject.Controllers.Players;

[ApiController]
[Route("api/crafting_recipes")]
[Microsoft.AspNetCore.Authorization.AllowAnonymous]
public class CraftingRecipeController : ControllerBase
{
    private readonly AppDbContext _db;
    public CraftingRecipeController(AppDbContext db) => _db = db;

    [HttpGet]
    public async Task<IActionResult> List()
    {
        var items = await _db.CraftingRecipes.AsNoTracking().ToListAsync();
        return Ok(items);
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CraftingRecipeDto dto)
    {
        var entity = new CraftingRecipe();
        if (dto.DustCost is not null) entity.DustCost = dto.DustCost.Value;
        if (dto.IsAvailable is not null) entity.IsAvailable = dto.IsAvailable.Value;
        if (dto.ResultCardId is not null) entity.ResultCardId = dto.ResultCardId;
        if (!TryValidateModel(entity)) return BadRequest(ModelState);
        _db.CraftingRecipes.Add(entity);
        await _db.SaveChangesAsync();
        return CreatedAtAction(nameof(Show), new { id = entity.Id }, entity);
    }

    [HttpGet("{id:int}")]
    public async Task<IActionResult> Show(int id)
    {
        var entity = await _db.CraftingRecipes.FindAsync(id);
        if (entity is null) return NotFound();
        return Ok(entity);
    }

    [HttpPut("{id:int}")]
    [HttpPatch("{id:int}")]
    public async Task<IActionResult> Update(int id, [FromBody] CraftingRecipeDto dto)
    {
        var entity = await _db.CraftingRecipes.FindAsync(id);
        if (entity is null) return NotFound();
        if (dto.DustCost is not null) entity.DustCost = dto.DustCost.Value;
        if (dto.IsAvailable is not null) entity.IsAvailable = dto.IsAvailable.Value;
        if (dto.ResultCardId is not null) entity.ResultCardId = dto.ResultCardId;
        if (!TryValidateModel(entity)) return BadRequest(ModelState);
        await _db.SaveChangesAsync();
        return Ok(entity);
    }

    [HttpDelete("{id:int}")]
    public async Task<IActionResult> Delete(int id)
    {
        var entity = await _db.CraftingRecipes.FindAsync(id);
        if (entity is null) return NotFound();
        _db.CraftingRecipes.Remove(entity);
        await _db.SaveChangesAsync();
        return NoContent();
    }

}
