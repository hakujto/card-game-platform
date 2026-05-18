using Microsoft.AspNetCore.Mvc;
using System.ComponentModel.DataAnnotations;
using CardsProject.Services.Cards;

namespace CardsProject.Controllers.Cards;

[ApiController]
[Route("api/cards")]
[Microsoft.AspNetCore.Authorization.AllowAnonymous]
public class CardController : ControllerBase
{
    private readonly CardService _svc;

    public CardController(CardService svc) => _svc = svc;

    [HttpGet]
    public async Task<IActionResult> List()
    {
        var items = await _svc.GetAllAsync();
        return Ok(items);
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CardDto dto)
    {
        if (!ModelState.IsValid) return BadRequest(ModelState);
        try
        {
            var entity = await _svc.CreateAsync(dto);
            return CreatedAtAction(nameof(Show), new { id = entity.Id }, entity);
        }
        catch (ValidationException ex) { return BadRequest(new { error = ex.Message }); }
        catch (InvalidOperationException ex) { return BadRequest(new { error = ex.Message }); }
    }

    [HttpGet("{id:int}")]
    public async Task<IActionResult> Show(int id)
    {
        var entity = await _svc.GetByIdAsync(id);
        if (entity is null) return NotFound();
        return Ok(entity);
    }

    [HttpPut("{id:int}")]
    [HttpPatch("{id:int}")]
    public async Task<IActionResult> Update(int id, [FromBody] CardDto dto)
    {
        try
        {
            var entity = await _svc.UpdateAsync(id, dto);
            if (entity is null) return NotFound();
            return Ok(entity);
        }
        catch (ValidationException ex) { return BadRequest(new { error = ex.Message }); }
        catch (InvalidOperationException ex) { return BadRequest(new { error = ex.Message }); }
    }

    [HttpDelete("{id:int}")]
    public async Task<IActionResult> Delete(int id)
    {
        var deleted = await _svc.DeleteAsync(id);
        if (!deleted) return NotFound();
        return NoContent();
    }

    [HttpPost("{id:int}/ban")]
    public async System.Threading.Tasks.Task<IActionResult> Ban(int id)
    {
        try
        {
            await _svc.BanAsync(id);
            return NoContent();
        }
        catch (KeyNotFoundException) { return NotFound(); }
    }

    [HttpPost("{id:int}/unban")]
    public async System.Threading.Tasks.Task<IActionResult> Unban(int id)
    {
        try
        {
            await _svc.UnbanAsync(id);
            return NoContent();
        }
        catch (KeyNotFoundException) { return NotFound(); }
    }

    [HttpPost("{id:int}/restrict")]
    public async System.Threading.Tasks.Task<IActionResult> Restrict(int id)
    {
        try
        {
            await _svc.RestrictAsync(id);
            return NoContent();
        }
        catch (KeyNotFoundException) { return NotFound(); }
    }

    [HttpPost("{id:int}/unrestrict")]
    public async System.Threading.Tasks.Task<IActionResult> Unrestrict(int id)
    {
        try
        {
            await _svc.UnrestrictAsync(id);
            return NoContent();
        }
        catch (KeyNotFoundException) { return NotFound(); }
    }

    [HttpGet("{id:int}/value")]
    public async System.Threading.Tasks.Task<IActionResult> CalculateValue(int id)
    {
        try
        {
            var result = await _svc.CalculateValueAsync(id);
            return Ok(result);
        }
        catch (KeyNotFoundException) { return NotFound(); }
    }

    [HttpPost("{id:int}/rarity-bonus")]
    public async System.Threading.Tasks.Task<IActionResult> ApplyRarityBonus(int id, [FromBody] System.Collections.Generic.Dictionary<string, object> body)
    {
        try
        {
            var multiplier = (int)body["multiplier"];
            var result = await _svc.ApplyRarityBonusAsync(id, multiplier);
            return Ok(result);
        }
        catch (KeyNotFoundException) { return NotFound(); }
    }

    [HttpGet("{id:int}/legal")]
    public async System.Threading.Tasks.Task<IActionResult> IsLegalInFormat(int id, [FromQuery] string format)
    {
        try
        {
            var result = await _svc.IsLegalInFormatAsync(id, format);
            return Ok(result);
        }
        catch (KeyNotFoundException) { return NotFound(); }
    }
}
