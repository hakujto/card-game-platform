using CardsProject.Domain.Tournaments;
using CardsProject.Infrastructure;

namespace CardsProject.Services.Tournaments;

public class TournamentJudgeService
{
    private readonly AppDbContext _db;

    public TournamentJudgeService(AppDbContext db) => _db = db;

    public async System.Threading.Tasks.Task<TournamentJudge> CreateAsync(TournamentJudge entity)
    {
        _db.TournamentJudges.Add(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async System.Threading.Tasks.Task<TournamentJudge> UpdateAsync(TournamentJudge entity)
    {
        _db.TournamentJudges.Update(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

}
