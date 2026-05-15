using Microsoft.EntityFrameworkCore;
using System.ComponentModel.DataAnnotations;
using CardsProject.Controllers.Marketplace;
using CardsProject.Domain.Marketplace;
using CardsProject.Infrastructure;

namespace CardsProject.Services.Marketplace;

public class OrderService
{
    private readonly AppDbContext _db;

    public OrderService(AppDbContext db) => _db = db;

    private static void ValidateEntity(object entity)
    {
        var ctx = new ValidationContext(entity);
        Validator.ValidateObject(entity, ctx, validateAllProperties: true);
    }

    public async Task<List<Order>> GetAllAsync()
        => await _db.Orders.AsNoTracking().ToListAsync();

    public async Task<Order?> GetByIdAsync(int id)
        => await _db.Orders.FindAsync(id);

    public async Task<Order> CreateAsync(OrderDto dto)
    {
        var entity = new Order();
        if (dto.Status is not null && Enum.TryParse<OrderStatusType>(dto.Status, out var statusVal)) entity.Status = statusVal;
        if (dto.Total is not null) entity.Total = dto.Total.Value;
        if (dto.DiscountApplied is not null) entity.DiscountApplied = dto.DiscountApplied.Value;
        if (dto.Currency is not null) entity.Currency = dto.Currency;
        if (dto.PaymentMethod is not null && Enum.TryParse<OrderPaymentMethodType>(dto.PaymentMethod, out var paymentMethodVal)) entity.PaymentMethod = paymentMethodVal;
        if (dto.PaymentReference is not null) entity.PaymentReference = dto.PaymentReference;
        if (dto.ShippingAddress is not null) entity.ShippingAddress = dto.ShippingAddress;
        if (dto.TrackingNumber is not null) entity.TrackingNumber = dto.TrackingNumber;
        if (dto.CreatedAt is not null) entity.CreatedAt = dto.CreatedAt.Value;
        if (dto.PaidAt is not null) entity.PaidAt = dto.PaidAt.Value;
        if (dto.ShippedAt is not null) entity.ShippedAt = dto.ShippedAt.Value;
        if (dto.PlayerId is not null) entity.PlayerId = dto.PlayerId;
        if (dto.CouponId is not null) entity.CouponId = dto.CouponId;
        Validate(entity);
        ValidateEntity(entity);
        _db.Orders.Add(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async Task<Order?> UpdateAsync(int id, OrderDto dto)
    {
        var entity = await _db.Orders.FindAsync(id);
        if (entity is null) return null;
        if (dto.Status is not null && Enum.TryParse<OrderStatusType>(dto.Status, out var statusVal)) entity.Status = statusVal;
        if (dto.Total is not null) entity.Total = dto.Total.Value;
        if (dto.DiscountApplied is not null) entity.DiscountApplied = dto.DiscountApplied.Value;
        if (dto.Currency is not null) entity.Currency = dto.Currency;
        if (dto.PaymentMethod is not null && Enum.TryParse<OrderPaymentMethodType>(dto.PaymentMethod, out var paymentMethodVal)) entity.PaymentMethod = paymentMethodVal;
        if (dto.PaymentReference is not null) entity.PaymentReference = dto.PaymentReference;
        if (dto.ShippingAddress is not null) entity.ShippingAddress = dto.ShippingAddress;
        if (dto.TrackingNumber is not null) entity.TrackingNumber = dto.TrackingNumber;
        if (dto.CreatedAt is not null) entity.CreatedAt = dto.CreatedAt.Value;
        if (dto.PaidAt is not null) entity.PaidAt = dto.PaidAt.Value;
        if (dto.ShippedAt is not null) entity.ShippedAt = dto.ShippedAt.Value;
        if (dto.PlayerId is not null) entity.PlayerId = dto.PlayerId;
        if (dto.CouponId is not null) entity.CouponId = dto.CouponId;
        Validate(entity);
        ValidateEntity(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async Task<bool> DeleteAsync(int id)
    {
        var entity = await _db.Orders.FindAsync(id);
        if (entity is null) return false;
        _db.Orders.Remove(entity);
        await _db.SaveChangesAsync();
        return true;
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
