using CardsProject.Domain.Marketplace;
using CardsProject.Infrastructure;

namespace CardsProject.Services.Marketplace;

public class TradeTransactionService
{
    private readonly AppDbContext _db;

    public TradeTransactionService(AppDbContext db) => _db = db;

    public System.Threading.Tasks.Task<TradeTransaction> Create(TradeTransaction entity)
    {
        throw new NotImplementedException();
    }

    public System.Threading.Tasks.Task<TradeTransaction> Update(TradeTransaction entity)
    {
        throw new NotImplementedException();
    }
}
