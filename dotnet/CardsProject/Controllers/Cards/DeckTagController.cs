using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using CardsProject.Infrastructure;
using CardsProject.Domain.Cards;

namespace CardsProject.Controllers.Cards;

[ApiController]
[Route("api/deck_tags")]
public class DeckTagController : ControllerBase
{
    private readonly AppDbContext _db;

    public DeckTagController(AppDbContext db) => _db = db;

    [HttpGet]
    public async Task<IActionResult> List()
    {
        var items = await _db.DeckTags.AsNoTracking().ToListAsync();
        return Ok(items);
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] DeckTagDto dto)
    {
        var entity = new DeckTag();
        if (dto.Name is not null) entity.Name = dto.Name;
        if (dto.Color is not null) entity.Color = dto.Color;
        _db.DeckTags.Add(entity);
        await _db.SaveChangesAsync();
        return CreatedAtAction(nameof(Show), new { id = entity.Id }, entity);
    }

    [HttpGet("{id:int}")]
    public async Task<IActionResult> Show(int id)
    {
        var entity = await _db.DeckTags.FindAsync(id);
        if (entity is null) return NotFound();
        return Ok(entity);
    }

    [HttpPut("{id:int}")]
    [HttpPatch("{id:int}")]
    public async Task<IActionResult> Update(int id, [FromBody] DeckTagDto dto)
    {
        var entity = await _db.DeckTags.FindAsync(id);
        if (entity is null) return NotFound();
        if (dto.Name is not null) entity.Name = dto.Name;
        if (dto.Color is not null) entity.Color = dto.Color;
        await _db.SaveChangesAsync();
        return Ok(entity);
    }

    [HttpDelete("{id:int}")]
    public async Task<IActionResult> Delete(int id)
    {
        var entity = await _db.DeckTags.FindAsync(id);
        if (entity is null) return NotFound();
        _db.DeckTags.Remove(entity);
        await _db.SaveChangesAsync();
        return NoContent();
    }
}
