using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using CardsProject.Infrastructure;
using CardsProject.Domain.Cards;
using CardsProject.Services.Cards;

namespace CardsProject.Controllers.Cards;

[ApiController]
[Route("api/decks")]
[Microsoft.AspNetCore.Authorization.AllowAnonymous]
public class DeckController : ControllerBase
{
    private readonly AppDbContext _db;
    public DeckController(AppDbContext db) => _db = db;

    [HttpGet]
    public async Task<IActionResult> List()
    {
        var items = await _db.Decks.AsNoTracking().ToListAsync();
        return Ok(items);
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] DeckDto dto)
    {
        var entity = new Deck();
        if (dto.Name is not null) entity.Name = dto.Name;
        if (dto.Description is not null) entity.Description = dto.Description;
        if (dto.Format is not null && Enum.TryParse<DeckFormatType>(dto.Format, out var formatVal)) entity.Format = formatVal;
        if (dto.IsPublic is not null) entity.IsPublic = dto.IsPublic.Value;
        if (dto.IsTournamentLegal is not null) entity.IsTournamentLegal = dto.IsTournamentLegal.Value;
        if (dto.Archetype is not null && Enum.TryParse<DeckArchetypeType>(dto.Archetype, out var archetypeVal)) entity.Archetype = archetypeVal;
        if (dto.Wins is not null) entity.Wins = dto.Wins.Value;
        if (dto.Losses is not null) entity.Losses = dto.Losses.Value;
        if (dto.CreatedAt is not null) entity.CreatedAt = dto.CreatedAt.Value;
        if (dto.UpdatedAt is not null) entity.UpdatedAt = dto.UpdatedAt.Value;
        if (dto.PlayerId is not null) entity.PlayerId = dto.PlayerId;
        if (!TryValidateModel(entity)) return BadRequest(ModelState);
        _db.Decks.Add(entity);
        await _db.SaveChangesAsync();
        return CreatedAtAction(nameof(Show), new { id = entity.Id }, entity);
    }

    [HttpGet("{id:int}")]
    public async Task<IActionResult> Show(int id)
    {
        var entity = await _db.Decks.FindAsync(id);
        if (entity is null) return NotFound();
        return Ok(entity);
    }

    [HttpPut("{id:int}")]
    [HttpPatch("{id:int}")]
    public async Task<IActionResult> Update(int id, [FromBody] DeckDto dto)
    {
        var entity = await _db.Decks.FindAsync(id);
        if (entity is null) return NotFound();
        if (dto.Name is not null) entity.Name = dto.Name;
        if (dto.Description is not null) entity.Description = dto.Description;
        if (dto.Format is not null && Enum.TryParse<DeckFormatType>(dto.Format, out var formatVal)) entity.Format = formatVal;
        if (dto.IsPublic is not null) entity.IsPublic = dto.IsPublic.Value;
        if (dto.IsTournamentLegal is not null) entity.IsTournamentLegal = dto.IsTournamentLegal.Value;
        if (dto.Archetype is not null && Enum.TryParse<DeckArchetypeType>(dto.Archetype, out var archetypeVal)) entity.Archetype = archetypeVal;
        if (dto.Wins is not null) entity.Wins = dto.Wins.Value;
        if (dto.Losses is not null) entity.Losses = dto.Losses.Value;
        if (dto.CreatedAt is not null) entity.CreatedAt = dto.CreatedAt.Value;
        if (dto.UpdatedAt is not null) entity.UpdatedAt = dto.UpdatedAt.Value;
        if (dto.PlayerId is not null) entity.PlayerId = dto.PlayerId;
        if (!TryValidateModel(entity)) return BadRequest(ModelState);
        await _db.SaveChangesAsync();
        return Ok(entity);
    }

    [HttpDelete("{id:int}")]
    public async Task<IActionResult> Delete(int id)
    {
        var entity = await _db.Decks.FindAsync(id);
        if (entity is null) return NotFound();
        _db.Decks.Remove(entity);
        await _db.SaveChangesAsync();
        return NoContent();
    }

    [HttpGet("{id:int}/validate")]
    public async System.Threading.Tasks.Task<IActionResult> ValidateSize(int id)
    {
        var entity = await _db.Decks.FindAsync(id);
        if (entity is null) return NotFound();
        var result = entity.ValidateSize();
        await _db.SaveChangesAsync();
        return Ok(result);
    }

    [HttpPost("{id:int}/clone")]
    public async System.Threading.Tasks.Task<IActionResult> Clone(int id)
    {
        var entity = await _db.Decks.FindAsync(id);
        if (entity is null) return NotFound();
        var result = entity.Clone();
        await _db.SaveChangesAsync();
        return Ok(result);
    }

    [HttpPost("{id:int}/publish")]
    public async System.Threading.Tasks.Task<IActionResult> Publish(int id)
    {
        var entity = await _db.Decks.FindAsync(id);
        if (entity is null) return NotFound();
        entity.Publish();
        await _db.SaveChangesAsync();
        return NoContent();
    }

    [HttpPost("{id:int}/unpublish")]
    public async System.Threading.Tasks.Task<IActionResult> Unpublish(int id)
    {
        var entity = await _db.Decks.FindAsync(id);
        if (entity is null) return NotFound();
        entity.Unpublish();
        await _db.SaveChangesAsync();
        return NoContent();
    }

    [HttpPost("{id:int}/certify")]
    public async System.Threading.Tasks.Task<IActionResult> CertifyTournamentLegal(int id)
    {
        var entity = await _db.Decks.FindAsync(id);
        if (entity is null) return NotFound();
        var result = entity.CertifyTournamentLegal();
        await _db.SaveChangesAsync();
        return Ok(result);
    }
}
