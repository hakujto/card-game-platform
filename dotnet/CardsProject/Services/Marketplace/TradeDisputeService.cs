using CardsProject.Domain.Marketplace;
using CardsProject.Infrastructure;

namespace CardsProject.Services.Marketplace;

public class TradeDisputeService
{
    private readonly AppDbContext _db;

    public TradeDisputeService(AppDbContext db) => _db = db;

    public System.Threading.Tasks.Task<TradeDispute> Create(TradeDispute entity)
    {
        throw new NotImplementedException();
    }

    public System.Threading.Tasks.Task<TradeDispute> Update(TradeDispute entity)
    {
        throw new NotImplementedException();
    }
}
