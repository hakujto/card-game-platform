using CardsProject.Domain.Players;
using CardsProject.Infrastructure;

namespace CardsProject.Services.Players;

public class PlayerAchievementService
{
    private readonly AppDbContext _db;

    public PlayerAchievementService(AppDbContext db) => _db = db;

    public System.Threading.Tasks.Task<PlayerAchievement> Create(PlayerAchievement entity)
    {
        throw new NotImplementedException();
    }

    public System.Threading.Tasks.Task<PlayerAchievement> Update(PlayerAchievement entity)
    {
        throw new NotImplementedException();
    }
}
