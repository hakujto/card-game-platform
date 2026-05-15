using CardsProject.Domain.Cards;
using CardsProject.Infrastructure;

namespace CardsProject.Services.Cards;

public class DeckTagService
{
    private readonly AppDbContext _db;

    public DeckTagService(AppDbContext db) => _db = db;

    public async System.Threading.Tasks.Task<DeckTag> CreateAsync(DeckTag entity)
    {
        _db.DeckTags.Add(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async System.Threading.Tasks.Task<DeckTag> UpdateAsync(DeckTag entity)
    {
        _db.DeckTags.Update(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async System.Threading.Tasks.Task<bool> MergeIntoAsync(int id, int targetTagId)
    {
        var entity = await _db.DeckTags.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("DeckTag not found: " + id);
        entity.MergeInto(targetTagId);
        await _db.SaveChangesAsync();
        return true;
    }
}
