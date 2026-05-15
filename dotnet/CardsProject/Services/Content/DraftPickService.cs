using Microsoft.EntityFrameworkCore;
using System.ComponentModel.DataAnnotations;
using CardsProject.Controllers.Content;
using CardsProject.Domain.Content;
using CardsProject.Infrastructure;

namespace CardsProject.Services.Content;

public class DraftPickService
{
    private readonly AppDbContext _db;

    public DraftPickService(AppDbContext db) => _db = db;

    private static void ValidateEntity(object entity)
    {
        var ctx = new ValidationContext(entity);
        Validator.ValidateObject(entity, ctx, validateAllProperties: true);
    }

    public async Task<List<DraftPick>> GetAllAsync()
        => await _db.DraftPicks.AsNoTracking().ToListAsync();

    public async Task<DraftPick?> GetByIdAsync(int id)
        => await _db.DraftPicks.FindAsync(id);

    public async Task<DraftPick> CreateAsync(DraftPickDto dto)
    {
        var entity = new DraftPick();
        if (dto.PickNumber is not null) entity.PickNumber = dto.PickNumber.Value;
        if (dto.PackNumber is not null) entity.PackNumber = dto.PackNumber.Value;
        if (dto.PickedAt is not null) entity.PickedAt = dto.PickedAt.Value;
        if (dto.ParticipantId is not null) entity.ParticipantId = dto.ParticipantId;
        if (dto.CardId is not null) entity.CardId = dto.CardId;
        ValidateEntity(entity);
        _db.DraftPicks.Add(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async Task<DraftPick?> UpdateAsync(int id, DraftPickDto dto)
    {
        var entity = await _db.DraftPicks.FindAsync(id);
        if (entity is null) return null;
        if (dto.PickNumber is not null) entity.PickNumber = dto.PickNumber.Value;
        if (dto.PackNumber is not null) entity.PackNumber = dto.PackNumber.Value;
        if (dto.PickedAt is not null) entity.PickedAt = dto.PickedAt.Value;
        if (dto.ParticipantId is not null) entity.ParticipantId = dto.ParticipantId;
        if (dto.CardId is not null) entity.CardId = dto.CardId;
        ValidateEntity(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async Task<bool> DeleteAsync(int id)
    {
        var entity = await _db.DraftPicks.FindAsync(id);
        if (entity is null) return false;
        _db.DraftPicks.Remove(entity);
        await _db.SaveChangesAsync();
        return true;
    }

}
