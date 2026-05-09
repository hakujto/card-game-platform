using CardsProject.Domain.Cards;
using CardsProject.Infrastructure;

namespace CardsProject.Services.Cards;

public class CardService
{
    private readonly AppDbContext _db;

    public CardService(AppDbContext db) => _db = db;

    public System.Threading.Tasks.Task<Card> Create(Card entity)
    {
        throw new NotImplementedException();
    }

    public System.Threading.Tasks.Task<Card> Update(Card entity)
    {
        throw new NotImplementedException();
    }
}
