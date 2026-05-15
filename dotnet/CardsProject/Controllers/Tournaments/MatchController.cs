using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using CardsProject.Infrastructure;
using CardsProject.Domain.Tournaments;
using CardsProject.Services.Tournaments;

namespace CardsProject.Controllers.Tournaments;

[ApiController]
[Route("api/matches")]
[Microsoft.AspNetCore.Authorization.AllowAnonymous]
public class MatchController : ControllerBase
{
    private readonly AppDbContext _db;
    private readonly MatchService _svc;

    public MatchController(AppDbContext db, MatchService svc) { _db = db; _svc = svc; }

    [HttpGet]
    public async Task<IActionResult> List()
    {
        var items = await _db.Matches.AsNoTracking().ToListAsync();
        return Ok(items);
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] MatchDto dto)
    {
        var entity = new Match();
        if (dto.TableNumber is not null) entity.TableNumber = dto.TableNumber.Value;
        if (dto.Status is not null && Enum.TryParse<MatchStatusType>(dto.Status, out var statusVal)) entity.Status = statusVal;
        if (dto.Player1Wins is not null) entity.Player1Wins = dto.Player1Wins.Value;
        if (dto.Player2Wins is not null) entity.Player2Wins = dto.Player2Wins.Value;
        if (dto.StartedAt is not null) entity.StartedAt = dto.StartedAt.Value;
        if (dto.EndedAt is not null) entity.EndedAt = dto.EndedAt.Value;
        if (dto.ResultNotes is not null) entity.ResultNotes = dto.ResultNotes;
        if (dto.RoundId is not null) entity.RoundId = dto.RoundId;
        if (dto.Player1Id is not null) entity.Player1Id = dto.Player1Id;
        if (dto.Player2Id is not null) entity.Player2Id = dto.Player2Id;
        if (!TryValidateModel(entity)) return BadRequest(ModelState);
        try { _svc.Validate(entity); } catch (InvalidOperationException ex) { return BadRequest(new { error = ex.Message }); }
        _db.Matches.Add(entity);
        await _db.SaveChangesAsync();
        return CreatedAtAction(nameof(Show), new { id = entity.Id }, entity);
    }

    [HttpGet("{id:int}")]
    public async Task<IActionResult> Show(int id)
    {
        var entity = await _db.Matches.FindAsync(id);
        if (entity is null) return NotFound();
        return Ok(entity);
    }

    [HttpPut("{id:int}")]
    [HttpPatch("{id:int}")]
    public async Task<IActionResult> Update(int id, [FromBody] MatchDto dto)
    {
        var entity = await _db.Matches.FindAsync(id);
        if (entity is null) return NotFound();
        if (dto.TableNumber is not null) entity.TableNumber = dto.TableNumber.Value;
        if (dto.Status is not null && Enum.TryParse<MatchStatusType>(dto.Status, out var statusVal)) entity.Status = statusVal;
        if (dto.Player1Wins is not null) entity.Player1Wins = dto.Player1Wins.Value;
        if (dto.Player2Wins is not null) entity.Player2Wins = dto.Player2Wins.Value;
        if (dto.StartedAt is not null) entity.StartedAt = dto.StartedAt.Value;
        if (dto.EndedAt is not null) entity.EndedAt = dto.EndedAt.Value;
        if (dto.ResultNotes is not null) entity.ResultNotes = dto.ResultNotes;
        if (dto.RoundId is not null) entity.RoundId = dto.RoundId;
        if (dto.Player1Id is not null) entity.Player1Id = dto.Player1Id;
        if (dto.Player2Id is not null) entity.Player2Id = dto.Player2Id;
        if (!TryValidateModel(entity)) return BadRequest(ModelState);
        try { _svc.Validate(entity); } catch (InvalidOperationException ex) { return BadRequest(new { error = ex.Message }); }
        await _db.SaveChangesAsync();
        return Ok(entity);
    }

    [HttpDelete("{id:int}")]
    public async Task<IActionResult> Delete(int id)
    {
        var entity = await _db.Matches.FindAsync(id);
        if (entity is null) return NotFound();
        _db.Matches.Remove(entity);
        await _db.SaveChangesAsync();
        return NoContent();
    }

    [HttpPost("{id:int}/record")]
    public async System.Threading.Tasks.Task<IActionResult> RecordResult(int id, [FromBody] System.Collections.Generic.Dictionary<string, object> body)
    {
        var entity = await _db.Matches.FindAsync(id);
        if (entity is null) return NotFound();
        var p1Wins = (int)body["p1_wins"];
        var p2Wins = (int)body["p2_wins"];
        entity.RecordResult(p1Wins, p2Wins);
        await _db.SaveChangesAsync();
        return NoContent();
    }

    [HttpGet("{id:int}/winner")]
    public async System.Threading.Tasks.Task<IActionResult> DetermineWinner(int id)
    {
        var entity = await _db.Matches.FindAsync(id);
        if (entity is null) return NotFound();
        var result = entity.DetermineWinner();
        await _db.SaveChangesAsync();
        return Ok(result);
    }

    [HttpPost("{id:int}/draw")]
    public async System.Threading.Tasks.Task<IActionResult> Draw(int id)
    {
        var entity = await _db.Matches.FindAsync(id);
        if (entity is null) return NotFound();
        entity.Draw();
        await _db.SaveChangesAsync();
        return NoContent();
    }
}
