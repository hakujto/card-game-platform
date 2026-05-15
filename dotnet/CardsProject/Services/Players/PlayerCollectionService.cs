using Microsoft.EntityFrameworkCore;
using System.ComponentModel.DataAnnotations;
using CardsProject.Controllers.Players;
using CardsProject.Domain.Players;
using CardsProject.Infrastructure;

namespace CardsProject.Services.Players;

public class PlayerCollectionService
{
    private readonly AppDbContext _db;

    public PlayerCollectionService(AppDbContext db) => _db = db;

    private static void ValidateEntity(object entity)
    {
        var ctx = new ValidationContext(entity);
        Validator.ValidateObject(entity, ctx, validateAllProperties: true);
    }

    public async Task<List<PlayerCollection>> GetAllAsync()
        => await _db.PlayerCollections.AsNoTracking().ToListAsync();

    public async Task<PlayerCollection?> GetByIdAsync(int id)
        => await _db.PlayerCollections.FindAsync(id);

    public async Task<PlayerCollection> CreateAsync(PlayerCollectionDto dto)
    {
        var entity = new PlayerCollection();
        if (dto.Quantity is not null) entity.Quantity = dto.Quantity.Value;
        if (dto.Foil is not null) entity.Foil = dto.Foil.Value;
        if (dto.Condition is not null && Enum.TryParse<PlayerCollectionConditionType>(dto.Condition, out var conditionVal)) entity.Condition = conditionVal;
        if (dto.AcquiredAt is not null) entity.AcquiredAt = dto.AcquiredAt.Value;
        if (dto.AcquiredVia is not null && Enum.TryParse<PlayerCollectionAcquiredViaType>(dto.AcquiredVia, out var acquiredViaVal)) entity.AcquiredVia = acquiredViaVal;
        if (dto.PlayerId is not null) entity.PlayerId = dto.PlayerId;
        if (dto.CardId is not null) entity.CardId = dto.CardId;
        ValidateEntity(entity);
        _db.PlayerCollections.Add(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async Task<PlayerCollection?> UpdateAsync(int id, PlayerCollectionDto dto)
    {
        var entity = await _db.PlayerCollections.FindAsync(id);
        if (entity is null) return null;
        if (dto.Quantity is not null) entity.Quantity = dto.Quantity.Value;
        if (dto.Foil is not null) entity.Foil = dto.Foil.Value;
        if (dto.Condition is not null && Enum.TryParse<PlayerCollectionConditionType>(dto.Condition, out var conditionVal)) entity.Condition = conditionVal;
        if (dto.AcquiredAt is not null) entity.AcquiredAt = dto.AcquiredAt.Value;
        if (dto.AcquiredVia is not null && Enum.TryParse<PlayerCollectionAcquiredViaType>(dto.AcquiredVia, out var acquiredViaVal)) entity.AcquiredVia = acquiredViaVal;
        if (dto.PlayerId is not null) entity.PlayerId = dto.PlayerId;
        if (dto.CardId is not null) entity.CardId = dto.CardId;
        ValidateEntity(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async Task<bool> DeleteAsync(int id)
    {
        var entity = await _db.PlayerCollections.FindAsync(id);
        if (entity is null) return false;
        _db.PlayerCollections.Remove(entity);
        await _db.SaveChangesAsync();
        return true;
    }

    public async System.Threading.Tasks.Task<decimal> EstimatedValueAsync(int id)
    {
        var entity = await _db.PlayerCollections.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("PlayerCollection not found: " + id);
        var result = entity.EstimatedValue();
        await _db.SaveChangesAsync();
        return result;
    }
}
