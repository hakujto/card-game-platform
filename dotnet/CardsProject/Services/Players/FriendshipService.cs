using CardsProject.Domain.Players;
using CardsProject.Infrastructure;

namespace CardsProject.Services.Players;

public class FriendshipService
{
    private readonly AppDbContext _db;

    public FriendshipService(AppDbContext db) => _db = db;

    public System.Threading.Tasks.Task<Friendship> Create(Friendship entity)
    {
        throw new NotImplementedException();
    }

    public System.Threading.Tasks.Task<Friendship> Update(Friendship entity)
    {
        throw new NotImplementedException();
    }
}
