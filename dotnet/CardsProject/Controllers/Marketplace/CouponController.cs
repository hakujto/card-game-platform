using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using CardsProject.Infrastructure;
using CardsProject.Domain.Marketplace;
using CardsProject.Services.Marketplace;

namespace CardsProject.Controllers.Marketplace;

[ApiController]
[Route("api/coupons")]
[Microsoft.AspNetCore.Authorization.AllowAnonymous]
public class CouponController : ControllerBase
{
    private readonly AppDbContext _db;
    private readonly CouponService _svc;

    public CouponController(AppDbContext db, CouponService svc) { _db = db; _svc = svc; }

    [HttpGet]
    public async Task<IActionResult> List()
    {
        var items = await _db.Coupons.AsNoTracking().ToListAsync();
        return Ok(items);
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CouponDto dto)
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
        if (!TryValidateModel(entity)) return BadRequest(ModelState);
        try { _svc.Validate(entity); } catch (InvalidOperationException ex) { return BadRequest(new { error = ex.Message }); }
        _db.Coupons.Add(entity);
        await _db.SaveChangesAsync();
        return CreatedAtAction(nameof(Show), new { id = entity.Id }, entity);
    }

    [HttpGet("{id:int}")]
    public async Task<IActionResult> Show(int id)
    {
        var entity = await _db.Coupons.FindAsync(id);
        if (entity is null) return NotFound();
        return Ok(entity);
    }

    [HttpPut("{id:int}")]
    [HttpPatch("{id:int}")]
    public async Task<IActionResult> Update(int id, [FromBody] CouponDto dto)
    {
        var entity = await _db.Coupons.FindAsync(id);
        if (entity is null) return NotFound();
        if (dto.Code is not null) entity.Code = dto.Code;
        if (dto.DiscountType is not null && Enum.TryParse<CouponDiscountTypeType>(dto.DiscountType, out var discountTypeVal)) entity.DiscountType = discountTypeVal;
        if (dto.DiscountValue is not null) entity.DiscountValue = dto.DiscountValue.Value;
        if (dto.MinOrderValue is not null) entity.MinOrderValue = dto.MinOrderValue.Value;
        if (dto.MaxUses is not null) entity.MaxUses = dto.MaxUses.Value;
        if (dto.UsesCount is not null) entity.UsesCount = dto.UsesCount.Value;
        if (dto.ValidFrom is not null) entity.ValidFrom = dto.ValidFrom.Value;
        if (dto.ValidUntil is not null) entity.ValidUntil = dto.ValidUntil.Value;
        if (dto.IsActive is not null) entity.IsActive = dto.IsActive.Value;
        if (!TryValidateModel(entity)) return BadRequest(ModelState);
        try { _svc.Validate(entity); } catch (InvalidOperationException ex) { return BadRequest(new { error = ex.Message }); }
        await _db.SaveChangesAsync();
        return Ok(entity);
    }

    [HttpDelete("{id:int}")]
    public async Task<IActionResult> Delete(int id)
    {
        var entity = await _db.Coupons.FindAsync(id);
        if (entity is null) return NotFound();
        _db.Coupons.Remove(entity);
        await _db.SaveChangesAsync();
        return NoContent();
    }

    [HttpPost("{id:int}/redeem")]
    public async System.Threading.Tasks.Task<IActionResult> Redeem(int id)
    {
        var entity = await _db.Coupons.FindAsync(id);
        if (entity is null) return NotFound();
        entity.Redeem();
        await _db.SaveChangesAsync();
        return NoContent();
    }

    [HttpPost("{id:int}/deactivate")]
    public async System.Threading.Tasks.Task<IActionResult> Deactivate(int id)
    {
        var entity = await _db.Coupons.FindAsync(id);
        if (entity is null) return NotFound();
        entity.Deactivate();
        await _db.SaveChangesAsync();
        return NoContent();
    }
}
