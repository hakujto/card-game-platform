using CardsProject.Domain.Players;
using CardsProject.Infrastructure;

namespace CardsProject.Services.Players;

public class CraftingRecipeService
{
    private readonly AppDbContext _db;

    public CraftingRecipeService(AppDbContext db) => _db = db;

    public System.Threading.Tasks.Task<CraftingRecipe> Create(CraftingRecipe entity)
    {
        throw new NotImplementedException();
    }

    public System.Threading.Tasks.Task<CraftingRecipe> Update(CraftingRecipe entity)
    {
        throw new NotImplementedException();
    }
}
