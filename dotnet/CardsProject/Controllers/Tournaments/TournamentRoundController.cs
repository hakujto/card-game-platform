using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using CardsProject.Infrastructure;
using CardsProject.Domain.Tournaments;

namespace CardsProject.Controllers.Tournaments;

[ApiController]
[Route("api/tournament_rounds")]
public class TournamentRoundController : ControllerBase
{
    private readonly AppDbContext _db;

    public TournamentRoundController(AppDbContext db) => _db = db;

    [HttpGet]
    public async Task<IActionResult> List()
    {
        var items = await _db.TournamentRounds.AsNoTracking().ToListAsync();
        return Ok(items);
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] TournamentRoundDto dto)
    {
        var entity = new TournamentRound();
        if (dto.RoundNumber is not null) entity.RoundNumber = dto.RoundNumber.Value;
        if (dto.Status is not null && Enum.TryParse<TournamentRoundStatusType>(dto.Status, out var statusVal)) entity.Status = statusVal;
        if (dto.StartedAt is not null) entity.StartedAt = dto.StartedAt.Value;
        if (dto.EndedAt is not null) entity.EndedAt = dto.EndedAt.Value;
        if (dto.TimeLimitMinutes is not null) entity.TimeLimitMinutes = dto.TimeLimitMinutes.Value;
        if (dto.TournamentId is not null) entity.TournamentId = dto.TournamentId;
        if (dto.MatchesId is not null) entity.MatchesId = dto.MatchesId;
        _db.TournamentRounds.Add(entity);
        await _db.SaveChangesAsync();
        return CreatedAtAction(nameof(Show), new { id = entity.Id }, entity);
    }

    [HttpGet("{id:int}")]
    public async Task<IActionResult> Show(int id)
    {
        var entity = await _db.TournamentRounds.FindAsync(id);
        if (entity is null) return NotFound();
        return Ok(entity);
    }

    [HttpPut("{id:int}")]
    [HttpPatch("{id:int}")]
    public async Task<IActionResult> Update(int id, [FromBody] TournamentRoundDto dto)
    {
        var entity = await _db.TournamentRounds.FindAsync(id);
        if (entity is null) return NotFound();
        if (dto.RoundNumber is not null) entity.RoundNumber = dto.RoundNumber.Value;
        if (dto.Status is not null && Enum.TryParse<TournamentRoundStatusType>(dto.Status, out var statusVal)) entity.Status = statusVal;
        if (dto.StartedAt is not null) entity.StartedAt = dto.StartedAt.Value;
        if (dto.EndedAt is not null) entity.EndedAt = dto.EndedAt.Value;
        if (dto.TimeLimitMinutes is not null) entity.TimeLimitMinutes = dto.TimeLimitMinutes.Value;
        if (dto.TournamentId is not null) entity.TournamentId = dto.TournamentId;
        if (dto.MatchesId is not null) entity.MatchesId = dto.MatchesId;
        await _db.SaveChangesAsync();
        return Ok(entity);
    }

    [HttpDelete("{id:int}")]
    public async Task<IActionResult> Delete(int id)
    {
        var entity = await _db.TournamentRounds.FindAsync(id);
        if (entity is null) return NotFound();
        _db.TournamentRounds.Remove(entity);
        await _db.SaveChangesAsync();
        return NoContent();
    }
}
