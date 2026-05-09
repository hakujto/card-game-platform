using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using CardsProject.Infrastructure;
using CardsProject.Domain.Content;

namespace CardsProject.Controllers.Content;

[ApiController]
[Route("api/draft_picks")]
public class DraftPickController : ControllerBase
{
    private readonly AppDbContext _db;

    public DraftPickController(AppDbContext db) => _db = db;

    [HttpGet]
    public async Task<IActionResult> List()
    {
        var items = await _db.DraftPicks.AsNoTracking().ToListAsync();
        return Ok(items);
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] DraftPickDto dto)
    {
        var entity = new DraftPick();
        if (dto.PickNumber is not null) entity.PickNumber = dto.PickNumber.Value;
        if (dto.PackNumber is not null) entity.PackNumber = dto.PackNumber.Value;
        if (dto.PickedAt is not null) entity.PickedAt = dto.PickedAt.Value;
        if (dto.ParticipantId is not null) entity.ParticipantId = dto.ParticipantId;
        if (dto.CardId is not null) entity.CardId = dto.CardId;
        _db.DraftPicks.Add(entity);
        await _db.SaveChangesAsync();
        return CreatedAtAction(nameof(Show), new { id = entity.Id }, entity);
    }

    [HttpGet("{id:int}")]
    public async Task<IActionResult> Show(int id)
    {
        var entity = await _db.DraftPicks.FindAsync(id);
        if (entity is null) return NotFound();
        return Ok(entity);
    }

    [HttpPut("{id:int}")]
    [HttpPatch("{id:int}")]
    public async Task<IActionResult> Update(int id, [FromBody] DraftPickDto dto)
    {
        var entity = await _db.DraftPicks.FindAsync(id);
        if (entity is null) return NotFound();
        if (dto.PickNumber is not null) entity.PickNumber = dto.PickNumber.Value;
        if (dto.PackNumber is not null) entity.PackNumber = dto.PackNumber.Value;
        if (dto.PickedAt is not null) entity.PickedAt = dto.PickedAt.Value;
        if (dto.ParticipantId is not null) entity.ParticipantId = dto.ParticipantId;
        if (dto.CardId is not null) entity.CardId = dto.CardId;
        await _db.SaveChangesAsync();
        return Ok(entity);
    }

    [HttpDelete("{id:int}")]
    public async Task<IActionResult> Delete(int id)
    {
        var entity = await _db.DraftPicks.FindAsync(id);
        if (entity is null) return NotFound();
        _db.DraftPicks.Remove(entity);
        await _db.SaveChangesAsync();
        return NoContent();
    }
}
