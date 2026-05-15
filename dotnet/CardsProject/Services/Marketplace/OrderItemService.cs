using CardsProject.Domain.Marketplace;
using CardsProject.Infrastructure;

namespace CardsProject.Services.Marketplace;

public class OrderItemService
{
    private readonly AppDbContext _db;

    public OrderItemService(AppDbContext db) => _db = db;

    public async System.Threading.Tasks.Task<OrderItem> CreateAsync(OrderItem entity)
    {
        _db.OrderItems.Add(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async System.Threading.Tasks.Task<OrderItem> UpdateAsync(OrderItem entity)
    {
        _db.OrderItems.Update(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

}
