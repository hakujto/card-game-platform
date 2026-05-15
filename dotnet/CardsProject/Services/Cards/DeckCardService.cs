using Microsoft.EntityFrameworkCore;
using System.ComponentModel.DataAnnotations;
using CardsProject.Controllers.Cards;
using CardsProject.Domain.Cards;
using CardsProject.Infrastructure;

namespace CardsProject.Services.Cards;

public class DeckCardService
{
    private readonly AppDbContext _db;

    public DeckCardService(AppDbContext db) => _db = db;

    private static void ValidateEntity(object entity)
    {
        var ctx = new ValidationContext(entity);
        Validator.ValidateObject(entity, ctx, validateAllProperties: true);
    }

    public async Task<List<DeckCard>> GetAllAsync()
        => await _db.DeckCards.AsNoTracking().ToListAsync();

    public async Task<DeckCard?> GetByIdAsync(int id)
        => await _db.DeckCards.FindAsync(id);

    public async Task<DeckCard> CreateAsync(DeckCardDto dto)
    {
        var entity = new DeckCard();
        if (dto.Quantity is not null) entity.Quantity = dto.Quantity.Value;
        if (dto.IsCommander is not null) entity.IsCommander = dto.IsCommander.Value;
        if (dto.DeckId is not null) entity.DeckId = dto.DeckId;
        if (dto.CardId is not null) entity.CardId = dto.CardId;
        ValidateEntity(entity);
        _db.DeckCards.Add(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async Task<DeckCard?> UpdateAsync(int id, DeckCardDto dto)
    {
        var entity = await _db.DeckCards.FindAsync(id);
        if (entity is null) return null;
        if (dto.Quantity is not null) entity.Quantity = dto.Quantity.Value;
        if (dto.IsCommander is not null) entity.IsCommander = dto.IsCommander.Value;
        if (dto.DeckId is not null) entity.DeckId = dto.DeckId;
        if (dto.CardId is not null) entity.CardId = dto.CardId;
        ValidateEntity(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async Task<bool> DeleteAsync(int id)
    {
        var entity = await _db.DeckCards.FindAsync(id);
        if (entity is null) return false;
        _db.DeckCards.Remove(entity);
        await _db.SaveChangesAsync();
        return true;
    }

}
