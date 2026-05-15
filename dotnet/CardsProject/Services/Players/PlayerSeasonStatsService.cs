using CardsProject.Domain.Players;
using CardsProject.Infrastructure;

namespace CardsProject.Services.Players;

public class PlayerSeasonStatsService
{
    private readonly AppDbContext _db;

    public PlayerSeasonStatsService(AppDbContext db) => _db = db;

    public async System.Threading.Tasks.Task<PlayerSeasonStats> CreateAsync(PlayerSeasonStats entity)
    {
        _db.PlayerSeasonStatses.Add(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async System.Threading.Tasks.Task<PlayerSeasonStats> UpdateAsync(PlayerSeasonStats entity)
    {
        _db.PlayerSeasonStatses.Update(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

}
