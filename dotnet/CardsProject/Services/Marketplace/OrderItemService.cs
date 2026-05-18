using Microsoft.EntityFrameworkCore;
using System.ComponentModel.DataAnnotations;
using CardsProject.Controllers.Marketplace;
using CardsProject.Domain.Marketplace;
using CardsProject.Infrastructure;

namespace CardsProject.Services.Marketplace;

public class OrderItemService
{
    private readonly AppDbContext _db;

    public OrderItemService(AppDbContext db) => _db = db;

    private static void ValidateEntity(object entity)
    {
        var ctx = new ValidationContext(entity);
        Validator.ValidateObject(entity, ctx, validateAllProperties: true);
    }

    public async Task<List<OrderItem>> GetAllAsync()
        => await _db.OrderItems.AsNoTracking().ToListAsync();

    public async Task<OrderItem?> GetByIdAsync(int id)
        => await _db.OrderItems.FindAsync(id);

    public async Task<OrderItem> CreateAsync(OrderItemDto dto)
    {
        var entity = new OrderItem();
        if (dto.Quantity is not null) entity.Quantity = dto.Quantity.Value;
        if (dto.PriceAtPurchase is not null) entity.PriceAtPurchase = dto.PriceAtPurchase.Value;
        if (dto.Foil is not null) entity.Foil = dto.Foil.Value;
        if (dto.OrderId is not null) entity.OrderId = dto.OrderId;
        if (dto.ProductId is not null) entity.ProductId = dto.ProductId;
        ValidateEntity(entity);
        _db.OrderItems.Add(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async Task<OrderItem?> UpdateAsync(int id, OrderItemDto dto)
    {
        var entity = await _db.OrderItems.FindAsync(id);
        if (entity is null) return null;
        if (dto.Quantity is not null) entity.Quantity = dto.Quantity.Value;
        if (dto.PriceAtPurchase is not null) entity.PriceAtPurchase = dto.PriceAtPurchase.Value;
        if (dto.Foil is not null) entity.Foil = dto.Foil.Value;
        if (dto.OrderId is not null) entity.OrderId = dto.OrderId;
        if (dto.ProductId is not null) entity.ProductId = dto.ProductId;
        ValidateEntity(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async Task<bool> DeleteAsync(int id)
    {
        var entity = await _db.OrderItems.FindAsync(id);
        if (entity is null) return false;
        _db.OrderItems.Remove(entity);
        await _db.SaveChangesAsync();
        return true;
    }

    public async System.Threading.Tasks.Task<decimal> LineTotalAsync(int id)
    {
        var entity = await _db.OrderItems.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("OrderItem not found: " + id);
        var result = entity.LineTotal();
        await _db.SaveChangesAsync();
        return result;
    }
}
