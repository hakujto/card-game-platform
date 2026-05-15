using CardsProject.Domain.Tournaments;
using CardsProject.Infrastructure;

namespace CardsProject.Services.Tournaments;

public class TournamentService
{
    private readonly AppDbContext _db;

    public TournamentService(AppDbContext db) => _db = db;

    public async System.Threading.Tasks.Task<Tournament> CreateAsync(Tournament entity)
    {
        _db.Tournaments.Add(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async System.Threading.Tasks.Task<Tournament> UpdateAsync(Tournament entity)
    {
        _db.Tournaments.Update(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async System.Threading.Tasks.Task<bool> StartAsync(int id)
    {
        var entity = await _db.Tournaments.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("Tournament not found: " + id);
        entity.Start();
        await _db.SaveChangesAsync();
        return true;
    }
    public async System.Threading.Tasks.Task<bool> CancelAsync(int id)
    {
        var entity = await _db.Tournaments.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("Tournament not found: " + id);
        entity.Cancel();
        await _db.SaveChangesAsync();
        return true;
    }
    public async System.Threading.Tasks.Task<bool> CompleteAsync(int id)
    {
        var entity = await _db.Tournaments.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("Tournament not found: " + id);
        entity.Complete();
        await _db.SaveChangesAsync();
        return true;
    }
    public async System.Threading.Tasks.Task<bool> GenerateRoundAsync(int id)
    {
        var entity = await _db.Tournaments.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("Tournament not found: " + id);
        entity.GenerateRound();
        await _db.SaveChangesAsync();
        return true;
    }
    public async System.Threading.Tasks.Task<decimal> CalculatePrizeDistributionAsync(int id)
    {
        var entity = await _db.Tournaments.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("Tournament not found: " + id);
        var result = entity.CalculatePrizeDistribution();
        await _db.SaveChangesAsync();
        return result;
    }
    public void Validate(Tournament entity)
    {
        if (entity.EndTime != null && !((entity.EndTime == null || (entity.StartTime != null && entity.EndTime > entity.StartTime)))) throw new InvalidOperationException("End time must be after start time");
    }
}
