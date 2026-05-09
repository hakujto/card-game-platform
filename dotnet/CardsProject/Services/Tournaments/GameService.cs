using CardsProject.Domain.Tournaments;
using CardsProject.Infrastructure;

namespace CardsProject.Services.Tournaments;

public class GameService
{
    private readonly AppDbContext _db;

    public GameService(AppDbContext db) => _db = db;

    public System.Threading.Tasks.Task<Game> Create(Game entity)
    {
        throw new NotImplementedException();
    }

    public System.Threading.Tasks.Task<Game> Update(Game entity)
    {
        throw new NotImplementedException();
    }
}
