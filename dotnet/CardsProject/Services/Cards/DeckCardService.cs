using CardsProject.Domain.Cards;
using CardsProject.Infrastructure;

namespace CardsProject.Services.Cards;

public class DeckCardService
{
    private readonly AppDbContext _db;

    public DeckCardService(AppDbContext db) => _db = db;

    public System.Threading.Tasks.Task<DeckCard> Create(DeckCard entity)
    {
        throw new NotImplementedException();
    }

    public System.Threading.Tasks.Task<DeckCard> Update(DeckCard entity)
    {
        throw new NotImplementedException();
    }
}
