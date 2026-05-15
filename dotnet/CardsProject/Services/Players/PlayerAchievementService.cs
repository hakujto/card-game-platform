using CardsProject.Domain.Players;
using CardsProject.Infrastructure;

namespace CardsProject.Services.Players;

public class PlayerAchievementService
{
    private readonly AppDbContext _db;

    public PlayerAchievementService(AppDbContext db) => _db = db;

    public async System.Threading.Tasks.Task<PlayerAchievement> CreateAsync(PlayerAchievement entity)
    {
        _db.PlayerAchievements.Add(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async System.Threading.Tasks.Task<PlayerAchievement> UpdateAsync(PlayerAchievement entity)
    {
        _db.PlayerAchievements.Update(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public void Validate(PlayerAchievement entity)
    {
        if (entity.IsCompleted == true && !(entity.Progress > 0)) throw new InvalidOperationException("Completed achievement must have progress greater than zero");
    }
}
