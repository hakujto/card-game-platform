using CardsProject.Domain.Tournaments;
using CardsProject.Infrastructure;

namespace CardsProject.Services.Tournaments;

public class TournamentRoundService
{
    private readonly AppDbContext _db;

    public TournamentRoundService(AppDbContext db) => _db = db;

    public async System.Threading.Tasks.Task<TournamentRound> CreateAsync(TournamentRound entity)
    {
        _db.TournamentRounds.Add(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async System.Threading.Tasks.Task<TournamentRound> UpdateAsync(TournamentRound entity)
    {
        _db.TournamentRounds.Update(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async System.Threading.Tasks.Task<bool> StartAsync(int id)
    {
        var entity = await _db.TournamentRounds.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("TournamentRound not found: " + id);
        entity.Start();
        await _db.SaveChangesAsync();
        return true;
    }
    public async System.Threading.Tasks.Task<bool> CompleteAsync(int id)
    {
        var entity = await _db.TournamentRounds.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("TournamentRound not found: " + id);
        entity.Complete();
        await _db.SaveChangesAsync();
        return true;
    }
    public async System.Threading.Tasks.Task<bool> GeneratePairingsAsync(int id)
    {
        var entity = await _db.TournamentRounds.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("TournamentRound not found: " + id);
        entity.GeneratePairings();
        await _db.SaveChangesAsync();
        return true;
    }
    public void Validate(TournamentRound entity)
    {
        if (entity.EndedAt != null && !((entity.EndedAt == null || (entity.StartedAt != null && entity.EndedAt > entity.StartedAt)))) throw new InvalidOperationException("Round end time must be after start time");
    }
}
