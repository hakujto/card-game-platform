using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using CardsProject.Infrastructure;
using CardsProject.Domain.Marketplace;

namespace CardsProject.Controllers.Marketplace;

[ApiController]
[Route("api/tradelistings")]
public class TradelistingController : ControllerBase
{
    private readonly AppDbContext _db;

    public TradelistingController(AppDbContext db) => _db = db;

    [HttpGet]
    public async Task<IActionResult> List()
    {
        var items = await _db.Tradelistings.AsNoTracking().ToListAsync();
        return Ok(items);
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] TradelistingDto dto)
    {
        var entity = new Tradelisting();
        if (dto.ListingType is not null && Enum.TryParse<TradelistingListingTypeType>(dto.ListingType, out var listingTypeVal)) entity.ListingType = listingTypeVal;
        if (dto.AskingPrice is not null) entity.AskingPrice = dto.AskingPrice.Value;
        if (dto.AuctionStartPrice is not null) entity.AuctionStartPrice = dto.AuctionStartPrice.Value;
        if (dto.AuctionCurrentBid is not null) entity.AuctionCurrentBid = dto.AuctionCurrentBid.Value;
        if (dto.AuctionEndTime is not null) entity.AuctionEndTime = dto.AuctionEndTime.Value;
        if (dto.Foil is not null) entity.Foil = dto.Foil.Value;
        if (dto.Condition is not null && Enum.TryParse<TradelistingConditionType>(dto.Condition, out var conditionVal)) entity.Condition = conditionVal;
        if (dto.Quantity is not null) entity.Quantity = dto.Quantity.Value;
        if (dto.Status is not null && Enum.TryParse<TradelistingStatusType>(dto.Status, out var statusVal)) entity.Status = statusVal;
        if (dto.Description is not null) entity.Description = dto.Description;
        if (dto.CreatedAt is not null) entity.CreatedAt = dto.CreatedAt.Value;
        if (dto.ExpiresAt is not null) entity.ExpiresAt = dto.ExpiresAt.Value;
        if (dto.SellerId is not null) entity.SellerId = dto.SellerId;
        if (dto.CardId is not null) entity.CardId = dto.CardId;
        if (dto.BidsId is not null) entity.BidsId = dto.BidsId;
        _db.Tradelistings.Add(entity);
        await _db.SaveChangesAsync();
        return CreatedAtAction(nameof(Show), new { id = entity.Id }, entity);
    }

    [HttpGet("{id:int}")]
    public async Task<IActionResult> Show(int id)
    {
        var entity = await _db.Tradelistings.FindAsync(id);
        if (entity is null) return NotFound();
        return Ok(entity);
    }

    [HttpPut("{id:int}")]
    [HttpPatch("{id:int}")]
    public async Task<IActionResult> Update(int id, [FromBody] TradelistingDto dto)
    {
        var entity = await _db.Tradelistings.FindAsync(id);
        if (entity is null) return NotFound();
        if (dto.ListingType is not null && Enum.TryParse<TradelistingListingTypeType>(dto.ListingType, out var listingTypeVal)) entity.ListingType = listingTypeVal;
        if (dto.AskingPrice is not null) entity.AskingPrice = dto.AskingPrice.Value;
        if (dto.AuctionStartPrice is not null) entity.AuctionStartPrice = dto.AuctionStartPrice.Value;
        if (dto.AuctionCurrentBid is not null) entity.AuctionCurrentBid = dto.AuctionCurrentBid.Value;
        if (dto.AuctionEndTime is not null) entity.AuctionEndTime = dto.AuctionEndTime.Value;
        if (dto.Foil is not null) entity.Foil = dto.Foil.Value;
        if (dto.Condition is not null && Enum.TryParse<TradelistingConditionType>(dto.Condition, out var conditionVal)) entity.Condition = conditionVal;
        if (dto.Quantity is not null) entity.Quantity = dto.Quantity.Value;
        if (dto.Status is not null && Enum.TryParse<TradelistingStatusType>(dto.Status, out var statusVal)) entity.Status = statusVal;
        if (dto.Description is not null) entity.Description = dto.Description;
        if (dto.CreatedAt is not null) entity.CreatedAt = dto.CreatedAt.Value;
        if (dto.ExpiresAt is not null) entity.ExpiresAt = dto.ExpiresAt.Value;
        if (dto.SellerId is not null) entity.SellerId = dto.SellerId;
        if (dto.CardId is not null) entity.CardId = dto.CardId;
        if (dto.BidsId is not null) entity.BidsId = dto.BidsId;
        await _db.SaveChangesAsync();
        return Ok(entity);
    }

    [HttpDelete("{id:int}")]
    public async Task<IActionResult> Delete(int id)
    {
        var entity = await _db.Tradelistings.FindAsync(id);
        if (entity is null) return NotFound();
        _db.Tradelistings.Remove(entity);
        await _db.SaveChangesAsync();
        return NoContent();
    }
}
