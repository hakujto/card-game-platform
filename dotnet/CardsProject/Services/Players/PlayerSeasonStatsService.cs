using CardsProject.Domain.Players;
using CardsProject.Infrastructure;

namespace CardsProject.Services.Players;

public class PlayerSeasonStatsService
{
    private readonly AppDbContext _db;

    public PlayerSeasonStatsService(AppDbContext db) => _db = db;

    public System.Threading.Tasks.Task<PlayerSeasonStats> Create(PlayerSeasonStats entity)
    {
        throw new NotImplementedException();
    }

    public System.Threading.Tasks.Task<PlayerSeasonStats> Update(PlayerSeasonStats entity)
    {
        throw new NotImplementedException();
    }
}
