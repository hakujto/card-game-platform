using CardsProject.Domain.Tournaments;
using CardsProject.Infrastructure;

namespace CardsProject.Services.Tournaments;

public class TournamentRoundService
{
    private readonly AppDbContext _db;

    public TournamentRoundService(AppDbContext db) => _db = db;

    public System.Threading.Tasks.Task<TournamentRound> Create(TournamentRound entity)
    {
        throw new NotImplementedException();
    }

    public System.Threading.Tasks.Task<TournamentRound> Update(TournamentRound entity)
    {
        throw new NotImplementedException();
    }
}
