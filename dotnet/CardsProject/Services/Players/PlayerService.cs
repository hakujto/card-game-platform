using Microsoft.EntityFrameworkCore;
using System.ComponentModel.DataAnnotations;
using CardsProject.Controllers.Players;
using CardsProject.Domain.Players;
using CardsProject.Infrastructure;

namespace CardsProject.Services.Players;

public class PlayerService
{
    private readonly AppDbContext _db;

    public PlayerService(AppDbContext db) => _db = db;

    private static void ValidateEntity(object entity)
    {
        var ctx = new ValidationContext(entity);
        Validator.ValidateObject(entity, ctx, validateAllProperties: true);
    }

    public async Task<List<Player>> GetAllAsync()
        => await _db.Players.AsNoTracking().ToListAsync();

    public async Task<Player?> GetByIdAsync(int id)
        => await _db.Players.FindAsync(id);

    public async Task<Player> CreateAsync(PlayerDto dto)
    {
        var entity = new Player();
        if (dto.DisplayName is not null) entity.DisplayName = dto.DisplayName;
        if (dto.Rank is not null && Enum.TryParse<PlayerRankType>(dto.Rank, out var rankVal)) entity.Rank = rankVal;
        if (dto.Rating is not null) entity.Rating = dto.Rating.Value;
        if (dto.PeakRating is not null) entity.PeakRating = dto.PeakRating.Value;
        if (dto.Bio is not null) entity.Bio = dto.Bio;
        if (dto.CountryCode is not null) entity.CountryCode = dto.CountryCode;
        if (dto.AvatarUrl is not null) entity.AvatarUrl = dto.AvatarUrl;
        if (dto.PreferredFormat is not null && Enum.TryParse<PlayerPreferredFormatType>(dto.PreferredFormat, out var preferredFormatVal)) entity.PreferredFormat = preferredFormatVal;
        if (dto.IsVerified is not null) entity.IsVerified = dto.IsVerified.Value;
        if (dto.CreatedAt is not null) entity.CreatedAt = dto.CreatedAt.Value;
        if (dto.LastActiveAt is not null) entity.LastActiveAt = dto.LastActiveAt.Value;
        if (dto.UserId is not null) entity.UserId = dto.UserId;
        ValidateEntity(entity);
        _db.Players.Add(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async Task<Player?> UpdateAsync(int id, PlayerDto dto)
    {
        var entity = await _db.Players.FindAsync(id);
        if (entity is null) return null;
        if (dto.DisplayName is not null) entity.DisplayName = dto.DisplayName;
        if (dto.Rank is not null && Enum.TryParse<PlayerRankType>(dto.Rank, out var rankVal)) entity.Rank = rankVal;
        if (dto.Rating is not null) entity.Rating = dto.Rating.Value;
        if (dto.PeakRating is not null) entity.PeakRating = dto.PeakRating.Value;
        if (dto.Bio is not null) entity.Bio = dto.Bio;
        if (dto.CountryCode is not null) entity.CountryCode = dto.CountryCode;
        if (dto.AvatarUrl is not null) entity.AvatarUrl = dto.AvatarUrl;
        if (dto.PreferredFormat is not null && Enum.TryParse<PlayerPreferredFormatType>(dto.PreferredFormat, out var preferredFormatVal)) entity.PreferredFormat = preferredFormatVal;
        if (dto.IsVerified is not null) entity.IsVerified = dto.IsVerified.Value;
        if (dto.CreatedAt is not null) entity.CreatedAt = dto.CreatedAt.Value;
        if (dto.LastActiveAt is not null) entity.LastActiveAt = dto.LastActiveAt.Value;
        if (dto.UserId is not null) entity.UserId = dto.UserId;
        ValidateEntity(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async Task<bool> DeleteAsync(int id)
    {
        var entity = await _db.Players.FindAsync(id);
        if (entity is null) return false;
        _db.Players.Remove(entity);
        await _db.SaveChangesAsync();
        return true;
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
