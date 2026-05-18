using Microsoft.EntityFrameworkCore;
using System.ComponentModel.DataAnnotations;
using CardsProject.Controllers.Marketplace;
using CardsProject.Domain.Marketplace;
using CardsProject.Infrastructure;

namespace CardsProject.Services.Marketplace;

public class CouponService
{
    private readonly AppDbContext _db;

    public CouponService(AppDbContext db) => _db = db;

    private static void ValidateEntity(object entity)
    {
        var ctx = new ValidationContext(entity);
        Validator.ValidateObject(entity, ctx, validateAllProperties: true);
    }

    public async Task<List<Coupon>> GetAllAsync()
        => await _db.Coupons.AsNoTracking().ToListAsync();

    public async Task<Coupon?> GetByIdAsync(int id)
        => await _db.Coupons.FindAsync(id);

    public async Task<Coupon> CreateAsync(CouponDto dto)
    {
        var entity = new Coupon();
        if (dto.Code is not null) entity.Code = dto.Code;
        if (dto.DiscountType is not null && Enum.TryParse<CouponDiscountTypeType>(dto.DiscountType, out var discountTypeVal)) entity.DiscountType = discountTypeVal;
        if (dto.DiscountValue is not null) entity.DiscountValue = dto.DiscountValue.Value;
        if (dto.MinOrderValue is not null) entity.MinOrderValue = dto.MinOrderValue.Value;
        if (dto.MaxUses is not null) entity.MaxUses = dto.MaxUses.Value;
        if (dto.UsesCount is not null) entity.UsesCount = dto.UsesCount.Value;
        if (dto.ValidFrom is not null) entity.ValidFrom = dto.ValidFrom.Value;
        if (dto.ValidUntil is not null) entity.ValidUntil = dto.ValidUntil.Value;
        if (dto.IsActive is not null) entity.IsActive = dto.IsActive.Value;
        Validate(entity);
        ValidateEntity(entity);
        _db.Coupons.Add(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async Task<Coupon?> UpdateAsync(int id, CouponDto dto)
    {
        var entity = await _db.Coupons.FindAsync(id);
        if (entity is null) return null;
        if (dto.Code is not null) entity.Code = dto.Code;
        if (dto.DiscountType is not null && Enum.TryParse<CouponDiscountTypeType>(dto.DiscountType, out var discountTypeVal)) entity.DiscountType = discountTypeVal;
        if (dto.DiscountValue is not null) entity.DiscountValue = dto.DiscountValue.Value;
        if (dto.MinOrderValue is not null) entity.MinOrderValue = dto.MinOrderValue.Value;
        if (dto.MaxUses is not null) entity.MaxUses = dto.MaxUses.Value;
        if (dto.UsesCount is not null) entity.UsesCount = dto.UsesCount.Value;
        if (dto.ValidFrom is not null) entity.ValidFrom = dto.ValidFrom.Value;
        if (dto.ValidUntil is not null) entity.ValidUntil = dto.ValidUntil.Value;
        if (dto.IsActive is not null) entity.IsActive = dto.IsActive.Value;
        Validate(entity);
        ValidateEntity(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async Task<bool> DeleteAsync(int id)
    {
        var entity = await _db.Coupons.FindAsync(id);
        if (entity is null) return false;
        _db.Coupons.Remove(entity);
        await _db.SaveChangesAsync();
        return true;
    }

    public async System.Threading.Tasks.Task<bool> IsValidAsync(int id)
    {
        var entity = await _db.Coupons.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("Coupon not found: " + id);
        var result = entity.IsValid();
        await _db.SaveChangesAsync();
        return result;
    }
    public async System.Threading.Tasks.Task<bool> IsApplicableToOrderAsync(int id, decimal orderTotal)
    {
        var entity = await _db.Coupons.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("Coupon not found: " + id);
        var result = entity.IsApplicableToOrder(orderTotal);
        await _db.SaveChangesAsync();
        return result;
    }
    public async System.Threading.Tasks.Task<bool> RedeemAsync(int id)
    {
        var entity = await _db.Coupons.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("Coupon not found: " + id);
        entity.Redeem();
        await _db.SaveChangesAsync();
        return true;
    }
    public async System.Threading.Tasks.Task<bool> DeactivateAsync(int id)
    {
        var entity = await _db.Coupons.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("Coupon not found: " + id);
        entity.Deactivate();
        await _db.SaveChangesAsync();
        return true;
    }
    public void Validate(Coupon entity)
    {
        if (entity.DiscountType == CouponDiscountTypeType.Percent && !(entity.DiscountValue >= 1m && entity.DiscountValue <= 100m)) throw new InvalidOperationException("Percent discount must be between 1 and 100");
        if (entity.MaxUses != null && !((entity.MaxUses != null && entity.UsesCount <= entity.MaxUses))) throw new InvalidOperationException("Coupon uses count cannot exceed max_uses");
    }
}
