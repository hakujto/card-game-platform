using Microsoft.EntityFrameworkCore;
using System.ComponentModel.DataAnnotations;
using CardsProject.Controllers.Cards;
using CardsProject.Domain.Cards;
using CardsProject.Infrastructure;

namespace CardsProject.Services.Cards;

public class DeckSideboardCardService
{
    private readonly AppDbContext _db;

    public DeckSideboardCardService(AppDbContext db) => _db = db;

    private static void ValidateEntity(object entity)
    {
        var ctx = new ValidationContext(entity);
        Validator.ValidateObject(entity, ctx, validateAllProperties: true);
    }

    public async Task<List<DeckSideboardCard>> GetAllAsync()
        => await _db.DeckSideboardCards.AsNoTracking().ToListAsync();

    public async Task<DeckSideboardCard?> GetByIdAsync(int id)
        => await _db.DeckSideboardCards.FindAsync(id);

    public async Task<DeckSideboardCard> CreateAsync(DeckSideboardCardDto dto)
    {
        var entity = new DeckSideboardCard();
        if (dto.Quantity is not null) entity.Quantity = dto.Quantity.Value;
        if (dto.DeckId is not null) entity.DeckId = dto.DeckId;
        if (dto.CardId is not null) entity.CardId = dto.CardId;
        ValidateEntity(entity);
        _db.DeckSideboardCards.Add(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async Task<DeckSideboardCard?> UpdateAsync(int id, DeckSideboardCardDto dto)
    {
        var entity = await _db.DeckSideboardCards.FindAsync(id);
        if (entity is null) return null;
        if (dto.Quantity is not null) entity.Quantity = dto.Quantity.Value;
        if (dto.DeckId is not null) entity.DeckId = dto.DeckId;
        if (dto.CardId is not null) entity.CardId = dto.CardId;
        ValidateEntity(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async Task<bool> DeleteAsync(int id)
    {
        var entity = await _db.DeckSideboardCards.FindAsync(id);
        if (entity is null) return false;
        _db.DeckSideboardCards.Remove(entity);
        await _db.SaveChangesAsync();
        return true;
    }

}
