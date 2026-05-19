using Microsoft.EntityFrameworkCore;
using System.ComponentModel.DataAnnotations;
using CardsProject.Controllers.Content;
using CardsProject.Domain.Content;
using CardsProject.Infrastructure;

namespace CardsProject.Services.Content;

public class DraftSessionService
{
    private readonly AppDbContext _db;

    public DraftSessionService(AppDbContext db) => _db = db;

    private static void ValidateEntity(object entity)
    {
        var ctx = new ValidationContext(entity);
        Validator.ValidateObject(entity, ctx, validateAllProperties: true);
    }

    public async Task<List<DraftSession>> GetAllAsync()
        => await _db.DraftSessions.AsNoTracking().ToListAsync();

    public async Task<DraftSession?> GetByIdAsync(int id)
        => await _db.DraftSessions.FindAsync(id);

    public async Task<DraftSession> CreateAsync(DraftSessionDto dto)
    {
        var entity = new DraftSession();
        if (dto.Status is not null && Enum.TryParse<DraftSessionStatusType>(dto.Status, out var statusVal)) entity.Status = statusVal;
        if (dto.DraftType is not null && Enum.TryParse<DraftSessionDraftTypeType>(dto.DraftType, out var draftTypeVal)) entity.DraftType = draftTypeVal;
        if (dto.Seats is not null) entity.Seats = dto.Seats.Value;
        if (dto.TimePerPickSeconds is not null) entity.TimePerPickSeconds = dto.TimePerPickSeconds.Value;
        if (dto.CreatedAt is not null) entity.CreatedAt = dto.CreatedAt.Value;
        if (dto.CompletedAt is not null) entity.CompletedAt = dto.CompletedAt.Value;
        if (dto.CardSetId is not null) entity.CardSetId = dto.CardSetId;
        Validate(entity);
        ValidateEntity(entity);
        _db.DraftSessions.Add(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async Task<DraftSession?> UpdateAsync(int id, DraftSessionDto dto)
    {
        var entity = await _db.DraftSessions.FindAsync(id);
        if (entity is null) return null;
        if (dto.Status is not null && Enum.TryParse<DraftSessionStatusType>(dto.Status, out var statusVal)) entity.Status = statusVal;
        if (dto.DraftType is not null && Enum.TryParse<DraftSessionDraftTypeType>(dto.DraftType, out var draftTypeVal)) entity.DraftType = draftTypeVal;
        if (dto.Seats is not null) entity.Seats = dto.Seats.Value;
        if (dto.TimePerPickSeconds is not null) entity.TimePerPickSeconds = dto.TimePerPickSeconds.Value;
        if (dto.CreatedAt is not null) entity.CreatedAt = dto.CreatedAt.Value;
        if (dto.CompletedAt is not null) entity.CompletedAt = dto.CompletedAt.Value;
        if (dto.CardSetId is not null) entity.CardSetId = dto.CardSetId;
        Validate(entity);
        ValidateEntity(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async Task<bool> DeleteAsync(int id)
    {
        var entity = await _db.DraftSessions.FindAsync(id);
        if (entity is null) return false;
        _db.DraftSessions.Remove(entity);
        await _db.SaveChangesAsync();
        return true;
    }

    public async System.Threading.Tasks.Task<bool> StartAsync(int id)
    {
        var entity = await _db.DraftSessions.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("DraftSession not found: " + id);
        entity.Start();
        await _db.SaveChangesAsync();
        return true;
    }
    public async System.Threading.Tasks.Task<bool> AbandonAsync(int id)
    {
        var entity = await _db.DraftSessions.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("DraftSession not found: " + id);
        entity.Abandon();
        await _db.SaveChangesAsync();
        return true;
    }
    public async System.Threading.Tasks.Task<bool> CompleteAsync(int id)
    {
        var entity = await _db.DraftSessions.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("DraftSession not found: " + id);
        entity.Complete();
        await _db.SaveChangesAsync();
        return true;
    }
    public async System.Threading.Tasks.Task<bool> IsFullAsync(int id)
    {
        var entity = await _db.DraftSessions.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("DraftSession not found: " + id);
        var result = entity.IsFull();
        await _db.SaveChangesAsync();
        return result;
    }
    public async Task<DraftSession> TransitionWaitingForPlayersToDraftingAsync(int id)
    {
        var entity = await _db.DraftSessions.FindAsync(id)
            ?? throw new KeyNotFoundException("DraftSession not found: " + id);
        entity.AssertTransition(DraftSessionStatusType.Drafting);
        entity.Status = DraftSessionStatusType.Drafting;
        entity.Start(); // @after
        await _db.SaveChangesAsync();
        return entity;
    }

    public async Task<DraftSession> TransitionDraftingToCompletedAsync(int id)
    {
        var entity = await _db.DraftSessions.FindAsync(id)
            ?? throw new KeyNotFoundException("DraftSession not found: " + id);
        entity.AssertTransition(DraftSessionStatusType.Completed);
        entity.Status = DraftSessionStatusType.Completed;
        entity.Complete(); // @after
        await _db.SaveChangesAsync();
        return entity;
    }

    public async Task<DraftSession> TransitionDraftingToAbandonedAsync(int id)
    {
        var entity = await _db.DraftSessions.FindAsync(id)
            ?? throw new KeyNotFoundException("DraftSession not found: " + id);
        entity.AssertTransition(DraftSessionStatusType.Abandoned);
        entity.Status = DraftSessionStatusType.Abandoned;
        entity.Abandon(); // @after
        await _db.SaveChangesAsync();
        return entity;
    }

    public async Task<DraftSession> TransitionWaitingForPlayersToAbandonedAsync(int id)
    {
        var entity = await _db.DraftSessions.FindAsync(id)
            ?? throw new KeyNotFoundException("DraftSession not found: " + id);
        entity.AssertTransition(DraftSessionStatusType.Abandoned);
        entity.Status = DraftSessionStatusType.Abandoned;
        entity.Abandon(); // @after
        await _db.SaveChangesAsync();
        return entity;
    }

    public async Task<DraftSession> TransitionCompletedToDraftingAsync(int id)
    {
        var entity = await _db.DraftSessions.FindAsync(id)
            ?? throw new KeyNotFoundException("DraftSession not found: " + id);
        throw new InvalidOperationException("Transition Completed -> Drafting is not allowed");
    }

    public async Task<DraftSession> TransitionAbandonedToDraftingAsync(int id)
    {
        var entity = await _db.DraftSessions.FindAsync(id)
            ?? throw new KeyNotFoundException("DraftSession not found: " + id);
        throw new InvalidOperationException("Transition Abandoned -> Drafting is not allowed");
    }
    public void Validate(DraftSession entity)
    {
        if (entity.CompletedAt != null && !(entity.Status == DraftSessionStatusType.Completed)) throw new InvalidOperationException("completed_at can only be set when draft status is Completed");
    }
}
