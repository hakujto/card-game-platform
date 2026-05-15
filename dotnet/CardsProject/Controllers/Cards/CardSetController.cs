using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using CardsProject.Infrastructure;
using CardsProject.Domain.Cards;
using CardsProject.Services.Cards;

namespace CardsProject.Controllers.Cards;

[ApiController]
[Route("api/card_sets")]
[Microsoft.AspNetCore.Authorization.AllowAnonymous]
public class CardSetController : ControllerBase
{
    private readonly AppDbContext _db;
    public CardSetController(AppDbContext db) => _db = db;

    [HttpGet]
    public async Task<IActionResult> List()
    {
        var items = await _db.CardSets.AsNoTracking().ToListAsync();
        return Ok(items);
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CardSetDto dto)
    {
        var entity = new CardSet();
        if (dto.Name is not null) entity.Name = dto.Name;
        if (dto.Code is not null) entity.Code = dto.Code;
        if (dto.ReleaseDate is not null) entity.ReleaseDate = dto.ReleaseDate.Value;
        if (dto.SetType is not null && Enum.TryParse<CardSetSetTypeType>(dto.SetType, out var setTypeVal)) entity.SetType = setTypeVal;
        if (dto.TotalCards is not null) entity.TotalCards = dto.TotalCards.Value;
        if (dto.Description is not null) entity.Description = dto.Description;
        if (dto.LogoUrl is not null) entity.LogoUrl = dto.LogoUrl;
        if (!TryValidateModel(entity)) return BadRequest(ModelState);
        _db.CardSets.Add(entity);
        await _db.SaveChangesAsync();
        return CreatedAtAction(nameof(Show), new { id = entity.Id }, entity);
    }

    [HttpGet("{id:int}")]
    public async Task<IActionResult> Show(int id)
    {
        var entity = await _db.CardSets.FindAsync(id);
        if (entity is null) return NotFound();
        return Ok(entity);
    }

    [HttpPut("{id:int}")]
    [HttpPatch("{id:int}")]
    public async Task<IActionResult> Update(int id, [FromBody] CardSetDto dto)
    {
        var entity = await _db.CardSets.FindAsync(id);
        if (entity is null) return NotFound();
        if (dto.Name is not null) entity.Name = dto.Name;
        if (dto.Code is not null) entity.Code = dto.Code;
        if (dto.ReleaseDate is not null) entity.ReleaseDate = dto.ReleaseDate.Value;
        if (dto.SetType is not null && Enum.TryParse<CardSetSetTypeType>(dto.SetType, out var setTypeVal)) entity.SetType = setTypeVal;
        if (dto.TotalCards is not null) entity.TotalCards = dto.TotalCards.Value;
        if (dto.Description is not null) entity.Description = dto.Description;
        if (dto.LogoUrl is not null) entity.LogoUrl = dto.LogoUrl;
        if (!TryValidateModel(entity)) return BadRequest(ModelState);
        await _db.SaveChangesAsync();
        return Ok(entity);
    }

    [HttpDelete("{id:int}")]
    public async Task<IActionResult> Delete(int id)
    {
        var entity = await _db.CardSets.FindAsync(id);
        if (entity is null) return NotFound();
        _db.CardSets.Remove(entity);
        await _db.SaveChangesAsync();
        return NoContent();
    }

}
