using CardsProject.Domain.Tournaments;
using CardsProject.Infrastructure;

namespace CardsProject.Services.Tournaments;

public class MatchService
{
    private readonly AppDbContext _db;

    public MatchService(AppDbContext db) => _db = db;

    public async System.Threading.Tasks.Task<Match> CreateAsync(Match entity)
    {
        _db.Matches.Add(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async System.Threading.Tasks.Task<Match> UpdateAsync(Match entity)
    {
        _db.Matches.Update(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async System.Threading.Tasks.Task<bool> RecordResultAsync(int id, int p1Wins, int p2Wins)
    {
        var entity = await _db.Matches.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("Match not found: " + id);
        entity.RecordResult(p1Wins, p2Wins);
        entity.DetermineWinner(); // @after
        await _db.SaveChangesAsync();
        return true;
    }
    public async System.Threading.Tasks.Task<bool> DetermineWinnerAsync(int id)
    {
        var entity = await _db.Matches.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("Match not found: " + id);
        var result = entity.DetermineWinner();
        await _db.SaveChangesAsync();
        return result;
    }
    public async System.Threading.Tasks.Task<bool> DrawAsync(int id)
    {
        var entity = await _db.Matches.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("Match not found: " + id);
        entity.Draw();
        await _db.SaveChangesAsync();
        return true;
    }
    public void Validate(Match entity)
    {
        if (entity.Status == MatchStatusType.BYE && entity.Player2Id != null) throw new InvalidOperationException("BYE match must not have a second player");
    }
}
