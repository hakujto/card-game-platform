using CardsProject.Domain.Tournaments;
using CardsProject.Infrastructure;

namespace CardsProject.Services.Tournaments;

public class TournamentService
{
    private readonly AppDbContext _db;

    public TournamentService(AppDbContext db) => _db = db;

    public System.Threading.Tasks.Task<Tournament> Create(Tournament entity)
    {
        throw new NotImplementedException();
    }

    public System.Threading.Tasks.Task<Tournament> Update(Tournament entity)
    {
        throw new NotImplementedException();
    }
}
