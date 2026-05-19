using Microsoft.EntityFrameworkCore;
using System.ComponentModel.DataAnnotations;
using CardsProject.Controllers.Marketplace;
using CardsProject.Domain.Marketplace;
using CardsProject.Infrastructure;

namespace CardsProject.Services.Marketplace;

public class TradeDisputeService
{
    private readonly AppDbContext _db;

    public TradeDisputeService(AppDbContext db) => _db = db;

    private static void ValidateEntity(object entity)
    {
        var ctx = new ValidationContext(entity);
        Validator.ValidateObject(entity, ctx, validateAllProperties: true);
    }

    public async Task<List<TradeDispute>> GetAllAsync()
        => await _db.TradeDisputes.AsNoTracking().ToListAsync();

    public async Task<TradeDispute?> GetByIdAsync(int id)
        => await _db.TradeDisputes.FindAsync(id);

    public async Task<TradeDispute> CreateAsync(TradeDisputeDto dto)
    {
        var entity = new TradeDispute();
        if (dto.Status is not null && Enum.TryParse<TradeDisputeStatusType>(dto.Status, out var statusVal)) entity.Status = statusVal;
        if (dto.Reason is not null && Enum.TryParse<TradeDisputeReasonType>(dto.Reason, out var reasonVal)) entity.Reason = reasonVal;
        if (dto.Description is not null) entity.Description = dto.Description;
        if (dto.Resolution is not null) entity.Resolution = dto.Resolution;
        if (dto.OpenedAt is not null) entity.OpenedAt = dto.OpenedAt.Value;
        if (dto.ResolvedAt is not null) entity.ResolvedAt = dto.ResolvedAt.Value;
        if (dto.TransactionId is not null) entity.TransactionId = dto.TransactionId;
        if (dto.OpenedById is not null) entity.OpenedById = dto.OpenedById;
        if (dto.ResolvedById is not null) entity.ResolvedById = dto.ResolvedById;
        Validate(entity);
        ValidateEntity(entity);
        _db.TradeDisputes.Add(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async Task<TradeDispute?> UpdateAsync(int id, TradeDisputeDto dto)
    {
        var entity = await _db.TradeDisputes.FindAsync(id);
        if (entity is null) return null;
        if (dto.Status is not null && Enum.TryParse<TradeDisputeStatusType>(dto.Status, out var statusVal)) entity.Status = statusVal;
        if (dto.Reason is not null && Enum.TryParse<TradeDisputeReasonType>(dto.Reason, out var reasonVal)) entity.Reason = reasonVal;
        if (dto.Description is not null) entity.Description = dto.Description;
        if (dto.Resolution is not null) entity.Resolution = dto.Resolution;
        if (dto.OpenedAt is not null) entity.OpenedAt = dto.OpenedAt.Value;
        if (dto.ResolvedAt is not null) entity.ResolvedAt = dto.ResolvedAt.Value;
        if (dto.TransactionId is not null) entity.TransactionId = dto.TransactionId;
        if (dto.OpenedById is not null) entity.OpenedById = dto.OpenedById;
        if (dto.ResolvedById is not null) entity.ResolvedById = dto.ResolvedById;
        Validate(entity);
        ValidateEntity(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async Task<bool> DeleteAsync(int id)
    {
        var entity = await _db.TradeDisputes.FindAsync(id);
        if (entity is null) return false;
        _db.TradeDisputes.Remove(entity);
        await _db.SaveChangesAsync();
        return true;
    }

    public async System.Threading.Tasks.Task<bool> EscalateAsync(int id)
    {
        var entity = await _db.TradeDisputes.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("TradeDispute not found: " + id);
        entity.Escalate();
        await _db.SaveChangesAsync();
        return true;
    }
    public async System.Threading.Tasks.Task<bool> ResolveAsync(int id, string resolutionText)
    {
        var entity = await _db.TradeDisputes.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("TradeDispute not found: " + id);
        entity.Resolve(resolutionText);
        await _db.SaveChangesAsync();
        return true;
    }
    public async System.Threading.Tasks.Task<bool> CloseResolvedAsync(int id)
    {
        var entity = await _db.TradeDisputes.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("TradeDispute not found: " + id);
        entity.CloseResolved();
        await _db.SaveChangesAsync();
        return true;
    }
    public async System.Threading.Tasks.Task<bool> ReviewAsync(int id)
    {
        var entity = await _db.TradeDisputes.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("TradeDispute not found: " + id);
        entity.Review();
        await _db.SaveChangesAsync();
        return true;
    }
    public async Task<TradeDispute> TransitionOpenToUnderReviewAsync(int id)
    {
        var entity = await _db.TradeDisputes.FindAsync(id)
            ?? throw new KeyNotFoundException("TradeDispute not found: " + id);
        entity.AssertTransition(TradeDisputeStatusType.UnderReview);
        entity.Status = TradeDisputeStatusType.UnderReview;
        entity.Review(); // @after
        await _db.SaveChangesAsync();
        return entity;
    }

    public async Task<TradeDispute> TransitionUnderReviewToResolvedAsync(int id)
    {
        var entity = await _db.TradeDisputes.FindAsync(id)
            ?? throw new KeyNotFoundException("TradeDispute not found: " + id);
        entity.AssertTransition(TradeDisputeStatusType.Resolved);
        if (entity.Resolution == null)
            throw new ArgumentException("resolution is required for UnderReview -> Resolved");
        entity.Status = TradeDisputeStatusType.Resolved;
        entity.CloseResolved(); // @after
        await _db.SaveChangesAsync();
        return entity;
    }

    public async Task<TradeDispute> TransitionUnderReviewToEscalatedAsync(int id)
    {
        var entity = await _db.TradeDisputes.FindAsync(id)
            ?? throw new KeyNotFoundException("TradeDispute not found: " + id);
        entity.AssertTransition(TradeDisputeStatusType.Escalated);
        entity.Status = TradeDisputeStatusType.Escalated;
        entity.Escalate(); // @after
        await _db.SaveChangesAsync();
        return entity;
    }

    public async Task<TradeDispute> TransitionEscalatedToResolvedAsync(int id)
    {
        var entity = await _db.TradeDisputes.FindAsync(id)
            ?? throw new KeyNotFoundException("TradeDispute not found: " + id);
        entity.AssertTransition(TradeDisputeStatusType.Resolved);
        if (entity.Resolution == null)
            throw new ArgumentException("resolution is required for Escalated -> Resolved");
        entity.Status = TradeDisputeStatusType.Resolved;
        entity.CloseResolved(); // @after
        await _db.SaveChangesAsync();
        return entity;
    }

    public async Task<TradeDispute> TransitionResolvedToOpenAsync(int id)
    {
        var entity = await _db.TradeDisputes.FindAsync(id)
            ?? throw new KeyNotFoundException("TradeDispute not found: " + id);
        throw new InvalidOperationException("Transition Resolved -> Open is not allowed");
    }
    public void Validate(TradeDispute entity)
    {
        if (entity.ResolvedAt != null && !(entity.Status == TradeDisputeStatusType.Resolved)) throw new InvalidOperationException("resolved_at_requires_terminal_status");
    }
}
