using CardsProject.Domain.Players;
using CardsProject.Infrastructure;

namespace CardsProject.Services.Players;

public class CraftingIngredientService
{
    private readonly AppDbContext _db;

    public CraftingIngredientService(AppDbContext db) => _db = db;

    public async System.Threading.Tasks.Task<CraftingIngredient> CreateAsync(CraftingIngredient entity)
    {
        _db.CraftingIngredients.Add(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async System.Threading.Tasks.Task<CraftingIngredient> UpdateAsync(CraftingIngredient entity)
    {
        _db.CraftingIngredients.Update(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

}
