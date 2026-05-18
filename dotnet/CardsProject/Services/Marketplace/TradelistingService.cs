using Microsoft.EntityFrameworkCore;
using System.ComponentModel.DataAnnotations;
using CardsProject.Controllers.Marketplace;
using CardsProject.Domain.Marketplace;
using CardsProject.Infrastructure;

namespace CardsProject.Services.Marketplace;

public class TradeListingService
{
    private readonly AppDbContext _db;

    public TradeListingService(AppDbContext db) => _db = db;

    private static void ValidateEntity(object entity)
    {
        var ctx = new ValidationContext(entity);
        Validator.ValidateObject(entity, ctx, validateAllProperties: true);
    }

    public async Task<List<TradeListing>> GetAllAsync()
        => await _db.TradeListings.AsNoTracking().ToListAsync();

    public async Task<TradeListing?> GetByIdAsync(int id)
        => await _db.TradeListings.FindAsync(id);

    public async Task<TradeListing> CreateAsync(TradeListingDto dto)
    {
        var entity = new TradeListing();
        if (dto.ListingType is not null && Enum.TryParse<TradeListingListingTypeType>(dto.ListingType, out var listingTypeVal)) entity.ListingType = listingTypeVal;
        if (dto.AskingPrice is not null) entity.AskingPrice = dto.AskingPrice.Value;
        if (dto.AuctionStartPrice is not null) entity.AuctionStartPrice = dto.AuctionStartPrice.Value;
        if (dto.AuctionCurrentBid is not null) entity.AuctionCurrentBid = dto.AuctionCurrentBid.Value;
        if (dto.AuctionEndTime is not null) entity.AuctionEndTime = dto.AuctionEndTime.Value;
        if (dto.Foil is not null) entity.Foil = dto.Foil.Value;
        if (dto.Condition is not null && Enum.TryParse<TradeListingConditionType>(dto.Condition, out var conditionVal)) entity.Condition = conditionVal;
        if (dto.Quantity is not null) entity.Quantity = dto.Quantity.Value;
        if (dto.Status is not null && Enum.TryParse<TradeListingStatusType>(dto.Status, out var statusVal)) entity.Status = statusVal;
        if (dto.Description is not null) entity.Description = dto.Description;
        if (dto.CreatedAt is not null) entity.CreatedAt = dto.CreatedAt.Value;
        if (dto.ExpiresAt is not null) entity.ExpiresAt = dto.ExpiresAt.Value;
        if (dto.SellerId is not null) entity.SellerId = dto.SellerId;
        if (dto.CardId is not null) entity.CardId = dto.CardId;
        Validate(entity);
        ValidateEntity(entity);
        _db.TradeListings.Add(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async Task<TradeListing?> UpdateAsync(int id, TradeListingDto dto)
    {
        var entity = await _db.TradeListings.FindAsync(id);
        if (entity is null) return null;
        if (dto.ListingType is not null && Enum.TryParse<TradeListingListingTypeType>(dto.ListingType, out var listingTypeVal)) entity.ListingType = listingTypeVal;
        if (dto.AskingPrice is not null) entity.AskingPrice = dto.AskingPrice.Value;
        if (dto.AuctionStartPrice is not null) entity.AuctionStartPrice = dto.AuctionStartPrice.Value;
        if (dto.AuctionCurrentBid is not null) entity.AuctionCurrentBid = dto.AuctionCurrentBid.Value;
        if (dto.AuctionEndTime is not null) entity.AuctionEndTime = dto.AuctionEndTime.Value;
        if (dto.Foil is not null) entity.Foil = dto.Foil.Value;
        if (dto.Condition is not null && Enum.TryParse<TradeListingConditionType>(dto.Condition, out var conditionVal)) entity.Condition = conditionVal;
        if (dto.Quantity is not null) entity.Quantity = dto.Quantity.Value;
        if (dto.Status is not null && Enum.TryParse<TradeListingStatusType>(dto.Status, out var statusVal)) entity.Status = statusVal;
        if (dto.Description is not null) entity.Description = dto.Description;
        if (dto.CreatedAt is not null) entity.CreatedAt = dto.CreatedAt.Value;
        if (dto.ExpiresAt is not null) entity.ExpiresAt = dto.ExpiresAt.Value;
        if (dto.SellerId is not null) entity.SellerId = dto.SellerId;
        if (dto.CardId is not null) entity.CardId = dto.CardId;
        Validate(entity);
        ValidateEntity(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async Task<bool> DeleteAsync(int id)
    {
        var entity = await _db.TradeListings.FindAsync(id);
        if (entity is null) return false;
        _db.TradeListings.Remove(entity);
        await _db.SaveChangesAsync();
        return true;
    }

    public async System.Threading.Tasks.Task<bool> CloseAsync(int id)
    {
        var entity = await _db.TradeListings.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("TradeListing not found: " + id);
        entity.Close();
        await _db.SaveChangesAsync();
        return true;
    }
    public async System.Threading.Tasks.Task<bool> ExtendAsync(int id, int days)
    {
        var entity = await _db.TradeListings.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("TradeListing not found: " + id);
        entity.Extend(days);
        await _db.SaveChangesAsync();
        return true;
    }
    public async System.Threading.Tasks.Task<bool> CancelAsync(int id)
    {
        var entity = await _db.TradeListings.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("TradeListing not found: " + id);
        entity.Cancel();
        await _db.SaveChangesAsync();
        return true;
    }
    public async System.Threading.Tasks.Task<bool> IsExpiredAsync(int id)
    {
        var entity = await _db.TradeListings.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("TradeListing not found: " + id);
        var result = entity.IsExpired();
        await _db.SaveChangesAsync();
        return result;
    }
    public async System.Threading.Tasks.Task<bool> FinalizeAuctionAsync(int id)
    {
        var entity = await _db.TradeListings.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("TradeListing not found: " + id);
        entity.FinalizeAuction();
        await _db.SaveChangesAsync();
        return true;
    }
    // triggered by @on(status = Sold)
    public async System.Threading.Tasks.Task SetStatusAsync(int id, TradeListingStatusType value)
    {
        var entity = await _db.TradeListings.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("TradeListing not found: " + id);
        entity.Status = value;
        if (value == TradeListingStatusType.Sold)
        {
            entity.FinalizeAuction();
        }
        await _db.SaveChangesAsync();
    }
    public void Validate(TradeListing entity)
    {
        if (entity.ListingType == TradeListingListingTypeType.FixedPrice && entity.AskingPrice == null) throw new InvalidOperationException("Fixed price listing must have an asking price");
        if (entity.ListingType == TradeListingListingTypeType.Auction && !(entity.AuctionStartPrice != null && entity.AuctionEndTime != null)) throw new InvalidOperationException("Auction listing must have a start price and end time");
    }
}
