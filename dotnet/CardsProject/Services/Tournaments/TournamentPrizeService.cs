using CardsProject.Domain.Tournaments;
using CardsProject.Infrastructure;

namespace CardsProject.Services.Tournaments;

public class TournamentPrizeService
{
    private readonly AppDbContext _db;

    public TournamentPrizeService(AppDbContext db) => _db = db;

    public System.Threading.Tasks.Task<TournamentPrize> Create(TournamentPrize entity)
    {
        throw new NotImplementedException();
    }

    public System.Threading.Tasks.Task<TournamentPrize> Update(TournamentPrize entity)
    {
        throw new NotImplementedException();
    }
}
