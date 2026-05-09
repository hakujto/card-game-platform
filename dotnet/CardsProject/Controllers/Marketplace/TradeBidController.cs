using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using CardsProject.Infrastructure;
using CardsProject.Domain.Marketplace;

namespace CardsProject.Controllers.Marketplace;

[ApiController]
[Route("api/trade_bids")]
public class TradeBidController : ControllerBase
{
    private readonly AppDbContext _db;

    public TradeBidController(AppDbContext db) => _db = db;

    [HttpGet]
    public async Task<IActionResult> List()
    {
        var items = await _db.TradeBids.AsNoTracking().ToListAsync();
        return Ok(items);
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] TradeBidDto dto)
    {
        var entity = new TradeBid();
        if (dto.Amount is not null) entity.Amount = dto.Amount.Value;
        if (dto.PlacedAt is not null) entity.PlacedAt = dto.PlacedAt.Value;
        if (dto.IsWinning is not null) entity.IsWinning = dto.IsWinning.Value;
        if (dto.ListingId is not null) entity.ListingId = dto.ListingId;
        if (dto.BidderId is not null) entity.BidderId = dto.BidderId;
        _db.TradeBids.Add(entity);
        await _db.SaveChangesAsync();
        return CreatedAtAction(nameof(Show), new { id = entity.Id }, entity);
    }

    [HttpGet("{id:int}")]
    public async Task<IActionResult> Show(int id)
    {
        var entity = await _db.TradeBids.FindAsync(id);
        if (entity is null) return NotFound();
        return Ok(entity);
    }

    [HttpPut("{id:int}")]
    [HttpPatch("{id:int}")]
    public async Task<IActionResult> Update(int id, [FromBody] TradeBidDto dto)
    {
        var entity = await _db.TradeBids.FindAsync(id);
        if (entity is null) return NotFound();
        if (dto.Amount is not null) entity.Amount = dto.Amount.Value;
        if (dto.PlacedAt is not null) entity.PlacedAt = dto.PlacedAt.Value;
        if (dto.IsWinning is not null) entity.IsWinning = dto.IsWinning.Value;
        if (dto.ListingId is not null) entity.ListingId = dto.ListingId;
        if (dto.BidderId is not null) entity.BidderId = dto.BidderId;
        await _db.SaveChangesAsync();
        return Ok(entity);
    }

    [HttpDelete("{id:int}")]
    public async Task<IActionResult> Delete(int id)
    {
        var entity = await _db.TradeBids.FindAsync(id);
        if (entity is null) return NotFound();
        _db.TradeBids.Remove(entity);
        await _db.SaveChangesAsync();
        return NoContent();
    }
}
