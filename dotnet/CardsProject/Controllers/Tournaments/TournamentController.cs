using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using CardsProject.Infrastructure;
using CardsProject.Domain.Tournaments;

namespace CardsProject.Controllers.Tournaments;

[ApiController]
[Route("api/tournaments")]
public class TournamentController : ControllerBase
{
    private readonly AppDbContext _db;

    public TournamentController(AppDbContext db) => _db = db;

    [HttpGet]
    public async Task<IActionResult> List()
    {
        var items = await _db.Tournaments.AsNoTracking().ToListAsync();
        return Ok(items);
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] TournamentDto dto)
    {
        var entity = new Tournament();
        if (dto.Name is not null) entity.Name = dto.Name;
        if (dto.Description is not null) entity.Description = dto.Description;
        if (dto.Format is not null && Enum.TryParse<TournamentFormatType>(dto.Format, out var formatVal)) entity.Format = formatVal;
        if (dto.TournamentType is not null && Enum.TryParse<TournamentTournamentTypeType>(dto.TournamentType, out var tournamentTypeVal)) entity.TournamentType = tournamentTypeVal;
        if (dto.Status is not null && Enum.TryParse<TournamentStatusType>(dto.Status, out var statusVal)) entity.Status = statusVal;
        if (dto.MaxPlayers is not null) entity.MaxPlayers = dto.MaxPlayers.Value;
        if (dto.EntryFee is not null) entity.EntryFee = dto.EntryFee.Value;
        if (dto.PrizePool is not null) entity.PrizePool = dto.PrizePool.Value;
        if (dto.StartTime is not null) entity.StartTime = dto.StartTime.Value;
        if (dto.EndTime is not null) entity.EndTime = dto.EndTime.Value;
        if (dto.IsOnline is not null) entity.IsOnline = dto.IsOnline.Value;
        if (dto.Location is not null) entity.Location = dto.Location;
        if (dto.RulesText is not null) entity.RulesText = dto.RulesText;
        if (dto.CreatedAt is not null) entity.CreatedAt = dto.CreatedAt.Value;
        if (dto.SeasonId is not null) entity.SeasonId = dto.SeasonId;
        if (dto.OrganizerId is not null) entity.OrganizerId = dto.OrganizerId;
        if (dto.RegistrationsId is not null) entity.RegistrationsId = dto.RegistrationsId;
        if (dto.RoundsId is not null) entity.RoundsId = dto.RoundsId;
        if (dto.PrizesId is not null) entity.PrizesId = dto.PrizesId;
        _db.Tournaments.Add(entity);
        await _db.SaveChangesAsync();
        return CreatedAtAction(nameof(Show), new { id = entity.Id }, entity);
    }

    [HttpGet("{id:int}")]
    public async Task<IActionResult> Show(int id)
    {
        var entity = await _db.Tournaments.FindAsync(id);
        if (entity is null) return NotFound();
        return Ok(entity);
    }

    [HttpPut("{id:int}")]
    [HttpPatch("{id:int}")]
    public async Task<IActionResult> Update(int id, [FromBody] TournamentDto dto)
    {
        var entity = await _db.Tournaments.FindAsync(id);
        if (entity is null) return NotFound();
        if (dto.Name is not null) entity.Name = dto.Name;
        if (dto.Description is not null) entity.Description = dto.Description;
        if (dto.Format is not null && Enum.TryParse<TournamentFormatType>(dto.Format, out var formatVal)) entity.Format = formatVal;
        if (dto.TournamentType is not null && Enum.TryParse<TournamentTournamentTypeType>(dto.TournamentType, out var tournamentTypeVal)) entity.TournamentType = tournamentTypeVal;
        if (dto.Status is not null && Enum.TryParse<TournamentStatusType>(dto.Status, out var statusVal)) entity.Status = statusVal;
        if (dto.MaxPlayers is not null) entity.MaxPlayers = dto.MaxPlayers.Value;
        if (dto.EntryFee is not null) entity.EntryFee = dto.EntryFee.Value;
        if (dto.PrizePool is not null) entity.PrizePool = dto.PrizePool.Value;
        if (dto.StartTime is not null) entity.StartTime = dto.StartTime.Value;
        if (dto.EndTime is not null) entity.EndTime = dto.EndTime.Value;
        if (dto.IsOnline is not null) entity.IsOnline = dto.IsOnline.Value;
        if (dto.Location is not null) entity.Location = dto.Location;
        if (dto.RulesText is not null) entity.RulesText = dto.RulesText;
        if (dto.CreatedAt is not null) entity.CreatedAt = dto.CreatedAt.Value;
        if (dto.SeasonId is not null) entity.SeasonId = dto.SeasonId;
        if (dto.OrganizerId is not null) entity.OrganizerId = dto.OrganizerId;
        if (dto.RegistrationsId is not null) entity.RegistrationsId = dto.RegistrationsId;
        if (dto.RoundsId is not null) entity.RoundsId = dto.RoundsId;
        if (dto.PrizesId is not null) entity.PrizesId = dto.PrizesId;
        await _db.SaveChangesAsync();
        return Ok(entity);
    }

    [HttpDelete("{id:int}")]
    public async Task<IActionResult> Delete(int id)
    {
        var entity = await _db.Tournaments.FindAsync(id);
        if (entity is null) return NotFound();
        _db.Tournaments.Remove(entity);
        await _db.SaveChangesAsync();
        return NoContent();
    }
}
