using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using CardsProject.Infrastructure;
using CardsProject.Domain.Content;
using CardsProject.Services.Content;
using Stream = CardsProject.Domain.Content.Stream;

namespace CardsProject.Controllers.Content;

[ApiController]
[Route("api/streams")]
[Microsoft.AspNetCore.Authorization.AllowAnonymous]
public class StreamController : ControllerBase
{
    private readonly AppDbContext _db;
    private readonly StreamService _svc;

    public StreamController(AppDbContext db, StreamService svc) { _db = db; _svc = svc; }

    [HttpGet]
    public async Task<IActionResult> List()
    {
        var items = await _db.Streams.AsNoTracking().ToListAsync();
        return Ok(items);
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] StreamDto dto)
    {
        var entity = new Stream();
        if (dto.Title is not null) entity.Title = dto.Title;
        if (dto.StreamUrl is not null) entity.StreamUrl = dto.StreamUrl;
        if (dto.Platform is not null && Enum.TryParse<StreamPlatformType>(dto.Platform, out var platformVal)) entity.Platform = platformVal;
        if (dto.Status is not null && Enum.TryParse<StreamStatusType>(dto.Status, out var statusVal)) entity.Status = statusVal;
        if (dto.ViewerCountPeak is not null) entity.ViewerCountPeak = dto.ViewerCountPeak.Value;
        if (dto.ScheduledStart is not null) entity.ScheduledStart = dto.ScheduledStart.Value;
        if (dto.ActualStart is not null) entity.ActualStart = dto.ActualStart.Value;
        if (dto.EndedAt is not null) entity.EndedAt = dto.EndedAt.Value;
        if (dto.VodUrl is not null) entity.VodUrl = dto.VodUrl;
        if (dto.TournamentId is not null) entity.TournamentId = dto.TournamentId;
        if (dto.StreamerId is not null) entity.StreamerId = dto.StreamerId;
        if (!TryValidateModel(entity)) return BadRequest(ModelState);
        try { _svc.Validate(entity); } catch (InvalidOperationException ex) { return BadRequest(new { error = ex.Message }); }
        _db.Streams.Add(entity);
        await _db.SaveChangesAsync();
        return CreatedAtAction(nameof(Show), new { id = entity.Id }, entity);
    }

    [HttpGet("{id:int}")]
    public async Task<IActionResult> Show(int id)
    {
        var entity = await _db.Streams.FindAsync(id);
        if (entity is null) return NotFound();
        return Ok(entity);
    }

    [HttpPut("{id:int}")]
    [HttpPatch("{id:int}")]
    public async Task<IActionResult> Update(int id, [FromBody] StreamDto dto)
    {
        var entity = await _db.Streams.FindAsync(id);
        if (entity is null) return NotFound();
        if (dto.Title is not null) entity.Title = dto.Title;
        if (dto.StreamUrl is not null) entity.StreamUrl = dto.StreamUrl;
        if (dto.Platform is not null && Enum.TryParse<StreamPlatformType>(dto.Platform, out var platformVal)) entity.Platform = platformVal;
        if (dto.Status is not null && Enum.TryParse<StreamStatusType>(dto.Status, out var statusVal)) entity.Status = statusVal;
        if (dto.ViewerCountPeak is not null) entity.ViewerCountPeak = dto.ViewerCountPeak.Value;
        if (dto.ScheduledStart is not null) entity.ScheduledStart = dto.ScheduledStart.Value;
        if (dto.ActualStart is not null) entity.ActualStart = dto.ActualStart.Value;
        if (dto.EndedAt is not null) entity.EndedAt = dto.EndedAt.Value;
        if (dto.VodUrl is not null) entity.VodUrl = dto.VodUrl;
        if (dto.TournamentId is not null) entity.TournamentId = dto.TournamentId;
        if (dto.StreamerId is not null) entity.StreamerId = dto.StreamerId;
        if (!TryValidateModel(entity)) return BadRequest(ModelState);
        try { _svc.Validate(entity); } catch (InvalidOperationException ex) { return BadRequest(new { error = ex.Message }); }
        await _db.SaveChangesAsync();
        return Ok(entity);
    }

    [HttpDelete("{id:int}")]
    public async Task<IActionResult> Delete(int id)
    {
        var entity = await _db.Streams.FindAsync(id);
        if (entity is null) return NotFound();
        _db.Streams.Remove(entity);
        await _db.SaveChangesAsync();
        return NoContent();
    }

    [HttpPost("{id:int}/live")]
    public async System.Threading.Tasks.Task<IActionResult> GoLive(int id)
    {
        var entity = await _db.Streams.FindAsync(id);
        if (entity is null) return NotFound();
        entity.GoLive();
        await _db.SaveChangesAsync();
        return NoContent();
    }

    [HttpPost("{id:int}/end")]
    public async System.Threading.Tasks.Task<IActionResult> End(int id)
    {
        var entity = await _db.Streams.FindAsync(id);
        if (entity is null) return NotFound();
        entity.End();
        await _db.SaveChangesAsync();
        return NoContent();
    }

    [HttpPatch("{id:int}/viewers")]
    public async System.Threading.Tasks.Task<IActionResult> UpdateViewerPeak(int id, [FromBody] System.Collections.Generic.Dictionary<string, object> body)
    {
        var entity = await _db.Streams.FindAsync(id);
        if (entity is null) return NotFound();
        var count = (int)body["count"];
        entity.UpdateViewerPeak(count);
        await _db.SaveChangesAsync();
        return NoContent();
    }
}
