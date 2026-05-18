using Microsoft.EntityFrameworkCore;
using System.ComponentModel.DataAnnotations;
using CardsProject.Controllers.Cards;
using CardsProject.Domain.Cards;
using CardsProject.Infrastructure;

namespace CardsProject.Services.Cards;

public class DeckService
{
    private readonly AppDbContext _db;

    public DeckService(AppDbContext db) => _db = db;

    private static void ValidateEntity(object entity)
    {
        var ctx = new ValidationContext(entity);
        Validator.ValidateObject(entity, ctx, validateAllProperties: true);
    }

    public async Task<List<Deck>> GetAllAsync()
        => await _db.Decks.AsNoTracking().ToListAsync();

    public async Task<Deck?> GetByIdAsync(int id)
        => await _db.Decks.FindAsync(id);

    public async Task<Deck> CreateAsync(DeckDto dto)
    {
        var entity = new Deck();
        if (dto.Name is not null) entity.Name = dto.Name;
        if (dto.Description is not null) entity.Description = dto.Description;
        if (dto.Format is not null && Enum.TryParse<DeckFormatType>(dto.Format, out var formatVal)) entity.Format = formatVal;
        if (dto.IsPublic is not null) entity.IsPublic = dto.IsPublic.Value;
        if (dto.IsTournamentLegal is not null) entity.IsTournamentLegal = dto.IsTournamentLegal.Value;
        if (dto.Archetype is not null && Enum.TryParse<DeckArchetypeType>(dto.Archetype, out var archetypeVal)) entity.Archetype = archetypeVal;
        if (dto.Wins is not null) entity.Wins = dto.Wins.Value;
        if (dto.Losses is not null) entity.Losses = dto.Losses.Value;
        if (dto.Draws is not null) entity.Draws = dto.Draws.Value;
        if (dto.CreatedAt is not null) entity.CreatedAt = dto.CreatedAt.Value;
        if (dto.UpdatedAt is not null) entity.UpdatedAt = dto.UpdatedAt.Value;
        if (dto.PlayerId is not null) entity.PlayerId = dto.PlayerId;
        Validate(entity);
        ValidateEntity(entity);
        _db.Decks.Add(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async Task<Deck?> UpdateAsync(int id, DeckDto dto)
    {
        var entity = await _db.Decks.FindAsync(id);
        if (entity is null) return null;
        if (dto.Name is not null) entity.Name = dto.Name;
        if (dto.Description is not null) entity.Description = dto.Description;
        if (dto.Format is not null && Enum.TryParse<DeckFormatType>(dto.Format, out var formatVal)) entity.Format = formatVal;
        if (dto.IsPublic is not null) entity.IsPublic = dto.IsPublic.Value;
        if (dto.IsTournamentLegal is not null) entity.IsTournamentLegal = dto.IsTournamentLegal.Value;
        if (dto.Archetype is not null && Enum.TryParse<DeckArchetypeType>(dto.Archetype, out var archetypeVal)) entity.Archetype = archetypeVal;
        if (dto.Wins is not null) entity.Wins = dto.Wins.Value;
        if (dto.Losses is not null) entity.Losses = dto.Losses.Value;
        if (dto.Draws is not null) entity.Draws = dto.Draws.Value;
        if (dto.CreatedAt is not null) entity.CreatedAt = dto.CreatedAt.Value;
        if (dto.UpdatedAt is not null) entity.UpdatedAt = dto.UpdatedAt.Value;
        if (dto.PlayerId is not null) entity.PlayerId = dto.PlayerId;
        Validate(entity);
        ValidateEntity(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async Task<bool> DeleteAsync(int id)
    {
        var entity = await _db.Decks.FindAsync(id);
        if (entity is null) return false;
        _db.Decks.Remove(entity);
        await _db.SaveChangesAsync();
        return true;
    }

    public async System.Threading.Tasks.Task<bool> ValidateSizeAsync(int id)
    {
        var entity = await _db.Decks.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("Deck not found: " + id);
        var result = entity.ValidateSize();
        await _db.SaveChangesAsync();
        return result;
    }
    public async System.Threading.Tasks.Task<bool> AddCardAsync(int id, int cardId, int quantity)
    {
        var entity = await _db.Decks.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("Deck not found: " + id);
        entity.AddCard(cardId, quantity);
        await _db.SaveChangesAsync();
        return true;
    }
    public async System.Threading.Tasks.Task<bool> RemoveCardAsync(int id, int cardId)
    {
        var entity = await _db.Decks.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("Deck not found: " + id);
        entity.RemoveCard(cardId);
        await _db.SaveChangesAsync();
        return true;
    }
    public async System.Threading.Tasks.Task<decimal> WinRateAsync(int id)
    {
        var entity = await _db.Decks.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("Deck not found: " + id);
        var result = entity.WinRate();
        await _db.SaveChangesAsync();
        return result;
    }
    public async System.Threading.Tasks.Task<object> CloneAsync(int id)
    {
        var entity = await _db.Decks.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("Deck not found: " + id);
        var result = entity.Clone();
        await _db.SaveChangesAsync();
        return result;
    }
    public async System.Threading.Tasks.Task<bool> PublishAsync(int id)
    {
        var entity = await _db.Decks.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("Deck not found: " + id);
        entity.Publish();
        await _db.SaveChangesAsync();
        return true;
    }
    public async System.Threading.Tasks.Task<bool> UnpublishAsync(int id)
    {
        var entity = await _db.Decks.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("Deck not found: " + id);
        entity.Unpublish();
        await _db.SaveChangesAsync();
        return true;
    }
    public async System.Threading.Tasks.Task<bool> CertifyTournamentLegalAsync(int id)
    {
        var entity = await _db.Decks.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("Deck not found: " + id);
        var result = entity.CertifyTournamentLegal();
        await _db.SaveChangesAsync();
        return result;
    }
    public void Validate(Deck entity)
    {
        if (entity.IsTournamentLegal == true && !(entity.IsPublic == true)) throw new InvalidOperationException("Tournament-legal deck must be made public");
    }
}
