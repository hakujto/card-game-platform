using CardsProject.Domain.Cards;
using CardsProject.Infrastructure;

namespace CardsProject.Services.Cards;

public class DeckTagService
{
    private readonly AppDbContext _db;

    public DeckTagService(AppDbContext db) => _db = db;

    public System.Threading.Tasks.Task<DeckTag> Create(DeckTag entity)
    {
        throw new NotImplementedException();
    }

    public System.Threading.Tasks.Task<DeckTag> Update(DeckTag entity)
    {
        throw new NotImplementedException();
    }
}
