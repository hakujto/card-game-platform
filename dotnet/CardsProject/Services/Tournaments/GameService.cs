using CardsProject.Domain.Tournaments;
using CardsProject.Infrastructure;

namespace CardsProject.Services.Tournaments;

public class GameService
{
    private readonly AppDbContext _db;

    public GameService(AppDbContext db) => _db = db;

    public async System.Threading.Tasks.Task<Game> CreateAsync(Game entity)
    {
        _db.Games.Add(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async System.Threading.Tasks.Task<Game> UpdateAsync(Game entity)
    {
        _db.Games.Update(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async System.Threading.Tasks.Task<bool> RecordWinnerAsync(int id, string winnerSide)
    {
        var entity = await _db.Games.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("Game not found: " + id);
        entity.RecordWinner(winnerSide);
        await _db.SaveChangesAsync();
        return true;
    }
    public void Validate(Game entity)
    {
        if (entity.TurnsPlayed != null && !((entity.TurnsPlayed == null || entity.TurnsPlayed > 0))) throw new InvalidOperationException("Turns played must be greater than zero");
        if (entity.DurationSeconds != null && !((entity.DurationSeconds == null || entity.DurationSeconds > 0))) throw new InvalidOperationException("Game duration must be greater than zero");
    }
}
