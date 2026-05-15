using CardsProject.Domain.Marketplace;
using CardsProject.Infrastructure;

namespace CardsProject.Services.Marketplace;

public class TradeDisputeService
{
    private readonly AppDbContext _db;

    public TradeDisputeService(AppDbContext db) => _db = db;

    public async System.Threading.Tasks.Task<TradeDispute> CreateAsync(TradeDispute entity)
    {
        _db.TradeDisputes.Add(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async System.Threading.Tasks.Task<TradeDispute> UpdateAsync(TradeDispute entity)
    {
        _db.TradeDisputes.Update(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async System.Threading.Tasks.Task<bool> EscalateAsync(int id)
    {
        var entity = await _db.TradeDisputes.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("TradeDispute not found: " + id);
        entity.Escalate();
        await _db.SaveChangesAsync();
        return true;
    }
    public async System.Threading.Tasks.Task<bool> ResolveAsync(int id, string resolutionText)
    {
        var entity = await _db.TradeDisputes.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("TradeDispute not found: " + id);
        entity.Resolve(resolutionText);
        await _db.SaveChangesAsync();
        return true;
    }
    public async System.Threading.Tasks.Task<bool> ReviewAsync(int id)
    {
        var entity = await _db.TradeDisputes.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("TradeDispute not found: " + id);
        entity.Review();
        await _db.SaveChangesAsync();
        return true;
    }
    public void Validate(TradeDispute entity)
    {
        if (entity.ResolvedAt != null && !(entity.Status == TradeDisputeStatusType.Resolved)) throw new InvalidOperationException("resolved_at_requires_terminal_status");
    }
}
