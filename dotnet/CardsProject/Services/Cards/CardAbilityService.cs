using CardsProject.Domain.Cards;
using CardsProject.Infrastructure;

namespace CardsProject.Services.Cards;

public class CardAbilityService
{
    private readonly AppDbContext _db;

    public CardAbilityService(AppDbContext db) => _db = db;

    public System.Threading.Tasks.Task<CardAbility> Create(CardAbility entity)
    {
        throw new NotImplementedException();
    }

    public System.Threading.Tasks.Task<CardAbility> Update(CardAbility entity)
    {
        throw new NotImplementedException();
    }
}
