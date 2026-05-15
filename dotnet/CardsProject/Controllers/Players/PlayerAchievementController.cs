using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using CardsProject.Infrastructure;
using CardsProject.Domain.Players;
using CardsProject.Services.Players;

namespace CardsProject.Controllers.Players;

[ApiController]
[Route("api/player_achievements")]
[Microsoft.AspNetCore.Authorization.AllowAnonymous]
public class PlayerAchievementController : ControllerBase
{
    private readonly AppDbContext _db;
    private readonly PlayerAchievementService _svc;

    public PlayerAchievementController(AppDbContext db, PlayerAchievementService svc) { _db = db; _svc = svc; }

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
        if (!TryValidateModel(entity)) return BadRequest(ModelState);
        try { _svc.Validate(entity); } catch (InvalidOperationException ex) { return BadRequest(new { error = ex.Message }); }
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
        if (!TryValidateModel(entity)) return BadRequest(ModelState);
        try { _svc.Validate(entity); } catch (InvalidOperationException ex) { return BadRequest(new { error = ex.Message }); }
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
