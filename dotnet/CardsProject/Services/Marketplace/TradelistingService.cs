using CardsProject.Domain.Marketplace;
using CardsProject.Infrastructure;

namespace CardsProject.Services.Marketplace;

public class TradelistingService
{
    private readonly AppDbContext _db;

    public TradelistingService(AppDbContext db) => _db = db;

    public async System.Threading.Tasks.Task<Tradelisting> CreateAsync(Tradelisting entity)
    {
        _db.Tradelistings.Add(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async System.Threading.Tasks.Task<Tradelisting> UpdateAsync(Tradelisting entity)
    {
        _db.Tradelistings.Update(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async System.Threading.Tasks.Task<bool> CloseAsync(int id)
    {
        var entity = await _db.Tradelistings.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("Tradelisting not found: " + id);
        entity.Close();
        await _db.SaveChangesAsync();
        return true;
    }
    public async System.Threading.Tasks.Task<bool> ExtendAsync(int id, int days)
    {
        var entity = await _db.Tradelistings.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("Tradelisting not found: " + id);
        entity.Extend(days);
        await _db.SaveChangesAsync();
        return true;
    }
    public async System.Threading.Tasks.Task<bool> CancelAsync(int id)
    {
        var entity = await _db.Tradelistings.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("Tradelisting not found: " + id);
        entity.Cancel();
        await _db.SaveChangesAsync();
        return true;
    }
    // triggered by @on(status = Sold)
    public async System.Threading.Tasks.Task SetStatusAsync(int id, TradelistingStatusType value)
    {
        var entity = await _db.Tradelistings.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("Tradelisting not found: " + id);
        entity.Status = value;
        if (value == TradelistingStatusType.Sold)
        {
            entity.FinalizeAuction();
        }
        await _db.SaveChangesAsync();
    }
    public void Validate(Tradelisting entity)
    {
        if (entity.ListingType == TradelistingListingTypeType.FixedPrice && entity.AskingPrice == null) throw new InvalidOperationException("Fixed price listing must have an asking price");
        if (entity.ListingType == TradelistingListingTypeType.Auction && !(entity.AuctionStartPrice != null && entity.AuctionEndTime != null)) throw new InvalidOperationException("Auction listing must have a start price and end time");
    }
}
