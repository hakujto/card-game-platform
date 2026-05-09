using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using CardsProject.Infrastructure;
using CardsProject.Domain.Marketplace;

namespace CardsProject.Controllers.Marketplace;

[ApiController]
[Route("api/order_items")]
public class OrderItemController : ControllerBase
{
    private readonly AppDbContext _db;

    public OrderItemController(AppDbContext db) => _db = db;

    [HttpGet]
    public async Task<IActionResult> List()
    {
        var items = await _db.OrderItems.AsNoTracking().ToListAsync();
        return Ok(items);
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] OrderItemDto dto)
    {
        var entity = new OrderItem();
        if (dto.Quantity is not null) entity.Quantity = dto.Quantity.Value;
        if (dto.PriceAtPurchase is not null) entity.PriceAtPurchase = dto.PriceAtPurchase.Value;
        if (dto.Foil is not null) entity.Foil = dto.Foil.Value;
        if (dto.OrderId is not null) entity.OrderId = dto.OrderId;
        if (dto.ProductId is not null) entity.ProductId = dto.ProductId;
        _db.OrderItems.Add(entity);
        await _db.SaveChangesAsync();
        return CreatedAtAction(nameof(Show), new { id = entity.Id }, entity);
    }

    [HttpGet("{id:int}")]
    public async Task<IActionResult> Show(int id)
    {
        var entity = await _db.OrderItems.FindAsync(id);
        if (entity is null) return NotFound();
        return Ok(entity);
    }

    [HttpPut("{id:int}")]
    [HttpPatch("{id:int}")]
    public async Task<IActionResult> Update(int id, [FromBody] OrderItemDto dto)
    {
        var entity = await _db.OrderItems.FindAsync(id);
        if (entity is null) return NotFound();
        if (dto.Quantity is not null) entity.Quantity = dto.Quantity.Value;
        if (dto.PriceAtPurchase is not null) entity.PriceAtPurchase = dto.PriceAtPurchase.Value;
        if (dto.Foil is not null) entity.Foil = dto.Foil.Value;
        if (dto.OrderId is not null) entity.OrderId = dto.OrderId;
        if (dto.ProductId is not null) entity.ProductId = dto.ProductId;
        await _db.SaveChangesAsync();
        return Ok(entity);
    }

    [HttpDelete("{id:int}")]
    public async Task<IActionResult> Delete(int id)
    {
        var entity = await _db.OrderItems.FindAsync(id);
        if (entity is null) return NotFound();
        _db.OrderItems.Remove(entity);
        await _db.SaveChangesAsync();
        return NoContent();
    }
}
