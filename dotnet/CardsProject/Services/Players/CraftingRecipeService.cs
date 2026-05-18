using Microsoft.EntityFrameworkCore;
using System.ComponentModel.DataAnnotations;
using CardsProject.Controllers.Players;
using CardsProject.Domain.Players;
using CardsProject.Infrastructure;

namespace CardsProject.Services.Players;

public class CraftingRecipeService
{
    private readonly AppDbContext _db;

    public CraftingRecipeService(AppDbContext db) => _db = db;

    private static void ValidateEntity(object entity)
    {
        var ctx = new ValidationContext(entity);
        Validator.ValidateObject(entity, ctx, validateAllProperties: true);
    }

    public async Task<List<CraftingRecipe>> GetAllAsync()
        => await _db.CraftingRecipes.AsNoTracking().ToListAsync();

    public async Task<CraftingRecipe?> GetByIdAsync(int id)
        => await _db.CraftingRecipes.FindAsync(id);

    public async Task<CraftingRecipe> CreateAsync(CraftingRecipeDto dto)
    {
        var entity = new CraftingRecipe();
        if (dto.DustCost is not null) entity.DustCost = dto.DustCost.Value;
        if (dto.IsAvailable is not null) entity.IsAvailable = dto.IsAvailable.Value;
        if (dto.ResultCardId is not null) entity.ResultCardId = dto.ResultCardId;
        ValidateEntity(entity);
        _db.CraftingRecipes.Add(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async Task<CraftingRecipe?> UpdateAsync(int id, CraftingRecipeDto dto)
    {
        var entity = await _db.CraftingRecipes.FindAsync(id);
        if (entity is null) return null;
        if (dto.DustCost is not null) entity.DustCost = dto.DustCost.Value;
        if (dto.IsAvailable is not null) entity.IsAvailable = dto.IsAvailable.Value;
        if (dto.ResultCardId is not null) entity.ResultCardId = dto.ResultCardId;
        ValidateEntity(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async Task<bool> DeleteAsync(int id)
    {
        var entity = await _db.CraftingRecipes.FindAsync(id);
        if (entity is null) return false;
        _db.CraftingRecipes.Remove(entity);
        await _db.SaveChangesAsync();
        return true;
    }

    public async System.Threading.Tasks.Task<bool> CanCraftAsync(int id, int playerId)
    {
        var entity = await _db.CraftingRecipes.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("CraftingRecipe not found: " + id);
        var result = entity.CanCraft(playerId);
        await _db.SaveChangesAsync();
        return result;
    }
    public async System.Threading.Tasks.Task<bool> ExecuteCraftAsync(int id, int playerId)
    {
        var entity = await _db.CraftingRecipes.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("CraftingRecipe not found: " + id);
        entity.ExecuteCraft(playerId);
        await _db.SaveChangesAsync();
        return true;
    }
    public async System.Threading.Tasks.Task<bool> DisableAsync(int id)
    {
        var entity = await _db.CraftingRecipes.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("CraftingRecipe not found: " + id);
        entity.Disable();
        await _db.SaveChangesAsync();
        return true;
    }
    public async System.Threading.Tasks.Task<bool> EnableAsync(int id)
    {
        var entity = await _db.CraftingRecipes.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("CraftingRecipe not found: " + id);
        entity.Enable();
        await _db.SaveChangesAsync();
        return true;
    }
}
