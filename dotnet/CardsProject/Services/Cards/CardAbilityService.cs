using CardsProject.Domain.Cards;
using CardsProject.Infrastructure;

namespace CardsProject.Services.Cards;

public class CardAbilityService
{
    private readonly AppDbContext _db;

    public CardAbilityService(AppDbContext db) => _db = db;

    public async System.Threading.Tasks.Task<CardAbility> CreateAsync(CardAbility entity)
    {
        _db.CardAbilities.Add(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async System.Threading.Tasks.Task<CardAbility> UpdateAsync(CardAbility entity)
    {
        _db.CardAbilities.Update(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public void Validate(CardAbility entity)
    {
        if (entity.AbilityType == CardAbilityAbilityTypeType.Keyword && entity.Keyword == null) throw new InvalidOperationException("Keyword ability must have a keyword name");
    }
}
