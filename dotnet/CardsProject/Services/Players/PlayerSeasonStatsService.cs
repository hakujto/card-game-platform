using Microsoft.EntityFrameworkCore;
using System.ComponentModel.DataAnnotations;
using CardsProject.Controllers.Players;
using CardsProject.Domain.Players;
using CardsProject.Infrastructure;

namespace CardsProject.Services.Players;

public class PlayerSeasonStatsService
{
    private readonly AppDbContext _db;

    public PlayerSeasonStatsService(AppDbContext db) => _db = db;

    private static void ValidateEntity(object entity)
    {
        var ctx = new ValidationContext(entity);
        Validator.ValidateObject(entity, ctx, validateAllProperties: true);
    }

    public async Task<List<PlayerSeasonStats>> GetAllAsync()
        => await _db.PlayerSeasonStatses.AsNoTracking().ToListAsync();

    public async Task<PlayerSeasonStats?> GetByIdAsync(int id)
        => await _db.PlayerSeasonStatses.FindAsync(id);

    public async Task<PlayerSeasonStats> CreateAsync(PlayerSeasonStatsDto dto)
    {
        var entity = new PlayerSeasonStats();
        if (dto.Wins is not null) entity.Wins = dto.Wins.Value;
        if (dto.Losses is not null) entity.Losses = dto.Losses.Value;
        if (dto.Draws is not null) entity.Draws = dto.Draws.Value;
        if (dto.TournamentWins is not null) entity.TournamentWins = dto.TournamentWins.Value;
        if (dto.HighestRank is not null && Enum.TryParse<PlayerSeasonStatsHighestRankType>(dto.HighestRank, out var highestRankVal)) entity.HighestRank = highestRankVal;
        if (dto.SeasonPoints is not null) entity.SeasonPoints = dto.SeasonPoints.Value;
        if (dto.PlayerId is not null) entity.PlayerId = dto.PlayerId;
        if (dto.SeasonId is not null) entity.SeasonId = dto.SeasonId;
        ValidateEntity(entity);
        _db.PlayerSeasonStatses.Add(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async Task<PlayerSeasonStats?> UpdateAsync(int id, PlayerSeasonStatsDto dto)
    {
        var entity = await _db.PlayerSeasonStatses.FindAsync(id);
        if (entity is null) return null;
        if (dto.Wins is not null) entity.Wins = dto.Wins.Value;
        if (dto.Losses is not null) entity.Losses = dto.Losses.Value;
        if (dto.Draws is not null) entity.Draws = dto.Draws.Value;
        if (dto.TournamentWins is not null) entity.TournamentWins = dto.TournamentWins.Value;
        if (dto.HighestRank is not null && Enum.TryParse<PlayerSeasonStatsHighestRankType>(dto.HighestRank, out var highestRankVal)) entity.HighestRank = highestRankVal;
        if (dto.SeasonPoints is not null) entity.SeasonPoints = dto.SeasonPoints.Value;
        if (dto.PlayerId is not null) entity.PlayerId = dto.PlayerId;
        if (dto.SeasonId is not null) entity.SeasonId = dto.SeasonId;
        ValidateEntity(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async Task<bool> DeleteAsync(int id)
    {
        var entity = await _db.PlayerSeasonStatses.FindAsync(id);
        if (entity is null) return false;
        _db.PlayerSeasonStatses.Remove(entity);
        await _db.SaveChangesAsync();
        return true;
    }

}
