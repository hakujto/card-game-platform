using Microsoft.EntityFrameworkCore;
using System.ComponentModel.DataAnnotations;
using CardsProject.Controllers.Cards;
using CardsProject.Domain.Cards;
using CardsProject.Infrastructure;

namespace CardsProject.Services.Cards;

public class CardSetService
{
    private readonly AppDbContext _db;

    public CardSetService(AppDbContext db) => _db = db;

    private static void ValidateEntity(object entity)
    {
        var ctx = new ValidationContext(entity);
        Validator.ValidateObject(entity, ctx, validateAllProperties: true);
    }

    public async Task<List<CardSet>> GetAllAsync()
        => await _db.CardSets.AsNoTracking().ToListAsync();

    public async Task<CardSet?> GetByIdAsync(int id)
        => await _db.CardSets.FindAsync(id);

    public async Task<CardSet> CreateAsync(CardSetDto dto)
    {
        var entity = new CardSet();
        if (dto.Name is not null) entity.Name = dto.Name;
        if (dto.Code is not null) entity.Code = dto.Code;
        if (dto.ReleaseDate is not null) entity.ReleaseDate = dto.ReleaseDate.Value;
        if (dto.RotationDate is not null) entity.RotationDate = dto.RotationDate.Value;
        if (dto.SetType is not null && Enum.TryParse<CardSetSetTypeType>(dto.SetType, out var setTypeVal)) entity.SetType = setTypeVal;
        if (dto.TotalCards is not null) entity.TotalCards = dto.TotalCards.Value;
        if (dto.IsRotated is not null) entity.IsRotated = dto.IsRotated.Value;
        if (dto.Description is not null) entity.Description = dto.Description;
        if (dto.LogoUrl is not null) entity.LogoUrl = dto.LogoUrl;
        Validate(entity);
        ValidateEntity(entity);
        _db.CardSets.Add(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async Task<CardSet?> UpdateAsync(int id, CardSetDto dto)
    {
        var entity = await _db.CardSets.FindAsync(id);
        if (entity is null) return null;
        if (dto.Name is not null) entity.Name = dto.Name;
        if (dto.Code is not null) entity.Code = dto.Code;
        if (dto.ReleaseDate is not null) entity.ReleaseDate = dto.ReleaseDate.Value;
        if (dto.RotationDate is not null) entity.RotationDate = dto.RotationDate.Value;
        if (dto.SetType is not null && Enum.TryParse<CardSetSetTypeType>(dto.SetType, out var setTypeVal)) entity.SetType = setTypeVal;
        if (dto.TotalCards is not null) entity.TotalCards = dto.TotalCards.Value;
        if (dto.IsRotated is not null) entity.IsRotated = dto.IsRotated.Value;
        if (dto.Description is not null) entity.Description = dto.Description;
        if (dto.LogoUrl is not null) entity.LogoUrl = dto.LogoUrl;
        Validate(entity);
        ValidateEntity(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async Task<bool> DeleteAsync(int id)
    {
        var entity = await _db.CardSets.FindAsync(id);
        if (entity is null) return false;
        _db.CardSets.Remove(entity);
        await _db.SaveChangesAsync();
        return true;
    }

    public async System.Threading.Tasks.Task<bool> IsLegalInStandardAsync(int id)
    {
        var entity = await _db.CardSets.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("CardSet not found: " + id);
        var result = entity.IsLegalInStandard();
        await _db.SaveChangesAsync();
        return result;
    }
    public async System.Threading.Tasks.Task<bool> IsLegalInFormatAsync(int id, string format)
    {
        var entity = await _db.CardSets.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("CardSet not found: " + id);
        var result = entity.IsLegalInFormat(format);
        await _db.SaveChangesAsync();
        return result;
    }
    public async System.Threading.Tasks.Task<int> CardCountByRarityAsync(int id, string rarity)
    {
        var entity = await _db.CardSets.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("CardSet not found: " + id);
        var result = entity.CardCountByRarity(rarity);
        await _db.SaveChangesAsync();
        return result;
    }
    public async System.Threading.Tasks.Task<bool> RotateOutAsync(int id)
    {
        var entity = await _db.CardSets.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("CardSet not found: " + id);
        entity.RotateOut();
        await _db.SaveChangesAsync();
        return true;
    }
    public void Validate(CardSet entity)
    {
        if (entity.RotationDate != null && !((entity.RotationDate == null || (entity.ReleaseDate != null && entity.RotationDate > entity.ReleaseDate)))) throw new InvalidOperationException("Rotation date must be after release date");
        if (entity.IsRotated == true && entity.RotationDate == null) throw new InvalidOperationException("Rotated set must have a rotation date");
    }
}
