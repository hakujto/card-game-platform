using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using CardsProject.Infrastructure;
using CardsProject.Domain.Tournaments;
using CardsProject.Services.Tournaments;

namespace CardsProject.Controllers.Tournaments;

[ApiController]
[Route("api/awarded_prizes")]
[Microsoft.AspNetCore.Authorization.AllowAnonymous]
public class AwardedPrizeController : ControllerBase
{
    private readonly AppDbContext _db;
    private readonly AwardedPrizeService _svc;

    public AwardedPrizeController(AppDbContext db, AwardedPrizeService svc) { _db = db; _svc = svc; }

    [HttpGet]
    public async Task<IActionResult> List()
    {
        var items = await _db.AwardedPrizes.AsNoTracking().ToListAsync();
        return Ok(items);
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] AwardedPrizeDto dto)
    {
        var entity = new AwardedPrize();
        if (dto.FinalPlacement is not null) entity.FinalPlacement = dto.FinalPlacement.Value;
        if (dto.AwardedAt is not null) entity.AwardedAt = dto.AwardedAt.Value;
        if (dto.Claimed is not null) entity.Claimed = dto.Claimed.Value;
        if (dto.ClaimedAt is not null) entity.ClaimedAt = dto.ClaimedAt.Value;
        if (dto.PrizeId is not null) entity.PrizeId = dto.PrizeId;
        if (dto.PlayerId is not null) entity.PlayerId = dto.PlayerId;
        if (!TryValidateModel(entity)) return BadRequest(ModelState);
        try { _svc.Validate(entity); } catch (InvalidOperationException ex) { return BadRequest(new { error = ex.Message }); }
        _db.AwardedPrizes.Add(entity);
        await _db.SaveChangesAsync();
        return CreatedAtAction(nameof(Show), new { id = entity.Id }, entity);
    }

    [HttpGet("{id:int}")]
    public async Task<IActionResult> Show(int id)
    {
        var entity = await _db.AwardedPrizes.FindAsync(id);
        if (entity is null) return NotFound();
        return Ok(entity);
    }

    [HttpPut("{id:int}")]
    [HttpPatch("{id:int}")]
    public async Task<IActionResult> Update(int id, [FromBody] AwardedPrizeDto dto)
    {
        var entity = await _db.AwardedPrizes.FindAsync(id);
        if (entity is null) return NotFound();
        if (dto.FinalPlacement is not null) entity.FinalPlacement = dto.FinalPlacement.Value;
        if (dto.AwardedAt is not null) entity.AwardedAt = dto.AwardedAt.Value;
        if (dto.Claimed is not null) entity.Claimed = dto.Claimed.Value;
        if (dto.ClaimedAt is not null) entity.ClaimedAt = dto.ClaimedAt.Value;
        if (dto.PrizeId is not null) entity.PrizeId = dto.PrizeId;
        if (dto.PlayerId is not null) entity.PlayerId = dto.PlayerId;
        if (!TryValidateModel(entity)) return BadRequest(ModelState);
        try { _svc.Validate(entity); } catch (InvalidOperationException ex) { return BadRequest(new { error = ex.Message }); }
        await _db.SaveChangesAsync();
        return Ok(entity);
    }

    [HttpDelete("{id:int}")]
    public async Task<IActionResult> Delete(int id)
    {
        var entity = await _db.AwardedPrizes.FindAsync(id);
        if (entity is null) return NotFound();
        _db.AwardedPrizes.Remove(entity);
        await _db.SaveChangesAsync();
        return NoContent();
    }

}
