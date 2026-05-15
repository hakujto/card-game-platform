using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using CardsProject.Infrastructure;
using CardsProject.Domain.Marketplace;
using CardsProject.Services.Marketplace;

namespace CardsProject.Controllers.Marketplace;

[ApiController]
[Route("api/card_price_histories")]
[Microsoft.AspNetCore.Authorization.AllowAnonymous]
public class CardPriceHistoryController : ControllerBase
{
    private readonly AppDbContext _db;
    public CardPriceHistoryController(AppDbContext db) => _db = db;

    [HttpGet]
    public async Task<IActionResult> List()
    {
        var items = await _db.CardPriceHistories.AsNoTracking().ToListAsync();
        return Ok(items);
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CardPriceHistoryDto dto)
    {
        var entity = new CardPriceHistory();
        if (dto.PriceDate is not null) entity.PriceDate = dto.PriceDate.Value;
        if (dto.AvgPrice is not null) entity.AvgPrice = dto.AvgPrice.Value;
        if (dto.MinPrice is not null) entity.MinPrice = dto.MinPrice.Value;
        if (dto.MaxPrice is not null) entity.MaxPrice = dto.MaxPrice.Value;
        if (dto.Volume is not null) entity.Volume = dto.Volume.Value;
        if (dto.Foil is not null) entity.Foil = dto.Foil.Value;
        if (dto.CardId is not null) entity.CardId = dto.CardId;
        if (!TryValidateModel(entity)) return BadRequest(ModelState);
        _db.CardPriceHistories.Add(entity);
        await _db.SaveChangesAsync();
        return CreatedAtAction(nameof(Show), new { id = entity.Id }, entity);
    }

    [HttpGet("{id:int}")]
    public async Task<IActionResult> Show(int id)
    {
        var entity = await _db.CardPriceHistories.FindAsync(id);
        if (entity is null) return NotFound();
        return Ok(entity);
    }

    [HttpPut("{id:int}")]
    [HttpPatch("{id:int}")]
    public async Task<IActionResult> Update(int id, [FromBody] CardPriceHistoryDto dto)
    {
        var entity = await _db.CardPriceHistories.FindAsync(id);
        if (entity is null) return NotFound();
        if (dto.PriceDate is not null) entity.PriceDate = dto.PriceDate.Value;
        if (dto.AvgPrice is not null) entity.AvgPrice = dto.AvgPrice.Value;
        if (dto.MinPrice is not null) entity.MinPrice = dto.MinPrice.Value;
        if (dto.MaxPrice is not null) entity.MaxPrice = dto.MaxPrice.Value;
        if (dto.Volume is not null) entity.Volume = dto.Volume.Value;
        if (dto.Foil is not null) entity.Foil = dto.Foil.Value;
        if (dto.CardId is not null) entity.CardId = dto.CardId;
        if (!TryValidateModel(entity)) return BadRequest(ModelState);
        await _db.SaveChangesAsync();
        return Ok(entity);
    }

    [HttpDelete("{id:int}")]
    public async Task<IActionResult> Delete(int id)
    {
        var entity = await _db.CardPriceHistories.FindAsync(id);
        if (entity is null) return NotFound();
        _db.CardPriceHistories.Remove(entity);
        await _db.SaveChangesAsync();
        return NoContent();
    }

}
