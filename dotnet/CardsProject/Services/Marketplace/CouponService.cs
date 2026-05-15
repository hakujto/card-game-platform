using CardsProject.Domain.Marketplace;
using CardsProject.Infrastructure;

namespace CardsProject.Services.Marketplace;

public class CouponService
{
    private readonly AppDbContext _db;

    public CouponService(AppDbContext db) => _db = db;

    public async System.Threading.Tasks.Task<Coupon> CreateAsync(Coupon entity)
    {
        _db.Coupons.Add(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async System.Threading.Tasks.Task<Coupon> UpdateAsync(Coupon entity)
    {
        _db.Coupons.Update(entity);
        await _db.SaveChangesAsync();
        return entity;
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
