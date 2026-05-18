using Microsoft.EntityFrameworkCore;
using System.ComponentModel.DataAnnotations;
using CardsProject.Controllers.Cards;
using CardsProject.Domain.Cards;
using CardsProject.Infrastructure;

namespace CardsProject.Services.Cards;

public class CardService
{
    private readonly AppDbContext _db;

    public CardService(AppDbContext db) => _db = db;

    private static void ValidateEntity(object entity)
    {
        var ctx = new ValidationContext(entity);
        Validator.ValidateObject(entity, ctx, validateAllProperties: true);
    }

    public async Task<List<Card>> GetAllAsync()
        => await _db.Cards.AsNoTracking().ToListAsync();

    public async Task<Card?> GetByIdAsync(int id)
        => await _db.Cards.FindAsync(id);

    public async Task<Card> CreateAsync(CardDto dto)
    {
        var entity = new Card();
        if (dto.Name is not null) entity.Name = dto.Name;
        if (dto.CardType is not null && Enum.TryParse<CardCardTypeType>(dto.CardType, out var cardTypeVal)) entity.CardType = cardTypeVal;
        if (dto.Rarity is not null && Enum.TryParse<CardRarityType>(dto.Rarity, out var rarityVal)) entity.Rarity = rarityVal;
        if (dto.ManaCost is not null) entity.ManaCost = dto.ManaCost.Value;
        if (dto.ManaColors is not null && Enum.TryParse<CardManaColorsType>(dto.ManaColors, out var manaColorsVal)) entity.ManaColors = manaColorsVal;
        if (dto.Attack is not null) entity.Attack = dto.Attack.Value;
        if (dto.Defense is not null) entity.Defense = dto.Defense.Value;
        if (dto.Loyalty is not null) entity.Loyalty = dto.Loyalty.Value;
        if (dto.Description is not null) entity.Description = dto.Description;
        if (dto.FlavorText is not null) entity.FlavorText = dto.FlavorText;
        if (dto.ImageUrl is not null) entity.ImageUrl = dto.ImageUrl;
        if (dto.ArtistName is not null) entity.ArtistName = dto.ArtistName;
        if (dto.LegalFormats is not null && Enum.TryParse<CardLegalFormatsType>(dto.LegalFormats, out var legalFormatsVal)) entity.LegalFormats = legalFormatsVal;
        if (dto.IsBanned is not null) entity.IsBanned = dto.IsBanned.Value;
        if (dto.IsRestricted is not null) entity.IsRestricted = dto.IsRestricted.Value;
        if (dto.PowerLevel is not null) entity.PowerLevel = dto.PowerLevel.Value;
        if (dto.SetId is not null) entity.SetId = dto.SetId;
        Validate(entity);
        ValidateEntity(entity);
        _db.Cards.Add(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async Task<Card?> UpdateAsync(int id, CardDto dto)
    {
        var entity = await _db.Cards.FindAsync(id);
        if (entity is null) return null;
        if (dto.Name is not null) entity.Name = dto.Name;
        if (dto.CardType is not null && Enum.TryParse<CardCardTypeType>(dto.CardType, out var cardTypeVal)) entity.CardType = cardTypeVal;
        if (dto.Rarity is not null && Enum.TryParse<CardRarityType>(dto.Rarity, out var rarityVal)) entity.Rarity = rarityVal;
        if (dto.ManaCost is not null) entity.ManaCost = dto.ManaCost.Value;
        if (dto.ManaColors is not null && Enum.TryParse<CardManaColorsType>(dto.ManaColors, out var manaColorsVal)) entity.ManaColors = manaColorsVal;
        if (dto.Attack is not null) entity.Attack = dto.Attack.Value;
        if (dto.Defense is not null) entity.Defense = dto.Defense.Value;
        if (dto.Loyalty is not null) entity.Loyalty = dto.Loyalty.Value;
        if (dto.Description is not null) entity.Description = dto.Description;
        if (dto.FlavorText is not null) entity.FlavorText = dto.FlavorText;
        if (dto.ImageUrl is not null) entity.ImageUrl = dto.ImageUrl;
        if (dto.ArtistName is not null) entity.ArtistName = dto.ArtistName;
        if (dto.LegalFormats is not null && Enum.TryParse<CardLegalFormatsType>(dto.LegalFormats, out var legalFormatsVal)) entity.LegalFormats = legalFormatsVal;
        if (dto.IsBanned is not null) entity.IsBanned = dto.IsBanned.Value;
        if (dto.IsRestricted is not null) entity.IsRestricted = dto.IsRestricted.Value;
        if (dto.PowerLevel is not null) entity.PowerLevel = dto.PowerLevel.Value;
        if (dto.SetId is not null) entity.SetId = dto.SetId;
        Validate(entity);
        ValidateEntity(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async Task<bool> DeleteAsync(int id)
    {
        var entity = await _db.Cards.FindAsync(id);
        if (entity is null) return false;
        _db.Cards.Remove(entity);
        await _db.SaveChangesAsync();
        return true;
    }

    public async System.Threading.Tasks.Task<bool> BanAsync(int id)
    {
        var entity = await _db.Cards.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("Card not found: " + id);
        entity.Ban();
        await _db.SaveChangesAsync();
        return true;
    }
    public async System.Threading.Tasks.Task<bool> UnbanAsync(int id)
    {
        var entity = await _db.Cards.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("Card not found: " + id);
        entity.Unban();
        await _db.SaveChangesAsync();
        return true;
    }
    public async System.Threading.Tasks.Task<bool> RestrictAsync(int id)
    {
        var entity = await _db.Cards.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("Card not found: " + id);
        entity.Restrict();
        await _db.SaveChangesAsync();
        return true;
    }
    public async System.Threading.Tasks.Task<bool> UnrestrictAsync(int id)
    {
        var entity = await _db.Cards.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("Card not found: " + id);
        entity.Unrestrict();
        await _db.SaveChangesAsync();
        return true;
    }
    public async System.Threading.Tasks.Task<decimal> CalculateValueAsync(int id)
    {
        var entity = await _db.Cards.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("Card not found: " + id);
        var result = entity.CalculateValue();
        await _db.SaveChangesAsync();
        return result;
    }
    public async System.Threading.Tasks.Task<decimal> ApplyRarityBonusAsync(int id, int multiplier)
    {
        var entity = await _db.Cards.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("Card not found: " + id);
        var result = entity.ApplyRarityBonus(multiplier);
        await _db.SaveChangesAsync();
        return result;
    }
    public async System.Threading.Tasks.Task<bool> IsLegalInFormatAsync(int id, string format)
    {
        var entity = await _db.Cards.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("Card not found: " + id);
        var result = entity.IsLegalInFormat(format);
        await _db.SaveChangesAsync();
        return result;
    }
    public void Validate(Card entity)
    {
        if (entity.CardType == CardCardTypeType.Creature && !(entity.Attack != null && entity.Defense != null)) throw new InvalidOperationException("Creature card must have attack and defense");
        if (entity.CardType == CardCardTypeType.Planeswalker && entity.Loyalty == null) throw new InvalidOperationException("Planeswalker card must have loyalty");
        if (entity.CardType != CardCardTypeType.Planeswalker && entity.Loyalty != null) throw new InvalidOperationException("Only Planeswalker cards can have loyalty");
        if (entity.IsBanned == true && true) throw new InvalidOperationException("banned_card_not_in_legal_formats");
    }
}
