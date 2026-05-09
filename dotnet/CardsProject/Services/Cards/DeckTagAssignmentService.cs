using CardsProject.Domain.Cards;
using CardsProject.Infrastructure;

namespace CardsProject.Services.Cards;

public class DeckTagAssignmentService
{
    private readonly AppDbContext _db;

    public DeckTagAssignmentService(AppDbContext db) => _db = db;

    public System.Threading.Tasks.Task<DeckTagAssignment> Create(DeckTagAssignment entity)
    {
        throw new NotImplementedException();
    }

    public System.Threading.Tasks.Task<DeckTagAssignment> Update(DeckTagAssignment entity)
    {
        throw new NotImplementedException();
    }
}
