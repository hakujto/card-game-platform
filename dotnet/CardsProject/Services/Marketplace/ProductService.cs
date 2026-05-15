using Microsoft.EntityFrameworkCore;
using System.ComponentModel.DataAnnotations;
using CardsProject.Controllers.Marketplace;
using CardsProject.Domain.Marketplace;
using CardsProject.Infrastructure;

namespace CardsProject.Services.Marketplace;

public class ProductService
{
    private readonly AppDbContext _db;

    public ProductService(AppDbContext db) => _db = db;

    private static void ValidateEntity(object entity)
    {
        var ctx = new ValidationContext(entity);
        Validator.ValidateObject(entity, ctx, validateAllProperties: true);
    }

    public async Task<List<Product>> GetAllAsync()
        => await _db.Products.AsNoTracking().ToListAsync();

    public async Task<Product?> GetByIdAsync(int id)
        => await _db.Products.FindAsync(id);

    public async Task<Product> CreateAsync(ProductDto dto)
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
        ValidateEntity(entity);
        _db.Products.Add(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async Task<Product?> UpdateAsync(int id, ProductDto dto)
    {
        var entity = await _db.Products.FindAsync(id);
        if (entity is null) return null;
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
        ValidateEntity(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async Task<bool> DeleteAsync(int id)
    {
        var entity = await _db.Products.FindAsync(id);
        if (entity is null) return false;
        _db.Products.Remove(entity);
        await _db.SaveChangesAsync();
        return true;
    }

    public async System.Threading.Tasks.Task<bool> ActivateAsync(int id)
    {
        var entity = await _db.Products.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("Product not found: " + id);
        entity.Activate();
        await _db.SaveChangesAsync();
        return true;
    }
    public async System.Threading.Tasks.Task<bool> DeactivateAsync(int id)
    {
        var entity = await _db.Products.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("Product not found: " + id);
        entity.Deactivate();
        await _db.SaveChangesAsync();
        return true;
    }
    public async System.Threading.Tasks.Task<decimal> ApplyDiscountAsync(int id, int percent)
    {
        var entity = await _db.Products.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("Product not found: " + id);
        var result = entity.ApplyDiscount(percent);
        await _db.SaveChangesAsync();
        return result;
    }
    public async System.Threading.Tasks.Task<bool> RestockAsync(int id, int quantity)
    {
        var entity = await _db.Products.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("Product not found: " + id);
        entity.Restock(quantity);
        await _db.SaveChangesAsync();
        return true;
    }
}
