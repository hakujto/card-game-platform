using CardsProject.Domain.Marketplace;
using CardsProject.Infrastructure;

namespace CardsProject.Services.Marketplace;

public class OrderService
{
    private readonly AppDbContext _db;

    public OrderService(AppDbContext db) => _db = db;

    public async System.Threading.Tasks.Task<Order> CreateAsync(Order entity)
    {
        _db.Orders.Add(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async System.Threading.Tasks.Task<Order> UpdateAsync(Order entity)
    {
        _db.Orders.Update(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async System.Threading.Tasks.Task<bool> CancelAsync(int id)
    {
        var entity = await _db.Orders.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("Order not found: " + id);
        entity.Cancel();
        await _db.SaveChangesAsync();
        return true;
    }
    public async System.Threading.Tasks.Task<bool> PayAsync(int id, string paymentRef)
    {
        var entity = await _db.Orders.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("Order not found: " + id);
        var result = entity.Pay(paymentRef);
        await _db.SaveChangesAsync();
        return result;
    }
    public async System.Threading.Tasks.Task<decimal> CalculateTotalAsync(int id)
    {
        var entity = await _db.Orders.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("Order not found: " + id);
        var result = entity.CalculateTotal();
        await _db.SaveChangesAsync();
        return result;
    }
    public async System.Threading.Tasks.Task<decimal> ApplyDiscountAsync(int id, int percent)
    {
        var entity = await _db.Orders.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("Order not found: " + id);
        var result = entity.ApplyDiscount(percent);
        await _db.SaveChangesAsync();
        return result;
    }
    public async System.Threading.Tasks.Task<bool> RefundAsync(int id)
    {
        var entity = await _db.Orders.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("Order not found: " + id);
        entity.Refund();
        await _db.SaveChangesAsync();
        return true;
    }
    // triggered by @on(status = Shipped)
    public async System.Threading.Tasks.Task SetStatusAsync(int id, OrderStatusType value)
    {
        var entity = await _db.Orders.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("Order not found: " + id);
        entity.Status = value;
        if (value == OrderStatusType.Shipped)
        {
            entity.NotifyShipped();
        }
        await _db.SaveChangesAsync();
    }
    public void Validate(Order entity)
    {
        if (entity.Status == OrderStatusType.Paid && entity.PaidAt == null) throw new InvalidOperationException("Paid order must have paid_at set");
        if (entity.Status == OrderStatusType.Shipped && entity.TrackingNumber == null) throw new InvalidOperationException("Shipped order must have a tracking number");
    }
}
