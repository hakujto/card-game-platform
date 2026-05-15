using CardsProject.Domain.Tournaments;
using CardsProject.Infrastructure;

namespace CardsProject.Services.Tournaments;

public class TournamentRegistrationService
{
    private readonly AppDbContext _db;

    public TournamentRegistrationService(AppDbContext db) => _db = db;

    public async System.Threading.Tasks.Task<TournamentRegistration> CreateAsync(TournamentRegistration entity)
    {
        _db.TournamentRegistrations.Add(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async System.Threading.Tasks.Task<TournamentRegistration> UpdateAsync(TournamentRegistration entity)
    {
        _db.TournamentRegistrations.Update(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async System.Threading.Tasks.Task<bool> WithdrawAsync(int id)
    {
        var entity = await _db.TournamentRegistrations.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("TournamentRegistration not found: " + id);
        entity.Withdraw();
        await _db.SaveChangesAsync();
        return true;
    }
    public async System.Threading.Tasks.Task<bool> DisqualifyAsync(int id, string reason)
    {
        var entity = await _db.TournamentRegistrations.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("TournamentRegistration not found: " + id);
        entity.Disqualify(reason);
        await _db.SaveChangesAsync();
        return true;
    }
    public async System.Threading.Tasks.Task<bool> PromoteFromWaitlistAsync(int id)
    {
        var entity = await _db.TournamentRegistrations.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("TournamentRegistration not found: " + id);
        entity.PromoteFromWaitlist();
        await _db.SaveChangesAsync();
        return true;
    }
}
