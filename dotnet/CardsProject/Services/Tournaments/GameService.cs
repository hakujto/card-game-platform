using Microsoft.EntityFrameworkCore;
using System.ComponentModel.DataAnnotations;
using CardsProject.Controllers.Tournaments;
using CardsProject.Domain.Tournaments;
using CardsProject.Infrastructure;

namespace CardsProject.Services.Tournaments;

public class GameService
{
    private readonly AppDbContext _db;

    public GameService(AppDbContext db) => _db = db;

    private static void ValidateEntity(object entity)
    {
        var ctx = new ValidationContext(entity);
        Validator.ValidateObject(entity, ctx, validateAllProperties: true);
    }

    public async Task<List<Game>> GetAllAsync()
        => await _db.Games.AsNoTracking().ToListAsync();

    public async Task<Game?> GetByIdAsync(int id)
        => await _db.Games.FindAsync(id);

    public async Task<Game> CreateAsync(GameDto dto)
    {
        var entity = new Game();
        if (dto.GameNumber is not null) entity.GameNumber = dto.GameNumber.Value;
        if (dto.WinnerSide is not null && Enum.TryParse<GameWinnerSideType>(dto.WinnerSide, out var winnerSideVal)) entity.WinnerSide = winnerSideVal;
        if (dto.TurnsPlayed is not null) entity.TurnsPlayed = dto.TurnsPlayed.Value;
        if (dto.DurationSeconds is not null) entity.DurationSeconds = dto.DurationSeconds.Value;
        if (dto.EndedBy is not null && Enum.TryParse<GameEndedByType>(dto.EndedBy, out var endedByVal)) entity.EndedBy = endedByVal;
        if (dto.ReplayUrl is not null) entity.ReplayUrl = dto.ReplayUrl;
        if (dto.MatchId is not null) entity.MatchId = dto.MatchId;
        if (dto.WinnerId is not null) entity.WinnerId = dto.WinnerId;
        Validate(entity);
        ValidateEntity(entity);
        _db.Games.Add(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async Task<Game?> UpdateAsync(int id, GameDto dto)
    {
        var entity = await _db.Games.FindAsync(id);
        if (entity is null) return null;
        if (dto.GameNumber is not null) entity.GameNumber = dto.GameNumber.Value;
        if (dto.WinnerSide is not null && Enum.TryParse<GameWinnerSideType>(dto.WinnerSide, out var winnerSideVal)) entity.WinnerSide = winnerSideVal;
        if (dto.TurnsPlayed is not null) entity.TurnsPlayed = dto.TurnsPlayed.Value;
        if (dto.DurationSeconds is not null) entity.DurationSeconds = dto.DurationSeconds.Value;
        if (dto.EndedBy is not null && Enum.TryParse<GameEndedByType>(dto.EndedBy, out var endedByVal)) entity.EndedBy = endedByVal;
        if (dto.ReplayUrl is not null) entity.ReplayUrl = dto.ReplayUrl;
        if (dto.MatchId is not null) entity.MatchId = dto.MatchId;
        if (dto.WinnerId is not null) entity.WinnerId = dto.WinnerId;
        Validate(entity);
        ValidateEntity(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async Task<bool> DeleteAsync(int id)
    {
        var entity = await _db.Games.FindAsync(id);
        if (entity is null) return false;
        _db.Games.Remove(entity);
        await _db.SaveChangesAsync();
        return true;
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
