using CardsProject.Domain.Content;
using CardsProject.Infrastructure;

namespace CardsProject.Services.Content;

public class DraftPickService
{
    private readonly AppDbContext _db;

    public DraftPickService(AppDbContext db) => _db = db;

    public async System.Threading.Tasks.Task<DraftPick> CreateAsync(DraftPick entity)
    {
        _db.DraftPicks.Add(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async System.Threading.Tasks.Task<DraftPick> UpdateAsync(DraftPick entity)
    {
        _db.DraftPicks.Update(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

}
