using Microsoft.EntityFrameworkCore;
using System.ComponentModel.DataAnnotations;
using CardsProject.Controllers.Cards;
using CardsProject.Domain.Cards;
using CardsProject.Infrastructure;

namespace CardsProject.Services.Cards;

public class DeckTagAssignmentService
{
    private readonly AppDbContext _db;

    public DeckTagAssignmentService(AppDbContext db) => _db = db;

    private static void ValidateEntity(object entity)
    {
        var ctx = new ValidationContext(entity);
        Validator.ValidateObject(entity, ctx, validateAllProperties: true);
    }

    public async Task<List<DeckTagAssignment>> GetAllAsync()
        => await _db.DeckTagAssignments.AsNoTracking().ToListAsync();

    public async Task<DeckTagAssignment?> GetByIdAsync(int id)
        => await _db.DeckTagAssignments.FindAsync(id);

    public async Task<DeckTagAssignment> CreateAsync(DeckTagAssignmentDto dto)
    {
        var entity = new DeckTagAssignment();
        if (dto.DeckId is not null) entity.DeckId = dto.DeckId;
        if (dto.TagId is not null) entity.TagId = dto.TagId;
        ValidateEntity(entity);
        _db.DeckTagAssignments.Add(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async Task<DeckTagAssignment?> UpdateAsync(int id, DeckTagAssignmentDto dto)
    {
        var entity = await _db.DeckTagAssignments.FindAsync(id);
        if (entity is null) return null;
        if (dto.DeckId is not null) entity.DeckId = dto.DeckId;
        if (dto.TagId is not null) entity.TagId = dto.TagId;
        ValidateEntity(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async Task<bool> DeleteAsync(int id)
    {
        var entity = await _db.DeckTagAssignments.FindAsync(id);
        if (entity is null) return false;
        _db.DeckTagAssignments.Remove(entity);
        await _db.SaveChangesAsync();
        return true;
    }

}
