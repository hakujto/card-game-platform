using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using CardsProject.Infrastructure;
using CardsProject.Domain.Players;
using CardsProject.Services.Players;

namespace CardsProject.Controllers.Players;

[ApiController]
[Route("api/players")]
[Microsoft.AspNetCore.Authorization.AllowAnonymous]
public class PlayerController : ControllerBase
{
    private readonly AppDbContext _db;
    public PlayerController(AppDbContext db) => _db = db;

    [HttpGet]
    public async Task<IActionResult> List()
    {
        var items = await _db.Players.AsNoTracking().ToListAsync();
        return Ok(items);
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] PlayerDto dto)
    {
        var entity = new Player();
        if (dto.DisplayName is not null) entity.DisplayName = dto.DisplayName;
        if (dto.Rank is not null && Enum.TryParse<PlayerRankType>(dto.Rank, out var rankVal)) entity.Rank = rankVal;
        if (dto.Rating is not null) entity.Rating = dto.Rating.Value;
        if (dto.PeakRating is not null) entity.PeakRating = dto.PeakRating.Value;
        if (dto.Bio is not null) entity.Bio = dto.Bio;
        if (dto.CountryCode is not null) entity.CountryCode = dto.CountryCode;
        if (dto.AvatarUrl is not null) entity.AvatarUrl = dto.AvatarUrl;
        if (dto.PreferredFormat is not null && Enum.TryParse<PlayerPreferredFormatType>(dto.PreferredFormat, out var preferredFormatVal)) entity.PreferredFormat = preferredFormatVal;
        if (dto.IsVerified is not null) entity.IsVerified = dto.IsVerified.Value;
        if (dto.CreatedAt is not null) entity.CreatedAt = dto.CreatedAt.Value;
        if (dto.LastActiveAt is not null) entity.LastActiveAt = dto.LastActiveAt.Value;
        if (dto.UserId is not null) entity.UserId = dto.UserId;
        if (!TryValidateModel(entity)) return BadRequest(ModelState);
        _db.Players.Add(entity);
        await _db.SaveChangesAsync();
        return CreatedAtAction(nameof(Show), new { id = entity.Id }, entity);
    }

    [HttpGet("{id:int}")]
    public async Task<IActionResult> Show(int id)
    {
        var entity = await _db.Players.FindAsync(id);
        if (entity is null) return NotFound();
        return Ok(entity);
    }

    [HttpPut("{id:int}")]
    [HttpPatch("{id:int}")]
    public async Task<IActionResult> Update(int id, [FromBody] PlayerDto dto)
    {
        var entity = await _db.Players.FindAsync(id);
        if (entity is null) return NotFound();
        if (dto.DisplayName is not null) entity.DisplayName = dto.DisplayName;
        if (dto.Rank is not null && Enum.TryParse<PlayerRankType>(dto.Rank, out var rankVal)) entity.Rank = rankVal;
        if (dto.Rating is not null) entity.Rating = dto.Rating.Value;
        if (dto.PeakRating is not null) entity.PeakRating = dto.PeakRating.Value;
        if (dto.Bio is not null) entity.Bio = dto.Bio;
        if (dto.CountryCode is not null) entity.CountryCode = dto.CountryCode;
        if (dto.AvatarUrl is not null) entity.AvatarUrl = dto.AvatarUrl;
        if (dto.PreferredFormat is not null && Enum.TryParse<PlayerPreferredFormatType>(dto.PreferredFormat, out var preferredFormatVal)) entity.PreferredFormat = preferredFormatVal;
        if (dto.IsVerified is not null) entity.IsVerified = dto.IsVerified.Value;
        if (dto.CreatedAt is not null) entity.CreatedAt = dto.CreatedAt.Value;
        if (dto.LastActiveAt is not null) entity.LastActiveAt = dto.LastActiveAt.Value;
        if (dto.UserId is not null) entity.UserId = dto.UserId;
        if (!TryValidateModel(entity)) return BadRequest(ModelState);
        await _db.SaveChangesAsync();
        return Ok(entity);
    }

    [HttpDelete("{id:int}")]
    public async Task<IActionResult> Delete(int id)
    {
        var entity = await _db.Players.FindAsync(id);
        if (entity is null) return NotFound();
        _db.Players.Remove(entity);
        await _db.SaveChangesAsync();
        return NoContent();
    }

    [HttpPost("{id:int}/promote")]
    public async System.Threading.Tasks.Task<IActionResult> Promote(int id)
    {
        var entity = await _db.Players.FindAsync(id);
        if (entity is null) return NotFound();
        var result = entity.Promote();
        await _db.SaveChangesAsync();
        return Ok(result);
    }

    [HttpPost("{id:int}/demote")]
    public async System.Threading.Tasks.Task<IActionResult> Demote(int id)
    {
        var entity = await _db.Players.FindAsync(id);
        if (entity is null) return NotFound();
        var result = entity.Demote();
        await _db.SaveChangesAsync();
        return Ok(result);
    }

    [HttpPost("{id:int}/win")]
    public async System.Threading.Tasks.Task<IActionResult> RecordWin(int id)
    {
        var entity = await _db.Players.FindAsync(id);
        if (entity is null) return NotFound();
        entity.RecordWin();
        await _db.SaveChangesAsync();
        return NoContent();
    }

    [HttpPost("{id:int}/loss")]
    public async System.Threading.Tasks.Task<IActionResult> RecordLoss(int id)
    {
        var entity = await _db.Players.FindAsync(id);
        if (entity is null) return NotFound();
        entity.RecordLoss();
        await _db.SaveChangesAsync();
        return NoContent();
    }

    [HttpGet("{id:int}/win-rate")]
    public async System.Threading.Tasks.Task<IActionResult> WinRate(int id)
    {
        var entity = await _db.Players.FindAsync(id);
        if (entity is null) return NotFound();
        var result = entity.WinRate();
        await _db.SaveChangesAsync();
        return Ok(result);
    }

    [HttpPost("{id:int}/verify")]
    public async System.Threading.Tasks.Task<IActionResult> Verify(int id)
    {
        var entity = await _db.Players.FindAsync(id);
        if (entity is null) return NotFound();
        entity.Verify();
        await _db.SaveChangesAsync();
        return NoContent();
    }

    [HttpPatch("{id:int}/rating")]
    public async System.Threading.Tasks.Task<IActionResult> UpdateRating(int id, [FromBody] System.Collections.Generic.Dictionary<string, object> body)
    {
        var entity = await _db.Players.FindAsync(id);
        if (entity is null) return NotFound();
        var delta = (int)body["delta"];
        entity.UpdateRating(delta);
        await _db.SaveChangesAsync();
        return NoContent();
    }
}
