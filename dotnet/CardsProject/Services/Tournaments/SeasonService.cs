using CardsProject.Domain.Tournaments;
using CardsProject.Infrastructure;

namespace CardsProject.Services.Tournaments;

public class SeasonService
{
    private readonly AppDbContext _db;

    public SeasonService(AppDbContext db) => _db = db;

    public async System.Threading.Tasks.Task<Season> CreateAsync(Season entity)
    {
        _db.Seasons.Add(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async System.Threading.Tasks.Task<Season> UpdateAsync(Season entity)
    {
        _db.Seasons.Update(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async System.Threading.Tasks.Task<bool> ActivateAsync(int id)
    {
        var entity = await _db.Seasons.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("Season not found: " + id);
        entity.Activate();
        await _db.SaveChangesAsync();
        return true;
    }
    public async System.Threading.Tasks.Task<bool> DeactivateAsync(int id)
    {
        var entity = await _db.Seasons.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("Season not found: " + id);
        entity.Deactivate();
        await _db.SaveChangesAsync();
        return true;
    }
    public async System.Threading.Tasks.Task<bool> FinalizeRewardsAsync(int id)
    {
        var entity = await _db.Seasons.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("Season not found: " + id);
        entity.FinalizeRewards();
        await _db.SaveChangesAsync();
        return true;
    }
}
