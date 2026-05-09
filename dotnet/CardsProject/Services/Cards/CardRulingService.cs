using CardsProject.Domain.Cards;
using CardsProject.Infrastructure;

namespace CardsProject.Services.Cards;

public class CardRulingService
{
    private readonly AppDbContext _db;

    public CardRulingService(AppDbContext db) => _db = db;

    public System.Threading.Tasks.Task<CardRuling> Create(CardRuling entity)
    {
        throw new NotImplementedException();
    }

    public System.Threading.Tasks.Task<CardRuling> Update(CardRuling entity)
    {
        throw new NotImplementedException();
    }
}
