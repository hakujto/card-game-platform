using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using CardsProject.Infrastructure;
using CardsProject.Domain.Tournaments;
using CardsProject.Services.Tournaments;

namespace CardsProject.Controllers.Tournaments;

[ApiController]
[Route("api/games")]
[Microsoft.AspNetCore.Authorization.AllowAnonymous]
public class GameController : ControllerBase
{
    private readonly AppDbContext _db;
    private readonly GameService _svc;

    public GameController(AppDbContext db, GameService svc) { _db = db; _svc = svc; }

    [HttpGet]
    public async Task<IActionResult> List()
    {
        var items = await _db.Games.AsNoTracking().ToListAsync();
        return Ok(items);
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] GameDto dto)
    {
        var entity = new Game();
        if (dto.GameNumber is not null) entity.GameNumber = dto.GameNumber.Value;
        if (dto.WinnerSide is not null && Enum.TryParse<GameWinnerSideType>(dto.WinnerSide, out var winnerSideVal)) entity.WinnerSide = winnerSideVal;
        if (dto.TurnsPlayed is not null) entity.TurnsPlayed = dto.TurnsPlayed.Value;
        if (dto.DurationSeconds is not null) entity.DurationSeconds = dto.DurationSeconds.Value;
        if (dto.EndedBy is not null && Enum.TryParse<GameEndedByType>(dto.EndedBy, out var endedByVal)) entity.EndedBy = endedByVal;
        if (dto.ReplayUrl is not null) entity.ReplayUrl = dto.ReplayUrl;
        if (dto.MatchId is not null) entity.MatchId = dto.MatchId;
        if (dto.WinnerId is not null) entity.WinnerId = dto.WinnerId;
        if (!TryValidateModel(entity)) return BadRequest(ModelState);
        try { _svc.Validate(entity); } catch (InvalidOperationException ex) { return BadRequest(new { error = ex.Message }); }
        _db.Games.Add(entity);
        await _db.SaveChangesAsync();
        return CreatedAtAction(nameof(Show), new { id = entity.Id }, entity);
    }

    [HttpGet("{id:int}")]
    public async Task<IActionResult> Show(int id)
    {
        var entity = await _db.Games.FindAsync(id);
        if (entity is null) return NotFound();
        return Ok(entity);
    }

    [HttpPut("{id:int}")]
    [HttpPatch("{id:int}")]
    public async Task<IActionResult> Update(int id, [FromBody] GameDto dto)
    {
        var entity = await _db.Games.FindAsync(id);
        if (entity is null) return NotFound();
        if (dto.GameNumber is not null) entity.GameNumber = dto.GameNumber.Value;
        if (dto.WinnerSide is not null && Enum.TryParse<GameWinnerSideType>(dto.WinnerSide, out var winnerSideVal)) entity.WinnerSide = winnerSideVal;
        if (dto.TurnsPlayed is not null) entity.TurnsPlayed = dto.TurnsPlayed.Value;
        if (dto.DurationSeconds is not null) entity.DurationSeconds = dto.DurationSeconds.Value;
        if (dto.EndedBy is not null && Enum.TryParse<GameEndedByType>(dto.EndedBy, out var endedByVal)) entity.EndedBy = endedByVal;
        if (dto.ReplayUrl is not null) entity.ReplayUrl = dto.ReplayUrl;
        if (dto.MatchId is not null) entity.MatchId = dto.MatchId;
        if (dto.WinnerId is not null) entity.WinnerId = dto.WinnerId;
        if (!TryValidateModel(entity)) return BadRequest(ModelState);
        try { _svc.Validate(entity); } catch (InvalidOperationException ex) { return BadRequest(new { error = ex.Message }); }
        await _db.SaveChangesAsync();
        return Ok(entity);
    }

    [HttpDelete("{id:int}")]
    public async Task<IActionResult> Delete(int id)
    {
        var entity = await _db.Games.FindAsync(id);
        if (entity is null) return NotFound();
        _db.Games.Remove(entity);
        await _db.SaveChangesAsync();
        return NoContent();
    }

    [HttpPost("{id:int}/winner")]
    public async System.Threading.Tasks.Task<IActionResult> RecordWinner(int id, [FromBody] System.Collections.Generic.Dictionary<string, object> body)
    {
        var entity = await _db.Games.FindAsync(id);
        if (entity is null) return NotFound();
        var winnerSide = (string)body["winner_side"];
        entity.RecordWinner(winnerSide);
        await _db.SaveChangesAsync();
        return NoContent();
    }
}
