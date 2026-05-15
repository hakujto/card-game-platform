using CardsProject.Domain.Tournaments;
using CardsProject.Infrastructure;

namespace CardsProject.Services.Tournaments;

public class TournamentPrizeService
{
    private readonly AppDbContext _db;

    public TournamentPrizeService(AppDbContext db) => _db = db;

    public async System.Threading.Tasks.Task<TournamentPrize> CreateAsync(TournamentPrize entity)
    {
        _db.TournamentPrizes.Add(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async System.Threading.Tasks.Task<TournamentPrize> UpdateAsync(TournamentPrize entity)
    {
        _db.TournamentPrizes.Update(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

}
