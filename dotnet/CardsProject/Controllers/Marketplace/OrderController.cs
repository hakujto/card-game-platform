using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using CardsProject.Infrastructure;
using CardsProject.Domain.Marketplace;
using CardsProject.Services.Marketplace;

namespace CardsProject.Controllers.Marketplace;

[ApiController]
[Route("api/orders")]
[Microsoft.AspNetCore.Authorization.AllowAnonymous]
public class OrderController : ControllerBase
{
    private readonly AppDbContext _db;
    private readonly OrderService _svc;

    public OrderController(AppDbContext db, OrderService svc) { _db = db; _svc = svc; }

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
        if (dto.CouponId is not null) entity.CouponId = dto.CouponId;
        if (!TryValidateModel(entity)) return BadRequest(ModelState);
        try { _svc.Validate(entity); } catch (InvalidOperationException ex) { return BadRequest(new { error = ex.Message }); }
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
        if (dto.CouponId is not null) entity.CouponId = dto.CouponId;
        if (!TryValidateModel(entity)) return BadRequest(ModelState);
        try { _svc.Validate(entity); } catch (InvalidOperationException ex) { return BadRequest(new { error = ex.Message }); }
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

    [HttpDelete("{id:int}/cancel")]
    public async System.Threading.Tasks.Task<IActionResult> Cancel(int id)
    {
        var entity = await _db.Orders.FindAsync(id);
        if (entity is null) return NotFound();
        entity.Cancel();
        await _db.SaveChangesAsync();
        return NoContent();
    }

    [HttpPost("{id:int}/pay")]
    public async System.Threading.Tasks.Task<IActionResult> Pay(int id, [FromBody] System.Collections.Generic.Dictionary<string, object> body)
    {
        var entity = await _db.Orders.FindAsync(id);
        if (entity is null) return NotFound();
        var paymentRef = (string)body["payment_ref"];
        var result = entity.Pay(paymentRef);
        await _db.SaveChangesAsync();
        return Ok(result);
    }

    [HttpGet("{id:int}/total")]
    public async System.Threading.Tasks.Task<IActionResult> CalculateTotal(int id)
    {
        var entity = await _db.Orders.FindAsync(id);
        if (entity is null) return NotFound();
        var result = entity.CalculateTotal();
        await _db.SaveChangesAsync();
        return Ok(result);
    }

    [HttpPatch("{id:int}/discount")]
    public async System.Threading.Tasks.Task<IActionResult> ApplyDiscount(int id, [FromBody] System.Collections.Generic.Dictionary<string, object> body)
    {
        var entity = await _db.Orders.FindAsync(id);
        if (entity is null) return NotFound();
        var percent = (int)body["percent"];
        var result = entity.ApplyDiscount(percent);
        await _db.SaveChangesAsync();
        return Ok(result);
    }

    [HttpPost("{id:int}/refund")]
    public async System.Threading.Tasks.Task<IActionResult> Refund(int id)
    {
        var entity = await _db.Orders.FindAsync(id);
        if (entity is null) return NotFound();
        entity.Refund();
        await _db.SaveChangesAsync();
        return NoContent();
    }
}
