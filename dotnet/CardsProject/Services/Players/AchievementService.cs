using Microsoft.EntityFrameworkCore;
using System.ComponentModel.DataAnnotations;
using CardsProject.Controllers.Players;
using CardsProject.Domain.Players;
using CardsProject.Infrastructure;

namespace CardsProject.Services.Players;

public class AchievementService
{
    private readonly AppDbContext _db;

    public AchievementService(AppDbContext db) => _db = db;

    private static void ValidateEntity(object entity)
    {
        var ctx = new ValidationContext(entity);
        Validator.ValidateObject(entity, ctx, validateAllProperties: true);
    }

    public async Task<List<Achievement>> GetAllAsync()
        => await _db.Achievements.AsNoTracking().ToListAsync();

    public async Task<Achievement?> GetByIdAsync(int id)
        => await _db.Achievements.FindAsync(id);

    public async Task<Achievement> CreateAsync(AchievementDto dto)
    {
        var entity = new Achievement();
        if (dto.Name is not null) entity.Name = dto.Name;
        if (dto.Description is not null) entity.Description = dto.Description;
        if (dto.IconUrl is not null) entity.IconUrl = dto.IconUrl;
        if (dto.Points is not null) entity.Points = dto.Points.Value;
        if (dto.Rarity is not null && Enum.TryParse<AchievementRarityType>(dto.Rarity, out var rarityVal)) entity.Rarity = rarityVal;
        if (dto.IsHidden is not null) entity.IsHidden = dto.IsHidden.Value;
        ValidateEntity(entity);
        _db.Achievements.Add(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async Task<Achievement?> UpdateAsync(int id, AchievementDto dto)
    {
        var entity = await _db.Achievements.FindAsync(id);
        if (entity is null) return null;
        if (dto.Name is not null) entity.Name = dto.Name;
        if (dto.Description is not null) entity.Description = dto.Description;
        if (dto.IconUrl is not null) entity.IconUrl = dto.IconUrl;
        if (dto.Points is not null) entity.Points = dto.Points.Value;
        if (dto.Rarity is not null && Enum.TryParse<AchievementRarityType>(dto.Rarity, out var rarityVal)) entity.Rarity = rarityVal;
        if (dto.IsHidden is not null) entity.IsHidden = dto.IsHidden.Value;
        ValidateEntity(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async Task<bool> DeleteAsync(int id)
    {
        var entity = await _db.Achievements.FindAsync(id);
        if (entity is null) return false;
        _db.Achievements.Remove(entity);
        await _db.SaveChangesAsync();
        return true;
    }

}
