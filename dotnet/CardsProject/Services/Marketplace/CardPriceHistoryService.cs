using CardsProject.Domain.Marketplace;
using CardsProject.Infrastructure;

namespace CardsProject.Services.Marketplace;

public class CardPriceHistoryService
{
    private readonly AppDbContext _db;

    public CardPriceHistoryService(AppDbContext db) => _db = db;

    public async System.Threading.Tasks.Task<CardPriceHistory> CreateAsync(CardPriceHistory entity)
    {
        _db.CardPriceHistories.Add(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async System.Threading.Tasks.Task<CardPriceHistory> UpdateAsync(CardPriceHistory entity)
    {
        _db.CardPriceHistories.Update(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

}
