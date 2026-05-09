using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using CardsProject.Infrastructure;
using CardsProject.Domain.Marketplace;

namespace CardsProject.Controllers.Marketplace;

[ApiController]
[Route("api/orders")]
public class OrderController : ControllerBase
{
    private readonly AppDbContext _db;

    public OrderController(AppDbContext db) => _db = db;

    [HttpGet]
    public async Task<IActionResult> List()
    {
        var items = await _db.Orders.AsNoTracking().ToListAsync();
        return Ok(items);
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] OrderDto dto)
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
        if (dto.ItemsId is not null) entity.ItemsId = dto.ItemsId;
        if (dto.CouponId is not null) entity.CouponId = dto.CouponId;
        _db.Orders.Add(entity);
        await _db.SaveChangesAsync();
        return CreatedAtAction(nameof(Show), new { id = entity.Id }, entity);
    }

    [HttpGet("{id:int}")]
    public async Task<IActionResult> Show(int id)
    {
        var entity = await _db.Orders.FindAsync(id);
        if (entity is null) return NotFound();
        return Ok(entity);
    }

    [HttpPut("{id:int}")]
    [HttpPatch("{id:int}")]
    public async Task<IActionResult> Update(int id, [FromBody] OrderDto dto)
    {
        var entity = await _db.Orders.FindAsync(id);
        if (entity is null) return NotFound();
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
        if (dto.ItemsId is not null) entity.ItemsId = dto.ItemsId;
        if (dto.CouponId is not null) entity.CouponId = dto.CouponId;
        await _db.SaveChangesAsync();
        return Ok(entity);
    }

    [HttpDelete("{id:int}")]
    public async Task<IActionResult> Delete(int id)
    {
        var entity = await _db.Orders.FindAsync(id);
        if (entity is null) return NotFound();
        _db.Orders.Remove(entity);
        await _db.SaveChangesAsync();
        return NoContent();
    }
}
