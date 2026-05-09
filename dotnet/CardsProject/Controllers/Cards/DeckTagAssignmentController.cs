using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using CardsProject.Infrastructure;
using CardsProject.Domain.Cards;

namespace CardsProject.Controllers.Cards;

[ApiController]
[Route("api/deck_tag_assignments")]
public class DeckTagAssignmentController : ControllerBase
{
    private readonly AppDbContext _db;

    public DeckTagAssignmentController(AppDbContext db) => _db = db;

    [HttpGet]
    public async Task<IActionResult> List()
    {
        var items = await _db.DeckTagAssignments.AsNoTracking().ToListAsync();
        return Ok(items);
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] DeckTagAssignmentDto dto)
    {
        var entity = new DeckTagAssignment();
        if (dto.DeckId is not null) entity.DeckId = dto.DeckId;
        if (dto.TagId is not null) entity.TagId = dto.TagId;
        _db.DeckTagAssignments.Add(entity);
        await _db.SaveChangesAsync();
        return CreatedAtAction(nameof(Show), new { id = entity.Id }, entity);
    }

    [HttpGet("{id:int}")]
    public async Task<IActionResult> Show(int id)
    {
        var entity = await _db.DeckTagAssignments.FindAsync(id);
        if (entity is null) return NotFound();
        return Ok(entity);
    }

    [HttpPut("{id:int}")]
    [HttpPatch("{id:int}")]
    public async Task<IActionResult> Update(int id, [FromBody] DeckTagAssignmentDto dto)
    {
        var entity = await _db.DeckTagAssignments.FindAsync(id);
        if (entity is null) return NotFound();
        if (dto.DeckId is not null) entity.DeckId = dto.DeckId;
        if (dto.TagId is not null) entity.TagId = dto.TagId;
        await _db.SaveChangesAsync();
        return Ok(entity);
    }

    [HttpDelete("{id:int}")]
    public async Task<IActionResult> Delete(int id)
    {
        var entity = await _db.DeckTagAssignments.FindAsync(id);
        if (entity is null) return NotFound();
        _db.DeckTagAssignments.Remove(entity);
        await _db.SaveChangesAsync();
        return NoContent();
    }
}
