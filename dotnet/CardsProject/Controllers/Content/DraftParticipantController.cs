using Microsoft.AspNetCore.Mvc;
using System.ComponentModel.DataAnnotations;
using CardsProject.Services.Content;

namespace CardsProject.Controllers.Content;

[ApiController]
[Route("api/draft_participants")]
[Microsoft.AspNetCore.Authorization.AllowAnonymous]
public class DraftParticipantController : ControllerBase
{
    private readonly DraftParticipantService _svc;

    public DraftParticipantController(DraftParticipantService svc) => _svc = svc;

    [HttpGet]
    public async Task<IActionResult> List()
    {
        var items = await _svc.GetAllAsync();
        return Ok(items);
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] DraftParticipantDto dto)
    {
        if (!ModelState.IsValid) return BadRequest(ModelState);
        try
        {
            var entity = await _svc.CreateAsync(dto);
            return CreatedAtAction(nameof(Show), new { id = entity.Id }, entity);
        }
        catch (ValidationException ex) { return BadRequest(new { error = ex.Message }); }
        catch (InvalidOperationException ex) { return BadRequest(new { error = ex.Message }); }
        catch (Microsoft.EntityFrameworkCore.DbUpdateException ex) { return BadRequest(new { error = ex.InnerException?.Message ?? ex.Message }); }
    }

    [HttpGet("{id:int}")]
    public async Task<IActionResult> Show(int id)
    {
        var entity = await _svc.GetByIdAsync(id);
        if (entity is null) return NotFound();
        return Ok(entity);
    }

    [HttpPost("{id:int}/pick")]
    public async System.Threading.Tasks.Task<IActionResult> PickCard(int id, [FromBody] System.Collections.Generic.Dictionary<string, object> body)
    {
        try
        {
            var cardId = (int)body["card_id"];
            var packNumber = (int)body["pack_number"];
            await _svc.PickCardAsync(id, cardId, packNumber);
            return NoContent();
        }
        catch (ArgumentException ex) { return UnprocessableEntity(new { error = ex.Message }); }
        catch (KeyNotFoundException) { return NotFound(); }
    }

    [HttpGet("{id:int}/card-count")]
    public async System.Threading.Tasks.Task<IActionResult> DraftedCardCount(int id)
    {
        try
        {
            var result = await _svc.DraftedCardCountAsync(id);
            return Ok(result);
        }
        catch (ArgumentException ex) { return UnprocessableEntity(new { error = ex.Message }); }
        catch (KeyNotFoundException) { return NotFound(); }
    }
}
