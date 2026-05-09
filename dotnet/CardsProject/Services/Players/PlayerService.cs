using CardsProject.Domain.Players;
using CardsProject.Infrastructure;

namespace CardsProject.Services.Players;

public class PlayerService
{
    private readonly AppDbContext _db;

    public PlayerService(AppDbContext db) => _db = db;

    public System.Threading.Tasks.Task<Player> Create(Player entity)
    {
        throw new NotImplementedException();
    }

    public System.Threading.Tasks.Task<Player> Update(Player entity)
    {
        throw new NotImplementedException();
    }
}
