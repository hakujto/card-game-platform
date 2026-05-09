using CardsProject.Domain.Tournaments;
using CardsProject.Infrastructure;

namespace CardsProject.Services.Tournaments;

public class MatchService
{
    private readonly AppDbContext _db;

    public MatchService(AppDbContext db) => _db = db;

    public System.Threading.Tasks.Task<Match> Create(Match entity)
    {
        throw new NotImplementedException();
    }

    public System.Threading.Tasks.Task<Match> Update(Match entity)
    {
        throw new NotImplementedException();
    }
}
