using CardsProject.Domain.Players;
using CardsProject.Infrastructure;

namespace CardsProject.Services.Players;

public class AchievementService
{
    private readonly AppDbContext _db;

    public AchievementService(AppDbContext db) => _db = db;

    public System.Threading.Tasks.Task<Achievement> Create(Achievement entity)
    {
        throw new NotImplementedException();
    }

    public System.Threading.Tasks.Task<Achievement> Update(Achievement entity)
    {
        throw new NotImplementedException();
    }
}
