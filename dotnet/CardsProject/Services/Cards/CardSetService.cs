using CardsProject.Domain.Cards;
using CardsProject.Infrastructure;

namespace CardsProject.Services.Cards;

public class CardSetService
{
    private readonly AppDbContext _db;

    public CardSetService(AppDbContext db) => _db = db;

    public async System.Threading.Tasks.Task<CardSet> CreateAsync(CardSet entity)
    {
        _db.CardSets.Add(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async System.Threading.Tasks.Task<CardSet> UpdateAsync(CardSet entity)
    {
        _db.CardSets.Update(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

}
