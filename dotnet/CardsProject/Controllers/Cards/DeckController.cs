using Microsoft.AspNetCore.Mvc;
using System.ComponentModel.DataAnnotations;
using CardsProject.Services.Cards;

namespace CardsProject.Controllers.Cards;

[ApiController]
[Route("api/decks")]
[Microsoft.AspNetCore.Authorization.AllowAnonymous]
public class DeckController : ControllerBase
{
    private readonly DeckService _svc;

    public DeckController(DeckService svc) => _svc = svc;

    [HttpGet]
    public async Task<IActionResult> List()
    {
        var items = await _svc.GetAllAsync();
        return Ok(items);
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] DeckDto dto)
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
    public async Task<IActionResult> Update(int id, [FromBody] DeckDto dto)
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

    [HttpGet("{id:int}/validate")]
    public async System.Threading.Tasks.Task<IActionResult> ValidateSize(int id)
    {
        try
        {
            var result = await _svc.ValidateSizeAsync(id);
            return Ok(result);
        }
        catch (KeyNotFoundException) { return NotFound(); }
    }

    [HttpPost("{id:int}/cards")]
    public async System.Threading.Tasks.Task<IActionResult> AddCard(int id, [FromBody] System.Collections.Generic.Dictionary<string, object> body)
    {
        try
        {
            var cardId = (int)body["card_id"];
            var quantity = (int)body["quantity"];
            await _svc.AddCardAsync(id, cardId, quantity);
            return NoContent();
        }
        catch (KeyNotFoundException) { return NotFound(); }
    }

    [HttpDelete("{id:int}/cards/{card_id}")]
    public async System.Threading.Tasks.Task<IActionResult> RemoveCard(int id, int cardId)
    {
        try
        {
            await _svc.RemoveCardAsync(id, cardId);
            return NoContent();
        }
        catch (KeyNotFoundException) { return NotFound(); }
    }

    [HttpGet("{id:int}/win-rate")]
    public async System.Threading.Tasks.Task<IActionResult> WinRate(int id)
    {
        try
        {
            var result = await _svc.WinRateAsync(id);
            return Ok(result);
        }
        catch (KeyNotFoundException) { return NotFound(); }
    }

    [HttpPost("{id:int}/clone")]
    public async System.Threading.Tasks.Task<IActionResult> Clone(int id)
    {
        try
        {
            var result = await _svc.CloneAsync(id);
            return Ok(result);
        }
        catch (KeyNotFoundException) { return NotFound(); }
    }

    [HttpPost("{id:int}/publish")]
    public async System.Threading.Tasks.Task<IActionResult> Publish(int id)
    {
        try
        {
            await _svc.PublishAsync(id);
            return NoContent();
        }
        catch (KeyNotFoundException) { return NotFound(); }
    }

    [HttpPost("{id:int}/unpublish")]
    public async System.Threading.Tasks.Task<IActionResult> Unpublish(int id)
    {
        try
        {
            await _svc.UnpublishAsync(id);
            return NoContent();
        }
        catch (KeyNotFoundException) { return NotFound(); }
    }

    [HttpPost("{id:int}/certify")]
    public async System.Threading.Tasks.Task<IActionResult> CertifyTournamentLegal(int id)
    {
        try
        {
            var result = await _svc.CertifyTournamentLegalAsync(id);
            return Ok(result);
        }
        catch (KeyNotFoundException) { return NotFound(); }
    }
}
