using Microsoft.EntityFrameworkCore;
using System.ComponentModel.DataAnnotations;
using CardsProject.Controllers.Tournaments;
using CardsProject.Domain.Tournaments;
using CardsProject.Infrastructure;

namespace CardsProject.Services.Tournaments;

public class TournamentPrizeService
{
    private readonly AppDbContext _db;

    public TournamentPrizeService(AppDbContext db) => _db = db;

    private static void ValidateEntity(object entity)
    {
        var ctx = new ValidationContext(entity);
        Validator.ValidateObject(entity, ctx, validateAllProperties: true);
    }

    public async Task<List<TournamentPrize>> GetAllAsync()
        => await _db.TournamentPrizes.AsNoTracking().ToListAsync();

    public async Task<TournamentPrize?> GetByIdAsync(int id)
        => await _db.TournamentPrizes.FindAsync(id);

    public async Task<TournamentPrize> CreateAsync(TournamentPrizeDto dto)
    {
        var entity = new TournamentPrize();
        if (dto.PlacementFrom is not null) entity.PlacementFrom = dto.PlacementFrom.Value;
        if (dto.PlacementTo is not null) entity.PlacementTo = dto.PlacementTo.Value;
        if (dto.PrizeType is not null && Enum.TryParse<TournamentPrizePrizeTypeType>(dto.PrizeType, out var prizeTypeVal)) entity.PrizeType = prizeTypeVal;
        if (dto.Amount is not null) entity.Amount = dto.Amount.Value;
        if (dto.Description is not null) entity.Description = dto.Description;
        if (dto.PacksCount is not null) entity.PacksCount = dto.PacksCount.Value;
        if (dto.SeasonPoints is not null) entity.SeasonPoints = dto.SeasonPoints.Value;
        if (dto.TournamentId is not null) entity.TournamentId = dto.TournamentId;
        ValidateEntity(entity);
        _db.TournamentPrizes.Add(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async Task<TournamentPrize?> UpdateAsync(int id, TournamentPrizeDto dto)
    {
        var entity = await _db.TournamentPrizes.FindAsync(id);
        if (entity is null) return null;
        if (dto.PlacementFrom is not null) entity.PlacementFrom = dto.PlacementFrom.Value;
        if (dto.PlacementTo is not null) entity.PlacementTo = dto.PlacementTo.Value;
        if (dto.PrizeType is not null && Enum.TryParse<TournamentPrizePrizeTypeType>(dto.PrizeType, out var prizeTypeVal)) entity.PrizeType = prizeTypeVal;
        if (dto.Amount is not null) entity.Amount = dto.Amount.Value;
        if (dto.Description is not null) entity.Description = dto.Description;
        if (dto.PacksCount is not null) entity.PacksCount = dto.PacksCount.Value;
        if (dto.SeasonPoints is not null) entity.SeasonPoints = dto.SeasonPoints.Value;
        if (dto.TournamentId is not null) entity.TournamentId = dto.TournamentId;
        ValidateEntity(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async Task<bool> DeleteAsync(int id)
    {
        var entity = await _db.TournamentPrizes.FindAsync(id);
        if (entity is null) return false;
        _db.TournamentPrizes.Remove(entity);
        await _db.SaveChangesAsync();
        return true;
    }

}
