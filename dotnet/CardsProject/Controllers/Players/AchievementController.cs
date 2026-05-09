using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using CardsProject.Infrastructure;
using CardsProject.Domain.Players;

namespace CardsProject.Controllers.Players;

[ApiController]
[Route("api/achievements")]
public class AchievementController : ControllerBase
{
    private readonly AppDbContext _db;

    public AchievementController(AppDbContext db) => _db = db;

    [HttpGet]
    public async Task<IActionResult> List()
    {
        var items = await _db.Achievements.AsNoTracking().ToListAsync();
        return Ok(items);
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] AchievementDto dto)
    {
        var entity = new Achievement();
        if (dto.Name is not null) entity.Name = dto.Name;
        if (dto.Description is not null) entity.Description = dto.Description;
        if (dto.IconUrl is not null) entity.IconUrl = dto.IconUrl;
        if (dto.Points is not null) entity.Points = dto.Points.Value;
        if (dto.Rarity is not null && Enum.TryParse<AchievementRarityType>(dto.Rarity, out var rarityVal)) entity.Rarity = rarityVal;
        if (dto.IsHidden is not null) entity.IsHidden = dto.IsHidden.Value;
        _db.Achievements.Add(entity);
        await _db.SaveChangesAsync();
        return CreatedAtAction(nameof(Show), new { id = entity.Id }, entity);
    }

    [HttpGet("{id:int}")]
    public async Task<IActionResult> Show(int id)
    {
        var entity = await _db.Achievements.FindAsync(id);
        if (entity is null) return NotFound();
        return Ok(entity);
    }

    [HttpPut("{id:int}")]
    [HttpPatch("{id:int}")]
    public async Task<IActionResult> Update(int id, [FromBody] AchievementDto dto)
    {
        var entity = await _db.Achievements.FindAsync(id);
        if (entity is null) return NotFound();
        if (dto.Name is not null) entity.Name = dto.Name;
        if (dto.Description is not null) entity.Description = dto.Description;
        if (dto.IconUrl is not null) entity.IconUrl = dto.IconUrl;
        if (dto.Points is not null) entity.Points = dto.Points.Value;
        if (dto.Rarity is not null && Enum.TryParse<AchievementRarityType>(dto.Rarity, out var rarityVal)) entity.Rarity = rarityVal;
        if (dto.IsHidden is not null) entity.IsHidden = dto.IsHidden.Value;
        await _db.SaveChangesAsync();
        return Ok(entity);
    }

    [HttpDelete("{id:int}")]
    public async Task<IActionResult> Delete(int id)
    {
        var entity = await _db.Achievements.FindAsync(id);
        if (entity is null) return NotFound();
        _db.Achievements.Remove(entity);
        await _db.SaveChangesAsync();
        return NoContent();
    }
}
