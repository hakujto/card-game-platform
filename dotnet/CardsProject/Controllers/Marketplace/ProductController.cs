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
    public async Task<IActionResult> List()
    {
        var items = await _svc.GetAllAsync();
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
        try
        {
            var entity = await _svc.UpdateAsync(id, dto);
            if (entity is null) return NotFound();
            return Ok(entity);
        }
        catch (ValidationException ex) { return BadRequest(new { error = ex.Message }); }
        catch (InvalidOperationException ex) { return BadRequest(new { error = ex.Message }); }
    }

    [HttpDelete("{id:int}")]
    public async Task<IActionResult> Delete(int id)
    {
        var deleted = await _svc.DeleteAsync(id);
        if (!deleted) return NotFound();
        return NoContent();
    }

    [HttpPost("{id:int}/activate")]
    public async System.Threading.Tasks.Task<IActionResult> Activate(int id)
    {
        try
        {
            await _svc.ActivateAsync(id);
            return NoContent();
        }
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
        catch (KeyNotFoundException) { return NotFound(); }
    }
}
