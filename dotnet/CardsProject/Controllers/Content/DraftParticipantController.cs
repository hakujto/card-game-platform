using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using CardsProject.Infrastructure;
using CardsProject.Domain.Content;
using CardsProject.Services.Content;

namespace CardsProject.Controllers.Content;

[ApiController]
[Route("api/draft_participants")]
[Microsoft.AspNetCore.Authorization.AllowAnonymous]
public class DraftParticipantController : ControllerBase
{
    private readonly AppDbContext _db;
    public DraftParticipantController(AppDbContext db) => _db = db;

    [HttpGet]
    public async Task<IActionResult> List()
    {
        var items = await _db.DraftParticipants.AsNoTracking().ToListAsync();
        return Ok(items);
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] DraftParticipantDto dto)
    {
        var entity = new DraftParticipant();
        if (dto.SeatNumber is not null) entity.SeatNumber = dto.SeatNumber.Value;
        if (dto.JoinedAt is not null) entity.JoinedAt = dto.JoinedAt.Value;
        if (dto.SessionId is not null) entity.SessionId = dto.SessionId;
        if (dto.PlayerId is not null) entity.PlayerId = dto.PlayerId;
        if (!TryValidateModel(entity)) return BadRequest(ModelState);
        _db.DraftParticipants.Add(entity);
        await _db.SaveChangesAsync();
        return CreatedAtAction(nameof(Show), new { id = entity.Id }, entity);
    }

    [HttpGet("{id:int}")]
    public async Task<IActionResult> Show(int id)
    {
        var entity = await _db.DraftParticipants.FindAsync(id);
        if (entity is null) return NotFound();
        return Ok(entity);
    }

    [HttpPut("{id:int}")]
    [HttpPatch("{id:int}")]
    public async Task<IActionResult> Update(int id, [FromBody] DraftParticipantDto dto)
    {
        var entity = await _db.DraftParticipants.FindAsync(id);
        if (entity is null) return NotFound();
        if (dto.SeatNumber is not null) entity.SeatNumber = dto.SeatNumber.Value;
        if (dto.JoinedAt is not null) entity.JoinedAt = dto.JoinedAt.Value;
        if (dto.SessionId is not null) entity.SessionId = dto.SessionId;
        if (dto.PlayerId is not null) entity.PlayerId = dto.PlayerId;
        if (!TryValidateModel(entity)) return BadRequest(ModelState);
        await _db.SaveChangesAsync();
        return Ok(entity);
    }

    [HttpDelete("{id:int}")]
    public async Task<IActionResult> Delete(int id)
    {
        var entity = await _db.DraftParticipants.FindAsync(id);
        if (entity is null) return NotFound();
        _db.DraftParticipants.Remove(entity);
        await _db.SaveChangesAsync();
        return NoContent();
    }

    [HttpPost("{id:int}/pick")]
    public async System.Threading.Tasks.Task<IActionResult> PickCard(int id, [FromBody] System.Collections.Generic.Dictionary<string, object> body)
    {
        var entity = await _db.DraftParticipants.FindAsync(id);
        if (entity is null) return NotFound();
        var cardId = (int)body["card_id"];
        var packNumber = (int)body["pack_number"];
        entity.PickCard(cardId, packNumber);
        await _db.SaveChangesAsync();
        return NoContent();
    }
}
