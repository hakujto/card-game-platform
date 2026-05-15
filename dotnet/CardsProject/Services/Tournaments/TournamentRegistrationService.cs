using Microsoft.EntityFrameworkCore;
using System.ComponentModel.DataAnnotations;
using CardsProject.Controllers.Tournaments;
using CardsProject.Domain.Tournaments;
using CardsProject.Infrastructure;

namespace CardsProject.Services.Tournaments;

public class TournamentRegistrationService
{
    private readonly AppDbContext _db;

    public TournamentRegistrationService(AppDbContext db) => _db = db;

    private static void ValidateEntity(object entity)
    {
        var ctx = new ValidationContext(entity);
        Validator.ValidateObject(entity, ctx, validateAllProperties: true);
    }

    public async Task<List<TournamentRegistration>> GetAllAsync()
        => await _db.TournamentRegistrations.AsNoTracking().ToListAsync();

    public async Task<TournamentRegistration?> GetByIdAsync(int id)
        => await _db.TournamentRegistrations.FindAsync(id);

    public async Task<TournamentRegistration> CreateAsync(TournamentRegistrationDto dto)
    {
        var entity = new TournamentRegistration();
        if (dto.Status is not null && Enum.TryParse<TournamentRegistrationStatusType>(dto.Status, out var statusVal)) entity.Status = statusVal;
        if (dto.Seed is not null) entity.Seed = dto.Seed.Value;
        if (dto.FinalStanding is not null) entity.FinalStanding = dto.FinalStanding.Value;
        if (dto.PointsEarned is not null) entity.PointsEarned = dto.PointsEarned.Value;
        if (dto.RegisteredAt is not null) entity.RegisteredAt = dto.RegisteredAt.Value;
        if (dto.TournamentId is not null) entity.TournamentId = dto.TournamentId;
        if (dto.PlayerId is not null) entity.PlayerId = dto.PlayerId;
        if (dto.DeckId is not null) entity.DeckId = dto.DeckId;
        ValidateEntity(entity);
        _db.TournamentRegistrations.Add(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async Task<TournamentRegistration?> UpdateAsync(int id, TournamentRegistrationDto dto)
    {
        var entity = await _db.TournamentRegistrations.FindAsync(id);
        if (entity is null) return null;
        if (dto.Status is not null && Enum.TryParse<TournamentRegistrationStatusType>(dto.Status, out var statusVal)) entity.Status = statusVal;
        if (dto.Seed is not null) entity.Seed = dto.Seed.Value;
        if (dto.FinalStanding is not null) entity.FinalStanding = dto.FinalStanding.Value;
        if (dto.PointsEarned is not null) entity.PointsEarned = dto.PointsEarned.Value;
        if (dto.RegisteredAt is not null) entity.RegisteredAt = dto.RegisteredAt.Value;
        if (dto.TournamentId is not null) entity.TournamentId = dto.TournamentId;
        if (dto.PlayerId is not null) entity.PlayerId = dto.PlayerId;
        if (dto.DeckId is not null) entity.DeckId = dto.DeckId;
        ValidateEntity(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async Task<bool> DeleteAsync(int id)
    {
        var entity = await _db.TournamentRegistrations.FindAsync(id);
        if (entity is null) return false;
        _db.TournamentRegistrations.Remove(entity);
        await _db.SaveChangesAsync();
        return true;
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
