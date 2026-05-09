using CardsProject.Domain.Marketplace;
using CardsProject.Infrastructure;

namespace CardsProject.Services.Marketplace;

public class TradelistingService
{
    private readonly AppDbContext _db;

    public TradelistingService(AppDbContext db) => _db = db;

    public System.Threading.Tasks.Task<Tradelisting> Create(Tradelisting entity)
    {
        throw new NotImplementedException();
    }

    public System.Threading.Tasks.Task<Tradelisting> Update(Tradelisting entity)
    {
        throw new NotImplementedException();
    }
}
