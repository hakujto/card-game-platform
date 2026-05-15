using CardsProject.Domain.Marketplace;
using CardsProject.Infrastructure;

namespace CardsProject.Services.Marketplace;

public class ProductService
{
    private readonly AppDbContext _db;

    public ProductService(AppDbContext db) => _db = db;

    public async System.Threading.Tasks.Task<Product> CreateAsync(Product entity)
    {
        _db.Products.Add(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async System.Threading.Tasks.Task<Product> UpdateAsync(Product entity)
    {
        _db.Products.Update(entity);
        await _db.SaveChangesAsync();
        return entity;
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
