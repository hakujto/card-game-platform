using Microsoft.EntityFrameworkCore;
using System.ComponentModel.DataAnnotations;
using CardsProject.Controllers.Players;
using CardsProject.Domain.Players;
using CardsProject.Infrastructure;

namespace CardsProject.Services.Players;

public class FriendshipService
{
    private readonly AppDbContext _db;

    public FriendshipService(AppDbContext db) => _db = db;

    private static void ValidateEntity(object entity)
    {
        var ctx = new ValidationContext(entity);
        Validator.ValidateObject(entity, ctx, validateAllProperties: true);
    }

    public async Task<List<Friendship>> GetAllAsync()
        => await _db.Friendships.AsNoTracking().ToListAsync();

    public async Task<Friendship?> GetByIdAsync(int id)
        => await _db.Friendships.FindAsync(id);

    public async Task<Friendship> CreateAsync(FriendshipDto dto)
    {
        var entity = new Friendship();
        if (dto.Status is not null && Enum.TryParse<FriendshipStatusType>(dto.Status, out var statusVal)) entity.Status = statusVal;
        if (dto.CreatedAt is not null) entity.CreatedAt = dto.CreatedAt.Value;
        if (dto.RequesterId is not null) entity.RequesterId = dto.RequesterId;
        if (dto.ReceiverId is not null) entity.ReceiverId = dto.ReceiverId;
        ValidateEntity(entity);
        _db.Friendships.Add(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async Task<Friendship?> UpdateAsync(int id, FriendshipDto dto)
    {
        var entity = await _db.Friendships.FindAsync(id);
        if (entity is null) return null;
        if (dto.Status is not null && Enum.TryParse<FriendshipStatusType>(dto.Status, out var statusVal)) entity.Status = statusVal;
        if (dto.CreatedAt is not null) entity.CreatedAt = dto.CreatedAt.Value;
        if (dto.RequesterId is not null) entity.RequesterId = dto.RequesterId;
        if (dto.ReceiverId is not null) entity.ReceiverId = dto.ReceiverId;
        ValidateEntity(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async Task<bool> DeleteAsync(int id)
    {
        var entity = await _db.Friendships.FindAsync(id);
        if (entity is null) return false;
        _db.Friendships.Remove(entity);
        await _db.SaveChangesAsync();
        return true;
    }

    public async System.Threading.Tasks.Task<bool> AcceptAsync(int id)
    {
        var entity = await _db.Friendships.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("Friendship not found: " + id);
        entity.Accept();
        await _db.SaveChangesAsync();
        return true;
    }
    public async System.Threading.Tasks.Task<bool> DeclineAsync(int id)
    {
        var entity = await _db.Friendships.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("Friendship not found: " + id);
        entity.Decline();
        await _db.SaveChangesAsync();
        return true;
    }
    public async System.Threading.Tasks.Task<bool> BlockAsync(int id)
    {
        var entity = await _db.Friendships.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("Friendship not found: " + id);
        entity.Block();
        await _db.SaveChangesAsync();
        return true;
    }
}
