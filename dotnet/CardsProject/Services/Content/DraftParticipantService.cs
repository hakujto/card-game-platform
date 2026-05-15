using CardsProject.Domain.Content;
using CardsProject.Infrastructure;

namespace CardsProject.Services.Content;

public class DraftParticipantService
{
    private readonly AppDbContext _db;

    public DraftParticipantService(AppDbContext db) => _db = db;

    public async System.Threading.Tasks.Task<DraftParticipant> CreateAsync(DraftParticipant entity)
    {
        _db.DraftParticipants.Add(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async System.Threading.Tasks.Task<DraftParticipant> UpdateAsync(DraftParticipant entity)
    {
        _db.DraftParticipants.Update(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async System.Threading.Tasks.Task<bool> PickCardAsync(int id, int cardId, int packNumber)
    {
        var entity = await _db.DraftParticipants.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("DraftParticipant not found: " + id);
        entity.PickCard(cardId, packNumber);
        await _db.SaveChangesAsync();
        return true;
    }
}
