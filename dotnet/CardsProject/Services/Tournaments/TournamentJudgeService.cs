using CardsProject.Domain.Tournaments;
using CardsProject.Infrastructure;

namespace CardsProject.Services.Tournaments;

public class TournamentJudgeService
{
    private readonly AppDbContext _db;

    public TournamentJudgeService(AppDbContext db) => _db = db;

    public System.Threading.Tasks.Task<TournamentJudge> Create(TournamentJudge entity)
    {
        throw new NotImplementedException();
    }

    public System.Threading.Tasks.Task<TournamentJudge> Update(TournamentJudge entity)
    {
        throw new NotImplementedException();
    }
}
