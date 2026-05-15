using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using CardsProject.Infrastructure;
using CardsProject.Domain.Tournaments;
using CardsProject.Services.Tournaments;

namespace CardsProject.Controllers.Tournaments;

[ApiController]
[Route("api/tournament_judges")]
[Microsoft.AspNetCore.Authorization.AllowAnonymous]
public class TournamentJudgeController : ControllerBase
{
    private readonly AppDbContext _db;
    public TournamentJudgeController(AppDbContext db) => _db = db;

    [HttpGet]
    public async Task<IActionResult> List()
    {
        var items = await _db.TournamentJudges.AsNoTracking().ToListAsync();
        return Ok(items);
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] TournamentJudgeDto dto)
    {
        var entity = new TournamentJudge();
        if (dto.Role is not null && Enum.TryParse<TournamentJudgeRoleType>(dto.Role, out var roleVal)) entity.Role = roleVal;
        if (dto.TournamentId is not null) entity.TournamentId = dto.TournamentId;
        if (dto.PlayerId is not null) entity.PlayerId = dto.PlayerId;
        if (!TryValidateModel(entity)) return BadRequest(ModelState);
        _db.TournamentJudges.Add(entity);
        await _db.SaveChangesAsync();
        return CreatedAtAction(nameof(Show), new { id = entity.Id }, entity);
    }

    [HttpGet("{id:int}")]
    public async Task<IActionResult> Show(int id)
    {
        var entity = await _db.TournamentJudges.FindAsync(id);
        if (entity is null) return NotFound();
        return Ok(entity);
    }

    [HttpPut("{id:int}")]
    [HttpPatch("{id:int}")]
    public async Task<IActionResult> Update(int id, [FromBody] TournamentJudgeDto dto)
    {
        var entity = await _db.TournamentJudges.FindAsync(id);
        if (entity is null) return NotFound();
        if (dto.Role is not null && Enum.TryParse<TournamentJudgeRoleType>(dto.Role, out var roleVal)) entity.Role = roleVal;
        if (dto.TournamentId is not null) entity.TournamentId = dto.TournamentId;
        if (dto.PlayerId is not null) entity.PlayerId = dto.PlayerId;
        if (!TryValidateModel(entity)) return BadRequest(ModelState);
        await _db.SaveChangesAsync();
        return Ok(entity);
    }

    [HttpDelete("{id:int}")]
    public async Task<IActionResult> Delete(int id)
    {
        var entity = await _db.TournamentJudges.FindAsync(id);
        if (entity is null) return NotFound();
        _db.TournamentJudges.Remove(entity);
        await _db.SaveChangesAsync();
        return NoContent();
    }

}
