using CardsProject.Domain.Marketplace;
using CardsProject.Infrastructure;

namespace CardsProject.Services.Marketplace;

public class TradeTransactionService
{
    private readonly AppDbContext _db;

    public TradeTransactionService(AppDbContext db) => _db = db;

    public async System.Threading.Tasks.Task<TradeTransaction> CreateAsync(TradeTransaction entity)
    {
        _db.TradeTransactions.Add(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async System.Threading.Tasks.Task<TradeTransaction> UpdateAsync(TradeTransaction entity)
    {
        _db.TradeTransactions.Update(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async System.Threading.Tasks.Task<bool> CompleteAsync(int id)
    {
        var entity = await _db.TradeTransactions.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("TradeTransaction not found: " + id);
        entity.Complete();
        await _db.SaveChangesAsync();
        return true;
    }
    public async System.Threading.Tasks.Task<bool> RefundAsync(int id)
    {
        var entity = await _db.TradeTransactions.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("TradeTransaction not found: " + id);
        entity.Refund();
        await _db.SaveChangesAsync();
        return true;
    }
    public async System.Threading.Tasks.Task<bool> OpenDisputeAsync(int id, string reason)
    {
        var entity = await _db.TradeTransactions.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("TradeTransaction not found: " + id);
        entity.OpenDispute(reason);
        await _db.SaveChangesAsync();
        return true;
    }
    public void Validate(TradeTransaction entity)
    {
        if (entity.Status == TradeTransactionStatusType.Completed && entity.CompletedAt == null) throw new InvalidOperationException("Completed transaction must have a completed_at timestamp");
    }
}
