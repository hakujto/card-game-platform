using CardsProject.Domain.Cards;
using CardsProject.Infrastructure;

namespace CardsProject.Services.Cards;

public class CardService
{
    private readonly AppDbContext _db;

    public CardService(AppDbContext db) => _db = db;

    public async System.Threading.Tasks.Task<Card> CreateAsync(Card entity)
    {
        _db.Cards.Add(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async System.Threading.Tasks.Task<Card> UpdateAsync(Card entity)
    {
        _db.Cards.Update(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async System.Threading.Tasks.Task<bool> BanAsync(int id)
    {
        var entity = await _db.Cards.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("Card not found: " + id);
        entity.Ban();
        await _db.SaveChangesAsync();
        return true;
    }
    public async System.Threading.Tasks.Task<bool> UnbanAsync(int id)
    {
        var entity = await _db.Cards.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("Card not found: " + id);
        entity.Unban();
        await _db.SaveChangesAsync();
        return true;
    }
    public async System.Threading.Tasks.Task<bool> RestrictAsync(int id)
    {
        var entity = await _db.Cards.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("Card not found: " + id);
        entity.Restrict();
        await _db.SaveChangesAsync();
        return true;
    }
    public async System.Threading.Tasks.Task<bool> UnrestrictAsync(int id)
    {
        var entity = await _db.Cards.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("Card not found: " + id);
        entity.Unrestrict();
        await _db.SaveChangesAsync();
        return true;
    }
    public async System.Threading.Tasks.Task<decimal> CalculateValueAsync(int id)
    {
        var entity = await _db.Cards.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("Card not found: " + id);
        var result = entity.CalculateValue();
        await _db.SaveChangesAsync();
        return result;
    }
    public void Validate(Card entity)
    {
        if (entity.CardType == CardCardTypeType.Creature && !(entity.Attack != null && entity.Defense != null)) throw new InvalidOperationException("Creature card must have attack and defense");
        if (entity.CardType == CardCardTypeType.Planeswalker && entity.Loyalty == null) throw new InvalidOperationException("Planeswalker card must have loyalty");
    }
}
