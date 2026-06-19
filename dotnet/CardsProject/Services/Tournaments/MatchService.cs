using Microsoft.EntityFrameworkCore;
using System.ComponentModel.DataAnnotations;
using CardsProject.Controllers.Tournaments;
using CardsProject.Domain.Tournaments;
using CardsProject.Infrastructure;

namespace CardsProject.Services.Tournaments;

public class MatchService
{
    private readonly AppDbContext _db;

    public MatchService(AppDbContext db) => _db = db;

    private static void ValidateEntity(object entity)
    {
        var ctx = new ValidationContext(entity);
        Validator.ValidateObject(entity, ctx, validateAllProperties: true);
    }

    public async Task<List<Match>> GetAllAsync()
        => await _db.Matches.AsNoTracking().ToListAsync();

    public async Task<Match?> GetByIdAsync(int id)
        => await _db.Matches.FindAsync(id);

    public async Task<Match> CreateAsync(MatchDto dto)
    {
        var entity = new Match();
        if (dto.TableNumber is not null) entity.TableNumber = dto.TableNumber.Value;
        if (dto.Status is not null && Enum.TryParse<MatchStatusType>(dto.Status, out var statusVal)) entity.Status = statusVal;
        if (dto.Player1Wins is not null) entity.Player1Wins = dto.Player1Wins.Value;
        if (dto.Player2Wins is not null) entity.Player2Wins = dto.Player2Wins.Value;
        if (dto.StartedAt is not null) entity.StartedAt = dto.StartedAt.Value;
        if (dto.EndedAt is not null) entity.EndedAt = dto.EndedAt.Value;
        if (dto.ResultNotes is not null) entity.ResultNotes = dto.ResultNotes;
        if (dto.RoundId is not null) entity.RoundId = dto.RoundId;
        if (dto.Player1Id is not null) entity.Player1Id = dto.Player1Id;
        if (dto.Player2Id is not null) entity.Player2Id = dto.Player2Id;
        Validate(entity);
        ValidateEntity(entity);
        _db.Matches.Add(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async Task<Match?> UpdateAsync(int id, MatchDto dto)
    {
        var entity = await _db.Matches.FindAsync(id);
        if (entity is null) return null;
        if (dto.TableNumber is not null) entity.TableNumber = dto.TableNumber.Value;
        if (dto.Status is not null && Enum.TryParse<MatchStatusType>(dto.Status, out var statusVal)) entity.Status = statusVal;
        if (dto.Player1Wins is not null) entity.Player1Wins = dto.Player1Wins.Value;
        if (dto.Player2Wins is not null) entity.Player2Wins = dto.Player2Wins.Value;
        if (dto.StartedAt is not null) entity.StartedAt = dto.StartedAt.Value;
        if (dto.EndedAt is not null) entity.EndedAt = dto.EndedAt.Value;
        if (dto.ResultNotes is not null) entity.ResultNotes = dto.ResultNotes;
        if (dto.RoundId is not null) entity.RoundId = dto.RoundId;
        if (dto.Player1Id is not null) entity.Player1Id = dto.Player1Id;
        if (dto.Player2Id is not null) entity.Player2Id = dto.Player2Id;
        Validate(entity);
        ValidateEntity(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async Task<bool> DeleteAsync(int id)
    {
        var entity = await _db.Matches.FindAsync(id);
        if (entity is null) return false;
        _db.Matches.Remove(entity);
        await _db.SaveChangesAsync();
        return true;
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
    public async System.Threading.Tasks.Task<bool> FinalizeResultAsync(int id)
    {
        var entity = await _db.Matches.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("Match not found: " + id);
        entity.FinalizeResult();
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
    public async System.Threading.Tasks.Task<bool> ConcedeAsync(int id, int playerId)
    {
        var entity = await _db.Matches.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("Match not found: " + id);
        if (!(entity.Status == MatchStatusType.Active))
            throw new ArgumentException("Guard condition not met for concede");
        entity.Concede(playerId);
        await _db.SaveChangesAsync();
        return true;
    }
    public async System.Threading.Tasks.Task<bool> DrawAsync(int id)
    {
        var entity = await _db.Matches.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("Match not found: " + id);
        entity.Draw();
        await _db.SaveChangesAsync();
        return true;
    }
    public async Task<Match> TransitionPendingToActiveAsync(int id)
    {
        var entity = await _db.Matches.FindAsync(id)
            ?? throw new KeyNotFoundException("Match not found: " + id);
        entity.AssertTransition(MatchStatusType.Active);
        entity.Status = MatchStatusType.Active;
        await _db.SaveChangesAsync();
        return entity;
    }

    public async Task<Match> TransitionActiveToCompletedAsync(int id)
    {
        var entity = await _db.Matches.FindAsync(id)
            ?? throw new KeyNotFoundException("Match not found: " + id);
        entity.AssertTransition(MatchStatusType.Completed);
        entity.Status = MatchStatusType.Completed;
        entity.FinalizeResult(); // @after
        await _db.SaveChangesAsync();
        return entity;
    }

    public async Task<Match> TransitionActiveToDrawAsync(int id)
    {
        var entity = await _db.Matches.FindAsync(id)
            ?? throw new KeyNotFoundException("Match not found: " + id);
        entity.AssertTransition(MatchStatusType.Draw);
        entity.Status = MatchStatusType.Draw;
        entity.Draw(); // @after
        await _db.SaveChangesAsync();
        return entity;
    }

    public async Task<Match> TransitionPendingToBYEAsync(int id)
    {
        var entity = await _db.Matches.FindAsync(id)
            ?? throw new KeyNotFoundException("Match not found: " + id);
        entity.AssertTransition(MatchStatusType.BYE);
        entity.Status = MatchStatusType.BYE;
        await _db.SaveChangesAsync();
        return entity;
    }

    public async Task<Match> TransitionCompletedToActiveAsync(int id)
    {
        var entity = await _db.Matches.FindAsync(id)
            ?? throw new KeyNotFoundException("Match not found: " + id);
        throw new InvalidOperationException("Transition Completed -> Active is not allowed");
    }

    public async Task<Match> TransitionDrawToActiveAsync(int id)
    {
        var entity = await _db.Matches.FindAsync(id)
            ?? throw new KeyNotFoundException("Match not found: " + id);
        throw new InvalidOperationException("Transition Draw -> Active is not allowed");
    }

    public async Task<Match> TransitionBYEToActiveAsync(int id)
    {
        var entity = await _db.Matches.FindAsync(id)
            ?? throw new KeyNotFoundException("Match not found: " + id);
        throw new InvalidOperationException("Transition BYE -> Active is not allowed");
    }
    public void Validate(Match entity)
    {
        if (entity.Status == MatchStatusType.BYE && entity.Player2Id != null) throw new InvalidOperationException("BYE match must not have a second player");
        if (entity.EndedAt != null && !((entity.EndedAt == null || (entity.StartedAt != null && entity.EndedAt > entity.StartedAt)))) throw new InvalidOperationException("Match end time must be after start time");
        if (entity.Status == MatchStatusType.Completed && entity.StartedAt == null) throw new InvalidOperationException("Completed match must have a start time");
    }
}
