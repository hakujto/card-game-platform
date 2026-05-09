using CardsProject.Domain.Marketplace;
using CardsProject.Infrastructure;

namespace CardsProject.Services.Marketplace;

public class TradeBidService
{
    private readonly AppDbContext _db;

    public TradeBidService(AppDbContext db) => _db = db;

    public System.Threading.Tasks.Task<TradeBid> Create(TradeBid entity)
    {
        throw new NotImplementedException();
    }

    public System.Threading.Tasks.Task<TradeBid> Update(TradeBid entity)
    {
        throw new NotImplementedException();
    }
}
