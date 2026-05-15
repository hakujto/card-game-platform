using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using CardsProject.Infrastructure;
using CardsProject.Domain.Tournaments;
using CardsProject.Services.Tournaments;

namespace CardsProject.Controllers.Tournaments;

[ApiController]
[Route("api/tournament_prizes")]
[Microsoft.AspNetCore.Authorization.AllowAnonymous]
public class TournamentPrizeController : ControllerBase
{
    private readonly AppDbContext _db;
    public TournamentPrizeController(AppDbContext db) => _db = db;

    [HttpGet]
    public async Task<IActionResult> List()
    {
        var items = await _db.TournamentPrizes.AsNoTracking().ToListAsync();
        return Ok(items);
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] TournamentPrizeDto dto)
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
        if (!TryValidateModel(entity)) return BadRequest(ModelState);
        _db.TournamentPrizes.Add(entity);
        await _db.SaveChangesAsync();
        return CreatedAtAction(nameof(Show), new { id = entity.Id }, entity);
    }

    [HttpGet("{id:int}")]
    public async Task<IActionResult> Show(int id)
    {
        var entity = await _db.TournamentPrizes.FindAsync(id);
        if (entity is null) return NotFound();
        return Ok(entity);
    }

    [HttpPut("{id:int}")]
    [HttpPatch("{id:int}")]
    public async Task<IActionResult> Update(int id, [FromBody] TournamentPrizeDto dto)
    {
        var entity = await _db.TournamentPrizes.FindAsync(id);
        if (entity is null) return NotFound();
        if (dto.PlacementFrom is not null) entity.PlacementFrom = dto.PlacementFrom.Value;
        if (dto.PlacementTo is not null) entity.PlacementTo = dto.PlacementTo.Value;
        if (dto.PrizeType is not null && Enum.TryParse<TournamentPrizePrizeTypeType>(dto.PrizeType, out var prizeTypeVal)) entity.PrizeType = prizeTypeVal;
        if (dto.Amount is not null) entity.Amount = dto.Amount.Value;
        if (dto.Description is not null) entity.Description = dto.Description;
        if (dto.PacksCount is not null) entity.PacksCount = dto.PacksCount.Value;
        if (dto.SeasonPoints is not null) entity.SeasonPoints = dto.SeasonPoints.Value;
        if (dto.TournamentId is not null) entity.TournamentId = dto.TournamentId;
        if (!TryValidateModel(entity)) return BadRequest(ModelState);
        await _db.SaveChangesAsync();
        return Ok(entity);
    }

    [HttpDelete("{id:int}")]
    public async Task<IActionResult> Delete(int id)
    {
        var entity = await _db.TournamentPrizes.FindAsync(id);
        if (entity is null) return NotFound();
        _db.TournamentPrizes.Remove(entity);
        await _db.SaveChangesAsync();
        return NoContent();
    }

}
