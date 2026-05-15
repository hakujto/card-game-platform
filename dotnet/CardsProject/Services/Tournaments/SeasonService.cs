using Microsoft.EntityFrameworkCore;
using System.ComponentModel.DataAnnotations;
using CardsProject.Controllers.Tournaments;
using CardsProject.Domain.Tournaments;
using CardsProject.Infrastructure;

namespace CardsProject.Services.Tournaments;

public class SeasonService
{
    private readonly AppDbContext _db;

    public SeasonService(AppDbContext db) => _db = db;

    private static void ValidateEntity(object entity)
    {
        var ctx = new ValidationContext(entity);
        Validator.ValidateObject(entity, ctx, validateAllProperties: true);
    }

    public async Task<List<Season>> GetAllAsync()
        => await _db.Seasons.AsNoTracking().ToListAsync();

    public async Task<Season?> GetByIdAsync(int id)
        => await _db.Seasons.FindAsync(id);

    public async Task<Season> CreateAsync(SeasonDto dto)
    {
        var entity = new Season();
        if (dto.Name is not null) entity.Name = dto.Name;
        if (dto.StartDate is not null) entity.StartDate = dto.StartDate.Value;
        if (dto.EndDate is not null) entity.EndDate = dto.EndDate.Value;
        if (dto.Format is not null && Enum.TryParse<SeasonFormatType>(dto.Format, out var formatVal)) entity.Format = formatVal;
        if (dto.IsActive is not null) entity.IsActive = dto.IsActive.Value;
        if (dto.RewardDescription is not null) entity.RewardDescription = dto.RewardDescription;
        ValidateEntity(entity);
        _db.Seasons.Add(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async Task<Season?> UpdateAsync(int id, SeasonDto dto)
    {
        var entity = await _db.Seasons.FindAsync(id);
        if (entity is null) return null;
        if (dto.Name is not null) entity.Name = dto.Name;
        if (dto.StartDate is not null) entity.StartDate = dto.StartDate.Value;
        if (dto.EndDate is not null) entity.EndDate = dto.EndDate.Value;
        if (dto.Format is not null && Enum.TryParse<SeasonFormatType>(dto.Format, out var formatVal)) entity.Format = formatVal;
        if (dto.IsActive is not null) entity.IsActive = dto.IsActive.Value;
        if (dto.RewardDescription is not null) entity.RewardDescription = dto.RewardDescription;
        ValidateEntity(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async Task<bool> DeleteAsync(int id)
    {
        var entity = await _db.Seasons.FindAsync(id);
        if (entity is null) return false;
        _db.Seasons.Remove(entity);
        await _db.SaveChangesAsync();
        return true;
    }

    public async System.Threading.Tasks.Task<bool> ActivateAsync(int id)
    {
        var entity = await _db.Seasons.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("Season not found: " + id);
        entity.Activate();
        await _db.SaveChangesAsync();
        return true;
    }
    public async System.Threading.Tasks.Task<bool> DeactivateAsync(int id)
    {
        var entity = await _db.Seasons.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("Season not found: " + id);
        entity.Deactivate();
        await _db.SaveChangesAsync();
        return true;
    }
    public async System.Threading.Tasks.Task<bool> FinalizeRewardsAsync(int id)
    {
        var entity = await _db.Seasons.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("Season not found: " + id);
        entity.FinalizeRewards();
        await _db.SaveChangesAsync();
        return true;
    }
}
