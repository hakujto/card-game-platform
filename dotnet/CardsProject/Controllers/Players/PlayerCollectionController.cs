using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using CardsProject.Infrastructure;
using CardsProject.Domain.Players;

namespace CardsProject.Controllers.Players;

[ApiController]
[Route("api/player_collections")]
public class PlayerCollectionController : ControllerBase
{
    private readonly AppDbContext _db;

    public PlayerCollectionController(AppDbContext db) => _db = db;

    [HttpGet]
    public async Task<IActionResult> List()
    {
        var items = await _db.PlayerCollections.AsNoTracking().ToListAsync();
        return Ok(items);
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] PlayerCollectionDto dto)
    {
        var entity = new PlayerCollection();
        if (dto.Quantity is not null) entity.Quantity = dto.Quantity.Value;
        if (dto.Foil is not null) entity.Foil = dto.Foil.Value;
        if (dto.Condition is not null && Enum.TryParse<PlayerCollectionConditionType>(dto.Condition, out var conditionVal)) entity.Condition = conditionVal;
        if (dto.AcquiredAt is not null) entity.AcquiredAt = dto.AcquiredAt.Value;
        if (dto.AcquiredVia is not null && Enum.TryParse<PlayerCollectionAcquiredViaType>(dto.AcquiredVia, out var acquiredViaVal)) entity.AcquiredVia = acquiredViaVal;
        if (dto.PlayerId is not null) entity.PlayerId = dto.PlayerId;
        if (dto.CardId is not null) entity.CardId = dto.CardId;
        _db.PlayerCollections.Add(entity);
        await _db.SaveChangesAsync();
        return CreatedAtAction(nameof(Show), new { id = entity.Id }, entity);
    }

    [HttpGet("{id:int}")]
    public async Task<IActionResult> Show(int id)
    {
        var entity = await _db.PlayerCollections.FindAsync(id);
        if (entity is null) return NotFound();
        return Ok(entity);
    }

    [HttpPut("{id:int}")]
    [HttpPatch("{id:int}")]
    public async Task<IActionResult> Update(int id, [FromBody] PlayerCollectionDto dto)
    {
        var entity = await _db.PlayerCollections.FindAsync(id);
        if (entity is null) return NotFound();
        if (dto.Quantity is not null) entity.Quantity = dto.Quantity.Value;
        if (dto.Foil is not null) entity.Foil = dto.Foil.Value;
        if (dto.Condition is not null && Enum.TryParse<PlayerCollectionConditionType>(dto.Condition, out var conditionVal)) entity.Condition = conditionVal;
        if (dto.AcquiredAt is not null) entity.AcquiredAt = dto.AcquiredAt.Value;
        if (dto.AcquiredVia is not null && Enum.TryParse<PlayerCollectionAcquiredViaType>(dto.AcquiredVia, out var acquiredViaVal)) entity.AcquiredVia = acquiredViaVal;
        if (dto.PlayerId is not null) entity.PlayerId = dto.PlayerId;
        if (dto.CardId is not null) entity.CardId = dto.CardId;
        await _db.SaveChangesAsync();
        return Ok(entity);
    }

    [HttpDelete("{id:int}")]
    public async Task<IActionResult> Delete(int id)
    {
        var entity = await _db.PlayerCollections.FindAsync(id);
        if (entity is null) return NotFound();
        _db.PlayerCollections.Remove(entity);
        await _db.SaveChangesAsync();
        return NoContent();
    }
}
