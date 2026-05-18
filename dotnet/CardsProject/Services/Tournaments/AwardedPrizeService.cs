using Microsoft.EntityFrameworkCore;
using System.ComponentModel.DataAnnotations;
using CardsProject.Controllers.Tournaments;
using CardsProject.Domain.Tournaments;
using CardsProject.Infrastructure;

namespace CardsProject.Services.Tournaments;

public class AwardedPrizeService
{
    private readonly AppDbContext _db;

    public AwardedPrizeService(AppDbContext db) => _db = db;

    private static void ValidateEntity(object entity)
    {
        var ctx = new ValidationContext(entity);
        Validator.ValidateObject(entity, ctx, validateAllProperties: true);
    }

    public async Task<List<AwardedPrize>> GetAllAsync()
        => await _db.AwardedPrizes.AsNoTracking().ToListAsync();

    public async Task<AwardedPrize?> GetByIdAsync(int id)
        => await _db.AwardedPrizes.FindAsync(id);

    public async Task<AwardedPrize> CreateAsync(AwardedPrizeDto dto)
    {
        var entity = new AwardedPrize();
        if (dto.FinalPlacement is not null) entity.FinalPlacement = dto.FinalPlacement.Value;
        if (dto.AwardedAt is not null) entity.AwardedAt = dto.AwardedAt.Value;
        if (dto.Claimed is not null) entity.Claimed = dto.Claimed.Value;
        if (dto.ClaimedAt is not null) entity.ClaimedAt = dto.ClaimedAt.Value;
        if (dto.PrizeId is not null) entity.PrizeId = dto.PrizeId;
        if (dto.PlayerId is not null) entity.PlayerId = dto.PlayerId;
        Validate(entity);
        ValidateEntity(entity);
        _db.AwardedPrizes.Add(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async Task<AwardedPrize?> UpdateAsync(int id, AwardedPrizeDto dto)
    {
        var entity = await _db.AwardedPrizes.FindAsync(id);
        if (entity is null) return null;
        if (dto.FinalPlacement is not null) entity.FinalPlacement = dto.FinalPlacement.Value;
        if (dto.AwardedAt is not null) entity.AwardedAt = dto.AwardedAt.Value;
        if (dto.Claimed is not null) entity.Claimed = dto.Claimed.Value;
        if (dto.ClaimedAt is not null) entity.ClaimedAt = dto.ClaimedAt.Value;
        if (dto.PrizeId is not null) entity.PrizeId = dto.PrizeId;
        if (dto.PlayerId is not null) entity.PlayerId = dto.PlayerId;
        Validate(entity);
        ValidateEntity(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async Task<bool> DeleteAsync(int id)
    {
        var entity = await _db.AwardedPrizes.FindAsync(id);
        if (entity is null) return false;
        _db.AwardedPrizes.Remove(entity);
        await _db.SaveChangesAsync();
        return true;
    }

    public async System.Threading.Tasks.Task<bool> ClaimAsync(int id)
    {
        var entity = await _db.AwardedPrizes.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("AwardedPrize not found: " + id);
        entity.Claim();
        await _db.SaveChangesAsync();
        return true;
    }
    // triggered by @on(claimed = true)
    public async System.Threading.Tasks.Task SetClaimedAsync(int id, bool value)
    {
        var entity = await _db.AwardedPrizes.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("AwardedPrize not found: " + id);
        entity.Claimed = value;
        if (value)
        {
            entity.Claim();
        }
        await _db.SaveChangesAsync();
    }
    public void Validate(AwardedPrize entity)
    {
        if (entity.Claimed == true && entity.ClaimedAt == null) throw new InvalidOperationException("Claimed prize must have a claimed_at timestamp");
    }
}
