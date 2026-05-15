using CardsProject.Domain.Players;
using CardsProject.Infrastructure;

namespace CardsProject.Services.Players;

public class CraftingRecipeService
{
    private readonly AppDbContext _db;

    public CraftingRecipeService(AppDbContext db) => _db = db;

    public async System.Threading.Tasks.Task<CraftingRecipe> CreateAsync(CraftingRecipe entity)
    {
        _db.CraftingRecipes.Add(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async System.Threading.Tasks.Task<CraftingRecipe> UpdateAsync(CraftingRecipe entity)
    {
        _db.CraftingRecipes.Update(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

}
