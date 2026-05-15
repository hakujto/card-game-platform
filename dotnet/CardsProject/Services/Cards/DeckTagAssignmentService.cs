using CardsProject.Domain.Cards;
using CardsProject.Infrastructure;

namespace CardsProject.Services.Cards;

public class DeckTagAssignmentService
{
    private readonly AppDbContext _db;

    public DeckTagAssignmentService(AppDbContext db) => _db = db;

    public async System.Threading.Tasks.Task<DeckTagAssignment> CreateAsync(DeckTagAssignment entity)
    {
        _db.DeckTagAssignments.Add(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async System.Threading.Tasks.Task<DeckTagAssignment> UpdateAsync(DeckTagAssignment entity)
    {
        _db.DeckTagAssignments.Update(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

}
