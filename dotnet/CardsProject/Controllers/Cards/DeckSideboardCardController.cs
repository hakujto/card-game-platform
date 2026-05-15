using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using CardsProject.Infrastructure;
using CardsProject.Domain.Cards;
using CardsProject.Services.Cards;

namespace CardsProject.Controllers.Cards;

[ApiController]
[Route("api/deck_sideboard_cards")]
[Microsoft.AspNetCore.Authorization.AllowAnonymous]
public class DeckSideboardCardController : ControllerBase
{
    private readonly AppDbContext _db;
    public DeckSideboardCardController(AppDbContext db) => _db = db;

    [HttpGet]
    public async Task<IActionResult> List()
    {
        var items = await _db.DeckSideboardCards.AsNoTracking().ToListAsync();
        return Ok(items);
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] DeckSideboardCardDto dto)
    {
        var entity = new DeckSideboardCard();
        if (dto.Quantity is not null) entity.Quantity = dto.Quantity.Value;
        if (dto.DeckId is not null) entity.DeckId = dto.DeckId;
        if (dto.CardId is not null) entity.CardId = dto.CardId;
        if (!TryValidateModel(entity)) return BadRequest(ModelState);
        _db.DeckSideboardCards.Add(entity);
        await _db.SaveChangesAsync();
        return CreatedAtAction(nameof(Show), new { id = entity.Id }, entity);
    }

    [HttpGet("{id:int}")]
    public async Task<IActionResult> Show(int id)
    {
        var entity = await _db.DeckSideboardCards.FindAsync(id);
        if (entity is null) return NotFound();
        return Ok(entity);
    }

    [HttpPut("{id:int}")]
    [HttpPatch("{id:int}")]
    public async Task<IActionResult> Update(int id, [FromBody] DeckSideboardCardDto dto)
    {
        var entity = await _db.DeckSideboardCards.FindAsync(id);
        if (entity is null) return NotFound();
        if (dto.Quantity is not null) entity.Quantity = dto.Quantity.Value;
        if (dto.DeckId is not null) entity.DeckId = dto.DeckId;
        if (dto.CardId is not null) entity.CardId = dto.CardId;
        if (!TryValidateModel(entity)) return BadRequest(ModelState);
        await _db.SaveChangesAsync();
        return Ok(entity);
    }

    [HttpDelete("{id:int}")]
    public async Task<IActionResult> Delete(int id)
    {
        var entity = await _db.DeckSideboardCards.FindAsync(id);
        if (entity is null) return NotFound();
        _db.DeckSideboardCards.Remove(entity);
        await _db.SaveChangesAsync();
        return NoContent();
    }

}
