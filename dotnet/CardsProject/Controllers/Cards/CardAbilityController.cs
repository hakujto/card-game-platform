using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using CardsProject.Infrastructure;
using CardsProject.Domain.Cards;

namespace CardsProject.Controllers.Cards;

[ApiController]
[Route("api/card_abilities")]
public class CardAbilityController : ControllerBase
{
    private readonly AppDbContext _db;

    public CardAbilityController(AppDbContext db) => _db = db;

    [HttpGet]
    public async Task<IActionResult> List()
    {
        var items = await _db.CardAbilities.AsNoTracking().ToListAsync();
        return Ok(items);
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CardAbilityDto dto)
    {
        var entity = new CardAbility();
        if (dto.AbilityType is not null && Enum.TryParse<CardAbilityAbilityTypeType>(dto.AbilityType, out var abilityTypeVal)) entity.AbilityType = abilityTypeVal;
        if (dto.Keyword is not null) entity.Keyword = dto.Keyword;
        if (dto.AbilityText is not null) entity.AbilityText = dto.AbilityText;
        if (dto.Timing is not null && Enum.TryParse<CardAbilityTimingType>(dto.Timing, out var timingVal)) entity.Timing = timingVal;
        if (dto.CardId is not null) entity.CardId = dto.CardId;
        _db.CardAbilities.Add(entity);
        await _db.SaveChangesAsync();
        return CreatedAtAction(nameof(Show), new { id = entity.Id }, entity);
    }

    [HttpGet("{id:int}")]
    public async Task<IActionResult> Show(int id)
    {
        var entity = await _db.CardAbilities.FindAsync(id);
        if (entity is null) return NotFound();
        return Ok(entity);
    }

    [HttpPut("{id:int}")]
    [HttpPatch("{id:int}")]
    public async Task<IActionResult> Update(int id, [FromBody] CardAbilityDto dto)
    {
        var entity = await _db.CardAbilities.FindAsync(id);
        if (entity is null) return NotFound();
        if (dto.AbilityType is not null && Enum.TryParse<CardAbilityAbilityTypeType>(dto.AbilityType, out var abilityTypeVal)) entity.AbilityType = abilityTypeVal;
        if (dto.Keyword is not null) entity.Keyword = dto.Keyword;
        if (dto.AbilityText is not null) entity.AbilityText = dto.AbilityText;
        if (dto.Timing is not null && Enum.TryParse<CardAbilityTimingType>(dto.Timing, out var timingVal)) entity.Timing = timingVal;
        if (dto.CardId is not null) entity.CardId = dto.CardId;
        await _db.SaveChangesAsync();
        return Ok(entity);
    }

    [HttpDelete("{id:int}")]
    public async Task<IActionResult> Delete(int id)
    {
        var entity = await _db.CardAbilities.FindAsync(id);
        if (entity is null) return NotFound();
        _db.CardAbilities.Remove(entity);
        await _db.SaveChangesAsync();
        return NoContent();
    }
}
