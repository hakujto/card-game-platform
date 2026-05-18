using Microsoft.EntityFrameworkCore;
using System.ComponentModel.DataAnnotations;
using CardsProject.Controllers.Cards;
using CardsProject.Domain.Cards;
using CardsProject.Infrastructure;

namespace CardsProject.Services.Cards;

public class CardAbilityService
{
    private readonly AppDbContext _db;

    public CardAbilityService(AppDbContext db) => _db = db;

    private static void ValidateEntity(object entity)
    {
        var ctx = new ValidationContext(entity);
        Validator.ValidateObject(entity, ctx, validateAllProperties: true);
    }

    public async Task<List<CardAbility>> GetAllAsync()
        => await _db.CardAbilities.AsNoTracking().ToListAsync();

    public async Task<CardAbility?> GetByIdAsync(int id)
        => await _db.CardAbilities.FindAsync(id);

    public async Task<CardAbility> CreateAsync(CardAbilityDto dto)
    {
        var entity = new CardAbility();
        if (dto.AbilityType is not null && Enum.TryParse<CardAbilityAbilityTypeType>(dto.AbilityType, out var abilityTypeVal)) entity.AbilityType = abilityTypeVal;
        if (dto.Keyword is not null) entity.Keyword = dto.Keyword;
        if (dto.AbilityText is not null) entity.AbilityText = dto.AbilityText;
        if (dto.Timing is not null && Enum.TryParse<CardAbilityTimingType>(dto.Timing, out var timingVal)) entity.Timing = timingVal;
        if (dto.CardId is not null) entity.CardId = dto.CardId;
        Validate(entity);
        ValidateEntity(entity);
        _db.CardAbilities.Add(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async Task<CardAbility?> UpdateAsync(int id, CardAbilityDto dto)
    {
        var entity = await _db.CardAbilities.FindAsync(id);
        if (entity is null) return null;
        if (dto.AbilityType is not null && Enum.TryParse<CardAbilityAbilityTypeType>(dto.AbilityType, out var abilityTypeVal)) entity.AbilityType = abilityTypeVal;
        if (dto.Keyword is not null) entity.Keyword = dto.Keyword;
        if (dto.AbilityText is not null) entity.AbilityText = dto.AbilityText;
        if (dto.Timing is not null && Enum.TryParse<CardAbilityTimingType>(dto.Timing, out var timingVal)) entity.Timing = timingVal;
        if (dto.CardId is not null) entity.CardId = dto.CardId;
        Validate(entity);
        ValidateEntity(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async Task<bool> DeleteAsync(int id)
    {
        var entity = await _db.CardAbilities.FindAsync(id);
        if (entity is null) return false;
        _db.CardAbilities.Remove(entity);
        await _db.SaveChangesAsync();
        return true;
    }

    public async System.Threading.Tasks.Task<bool> IsUsableAtAsync(int id, string timing)
    {
        var entity = await _db.CardAbilities.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("CardAbility not found: " + id);
        var result = entity.IsUsableAt(timing);
        await _db.SaveChangesAsync();
        return result;
    }
    public async System.Threading.Tasks.Task<string> DescribeAsync(int id)
    {
        var entity = await _db.CardAbilities.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("CardAbility not found: " + id);
        var result = entity.Describe();
        await _db.SaveChangesAsync();
        return result;
    }
    public void Validate(CardAbility entity)
    {
        if (entity.AbilityType == CardAbilityAbilityTypeType.Keyword && entity.Keyword == null) throw new InvalidOperationException("Keyword ability must have a keyword name");
    }
}
