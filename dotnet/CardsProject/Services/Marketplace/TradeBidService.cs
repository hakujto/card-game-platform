using CardsProject.Domain.Marketplace;
using CardsProject.Infrastructure;

namespace CardsProject.Services.Marketplace;

public class TradeBidService
{
    private readonly AppDbContext _db;

    public TradeBidService(AppDbContext db) => _db = db;

    public async System.Threading.Tasks.Task<TradeBid> CreateAsync(TradeBid entity)
    {
        _db.TradeBids.Add(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async System.Threading.Tasks.Task<TradeBid> UpdateAsync(TradeBid entity)
    {
        _db.TradeBids.Update(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

}
