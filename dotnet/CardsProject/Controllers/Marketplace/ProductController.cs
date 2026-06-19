using Microsoft.AspNetCore.Mvc;
using System.ComponentModel.DataAnnotations;
using CardsProject.Services.Marketplace;

namespace CardsProject.Controllers.Marketplace;

[ApiController]
[Route("api/products")]
[Microsoft.AspNetCore.Authorization.AllowAnonymous]
public class ProductController : ControllerBase
{
    private readonly ProductService _svc;

    public ProductController(ProductService svc) => _svc = svc;

    [HttpGet]
    public async Task<IActionResult> List([FromQuery] string? q = null)
    {
        var items = await _svc.SearchAsync(q);
        return Ok(items);
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] ProductDto dto)
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
    public async Task<IActionResult> Update(int id, [FromBody] ProductDto dto)
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

    [HttpPost("{id:int}/activate")]
    public async System.Threading.Tasks.Task<IActionResult> Activate(int id)
    {
        try
        {
            await _svc.ActivateAsync(id);
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

    [HttpPatch("{id:int}/discount")]
    public async System.Threading.Tasks.Task<IActionResult> ApplyDiscount(int id, [FromBody] System.Collections.Generic.Dictionary<string, object> body)
    {
        try
        {
            var percent = (int)body["percent"];
            var result = await _svc.ApplyDiscountAsync(id, percent);
            return Ok(result);
        }
        catch (ArgumentException ex) { return UnprocessableEntity(new { error = ex.Message }); }
        catch (KeyNotFoundException) { return NotFound(); }
    }

    [HttpPost("{id:int}/restock")]
    public async System.Threading.Tasks.Task<IActionResult> Restock(int id, [FromBody] System.Collections.Generic.Dictionary<string, object> body)
    {
        try
        {
            var quantity = (int)body["quantity"];
            await _svc.RestockAsync(id, quantity);
            return NoContent();
        }
        catch (ArgumentException ex) { return UnprocessableEntity(new { error = ex.Message }); }
        catch (KeyNotFoundException) { return NotFound(); }
    }

    [HttpGet("{id:int}/effective-price")]
    public async System.Threading.Tasks.Task<IActionResult> EffectivePrice(int id)
    {
        try
        {
            var result = await _svc.EffectivePriceAsync(id);
            return Ok(result);
        }
        catch (ArgumentException ex) { return UnprocessableEntity(new { error = ex.Message }); }
        catch (KeyNotFoundException) { return NotFound(); }
    }

    [HttpGet("{id:int}/in-stock")]
    public async System.Threading.Tasks.Task<IActionResult> IsInStock(int id)
    {
        try
        {
            var result = await _svc.IsInStockAsync(id);
            return Ok(result);
        }
        catch (ArgumentException ex) { return UnprocessableEntity(new { error = ex.Message }); }
        catch (KeyNotFoundException) { return NotFound(); }
    }
}
