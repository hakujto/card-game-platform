using CardsProject.Domain.Content;
using CardsProject.Infrastructure;

namespace CardsProject.Services.Content;

public class DraftSessionService
{
    private readonly AppDbContext _db;

    public DraftSessionService(AppDbContext db) => _db = db;

    public async System.Threading.Tasks.Task<DraftSession> CreateAsync(DraftSession entity)
    {
        _db.DraftSessions.Add(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async System.Threading.Tasks.Task<DraftSession> UpdateAsync(DraftSession entity)
    {
        _db.DraftSessions.Update(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async System.Threading.Tasks.Task<bool> StartAsync(int id)
    {
        var entity = await _db.DraftSessions.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("DraftSession not found: " + id);
        entity.Start();
        await _db.SaveChangesAsync();
        return true;
    }
    public async System.Threading.Tasks.Task<bool> AbandonAsync(int id)
    {
        var entity = await _db.DraftSessions.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("DraftSession not found: " + id);
        entity.Abandon();
        await _db.SaveChangesAsync();
        return true;
    }
    public async System.Threading.Tasks.Task<bool> CompleteAsync(int id)
    {
        var entity = await _db.DraftSessions.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("DraftSession not found: " + id);
        entity.Complete();
        await _db.SaveChangesAsync();
        return true;
    }
}
