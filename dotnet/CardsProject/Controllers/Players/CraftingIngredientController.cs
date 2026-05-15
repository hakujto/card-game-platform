using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using CardsProject.Infrastructure;
using CardsProject.Domain.Players;
using CardsProject.Services.Players;

namespace CardsProject.Controllers.Players;

[ApiController]
[Route("api/crafting_ingredients")]
[Microsoft.AspNetCore.Authorization.AllowAnonymous]
public class CraftingIngredientController : ControllerBase
{
    private readonly AppDbContext _db;
    public CraftingIngredientController(AppDbContext db) => _db = db;

    [HttpGet]
    public async Task<IActionResult> List()
    {
        var items = await _db.CraftingIngredients.AsNoTracking().ToListAsync();
        return Ok(items);
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CraftingIngredientDto dto)
    {
        var entity = new CraftingIngredient();
        if (dto.Quantity is not null) entity.Quantity = dto.Quantity.Value;
        if (dto.RecipeId is not null) entity.RecipeId = dto.RecipeId;
        if (dto.CardId is not null) entity.CardId = dto.CardId;
        if (!TryValidateModel(entity)) return BadRequest(ModelState);
        _db.CraftingIngredients.Add(entity);
        await _db.SaveChangesAsync();
        return CreatedAtAction(nameof(Show), new { id = entity.Id }, entity);
    }

    [HttpGet("{id:int}")]
    public async Task<IActionResult> Show(int id)
    {
        var entity = await _db.CraftingIngredients.FindAsync(id);
        if (entity is null) return NotFound();
        return Ok(entity);
    }

    [HttpPut("{id:int}")]
    [HttpPatch("{id:int}")]
    public async Task<IActionResult> Update(int id, [FromBody] CraftingIngredientDto dto)
    {
        var entity = await _db.CraftingIngredients.FindAsync(id);
        if (entity is null) return NotFound();
        if (dto.Quantity is not null) entity.Quantity = dto.Quantity.Value;
        if (dto.RecipeId is not null) entity.RecipeId = dto.RecipeId;
        if (dto.CardId is not null) entity.CardId = dto.CardId;
        if (!TryValidateModel(entity)) return BadRequest(ModelState);
        await _db.SaveChangesAsync();
        return Ok(entity);
    }

    [HttpDelete("{id:int}")]
    public async Task<IActionResult> Delete(int id)
    {
        var entity = await _db.CraftingIngredients.FindAsync(id);
        if (entity is null) return NotFound();
        _db.CraftingIngredients.Remove(entity);
        await _db.SaveChangesAsync();
        return NoContent();
    }

}
