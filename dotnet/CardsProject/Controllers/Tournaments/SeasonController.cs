using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using CardsProject.Infrastructure;
using CardsProject.Domain.Tournaments;

namespace CardsProject.Controllers.Tournaments;

[ApiController]
[Route("api/seasons")]
public class SeasonController : ControllerBase
{
    private readonly AppDbContext _db;

    public SeasonController(AppDbContext db) => _db = db;

    [HttpGet]
    public async Task<IActionResult> List()
    {
        var items = await _db.Seasons.AsNoTracking().ToListAsync();
        return Ok(items);
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] SeasonDto dto)
    {
        var entity = new Season();
        if (dto.Name is not null) entity.Name = dto.Name;
        if (dto.StartDate is not null) entity.StartDate = dto.StartDate.Value;
        if (dto.EndDate is not null) entity.EndDate = dto.EndDate.Value;
        if (dto.Format is not null && Enum.TryParse<SeasonFormatType>(dto.Format, out var formatVal)) entity.Format = formatVal;
        if (dto.IsActive is not null) entity.IsActive = dto.IsActive.Value;
        if (dto.RewardDescription is not null) entity.RewardDescription = dto.RewardDescription;
        _db.Seasons.Add(entity);
        await _db.SaveChangesAsync();
        return CreatedAtAction(nameof(Show), new { id = entity.Id }, entity);
    }

    [HttpGet("{id:int}")]
    public async Task<IActionResult> Show(int id)
    {
        var entity = await _db.Seasons.FindAsync(id);
        if (entity is null) return NotFound();
        return Ok(entity);
    }

    [HttpPut("{id:int}")]
    [HttpPatch("{id:int}")]
    public async Task<IActionResult> Update(int id, [FromBody] SeasonDto dto)
    {
        var entity = await _db.Seasons.FindAsync(id);
        if (entity is null) return NotFound();
        if (dto.Name is not null) entity.Name = dto.Name;
        if (dto.StartDate is not null) entity.StartDate = dto.StartDate.Value;
        if (dto.EndDate is not null) entity.EndDate = dto.EndDate.Value;
        if (dto.Format is not null && Enum.TryParse<SeasonFormatType>(dto.Format, out var formatVal)) entity.Format = formatVal;
        if (dto.IsActive is not null) entity.IsActive = dto.IsActive.Value;
        if (dto.RewardDescription is not null) entity.RewardDescription = dto.RewardDescription;
        await _db.SaveChangesAsync();
        return Ok(entity);
    }

    [HttpDelete("{id:int}")]
    public async Task<IActionResult> Delete(int id)
    {
        var entity = await _db.Seasons.FindAsync(id);
        if (entity is null) return NotFound();
        _db.Seasons.Remove(entity);
        await _db.SaveChangesAsync();
        return NoContent();
    }
}
