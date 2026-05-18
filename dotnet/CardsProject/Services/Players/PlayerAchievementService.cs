using Microsoft.EntityFrameworkCore;
using System.ComponentModel.DataAnnotations;
using CardsProject.Controllers.Players;
using CardsProject.Domain.Players;
using CardsProject.Infrastructure;

namespace CardsProject.Services.Players;

public class PlayerAchievementService
{
    private readonly AppDbContext _db;

    public PlayerAchievementService(AppDbContext db) => _db = db;

    private static void ValidateEntity(object entity)
    {
        var ctx = new ValidationContext(entity);
        Validator.ValidateObject(entity, ctx, validateAllProperties: true);
    }

    public async Task<List<PlayerAchievement>> GetAllAsync()
        => await _db.PlayerAchievements.AsNoTracking().ToListAsync();

    public async Task<PlayerAchievement?> GetByIdAsync(int id)
        => await _db.PlayerAchievements.FindAsync(id);

    public async Task<PlayerAchievement> CreateAsync(PlayerAchievementDto dto)
    {
        var entity = new PlayerAchievement();
        if (dto.EarnedAt is not null) entity.EarnedAt = dto.EarnedAt.Value;
        if (dto.Progress is not null) entity.Progress = dto.Progress.Value;
        if (dto.IsCompleted is not null) entity.IsCompleted = dto.IsCompleted.Value;
        if (dto.PlayerId is not null) entity.PlayerId = dto.PlayerId;
        if (dto.AchievementId is not null) entity.AchievementId = dto.AchievementId;
        Validate(entity);
        ValidateEntity(entity);
        _db.PlayerAchievements.Add(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async Task<PlayerAchievement?> UpdateAsync(int id, PlayerAchievementDto dto)
    {
        var entity = await _db.PlayerAchievements.FindAsync(id);
        if (entity is null) return null;
        if (dto.EarnedAt is not null) entity.EarnedAt = dto.EarnedAt.Value;
        if (dto.Progress is not null) entity.Progress = dto.Progress.Value;
        if (dto.IsCompleted is not null) entity.IsCompleted = dto.IsCompleted.Value;
        if (dto.PlayerId is not null) entity.PlayerId = dto.PlayerId;
        if (dto.AchievementId is not null) entity.AchievementId = dto.AchievementId;
        Validate(entity);
        ValidateEntity(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async Task<bool> DeleteAsync(int id)
    {
        var entity = await _db.PlayerAchievements.FindAsync(id);
        if (entity is null) return false;
        _db.PlayerAchievements.Remove(entity);
        await _db.SaveChangesAsync();
        return true;
    }

    public async System.Threading.Tasks.Task<bool> IncrementProgressAsync(int id, int amount)
    {
        var entity = await _db.PlayerAchievements.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("PlayerAchievement not found: " + id);
        entity.IncrementProgress(amount);
        await _db.SaveChangesAsync();
        return true;
    }
    public async System.Threading.Tasks.Task<bool> CompleteAsync(int id)
    {
        var entity = await _db.PlayerAchievements.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("PlayerAchievement not found: " + id);
        entity.Complete();
        await _db.SaveChangesAsync();
        return true;
    }
    // triggered by @on(is_completed = true)
    public async System.Threading.Tasks.Task SetIsCompletedAsync(int id, bool value)
    {
        var entity = await _db.PlayerAchievements.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("PlayerAchievement not found: " + id);
        entity.IsCompleted = value;
        if (value)
        {
            entity.Complete();
        }
        await _db.SaveChangesAsync();
    }
    public void Validate(PlayerAchievement entity)
    {
        if (entity.IsCompleted == true && !(entity.Progress > 0)) throw new InvalidOperationException("Completed achievement must have progress greater than zero");
    }
}
