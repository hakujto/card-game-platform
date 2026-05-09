using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using CardsProject.Infrastructure;
using CardsProject.Domain.Marketplace;

namespace CardsProject.Controllers.Marketplace;

[ApiController]
[Route("api/products")]
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
}
