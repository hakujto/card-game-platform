using CardsProject.Domain.Players;
using CardsProject.Infrastructure;

namespace CardsProject.Services.Players;

public class PlayerCollectionService
{
    private readonly AppDbContext _db;

    public PlayerCollectionService(AppDbContext db) => _db = db;

    public System.Threading.Tasks.Task<PlayerCollection> Create(PlayerCollection entity)
    {
        throw new NotImplementedException();
    }

    public System.Threading.Tasks.Task<PlayerCollection> Update(PlayerCollection entity)
    {
        throw new NotImplementedException();
    }
}
