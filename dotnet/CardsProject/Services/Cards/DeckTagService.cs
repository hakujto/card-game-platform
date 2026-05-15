using Microsoft.EntityFrameworkCore;
using System.ComponentModel.DataAnnotations;
using CardsProject.Controllers.Cards;
using CardsProject.Domain.Cards;
using CardsProject.Infrastructure;

namespace CardsProject.Services.Cards;

public class DeckTagService
{
    private readonly AppDbContext _db;

    public DeckTagService(AppDbContext db) => _db = db;

    private static void ValidateEntity(object entity)
    {
        var ctx = new ValidationContext(entity);
        Validator.ValidateObject(entity, ctx, validateAllProperties: true);
    }

    public async Task<List<DeckTag>> GetAllAsync()
        => await _db.DeckTags.AsNoTracking().ToListAsync();

    public async Task<DeckTag?> GetByIdAsync(int id)
        => await _db.DeckTags.FindAsync(id);

    public async Task<DeckTag> CreateAsync(DeckTagDto dto)
    {
        var entity = new DeckTag();
        if (dto.Name is not null) entity.Name = dto.Name;
        if (dto.Color is not null) entity.Color = dto.Color;
        ValidateEntity(entity);
        _db.DeckTags.Add(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async Task<DeckTag?> UpdateAsync(int id, DeckTagDto dto)
    {
        var entity = await _db.DeckTags.FindAsync(id);
        if (entity is null) return null;
        if (dto.Name is not null) entity.Name = dto.Name;
        if (dto.Color is not null) entity.Color = dto.Color;
        ValidateEntity(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async Task<bool> DeleteAsync(int id)
    {
        var entity = await _db.DeckTags.FindAsync(id);
        if (entity is null) return false;
        _db.DeckTags.Remove(entity);
        await _db.SaveChangesAsync();
        return true;
    }

    public async System.Threading.Tasks.Task<bool> MergeIntoAsync(int id, int targetTagId)
    {
        var entity = await _db.DeckTags.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("DeckTag not found: " + id);
        entity.MergeInto(targetTagId);
        await _db.SaveChangesAsync();
        return true;
    }
}
