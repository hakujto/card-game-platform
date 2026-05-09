using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using CardsProject.Infrastructure;
using CardsProject.Domain.Content;

namespace CardsProject.Controllers.Content;

[ApiController]
[Route("api/draft_sessions")]
public class DraftSessionController : ControllerBase
{
    private readonly AppDbContext _db;

    public DraftSessionController(AppDbContext db) => _db = db;

    [HttpGet]
    public async Task<IActionResult> List()
    {
        var items = await _db.DraftSessions.AsNoTracking().ToListAsync();
        return Ok(items);
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] DraftSessionDto dto)
    {
        var entity = new DraftSession();
        if (dto.Status is not null && Enum.TryParse<DraftSessionStatusType>(dto.Status, out var statusVal)) entity.Status = statusVal;
        if (dto.DraftType is not null && Enum.TryParse<DraftSessionDraftTypeType>(dto.DraftType, out var draftTypeVal)) entity.DraftType = draftTypeVal;
        if (dto.Seats is not null) entity.Seats = dto.Seats.Value;
        if (dto.CreatedAt is not null) entity.CreatedAt = dto.CreatedAt.Value;
        if (dto.CompletedAt is not null) entity.CompletedAt = dto.CompletedAt.Value;
        if (dto.CardSetId is not null) entity.CardSetId = dto.CardSetId;
        if (dto.ParticipantsId is not null) entity.ParticipantsId = dto.ParticipantsId;
        _db.DraftSessions.Add(entity);
        await _db.SaveChangesAsync();
        return CreatedAtAction(nameof(Show), new { id = entity.Id }, entity);
    }

    [HttpGet("{id:int}")]
    public async Task<IActionResult> Show(int id)
    {
        var entity = await _db.DraftSessions.FindAsync(id);
        if (entity is null) return NotFound();
        return Ok(entity);
    }

    [HttpPut("{id:int}")]
    [HttpPatch("{id:int}")]
    public async Task<IActionResult> Update(int id, [FromBody] DraftSessionDto dto)
    {
        var entity = await _db.DraftSessions.FindAsync(id);
        if (entity is null) return NotFound();
        if (dto.Status is not null && Enum.TryParse<DraftSessionStatusType>(dto.Status, out var statusVal)) entity.Status = statusVal;
        if (dto.DraftType is not null && Enum.TryParse<DraftSessionDraftTypeType>(dto.DraftType, out var draftTypeVal)) entity.DraftType = draftTypeVal;
        if (dto.Seats is not null) entity.Seats = dto.Seats.Value;
        if (dto.CreatedAt is not null) entity.CreatedAt = dto.CreatedAt.Value;
        if (dto.CompletedAt is not null) entity.CompletedAt = dto.CompletedAt.Value;
        if (dto.CardSetId is not null) entity.CardSetId = dto.CardSetId;
        if (dto.ParticipantsId is not null) entity.ParticipantsId = dto.ParticipantsId;
        await _db.SaveChangesAsync();
        return Ok(entity);
    }

    [HttpDelete("{id:int}")]
    public async Task<IActionResult> Delete(int id)
    {
        var entity = await _db.DraftSessions.FindAsync(id);
        if (entity is null) return NotFound();
        _db.DraftSessions.Remove(entity);
        await _db.SaveChangesAsync();
        return NoContent();
    }
}
