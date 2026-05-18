using Microsoft.EntityFrameworkCore;
using System.ComponentModel.DataAnnotations;
using CardsProject.Controllers.Cards;
using CardsProject.Domain.Cards;
using CardsProject.Infrastructure;

namespace CardsProject.Services.Cards;

public class CardRulingService
{
    private readonly AppDbContext _db;

    public CardRulingService(AppDbContext db) => _db = db;

    private static void ValidateEntity(object entity)
    {
        var ctx = new ValidationContext(entity);
        Validator.ValidateObject(entity, ctx, validateAllProperties: true);
    }

    public async Task<List<CardRuling>> GetAllAsync()
        => await _db.CardRulings.AsNoTracking().ToListAsync();

    public async Task<CardRuling?> GetByIdAsync(int id)
        => await _db.CardRulings.FindAsync(id);

    public async Task<CardRuling> CreateAsync(CardRulingDto dto)
    {
        var entity = new CardRuling();
        if (dto.RulingText is not null) entity.RulingText = dto.RulingText;
        if (dto.PublishedAt is not null) entity.PublishedAt = dto.PublishedAt.Value;
        if (dto.Source is not null) entity.Source = dto.Source;
        if (dto.CardId is not null) entity.CardId = dto.CardId;
        ValidateEntity(entity);
        _db.CardRulings.Add(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async Task<CardRuling?> UpdateAsync(int id, CardRulingDto dto)
    {
        var entity = await _db.CardRulings.FindAsync(id);
        if (entity is null) return null;
        if (dto.RulingText is not null) entity.RulingText = dto.RulingText;
        if (dto.PublishedAt is not null) entity.PublishedAt = dto.PublishedAt.Value;
        if (dto.Source is not null) entity.Source = dto.Source;
        if (dto.CardId is not null) entity.CardId = dto.CardId;
        ValidateEntity(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async Task<bool> DeleteAsync(int id)
    {
        var entity = await _db.CardRulings.FindAsync(id);
        if (entity is null) return false;
        _db.CardRulings.Remove(entity);
        await _db.SaveChangesAsync();
        return true;
    }

    public async System.Threading.Tasks.Task<bool> IsCurrentAsync(int id)
    {
        var entity = await _db.CardRulings.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("CardRuling not found: " + id);
        var result = entity.IsCurrent();
        await _db.SaveChangesAsync();
        return result;
    }
    public async System.Threading.Tasks.Task<bool> SupersedesPreviousAsync(int id)
    {
        var entity = await _db.CardRulings.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("CardRuling not found: " + id);
        var result = entity.SupersedesPrevious();
        await _db.SaveChangesAsync();
        return result;
    }
}
