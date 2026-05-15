using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using CardsProject.Infrastructure;
using CardsProject.Domain.Marketplace;
using CardsProject.Services.Marketplace;

namespace CardsProject.Controllers.Marketplace;

[ApiController]
[Route("api/products")]
[Microsoft.AspNetCore.Authorization.AllowAnonymous]
public class ProductController : ControllerBase
{
    private readonly AppDbContext _db;
    public ProductController(AppDbContext db) => _db = db;

    [HttpGet]
    public async Task<IActionResult> List()
    {
        var items = await _db.Products.AsNoTracking().ToListAsync();
        return Ok(items);
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] ProductDto dto)
    {
        var entity = new Product();
        if (dto.Name is not null) entity.Name = dto.Name;
        if (dto.ProductType is not null && Enum.TryParse<ProductProductTypeType>(dto.ProductType, out var productTypeVal)) entity.ProductType = productTypeVal;
        if (dto.Price is not null) entity.Price = dto.Price.Value;
        if (dto.Stock is not null) entity.Stock = dto.Stock.Value;
        if (dto.Active is not null) entity.Active = dto.Active.Value;
        if (dto.DiscountPercent is not null) entity.DiscountPercent = dto.DiscountPercent.Value;
        if (dto.Description is not null) entity.Description = dto.Description;
        if (dto.ImageUrl is not null) entity.ImageUrl = dto.ImageUrl;
        if (dto.Featured is not null) entity.Featured = dto.Featured.Value;
        if (dto.CardId is not null) entity.CardId = dto.CardId;
        if (dto.CardSetId is not null) entity.CardSetId = dto.CardSetId;
        if (!TryValidateModel(entity)) return BadRequest(ModelState);
        _db.Products.Add(entity);
        await _db.SaveChangesAsync();
        return CreatedAtAction(nameof(Show), new { id = entity.Id }, entity);
    }

    [HttpGet("{id:int}")]
    public async Task<IActionResult> Show(int id)
    {
        var entity = await _db.Products.FindAsync(id);
        if (entity is null) return NotFound();
        return Ok(entity);
    }

    [HttpPut("{id:int}")]
    [HttpPatch("{id:int}")]
    public async Task<IActionResult> Update(int id, [FromBody] ProductDto dto)
    {
        var entity = await _db.Products.FindAsync(id);
        if (entity is null) return NotFound();
        if (dto.Name is not null) entity.Name = dto.Name;
        if (dto.ProductType is not null && Enum.TryParse<ProductProductTypeType>(dto.ProductType, out var productTypeVal)) entity.ProductType = productTypeVal;
        if (dto.Price is not null) entity.Price = dto.Price.Value;
        if (dto.Stock is not null) entity.Stock = dto.Stock.Value;
        if (dto.Active is not null) entity.Active = dto.Active.Value;
        if (dto.DiscountPercent is not null) entity.DiscountPercent = dto.DiscountPercent.Value;
        if (dto.Description is not null) entity.Description = dto.Description;
        if (dto.ImageUrl is not null) entity.ImageUrl = dto.ImageUrl;
        if (dto.Featured is not null) entity.Featured = dto.Featured.Value;
        if (dto.CardId is not null) entity.CardId = dto.CardId;
        if (dto.CardSetId is not null) entity.CardSetId = dto.CardSetId;
        if (!TryValidateModel(entity)) return BadRequest(ModelState);
        await _db.SaveChangesAsync();
        return Ok(entity);
    }

    [HttpDelete("{id:int}")]
    public async Task<IActionResult> Delete(int id)
    {
        var entity = await _db.Products.FindAsync(id);
        if (entity is null) return NotFound();
        _db.Products.Remove(entity);
        await _db.SaveChangesAsync();
        return NoContent();
    }

    [HttpPost("{id:int}/activate")]
    public async System.Threading.Tasks.Task<IActionResult> Activate(int id)
    {
        var entity = await _db.Products.FindAsync(id);
        if (entity is null) return NotFound();
        entity.Activate();
        await _db.SaveChangesAsync();
        return NoContent();
    }

    [HttpPost("{id:int}/deactivate")]
    public async System.Threading.Tasks.Task<IActionResult> Deactivate(int id)
    {
        var entity = await _db.Products.FindAsync(id);
        if (entity is null) return NotFound();
        entity.Deactivate();
        await _db.SaveChangesAsync();
        return NoContent();
    }

    [HttpPatch("{id:int}/discount")]
    public async System.Threading.Tasks.Task<IActionResult> ApplyDiscount(int id, [FromBody] System.Collections.Generic.Dictionary<string, object> body)
    {
        var entity = await _db.Products.FindAsync(id);
        if (entity is null) return NotFound();
        var percent = (int)body["percent"];
        var result = entity.ApplyDiscount(percent);
        await _db.SaveChangesAsync();
        return Ok(result);
    }

    [HttpPost("{id:int}/restock")]
    public async System.Threading.Tasks.Task<IActionResult> Restock(int id, [FromBody] System.Collections.Generic.Dictionary<string, object> body)
    {
        var entity = await _db.Products.FindAsync(id);
        if (entity is null) return NotFound();
        var quantity = (int)body["quantity"];
        entity.Restock(quantity);
        await _db.SaveChangesAsync();
        return NoContent();
    }
}
