using Microsoft.EntityFrameworkCore;
using System.ComponentModel.DataAnnotations;
using CardsProject.Controllers.Marketplace;
using CardsProject.Domain.Marketplace;
using CardsProject.Infrastructure;

namespace CardsProject.Services.Marketplace;

public class TradeTransactionService
{
    private readonly AppDbContext _db;

    public TradeTransactionService(AppDbContext db) => _db = db;

    private static void ValidateEntity(object entity)
    {
        var ctx = new ValidationContext(entity);
        Validator.ValidateObject(entity, ctx, validateAllProperties: true);
    }

    public async Task<List<TradeTransaction>> GetAllAsync()
        => await _db.TradeTransactions.AsNoTracking().ToListAsync();

    public async Task<TradeTransaction?> GetByIdAsync(int id)
        => await _db.TradeTransactions.FindAsync(id);

    public async Task<TradeTransaction> CreateAsync(TradeTransactionDto dto)
    {
        var entity = new TradeTransaction();
        if (dto.FinalPrice is not null) entity.FinalPrice = dto.FinalPrice.Value;
        if (dto.PlatformFee is not null) entity.PlatformFee = dto.PlatformFee.Value;
        if (dto.Status is not null && Enum.TryParse<TradeTransactionStatusType>(dto.Status, out var statusVal)) entity.Status = statusVal;
        if (dto.CompletedAt is not null) entity.CompletedAt = dto.CompletedAt.Value;
        if (dto.ListingId is not null) entity.ListingId = dto.ListingId;
        if (dto.BuyerId is not null) entity.BuyerId = dto.BuyerId;
        if (dto.SellerId is not null) entity.SellerId = dto.SellerId;
        Validate(entity);
        ValidateEntity(entity);
        _db.TradeTransactions.Add(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async Task<TradeTransaction?> UpdateAsync(int id, TradeTransactionDto dto)
    {
        var entity = await _db.TradeTransactions.FindAsync(id);
        if (entity is null) return null;
        if (dto.FinalPrice is not null) entity.FinalPrice = dto.FinalPrice.Value;
        if (dto.PlatformFee is not null) entity.PlatformFee = dto.PlatformFee.Value;
        if (dto.Status is not null && Enum.TryParse<TradeTransactionStatusType>(dto.Status, out var statusVal)) entity.Status = statusVal;
        if (dto.CompletedAt is not null) entity.CompletedAt = dto.CompletedAt.Value;
        if (dto.ListingId is not null) entity.ListingId = dto.ListingId;
        if (dto.BuyerId is not null) entity.BuyerId = dto.BuyerId;
        if (dto.SellerId is not null) entity.SellerId = dto.SellerId;
        Validate(entity);
        ValidateEntity(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async Task<bool> DeleteAsync(int id)
    {
        var entity = await _db.TradeTransactions.FindAsync(id);
        if (entity is null) return false;
        _db.TradeTransactions.Remove(entity);
        await _db.SaveChangesAsync();
        return true;
    }

    public async System.Threading.Tasks.Task<bool> CompleteAsync(int id)
    {
        var entity = await _db.TradeTransactions.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("TradeTransaction not found: " + id);
        entity.Complete();
        await _db.SaveChangesAsync();
        return true;
    }
    public async System.Threading.Tasks.Task<bool> RefundAsync(int id)
    {
        var entity = await _db.TradeTransactions.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("TradeTransaction not found: " + id);
        entity.Refund();
        await _db.SaveChangesAsync();
        return true;
    }
    public async System.Threading.Tasks.Task<bool> OpenDisputeAsync(int id, string reason)
    {
        var entity = await _db.TradeTransactions.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("TradeTransaction not found: " + id);
        entity.OpenDispute(reason);
        await _db.SaveChangesAsync();
        return true;
    }
    public async System.Threading.Tasks.Task<decimal> SellerNetAsync(int id)
    {
        var entity = await _db.TradeTransactions.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("TradeTransaction not found: " + id);
        var result = entity.SellerNet();
        await _db.SaveChangesAsync();
        return result;
    }
    public void Validate(TradeTransaction entity)
    {
        if (entity.Status == TradeTransactionStatusType.Completed && entity.CompletedAt == null) throw new InvalidOperationException("Completed transaction must have a completed_at timestamp");
    }
}
