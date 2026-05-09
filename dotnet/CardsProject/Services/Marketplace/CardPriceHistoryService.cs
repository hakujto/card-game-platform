using CardsProject.Domain.Marketplace;
using CardsProject.Infrastructure;

namespace CardsProject.Services.Marketplace;

public class CardPriceHistoryService
{
    private readonly AppDbContext _db;

    public CardPriceHistoryService(AppDbContext db) => _db = db;

    public System.Threading.Tasks.Task<CardPriceHistory> Create(CardPriceHistory entity)
    {
        throw new NotImplementedException();
    }

    public System.Threading.Tasks.Task<CardPriceHistory> Update(CardPriceHistory entity)
    {
        throw new NotImplementedException();
    }
}
