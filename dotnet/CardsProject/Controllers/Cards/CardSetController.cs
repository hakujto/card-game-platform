using Microsoft.AspNetCore.Mvc;
using System.ComponentModel.DataAnnotations;
using CardsProject.Services.Cards;

namespace CardsProject.Controllers.Cards;

[ApiController]
[Route("api/card_sets")]
[Microsoft.AspNetCore.Authorization.AllowAnonymous]
public class CardSetController : ControllerBase
{
    private readonly CardSetService _svc;

    public CardSetController(CardSetService svc) => _svc = svc;

    [HttpGet]
    public async Task<IActionResult> List()
    {
        var items = await _svc.GetAllAsync();
        return Ok(items);
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CardSetDto dto)
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
    public async Task<IActionResult> Update(int id, [FromBody] CardSetDto dto)
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

    [HttpGet("{id:int}/standard-legal")]
    public async System.Threading.Tasks.Task<IActionResult> IsLegalInStandard(int id)
    {
        try
        {
            var result = await _svc.IsLegalInStandardAsync(id);
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

    [HttpGet("{id:int}/rarity-count")]
    public async System.Threading.Tasks.Task<IActionResult> CardCountByRarity(int id, [FromQuery] string rarity)
    {
        try
        {
            var result = await _svc.CardCountByRarityAsync(id, rarity);
            return Ok(result);
        }
        catch (KeyNotFoundException) { return NotFound(); }
    }

    [HttpPost("{id:int}/rotate")]
    public async System.Threading.Tasks.Task<IActionResult> RotateOut(int id)
    {
        try
        {
            await _svc.RotateOutAsync(id);
            return NoContent();
        }
        catch (KeyNotFoundException) { return NotFound(); }
    }
}
