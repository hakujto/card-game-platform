using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using CardsProject.Infrastructure;
using CardsProject.Domain.Players;
using CardsProject.Services.Players;

namespace CardsProject.Controllers.Players;

[ApiController]
[Route("api/player_season_statses")]
[Microsoft.AspNetCore.Authorization.AllowAnonymous]
public class PlayerSeasonStatsController : ControllerBase
{
    private readonly AppDbContext _db;
    public PlayerSeasonStatsController(AppDbContext db) => _db = db;

    [HttpGet]
    public async Task<IActionResult> List()
    {
        var items = await _db.PlayerSeasonStatses.AsNoTracking().ToListAsync();
        return Ok(items);
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] PlayerSeasonStatsDto dto)
    {
        var entity = new PlayerSeasonStats();
        if (dto.Wins is not null) entity.Wins = dto.Wins.Value;
        if (dto.Losses is not null) entity.Losses = dto.Losses.Value;
        if (dto.Draws is not null) entity.Draws = dto.Draws.Value;
        if (dto.TournamentWins is not null) entity.TournamentWins = dto.TournamentWins.Value;
        if (dto.HighestRank is not null && Enum.TryParse<PlayerSeasonStatsHighestRankType>(dto.HighestRank, out var highestRankVal)) entity.HighestRank = highestRankVal;
        if (dto.SeasonPoints is not null) entity.SeasonPoints = dto.SeasonPoints.Value;
        if (dto.PlayerId is not null) entity.PlayerId = dto.PlayerId;
        if (dto.SeasonId is not null) entity.SeasonId = dto.SeasonId;
        if (!TryValidateModel(entity)) return BadRequest(ModelState);
        _db.PlayerSeasonStatses.Add(entity);
        await _db.SaveChangesAsync();
        return CreatedAtAction(nameof(Show), new { id = entity.Id }, entity);
    }

    [HttpGet("{id:int}")]
    public async Task<IActionResult> Show(int id)
    {
        var entity = await _db.PlayerSeasonStatses.FindAsync(id);
        if (entity is null) return NotFound();
        return Ok(entity);
    }

    [HttpPut("{id:int}")]
    [HttpPatch("{id:int}")]
    public async Task<IActionResult> Update(int id, [FromBody] PlayerSeasonStatsDto dto)
    {
        var entity = await _db.PlayerSeasonStatses.FindAsync(id);
        if (entity is null) return NotFound();
        if (dto.Wins is not null) entity.Wins = dto.Wins.Value;
        if (dto.Losses is not null) entity.Losses = dto.Losses.Value;
        if (dto.Draws is not null) entity.Draws = dto.Draws.Value;
        if (dto.TournamentWins is not null) entity.TournamentWins = dto.TournamentWins.Value;
        if (dto.HighestRank is not null && Enum.TryParse<PlayerSeasonStatsHighestRankType>(dto.HighestRank, out var highestRankVal)) entity.HighestRank = highestRankVal;
        if (dto.SeasonPoints is not null) entity.SeasonPoints = dto.SeasonPoints.Value;
        if (dto.PlayerId is not null) entity.PlayerId = dto.PlayerId;
        if (dto.SeasonId is not null) entity.SeasonId = dto.SeasonId;
        if (!TryValidateModel(entity)) return BadRequest(ModelState);
        await _db.SaveChangesAsync();
        return Ok(entity);
    }

    [HttpDelete("{id:int}")]
    public async Task<IActionResult> Delete(int id)
    {
        var entity = await _db.PlayerSeasonStatses.FindAsync(id);
        if (entity is null) return NotFound();
        _db.PlayerSeasonStatses.Remove(entity);
        await _db.SaveChangesAsync();
        return NoContent();
    }

}
