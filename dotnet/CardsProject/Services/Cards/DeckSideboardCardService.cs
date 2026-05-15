using CardsProject.Domain.Cards;
using CardsProject.Infrastructure;

namespace CardsProject.Services.Cards;

public class DeckSideboardCardService
{
    private readonly AppDbContext _db;

    public DeckSideboardCardService(AppDbContext db) => _db = db;

    public async System.Threading.Tasks.Task<DeckSideboardCard> CreateAsync(DeckSideboardCard entity)
    {
        _db.DeckSideboardCards.Add(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async System.Threading.Tasks.Task<DeckSideboardCard> UpdateAsync(DeckSideboardCard entity)
    {
        _db.DeckSideboardCards.Update(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

}
