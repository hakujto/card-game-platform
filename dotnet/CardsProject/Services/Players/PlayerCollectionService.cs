using CardsProject.Domain.Players;
using CardsProject.Infrastructure;

namespace CardsProject.Services.Players;

public class PlayerCollectionService
{
    private readonly AppDbContext _db;

    public PlayerCollectionService(AppDbContext db) => _db = db;

    public async System.Threading.Tasks.Task<PlayerCollection> CreateAsync(PlayerCollection entity)
    {
        _db.PlayerCollections.Add(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async System.Threading.Tasks.Task<PlayerCollection> UpdateAsync(PlayerCollection entity)
    {
        _db.PlayerCollections.Update(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async System.Threading.Tasks.Task<decimal> EstimatedValueAsync(int id)
    {
        var entity = await _db.PlayerCollections.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("PlayerCollection not found: " + id);
        var result = entity.EstimatedValue();
        await _db.SaveChangesAsync();
        return result;
    }
}
