using Microsoft.EntityFrameworkCore;
using System.ComponentModel.DataAnnotations;
using CardsProject.Controllers.Content;
using CardsProject.Domain.Content;
using CardsProject.Infrastructure;

namespace CardsProject.Services.Content;

public class DraftParticipantService
{
    private readonly AppDbContext _db;

    public DraftParticipantService(AppDbContext db) => _db = db;

    private static void ValidateEntity(object entity)
    {
        var ctx = new ValidationContext(entity);
        Validator.ValidateObject(entity, ctx, validateAllProperties: true);
    }

    public async Task<List<DraftParticipant>> GetAllAsync()
        => await _db.DraftParticipants.AsNoTracking().ToListAsync();

    public async Task<DraftParticipant?> GetByIdAsync(int id)
        => await _db.DraftParticipants.FindAsync(id);

    public async Task<DraftParticipant> CreateAsync(DraftParticipantDto dto)
    {
        var entity = new DraftParticipant();
        if (dto.SeatNumber is not null) entity.SeatNumber = dto.SeatNumber.Value;
        if (dto.JoinedAt is not null) entity.JoinedAt = dto.JoinedAt.Value;
        if (dto.SessionId is not null) entity.SessionId = dto.SessionId;
        if (dto.PlayerId is not null) entity.PlayerId = dto.PlayerId;
        ValidateEntity(entity);
        _db.DraftParticipants.Add(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async Task<DraftParticipant?> UpdateAsync(int id, DraftParticipantDto dto)
    {
        var entity = await _db.DraftParticipants.FindAsync(id);
        if (entity is null) return null;
        if (dto.SeatNumber is not null) entity.SeatNumber = dto.SeatNumber.Value;
        if (dto.JoinedAt is not null) entity.JoinedAt = dto.JoinedAt.Value;
        if (dto.SessionId is not null) entity.SessionId = dto.SessionId;
        if (dto.PlayerId is not null) entity.PlayerId = dto.PlayerId;
        ValidateEntity(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async Task<bool> DeleteAsync(int id)
    {
        var entity = await _db.DraftParticipants.FindAsync(id);
        if (entity is null) return false;
        _db.DraftParticipants.Remove(entity);
        await _db.SaveChangesAsync();
        return true;
    }

    public async System.Threading.Tasks.Task<bool> PickCardAsync(int id, int cardId, int packNumber)
    {
        var entity = await _db.DraftParticipants.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("DraftParticipant not found: " + id);
        entity.PickCard(cardId, packNumber);
        await _db.SaveChangesAsync();
        return true;
    }
}
