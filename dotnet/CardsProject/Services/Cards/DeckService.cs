using CardsProject.Domain.Cards;
using CardsProject.Infrastructure;

namespace CardsProject.Services.Cards;

public class DeckService
{
    private readonly AppDbContext _db;

    public DeckService(AppDbContext db) => _db = db;

    public async System.Threading.Tasks.Task<Deck> CreateAsync(Deck entity)
    {
        _db.Decks.Add(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async System.Threading.Tasks.Task<Deck> UpdateAsync(Deck entity)
    {
        _db.Decks.Update(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async System.Threading.Tasks.Task<bool> ValidateSizeAsync(int id)
    {
        var entity = await _db.Decks.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("Deck not found: " + id);
        var result = entity.ValidateSize();
        await _db.SaveChangesAsync();
        return result;
    }
    public async System.Threading.Tasks.Task<object> CloneAsync(int id)
    {
        var entity = await _db.Decks.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("Deck not found: " + id);
        var result = entity.Clone();
        await _db.SaveChangesAsync();
        return result;
    }
    public async System.Threading.Tasks.Task<bool> PublishAsync(int id)
    {
        var entity = await _db.Decks.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("Deck not found: " + id);
        entity.Publish();
        await _db.SaveChangesAsync();
        return true;
    }
    public async System.Threading.Tasks.Task<bool> UnpublishAsync(int id)
    {
        var entity = await _db.Decks.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("Deck not found: " + id);
        entity.Unpublish();
        await _db.SaveChangesAsync();
        return true;
    }
    public async System.Threading.Tasks.Task<bool> CertifyTournamentLegalAsync(int id)
    {
        var entity = await _db.Decks.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("Deck not found: " + id);
        var result = entity.CertifyTournamentLegal();
        await _db.SaveChangesAsync();
        return result;
    }
}
