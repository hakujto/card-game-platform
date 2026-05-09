using CardsProject.Domain.Cards;
using CardsProject.Infrastructure;

namespace CardsProject.Services.Cards;

public class DeckSideboardCardService
{
    private readonly AppDbContext _db;

    public DeckSideboardCardService(AppDbContext db) => _db = db;

    public System.Threading.Tasks.Task<DeckSideboardCard> Create(DeckSideboardCard entity)
    {
        throw new NotImplementedException();
    }

    public System.Threading.Tasks.Task<DeckSideboardCard> Update(DeckSideboardCard entity)
    {
        throw new NotImplementedException();
    }
}
