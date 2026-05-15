using CardsProject.Domain.Players;
using CardsProject.Infrastructure;

namespace CardsProject.Services.Players;

public class AchievementService
{
    private readonly AppDbContext _db;

    public AchievementService(AppDbContext db) => _db = db;

    public async System.Threading.Tasks.Task<Achievement> CreateAsync(Achievement entity)
    {
        _db.Achievements.Add(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async System.Threading.Tasks.Task<Achievement> UpdateAsync(Achievement entity)
    {
        _db.Achievements.Update(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

}
