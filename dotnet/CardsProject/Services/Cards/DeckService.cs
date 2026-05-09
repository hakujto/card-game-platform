using CardsProject.Domain.Cards;
using CardsProject.Infrastructure;

namespace CardsProject.Services.Cards;

public class DeckService
{
    private readonly AppDbContext _db;

    public DeckService(AppDbContext db) => _db = db;

    public System.Threading.Tasks.Task<Deck> Create(Deck entity)
    {
        throw new NotImplementedException();
    }

    public System.Threading.Tasks.Task<Deck> Update(Deck entity)
    {
        throw new NotImplementedException();
    }
}
