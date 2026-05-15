using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using CardsProject.Infrastructure;
using CardsProject.Domain.Tournaments;
using CardsProject.Services.Tournaments;

namespace CardsProject.Controllers.Tournaments;

[ApiController]
[Route("api/tournament_registrations")]
[Microsoft.AspNetCore.Authorization.AllowAnonymous]
public class TournamentRegistrationController : ControllerBase
{
    private readonly AppDbContext _db;
    public TournamentRegistrationController(AppDbContext db) => _db = db;

    [HttpGet]
    public async Task<IActionResult> List()
    {
        var items = await _db.TournamentRegistrations.AsNoTracking().ToListAsync();
        return Ok(items);
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] TournamentRegistrationDto dto)
    {
        var entity = new TournamentRegistration();
        if (dto.Status is not null && Enum.TryParse<TournamentRegistrationStatusType>(dto.Status, out var statusVal)) entity.Status = statusVal;
        if (dto.Seed is not null) entity.Seed = dto.Seed.Value;
        if (dto.FinalStanding is not null) entity.FinalStanding = dto.FinalStanding.Value;
        if (dto.PointsEarned is not null) entity.PointsEarned = dto.PointsEarned.Value;
        if (dto.RegisteredAt is not null) entity.RegisteredAt = dto.RegisteredAt.Value;
        if (dto.TournamentId is not null) entity.TournamentId = dto.TournamentId;
        if (dto.PlayerId is not null) entity.PlayerId = dto.PlayerId;
        if (dto.DeckId is not null) entity.DeckId = dto.DeckId;
        if (!TryValidateModel(entity)) return BadRequest(ModelState);
        _db.TournamentRegistrations.Add(entity);
        await _db.SaveChangesAsync();
        return CreatedAtAction(nameof(Show), new { id = entity.Id }, entity);
    }

    [HttpGet("{id:int}")]
    public async Task<IActionResult> Show(int id)
    {
        var entity = await _db.TournamentRegistrations.FindAsync(id);
        if (entity is null) return NotFound();
        return Ok(entity);
    }

    [HttpPut("{id:int}")]
    [HttpPatch("{id:int}")]
    public async Task<IActionResult> Update(int id, [FromBody] TournamentRegistrationDto dto)
    {
        var entity = await _db.TournamentRegistrations.FindAsync(id);
        if (entity is null) return NotFound();
        if (dto.Status is not null && Enum.TryParse<TournamentRegistrationStatusType>(dto.Status, out var statusVal)) entity.Status = statusVal;
        if (dto.Seed is not null) entity.Seed = dto.Seed.Value;
        if (dto.FinalStanding is not null) entity.FinalStanding = dto.FinalStanding.Value;
        if (dto.PointsEarned is not null) entity.PointsEarned = dto.PointsEarned.Value;
        if (dto.RegisteredAt is not null) entity.RegisteredAt = dto.RegisteredAt.Value;
        if (dto.TournamentId is not null) entity.TournamentId = dto.TournamentId;
        if (dto.PlayerId is not null) entity.PlayerId = dto.PlayerId;
        if (dto.DeckId is not null) entity.DeckId = dto.DeckId;
        if (!TryValidateModel(entity)) return BadRequest(ModelState);
        await _db.SaveChangesAsync();
        return Ok(entity);
    }

    [HttpDelete("{id:int}")]
    public async Task<IActionResult> Delete(int id)
    {
        var entity = await _db.TournamentRegistrations.FindAsync(id);
        if (entity is null) return NotFound();
        _db.TournamentRegistrations.Remove(entity);
        await _db.SaveChangesAsync();
        return NoContent();
    }

    [HttpPost("{id:int}/withdraw")]
    public async System.Threading.Tasks.Task<IActionResult> Withdraw(int id)
    {
        var entity = await _db.TournamentRegistrations.FindAsync(id);
        if (entity is null) return NotFound();
        entity.Withdraw();
        await _db.SaveChangesAsync();
        return NoContent();
    }

    [HttpPost("{id:int}/disqualify")]
    public async System.Threading.Tasks.Task<IActionResult> Disqualify(int id, [FromBody] System.Collections.Generic.Dictionary<string, object> body)
    {
        var entity = await _db.TournamentRegistrations.FindAsync(id);
        if (entity is null) return NotFound();
        var reason = (string)body["reason"];
        entity.Disqualify(reason);
        await _db.SaveChangesAsync();
        return NoContent();
    }

    [HttpPost("{id:int}/promote")]
    public async System.Threading.Tasks.Task<IActionResult> PromoteFromWaitlist(int id)
    {
        var entity = await _db.TournamentRegistrations.FindAsync(id);
        if (entity is null) return NotFound();
        entity.PromoteFromWaitlist();
        await _db.SaveChangesAsync();
        return NoContent();
    }
}
