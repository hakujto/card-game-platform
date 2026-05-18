using Microsoft.EntityFrameworkCore;
using System.ComponentModel.DataAnnotations;
using CardsProject.Controllers.Tournaments;
using CardsProject.Domain.Tournaments;
using CardsProject.Infrastructure;

namespace CardsProject.Services.Tournaments;

public class TournamentJudgeService
{
    private readonly AppDbContext _db;

    public TournamentJudgeService(AppDbContext db) => _db = db;

    private static void ValidateEntity(object entity)
    {
        var ctx = new ValidationContext(entity);
        Validator.ValidateObject(entity, ctx, validateAllProperties: true);
    }

    public async Task<List<TournamentJudge>> GetAllAsync()
        => await _db.TournamentJudges.AsNoTracking().ToListAsync();

    public async Task<TournamentJudge?> GetByIdAsync(int id)
        => await _db.TournamentJudges.FindAsync(id);

    public async Task<TournamentJudge> CreateAsync(TournamentJudgeDto dto)
    {
        var entity = new TournamentJudge();
        if (dto.Role is not null && Enum.TryParse<TournamentJudgeRoleType>(dto.Role, out var roleVal)) entity.Role = roleVal;
        if (dto.TournamentId is not null) entity.TournamentId = dto.TournamentId;
        if (dto.PlayerId is not null) entity.PlayerId = dto.PlayerId;
        ValidateEntity(entity);
        _db.TournamentJudges.Add(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async Task<TournamentJudge?> UpdateAsync(int id, TournamentJudgeDto dto)
    {
        var entity = await _db.TournamentJudges.FindAsync(id);
        if (entity is null) return null;
        if (dto.Role is not null && Enum.TryParse<TournamentJudgeRoleType>(dto.Role, out var roleVal)) entity.Role = roleVal;
        if (dto.TournamentId is not null) entity.TournamentId = dto.TournamentId;
        if (dto.PlayerId is not null) entity.PlayerId = dto.PlayerId;
        ValidateEntity(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async Task<bool> DeleteAsync(int id)
    {
        var entity = await _db.TournamentJudges.FindAsync(id);
        if (entity is null) return false;
        _db.TournamentJudges.Remove(entity);
        await _db.SaveChangesAsync();
        return true;
    }

    public async System.Threading.Tasks.Task<bool> PromoteToHeadAsync(int id)
    {
        var entity = await _db.TournamentJudges.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("TournamentJudge not found: " + id);
        entity.PromoteToHead();
        await _db.SaveChangesAsync();
        return true;
    }
    public async System.Threading.Tasks.Task<bool> RemoveAsync(int id)
    {
        var entity = await _db.TournamentJudges.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("TournamentJudge not found: " + id);
        entity.Remove();
        await _db.SaveChangesAsync();
        return true;
    }
}
