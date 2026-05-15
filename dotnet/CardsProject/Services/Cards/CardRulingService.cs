using CardsProject.Domain.Cards;
using CardsProject.Infrastructure;

namespace CardsProject.Services.Cards;

public class CardRulingService
{
    private readonly AppDbContext _db;

    public CardRulingService(AppDbContext db) => _db = db;

    public async System.Threading.Tasks.Task<CardRuling> CreateAsync(CardRuling entity)
    {
        _db.CardRulings.Add(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async System.Threading.Tasks.Task<CardRuling> UpdateAsync(CardRuling entity)
    {
        _db.CardRulings.Update(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

}
