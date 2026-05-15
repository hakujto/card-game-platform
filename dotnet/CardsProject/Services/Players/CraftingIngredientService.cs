using Microsoft.EntityFrameworkCore;
using System.ComponentModel.DataAnnotations;
using CardsProject.Controllers.Players;
using CardsProject.Domain.Players;
using CardsProject.Infrastructure;

namespace CardsProject.Services.Players;

public class CraftingIngredientService
{
    private readonly AppDbContext _db;

    public CraftingIngredientService(AppDbContext db) => _db = db;

    private static void ValidateEntity(object entity)
    {
        var ctx = new ValidationContext(entity);
        Validator.ValidateObject(entity, ctx, validateAllProperties: true);
    }

    public async Task<List<CraftingIngredient>> GetAllAsync()
        => await _db.CraftingIngredients.AsNoTracking().ToListAsync();

    public async Task<CraftingIngredient?> GetByIdAsync(int id)
        => await _db.CraftingIngredients.FindAsync(id);

    public async Task<CraftingIngredient> CreateAsync(CraftingIngredientDto dto)
    {
        var entity = new CraftingIngredient();
        if (dto.Quantity is not null) entity.Quantity = dto.Quantity.Value;
        if (dto.RecipeId is not null) entity.RecipeId = dto.RecipeId;
        if (dto.CardId is not null) entity.CardId = dto.CardId;
        ValidateEntity(entity);
        _db.CraftingIngredients.Add(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async Task<CraftingIngredient?> UpdateAsync(int id, CraftingIngredientDto dto)
    {
        var entity = await _db.CraftingIngredients.FindAsync(id);
        if (entity is null) return null;
        if (dto.Quantity is not null) entity.Quantity = dto.Quantity.Value;
        if (dto.RecipeId is not null) entity.RecipeId = dto.RecipeId;
        if (dto.CardId is not null) entity.CardId = dto.CardId;
        ValidateEntity(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async Task<bool> DeleteAsync(int id)
    {
        var entity = await _db.CraftingIngredients.FindAsync(id);
        if (entity is null) return false;
        _db.CraftingIngredients.Remove(entity);
        await _db.SaveChangesAsync();
        return true;
    }

}
