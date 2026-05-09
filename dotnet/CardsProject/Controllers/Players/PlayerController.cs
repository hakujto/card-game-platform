using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using CardsProject.Infrastructure;
using CardsProject.Domain.Players;

namespace CardsProject.Controllers.Players;

[ApiController]
[Route("api/players")]
public class PlayerController : ControllerBase
{
    private readonly AppDbContext _db;

    public PlayerController(AppDbContext db) => _db = db;

    [HttpGet]
    public async Task<IActionResult> List()
    {
        var items = await _db.Players.AsNoTracking().ToListAsync();
        return Ok(items);
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] PlayerDto dto)
    {
        var entity = new Player();
        if (dto.DisplayName is not null) entity.DisplayName = dto.DisplayName;
        if (dto.Rank is not null && Enum.TryParse<PlayerRankType>(dto.Rank, out var rankVal)) entity.Rank = rankVal;
        if (dto.Rating is not null) entity.Rating = dto.Rating.Value;
        if (dto.PeakRating is not null) entity.PeakRating = dto.PeakRating.Value;
        if (dto.Bio is not null) entity.Bio = dto.Bio;
        if (dto.CountryCode is not null) entity.CountryCode = dto.CountryCode;
        if (dto.AvatarUrl is not null) entity.AvatarUrl = dto.AvatarUrl;
        if (dto.PreferredFormat is not null && Enum.TryParse<PlayerPreferredFormatType>(dto.PreferredFormat, out var preferredFormatVal)) entity.PreferredFormat = preferredFormatVal;
        if (dto.IsVerified is not null) entity.IsVerified = dto.IsVerified.Value;
        if (dto.CreatedAt is not null) entity.CreatedAt = dto.CreatedAt.Value;
        if (dto.LastActiveAt is not null) entity.LastActiveAt = dto.LastActiveAt.Value;
        if (dto.UserId is not null) entity.UserId = dto.UserId;
        if (dto.SeasonStatsId is not null) entity.SeasonStatsId = dto.SeasonStatsId;
        _db.Players.Add(entity);
        await _db.SaveChangesAsync();
        return CreatedAtAction(nameof(Show), new { id = entity.Id }, entity);
    }

    [HttpGet("{id:int}")]
    public async Task<IActionResult> Show(int id)
    {
        var entity = await _db.Players.FindAsync(id);
        if (entity is null) return NotFound();
        return Ok(entity);
    }

    [HttpPut("{id:int}")]
    [HttpPatch("{id:int}")]
    public async Task<IActionResult> Update(int id, [FromBody] PlayerDto dto)
    {
        var entity = await _db.Players.FindAsync(id);
        if (entity is null) return NotFound();
        if (dto.DisplayName is not null) entity.DisplayName = dto.DisplayName;
        if (dto.Rank is not null && Enum.TryParse<PlayerRankType>(dto.Rank, out var rankVal)) entity.Rank = rankVal;
        if (dto.Rating is not null) entity.Rating = dto.Rating.Value;
        if (dto.PeakRating is not null) entity.PeakRating = dto.PeakRating.Value;
        if (dto.Bio is not null) entity.Bio = dto.Bio;
        if (dto.CountryCode is not null) entity.CountryCode = dto.CountryCode;
        if (dto.AvatarUrl is not null) entity.AvatarUrl = dto.AvatarUrl;
        if (dto.PreferredFormat is not null && Enum.TryParse<PlayerPreferredFormatType>(dto.PreferredFormat, out var preferredFormatVal)) entity.PreferredFormat = preferredFormatVal;
        if (dto.IsVerified is not null) entity.IsVerified = dto.IsVerified.Value;
        if (dto.CreatedAt is not null) entity.CreatedAt = dto.CreatedAt.Value;
        if (dto.LastActiveAt is not null) entity.LastActiveAt = dto.LastActiveAt.Value;
        if (dto.UserId is not null) entity.UserId = dto.UserId;
        if (dto.SeasonStatsId is not null) entity.SeasonStatsId = dto.SeasonStatsId;
        await _db.SaveChangesAsync();
        return Ok(entity);
    }

    [HttpDelete("{id:int}")]
    public async Task<IActionResult> Delete(int id)
    {
        var entity = await _db.Players.FindAsync(id);
        if (entity is null) return NotFound();
        _db.Players.Remove(entity);
        await _db.SaveChangesAsync();
        return NoContent();
    }
}
