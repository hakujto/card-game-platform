using Microsoft.EntityFrameworkCore;
using System.ComponentModel.DataAnnotations;
using CardsProject.Controllers.Marketplace;
using CardsProject.Domain.Marketplace;
using CardsProject.Infrastructure;

namespace CardsProject.Services.Marketplace;

public class CardPriceHistoryService
{
    private readonly AppDbContext _db;

    public CardPriceHistoryService(AppDbContext db) => _db = db;

    private static void ValidateEntity(object entity)
    {
        var ctx = new ValidationContext(entity);
        Validator.ValidateObject(entity, ctx, validateAllProperties: true);
    }

    public async Task<List<CardPriceHistory>> GetAllAsync()
        => await _db.CardPriceHistories.AsNoTracking().ToListAsync();

    public async Task<CardPriceHistory?> GetByIdAsync(int id)
        => await _db.CardPriceHistories.FindAsync(id);

    public async Task<CardPriceHistory> CreateAsync(CardPriceHistoryDto dto)
    {
        var entity = new CardPriceHistory();
        if (dto.PriceDate is not null) entity.PriceDate = dto.PriceDate.Value;
        if (dto.AvgPrice is not null) entity.AvgPrice = dto.AvgPrice.Value;
        if (dto.MinPrice is not null) entity.MinPrice = dto.MinPrice.Value;
        if (dto.MaxPrice is not null) entity.MaxPrice = dto.MaxPrice.Value;
        if (dto.Volume is not null) entity.Volume = dto.Volume.Value;
        if (dto.Foil is not null) entity.Foil = dto.Foil.Value;
        if (dto.CardId is not null) entity.CardId = dto.CardId;
        ValidateEntity(entity);
        _db.CardPriceHistories.Add(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async Task<CardPriceHistory?> UpdateAsync(int id, CardPriceHistoryDto dto)
    {
        var entity = await _db.CardPriceHistories.FindAsync(id);
        if (entity is null) return null;
        if (dto.PriceDate is not null) entity.PriceDate = dto.PriceDate.Value;
        if (dto.AvgPrice is not null) entity.AvgPrice = dto.AvgPrice.Value;
        if (dto.MinPrice is not null) entity.MinPrice = dto.MinPrice.Value;
        if (dto.MaxPrice is not null) entity.MaxPrice = dto.MaxPrice.Value;
        if (dto.Volume is not null) entity.Volume = dto.Volume.Value;
        if (dto.Foil is not null) entity.Foil = dto.Foil.Value;
        if (dto.CardId is not null) entity.CardId = dto.CardId;
        ValidateEntity(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async Task<bool> DeleteAsync(int id)
    {
        var entity = await _db.CardPriceHistories.FindAsync(id);
        if (entity is null) return false;
        _db.CardPriceHistories.Remove(entity);
        await _db.SaveChangesAsync();
        return true;
    }

}
