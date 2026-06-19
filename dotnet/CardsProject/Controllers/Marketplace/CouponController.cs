using Microsoft.AspNetCore.Mvc;
using System.ComponentModel.DataAnnotations;
using CardsProject.Services.Marketplace;

namespace CardsProject.Controllers.Marketplace;

[ApiController]
[Route("api/coupons")]
[Microsoft.AspNetCore.Authorization.AllowAnonymous]
public class CouponController : ControllerBase
{
    private readonly CouponService _svc;

    public CouponController(CouponService svc) => _svc = svc;

    [HttpGet]
    public async Task<IActionResult> List([FromQuery] string? q = null)
    {
        var items = await _svc.SearchAsync(q);
        return Ok(items);
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CouponDto dto)
    {
        if (!ModelState.IsValid) return BadRequest(ModelState);
        try
        {
            var entity = await _svc.CreateAsync(dto);
            return CreatedAtAction(nameof(Show), new { id = entity.Id }, entity);
        }
        catch (ValidationException ex) { return BadRequest(new { error = ex.Message }); }
        catch (InvalidOperationException ex) { return BadRequest(new { error = ex.Message }); }
        catch (Microsoft.EntityFrameworkCore.DbUpdateException ex) { return BadRequest(new { error = ex.InnerException?.Message ?? ex.Message }); }
    }

    [HttpGet("{id:int}")]
    public async Task<IActionResult> Show(int id)
    {
        var entity = await _svc.GetByIdAsync(id);
        if (entity is null) return NotFound();
        return Ok(entity);
    }

    [HttpPut("{id:int}")]
    [HttpPatch("{id:int}")]
    public async Task<IActionResult> Update(int id, [FromBody] CouponDto dto)
    {
        var existing = await _svc.GetByIdAsync(id);
        if (existing is null) return NotFound();
        try
        {
            var entity = await _svc.UpdateAsync(id, dto);
            if (entity is null) return NotFound();
            return Ok(entity);
        }
        catch (ValidationException ex) { return BadRequest(new { error = ex.Message }); }
        catch (InvalidOperationException ex) { return BadRequest(new { error = ex.Message }); }
        catch (Microsoft.EntityFrameworkCore.DbUpdateException ex) { return BadRequest(new { error = ex.InnerException?.Message ?? ex.Message }); }
    }

    [HttpGet("{id:int}/valid")]
    public async System.Threading.Tasks.Task<IActionResult> IsValid(int id)
    {
        try
        {
            var result = await _svc.IsValidAsync(id);
            return Ok(result);
        }
        catch (ArgumentException ex) { return UnprocessableEntity(new { error = ex.Message }); }
        catch (KeyNotFoundException) { return NotFound(); }
    }

    [HttpGet("{id:int}/applicable")]
    public async System.Threading.Tasks.Task<IActionResult> IsApplicableToOrder(int id, [FromQuery] decimal orderTotal)
    {
        try
        {
            var result = await _svc.IsApplicableToOrderAsync(id, orderTotal);
            return Ok(result);
        }
        catch (ArgumentException ex) { return UnprocessableEntity(new { error = ex.Message }); }
        catch (KeyNotFoundException) { return NotFound(); }
    }

    [HttpPost("{id:int}/redeem")]
    public async System.Threading.Tasks.Task<IActionResult> Redeem(int id)
    {
        try
        {
            await _svc.RedeemAsync(id);
            return NoContent();
        }
        catch (ArgumentException ex) { return UnprocessableEntity(new { error = ex.Message }); }
        catch (KeyNotFoundException) { return NotFound(); }
    }

    [HttpPost("{id:int}/deactivate")]
    public async System.Threading.Tasks.Task<IActionResult> Deactivate(int id)
    {
        try
        {
            await _svc.DeactivateAsync(id);
            return NoContent();
        }
        catch (ArgumentException ex) { return UnprocessableEntity(new { error = ex.Message }); }
        catch (KeyNotFoundException) { return NotFound(); }
    }
}
