using CardsProject.Domain.Players;
using CardsProject.Infrastructure;

namespace CardsProject.Services.Players;

public class PlayerService
{
    private readonly AppDbContext _db;

    public PlayerService(AppDbContext db) => _db = db;

    public async System.Threading.Tasks.Task<Player> CreateAsync(Player entity)
    {
        _db.Players.Add(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async System.Threading.Tasks.Task<Player> UpdateAsync(Player entity)
    {
        _db.Players.Update(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async System.Threading.Tasks.Task<bool> PromoteAsync(int id)
    {
        var entity = await _db.Players.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("Player not found: " + id);
        var result = entity.Promote();
        await _db.SaveChangesAsync();
        return result;
    }
    public async System.Threading.Tasks.Task<bool> DemoteAsync(int id)
    {
        var entity = await _db.Players.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("Player not found: " + id);
        var result = entity.Demote();
        await _db.SaveChangesAsync();
        return result;
    }
    public async System.Threading.Tasks.Task<bool> RecordWinAsync(int id)
    {
        var entity = await _db.Players.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("Player not found: " + id);
        entity.RecordWin();
        await _db.SaveChangesAsync();
        return true;
    }
    public async System.Threading.Tasks.Task<bool> RecordLossAsync(int id)
    {
        var entity = await _db.Players.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("Player not found: " + id);
        entity.RecordLoss();
        await _db.SaveChangesAsync();
        return true;
    }
    public async System.Threading.Tasks.Task<decimal> WinRateAsync(int id)
    {
        var entity = await _db.Players.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("Player not found: " + id);
        var result = entity.WinRate();
        await _db.SaveChangesAsync();
        return result;
    }
    public async System.Threading.Tasks.Task<bool> VerifyAsync(int id)
    {
        var entity = await _db.Players.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("Player not found: " + id);
        entity.Verify();
        await _db.SaveChangesAsync();
        return true;
    }
    public async System.Threading.Tasks.Task<bool> UpdateRatingAsync(int id, int delta)
    {
        var entity = await _db.Players.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("Player not found: " + id);
        entity.UpdateRating(delta);
        await _db.SaveChangesAsync();
        return true;
    }
}
