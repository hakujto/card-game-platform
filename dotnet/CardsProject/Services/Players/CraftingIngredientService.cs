using CardsProject.Domain.Players;
using CardsProject.Infrastructure;

namespace CardsProject.Services.Players;

public class CraftingIngredientService
{
    private readonly AppDbContext _db;

    public CraftingIngredientService(AppDbContext db) => _db = db;

    public System.Threading.Tasks.Task<CraftingIngredient> Create(CraftingIngredient entity)
    {
        throw new NotImplementedException();
    }

    public System.Threading.Tasks.Task<CraftingIngredient> Update(CraftingIngredient entity)
    {
        throw new NotImplementedException();
    }
}
