using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using CardsProject.Infrastructure;
using CardsProject.Domain.Players;

namespace CardsProject.Controllers.Players;

[ApiController]
[Route("api/player_achievements")]
public class PlayerAchievementController : ControllerBase
{
    private readonly AppDbContext _db;

    public PlayerAchievementController(AppDbContext db) => _db = db;

    [HttpGet]
    public async Task<IActionResult> List()
    {
        var items = await _db.PlayerAchievements.AsNoTracking().ToListAsync();
        return Ok(items);
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] PlayerAchievementDto dto)
    {
        var entity = new PlayerAchievement();
        if (dto.EarnedAt is not null) entity.EarnedAt = dto.EarnedAt.Value;
        if (dto.Progress is not null) entity.Progress = dto.Progress.Value;
        if (dto.IsCompleted is not null) entity.IsCompleted = dto.IsCompleted.Value;
        if (dto.PlayerId is not null) entity.PlayerId = dto.PlayerId;
        if (dto.AchievementId is not null) entity.AchievementId = dto.AchievementId;
        _db.PlayerAchievements.Add(entity);
        await _db.SaveChangesAsync();
        return CreatedAtAction(nameof(Show), new { id = entity.Id }, entity);
    }

    [HttpGet("{id:int}")]
    public async Task<IActionResult> Show(int id)
    {
        var entity = await _db.PlayerAchievements.FindAsync(id);
        if (entity is null) return NotFound();
        return Ok(entity);
    }

    [HttpPut("{id:int}")]
    [HttpPatch("{id:int}")]
    public async Task<IActionResult> Update(int id, [FromBody] PlayerAchievementDto dto)
    {
        var entity = await _db.PlayerAchievements.FindAsync(id);
        if (entity is null) return NotFound();
        if (dto.EarnedAt is not null) entity.EarnedAt = dto.EarnedAt.Value;
        if (dto.Progress is not null) entity.Progress = dto.Progress.Value;
        if (dto.IsCompleted is not null) entity.IsCompleted = dto.IsCompleted.Value;
        if (dto.PlayerId is not null) entity.PlayerId = dto.PlayerId;
        if (dto.AchievementId is not null) entity.AchievementId = dto.AchievementId;
        await _db.SaveChangesAsync();
        return Ok(entity);
    }

    [HttpDelete("{id:int}")]
    public async Task<IActionResult> Delete(int id)
    {
        var entity = await _db.PlayerAchievements.FindAsync(id);
        if (entity is null) return NotFound();
        _db.PlayerAchievements.Remove(entity);
        await _db.SaveChangesAsync();
        return NoContent();
    }
}
