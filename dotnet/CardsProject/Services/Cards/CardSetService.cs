using CardsProject.Domain.Cards;
using CardsProject.Infrastructure;

namespace CardsProject.Services.Cards;

public class CardSetService
{
    private readonly AppDbContext _db;

    public CardSetService(AppDbContext db) => _db = db;

    public System.Threading.Tasks.Task<CardSet> Create(CardSet entity)
    {
        throw new NotImplementedException();
    }

    public System.Threading.Tasks.Task<CardSet> Update(CardSet entity)
    {
        throw new NotImplementedException();
    }
}
