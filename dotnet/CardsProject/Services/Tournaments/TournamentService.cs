using Microsoft.EntityFrameworkCore;
using System.ComponentModel.DataAnnotations;
using CardsProject.Controllers.Tournaments;
using CardsProject.Domain.Tournaments;
using CardsProject.Infrastructure;

namespace CardsProject.Services.Tournaments;

public class TournamentService
{
    private readonly AppDbContext _db;

    public TournamentService(AppDbContext db) => _db = db;

    private static void ValidateEntity(object entity)
    {
        var ctx = new ValidationContext(entity);
        Validator.ValidateObject(entity, ctx, validateAllProperties: true);
    }

    public async Task<List<Tournament>> GetAllAsync()
        => await _db.Tournaments.AsNoTracking().ToListAsync();

    public async Task<Tournament?> GetByIdAsync(int id)
        => await _db.Tournaments.FindAsync(id);

    public async Task<Tournament> CreateAsync(TournamentDto dto)
    {
        var entity = new Tournament();
        if (dto.Name is not null) entity.Name = dto.Name;
        if (dto.Description is not null) entity.Description = dto.Description;
        if (dto.Format is not null && Enum.TryParse<TournamentFormatType>(dto.Format, out var formatVal)) entity.Format = formatVal;
        if (dto.TournamentType is not null && Enum.TryParse<TournamentTournamentTypeType>(dto.TournamentType, out var tournamentTypeVal)) entity.TournamentType = tournamentTypeVal;
        if (dto.Status is not null && Enum.TryParse<TournamentStatusType>(dto.Status, out var statusVal)) entity.Status = statusVal;
        if (dto.MaxPlayers is not null) entity.MaxPlayers = dto.MaxPlayers.Value;
        if (dto.EntryFee is not null) entity.EntryFee = dto.EntryFee.Value;
        if (dto.PrizePool is not null) entity.PrizePool = dto.PrizePool.Value;
        if (dto.StartTime is not null) entity.StartTime = dto.StartTime.Value;
        if (dto.EndTime is not null) entity.EndTime = dto.EndTime.Value;
        if (dto.IsOnline is not null) entity.IsOnline = dto.IsOnline.Value;
        if (dto.Location is not null) entity.Location = dto.Location;
        if (dto.RulesText is not null) entity.RulesText = dto.RulesText;
        if (dto.CreatedAt is not null) entity.CreatedAt = dto.CreatedAt.Value;
        if (dto.SeasonId is not null) entity.SeasonId = dto.SeasonId;
        if (dto.OrganizerId is not null) entity.OrganizerId = dto.OrganizerId;
        Validate(entity);
        ValidateEntity(entity);
        _db.Tournaments.Add(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async Task<Tournament?> UpdateAsync(int id, TournamentDto dto)
    {
        var entity = await _db.Tournaments.FindAsync(id);
        if (entity is null) return null;
        if (dto.Name is not null) entity.Name = dto.Name;
        if (dto.Description is not null) entity.Description = dto.Description;
        if (dto.Format is not null && Enum.TryParse<TournamentFormatType>(dto.Format, out var formatVal)) entity.Format = formatVal;
        if (dto.TournamentType is not null && Enum.TryParse<TournamentTournamentTypeType>(dto.TournamentType, out var tournamentTypeVal)) entity.TournamentType = tournamentTypeVal;
        if (dto.Status is not null && Enum.TryParse<TournamentStatusType>(dto.Status, out var statusVal)) entity.Status = statusVal;
        if (dto.MaxPlayers is not null) entity.MaxPlayers = dto.MaxPlayers.Value;
        if (dto.EntryFee is not null) entity.EntryFee = dto.EntryFee.Value;
        if (dto.PrizePool is not null) entity.PrizePool = dto.PrizePool.Value;
        if (dto.StartTime is not null) entity.StartTime = dto.StartTime.Value;
        if (dto.EndTime is not null) entity.EndTime = dto.EndTime.Value;
        if (dto.IsOnline is not null) entity.IsOnline = dto.IsOnline.Value;
        if (dto.Location is not null) entity.Location = dto.Location;
        if (dto.RulesText is not null) entity.RulesText = dto.RulesText;
        if (dto.CreatedAt is not null) entity.CreatedAt = dto.CreatedAt.Value;
        if (dto.SeasonId is not null) entity.SeasonId = dto.SeasonId;
        if (dto.OrganizerId is not null) entity.OrganizerId = dto.OrganizerId;
        Validate(entity);
        ValidateEntity(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async Task<bool> DeleteAsync(int id)
    {
        var entity = await _db.Tournaments.FindAsync(id);
        if (entity is null) return false;
        _db.Tournaments.Remove(entity);
        await _db.SaveChangesAsync();
        return true;
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
    public async System.Threading.Tasks.Task<bool> RegisterPlayerAsync(int id, int playerId, int deckId)
    {
        var entity = await _db.Tournaments.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("Tournament not found: " + id);
        entity.RegisterPlayer(playerId, deckId);
        await _db.SaveChangesAsync();
        return true;
    }
    public async System.Threading.Tasks.Task<bool> IsFullAsync(int id)
    {
        var entity = await _db.Tournaments.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("Tournament not found: " + id);
        var result = entity.IsFull();
        await _db.SaveChangesAsync();
        return result;
    }
    public void Validate(Tournament entity)
    {
        if (entity.EndTime != null && !((entity.EndTime == null || (entity.StartTime != null && entity.EndTime > entity.StartTime)))) throw new InvalidOperationException("End time must be after start time");
    }
}
