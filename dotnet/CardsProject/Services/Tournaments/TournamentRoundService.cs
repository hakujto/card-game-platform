using Microsoft.EntityFrameworkCore;
using System.ComponentModel.DataAnnotations;
using CardsProject.Controllers.Tournaments;
using CardsProject.Domain.Tournaments;
using CardsProject.Infrastructure;

namespace CardsProject.Services.Tournaments;

public class TournamentRoundService
{
    private readonly AppDbContext _db;

    public TournamentRoundService(AppDbContext db) => _db = db;

    private static void ValidateEntity(object entity)
    {
        var ctx = new ValidationContext(entity);
        Validator.ValidateObject(entity, ctx, validateAllProperties: true);
    }

    public async Task<List<TournamentRound>> GetAllAsync()
        => await _db.TournamentRounds.AsNoTracking().ToListAsync();

    public async Task<TournamentRound?> GetByIdAsync(int id)
        => await _db.TournamentRounds.FindAsync(id);

    public async Task<TournamentRound> CreateAsync(TournamentRoundDto dto)
    {
        var entity = new TournamentRound();
        if (dto.RoundNumber is not null) entity.RoundNumber = dto.RoundNumber.Value;
        if (dto.Status is not null && Enum.TryParse<TournamentRoundStatusType>(dto.Status, out var statusVal)) entity.Status = statusVal;
        if (dto.StartedAt is not null) entity.StartedAt = dto.StartedAt.Value;
        if (dto.EndedAt is not null) entity.EndedAt = dto.EndedAt.Value;
        if (dto.TimeLimitMinutes is not null) entity.TimeLimitMinutes = dto.TimeLimitMinutes.Value;
        if (dto.TournamentId is not null) entity.TournamentId = dto.TournamentId;
        Validate(entity);
        ValidateEntity(entity);
        _db.TournamentRounds.Add(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async Task<TournamentRound?> UpdateAsync(int id, TournamentRoundDto dto)
    {
        var entity = await _db.TournamentRounds.FindAsync(id);
        if (entity is null) return null;
        if (dto.RoundNumber is not null) entity.RoundNumber = dto.RoundNumber.Value;
        if (dto.Status is not null && Enum.TryParse<TournamentRoundStatusType>(dto.Status, out var statusVal)) entity.Status = statusVal;
        if (dto.StartedAt is not null) entity.StartedAt = dto.StartedAt.Value;
        if (dto.EndedAt is not null) entity.EndedAt = dto.EndedAt.Value;
        if (dto.TimeLimitMinutes is not null) entity.TimeLimitMinutes = dto.TimeLimitMinutes.Value;
        if (dto.TournamentId is not null) entity.TournamentId = dto.TournamentId;
        Validate(entity);
        ValidateEntity(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async Task<bool> DeleteAsync(int id)
    {
        var entity = await _db.TournamentRounds.FindAsync(id);
        if (entity is null) return false;
        _db.TournamentRounds.Remove(entity);
        await _db.SaveChangesAsync();
        return true;
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
    public async System.Threading.Tasks.Task<bool> IsTimeExpiredAsync(int id)
    {
        var entity = await _db.TournamentRounds.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("TournamentRound not found: " + id);
        var result = entity.IsTimeExpired();
        await _db.SaveChangesAsync();
        return result;
    }
    public void Validate(TournamentRound entity)
    {
        if (entity.EndedAt != null && !((entity.EndedAt == null || (entity.StartedAt != null && entity.EndedAt > entity.StartedAt)))) throw new InvalidOperationException("Round end time must be after start time");
        if (entity.Status == TournamentRoundStatusType.Completed && entity.StartedAt == null) throw new InvalidOperationException("Completed round must have a start time");
    }
}
