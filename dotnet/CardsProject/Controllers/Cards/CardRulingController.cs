using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using CardsProject.Infrastructure;
using CardsProject.Domain.Cards;
using CardsProject.Services.Cards;

namespace CardsProject.Controllers.Cards;

[ApiController]
[Route("api/card_rulings")]
[Microsoft.AspNetCore.Authorization.AllowAnonymous]
public class CardRulingController : ControllerBase
{
    private readonly AppDbContext _db;
    public CardRulingController(AppDbContext db) => _db = db;

    [HttpGet]
    public async Task<IActionResult> List()
    {
        var items = await _db.CardRulings.AsNoTracking().ToListAsync();
        return Ok(items);
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CardRulingDto dto)
    {
        var entity = new CardRuling();
        if (dto.RulingText is not null) entity.RulingText = dto.RulingText;
        if (dto.PublishedAt is not null) entity.PublishedAt = dto.PublishedAt.Value;
        if (dto.Source is not null) entity.Source = dto.Source;
        if (dto.CardId is not null) entity.CardId = dto.CardId;
        if (!TryValidateModel(entity)) return BadRequest(ModelState);
        _db.CardRulings.Add(entity);
        await _db.SaveChangesAsync();
        return CreatedAtAction(nameof(Show), new { id = entity.Id }, entity);
    }

    [HttpGet("{id:int}")]
    public async Task<IActionResult> Show(int id)
    {
        var entity = await _db.CardRulings.FindAsync(id);
        if (entity is null) return NotFound();
        return Ok(entity);
    }

    [HttpPut("{id:int}")]
    [HttpPatch("{id:int}")]
    public async Task<IActionResult> Update(int id, [FromBody] CardRulingDto dto)
    {
        var entity = await _db.CardRulings.FindAsync(id);
        if (entity is null) return NotFound();
        if (dto.RulingText is not null) entity.RulingText = dto.RulingText;
        if (dto.PublishedAt is not null) entity.PublishedAt = dto.PublishedAt.Value;
        if (dto.Source is not null) entity.Source = dto.Source;
        if (dto.CardId is not null) entity.CardId = dto.CardId;
        if (!TryValidateModel(entity)) return BadRequest(ModelState);
        await _db.SaveChangesAsync();
        return Ok(entity);
    }

    [HttpDelete("{id:int}")]
    public async Task<IActionResult> Delete(int id)
    {
        var entity = await _db.CardRulings.FindAsync(id);
        if (entity is null) return NotFound();
        _db.CardRulings.Remove(entity);
        await _db.SaveChangesAsync();
        return NoContent();
    }

}
