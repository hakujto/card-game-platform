using CardsProject.Domain.Players;
using CardsProject.Infrastructure;

namespace CardsProject.Services.Players;

public class FriendshipService
{
    private readonly AppDbContext _db;

    public FriendshipService(AppDbContext db) => _db = db;

    public async System.Threading.Tasks.Task<Friendship> CreateAsync(Friendship entity)
    {
        _db.Friendships.Add(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async System.Threading.Tasks.Task<Friendship> UpdateAsync(Friendship entity)
    {
        _db.Friendships.Update(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async System.Threading.Tasks.Task<bool> AcceptAsync(int id)
    {
        var entity = await _db.Friendships.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("Friendship not found: " + id);
        entity.Accept();
        await _db.SaveChangesAsync();
        return true;
    }
    public async System.Threading.Tasks.Task<bool> DeclineAsync(int id)
    {
        var entity = await _db.Friendships.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("Friendship not found: " + id);
        entity.Decline();
        await _db.SaveChangesAsync();
        return true;
    }
    public async System.Threading.Tasks.Task<bool> BlockAsync(int id)
    {
        var entity = await _db.Friendships.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("Friendship not found: " + id);
        entity.Block();
        await _db.SaveChangesAsync();
        return true;
    }
}
