using CardsProject.Domain.Cards;
using CardsProject.Infrastructure;

namespace CardsProject.Services.Cards;

public class DeckCardService
{
    private readonly AppDbContext _db;

    public DeckCardService(AppDbContext db) => _db = db;

    public async System.Threading.Tasks.Task<DeckCard> CreateAsync(DeckCard entity)
    {
        _db.DeckCards.Add(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async System.Threading.Tasks.Task<DeckCard> UpdateAsync(DeckCard entity)
    {
        _db.DeckCards.Update(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

}
