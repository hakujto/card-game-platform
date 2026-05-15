using Microsoft.EntityFrameworkCore;
using System.ComponentModel.DataAnnotations;
using CardsProject.Controllers.Marketplace;
using CardsProject.Domain.Marketplace;
using CardsProject.Infrastructure;

namespace CardsProject.Services.Marketplace;

public class TradeBidService
{
    private readonly AppDbContext _db;

    public TradeBidService(AppDbContext db) => _db = db;

    private static void ValidateEntity(object entity)
    {
        var ctx = new ValidationContext(entity);
        Validator.ValidateObject(entity, ctx, validateAllProperties: true);
    }

    public async Task<List<TradeBid>> GetAllAsync()
        => await _db.TradeBids.AsNoTracking().ToListAsync();

    public async Task<TradeBid?> GetByIdAsync(int id)
        => await _db.TradeBids.FindAsync(id);

    public async Task<TradeBid> CreateAsync(TradeBidDto dto)
    {
        var entity = new TradeBid();
        if (dto.Amount is not null) entity.Amount = dto.Amount.Value;
        if (dto.PlacedAt is not null) entity.PlacedAt = dto.PlacedAt.Value;
        if (dto.IsWinning is not null) entity.IsWinning = dto.IsWinning.Value;
        if (dto.ListingId is not null) entity.ListingId = dto.ListingId;
        if (dto.BidderId is not null) entity.BidderId = dto.BidderId;
        ValidateEntity(entity);
        _db.TradeBids.Add(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async Task<TradeBid?> UpdateAsync(int id, TradeBidDto dto)
    {
        var entity = await _db.TradeBids.FindAsync(id);
        if (entity is null) return null;
        if (dto.Amount is not null) entity.Amount = dto.Amount.Value;
        if (dto.PlacedAt is not null) entity.PlacedAt = dto.PlacedAt.Value;
        if (dto.IsWinning is not null) entity.IsWinning = dto.IsWinning.Value;
        if (dto.ListingId is not null) entity.ListingId = dto.ListingId;
        if (dto.BidderId is not null) entity.BidderId = dto.BidderId;
        ValidateEntity(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async Task<bool> DeleteAsync(int id)
    {
        var entity = await _db.TradeBids.FindAsync(id);
        if (entity is null) return false;
        _db.TradeBids.Remove(entity);
        await _db.SaveChangesAsync();
        return true;
    }

}
