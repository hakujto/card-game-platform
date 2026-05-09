using CardsProject.Domain.Marketplace;
using CardsProject.Infrastructure;

namespace CardsProject.Services.Marketplace;

public class CouponService
{
    private readonly AppDbContext _db;

    public CouponService(AppDbContext db) => _db = db;

    public System.Threading.Tasks.Task<Coupon> Create(Coupon entity)
    {
        throw new NotImplementedException();
    }

    public System.Threading.Tasks.Task<Coupon> Update(Coupon entity)
    {
        throw new NotImplementedException();
    }
}
