using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using CardsProject.Infrastructure;
using CardsProject.Domain.Cards;
using CardsProject.Services.Cards;

namespace CardsProject.Controllers.Cards;

[ApiController]
[Route("api/cards")]
[Microsoft.AspNetCore.Authorization.AllowAnonymous]
public class CardController : ControllerBase
{
    private readonly AppDbContext _db;
    private readonly CardService _svc;

    public CardController(AppDbContext db, CardService svc) { _db = db; _svc = svc; }

    [HttpGet]
    public async Task<IActionResult> List()
    {
        var items = await _db.Cards.AsNoTracking().ToListAsync();
        return Ok(items);
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CardDto dto)
    {
        var entity = new Card();
        if (dto.Name is not null) entity.Name = dto.Name;
        if (dto.CardType is not null && Enum.TryParse<CardCardTypeType>(dto.CardType, out var cardTypeVal)) entity.CardType = cardTypeVal;
        if (dto.Rarity is not null && Enum.TryParse<CardRarityType>(dto.Rarity, out var rarityVal)) entity.Rarity = rarityVal;
        if (dto.ManaCost is not null) entity.ManaCost = dto.ManaCost.Value;
        if (dto.ManaColors is not null && Enum.TryParse<CardManaColorsType>(dto.ManaColors, out var manaColorsVal)) entity.ManaColors = manaColorsVal;
        if (dto.Attack is not null) entity.Attack = dto.Attack.Value;
        if (dto.Defense is not null) entity.Defense = dto.Defense.Value;
        if (dto.Loyalty is not null) entity.Loyalty = dto.Loyalty.Value;
        if (dto.Description is not null) entity.Description = dto.Description;
        if (dto.FlavorText is not null) entity.FlavorText = dto.FlavorText;
        if (dto.ImageUrl is not null) entity.ImageUrl = dto.ImageUrl;
        if (dto.ArtistName is not null) entity.ArtistName = dto.ArtistName;
        if (dto.LegalFormats is not null && Enum.TryParse<CardLegalFormatsType>(dto.LegalFormats, out var legalFormatsVal)) entity.LegalFormats = legalFormatsVal;
        if (dto.IsBanned is not null) entity.IsBanned = dto.IsBanned.Value;
        if (dto.IsRestricted is not null) entity.IsRestricted = dto.IsRestricted.Value;
        if (dto.PowerLevel is not null) entity.PowerLevel = dto.PowerLevel.Value;
        if (dto.SetId is not null) entity.SetId = dto.SetId;
        if (!TryValidateModel(entity)) return BadRequest(ModelState);
        try { _svc.Validate(entity); } catch (InvalidOperationException ex) { return BadRequest(new { error = ex.Message }); }
        _db.Cards.Add(entity);
        await _db.SaveChangesAsync();
        return CreatedAtAction(nameof(Show), new { id = entity.Id }, entity);
    }

    [HttpGet("{id:int}")]
    public async Task<IActionResult> Show(int id)
    {
        var entity = await _db.Cards.FindAsync(id);
        if (entity is null) return NotFound();
        return Ok(entity);
    }

    [HttpPut("{id:int}")]
    [HttpPatch("{id:int}")]
    public async Task<IActionResult> Update(int id, [FromBody] CardDto dto)
    {
        var entity = await _db.Cards.FindAsync(id);
        if (entity is null) return NotFound();
        if (dto.Name is not null) entity.Name = dto.Name;
        if (dto.CardType is not null && Enum.TryParse<CardCardTypeType>(dto.CardType, out var cardTypeVal)) entity.CardType = cardTypeVal;
        if (dto.Rarity is not null && Enum.TryParse<CardRarityType>(dto.Rarity, out var rarityVal)) entity.Rarity = rarityVal;
        if (dto.ManaCost is not null) entity.ManaCost = dto.ManaCost.Value;
        if (dto.ManaColors is not null && Enum.TryParse<CardManaColorsType>(dto.ManaColors, out var manaColorsVal)) entity.ManaColors = manaColorsVal;
        if (dto.Attack is not null) entity.Attack = dto.Attack.Value;
        if (dto.Defense is not null) entity.Defense = dto.Defense.Value;
        if (dto.Loyalty is not null) entity.Loyalty = dto.Loyalty.Value;
        if (dto.Description is not null) entity.Description = dto.Description;
        if (dto.FlavorText is not null) entity.FlavorText = dto.FlavorText;
        if (dto.ImageUrl is not null) entity.ImageUrl = dto.ImageUrl;
        if (dto.ArtistName is not null) entity.ArtistName = dto.ArtistName;
        if (dto.LegalFormats is not null && Enum.TryParse<CardLegalFormatsType>(dto.LegalFormats, out var legalFormatsVal)) entity.LegalFormats = legalFormatsVal;
        if (dto.IsBanned is not null) entity.IsBanned = dto.IsBanned.Value;
        if (dto.IsRestricted is not null) entity.IsRestricted = dto.IsRestricted.Value;
        if (dto.PowerLevel is not null) entity.PowerLevel = dto.PowerLevel.Value;
        if (dto.SetId is not null) entity.SetId = dto.SetId;
        if (!TryValidateModel(entity)) return BadRequest(ModelState);
        try { _svc.Validate(entity); } catch (InvalidOperationException ex) { return BadRequest(new { error = ex.Message }); }
        await _db.SaveChangesAsync();
        return Ok(entity);
    }

    [HttpDelete("{id:int}")]
    public async Task<IActionResult> Delete(int id)
    {
        var entity = await _db.Cards.FindAsync(id);
        if (entity is null) return NotFound();
        _db.Cards.Remove(entity);
        await _db.SaveChangesAsync();
        return NoContent();
    }

    [HttpPost("{id:int}/ban")]
    public async System.Threading.Tasks.Task<IActionResult> Ban(int id)
    {
        var entity = await _db.Cards.FindAsync(id);
        if (entity is null) return NotFound();
        entity.Ban();
        await _db.SaveChangesAsync();
        return NoContent();
    }

    [HttpPost("{id:int}/unban")]
    public async System.Threading.Tasks.Task<IActionResult> Unban(int id)
    {
        var entity = await _db.Cards.FindAsync(id);
        if (entity is null) return NotFound();
        entity.Unban();
        await _db.SaveChangesAsync();
        return NoContent();
    }

    [HttpPost("{id:int}/restrict")]
    public async System.Threading.Tasks.Task<IActionResult> Restrict(int id)
    {
        var entity = await _db.Cards.FindAsync(id);
        if (entity is null) return NotFound();
        entity.Restrict();
        await _db.SaveChangesAsync();
        return NoContent();
    }

    [HttpPost("{id:int}/unrestrict")]
    public async System.Threading.Tasks.Task<IActionResult> Unrestrict(int id)
    {
        var entity = await _db.Cards.FindAsync(id);
        if (entity is null) return NotFound();
        entity.Unrestrict();
        await _db.SaveChangesAsync();
        return NoContent();
    }

    [HttpGet("{id:int}/value")]
    public async System.Threading.Tasks.Task<IActionResult> CalculateValue(int id)
    {
        var entity = await _db.Cards.FindAsync(id);
        if (entity is null) return NotFound();
        var result = entity.CalculateValue();
        await _db.SaveChangesAsync();
        return Ok(result);
    }
}
