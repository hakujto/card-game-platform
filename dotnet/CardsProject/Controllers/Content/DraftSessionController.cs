using Microsoft.AspNetCore.Mvc;
using System.ComponentModel.DataAnnotations;
using CardsProject.Services.Content;

namespace CardsProject.Controllers.Content;

[ApiController]
[Route("api/draft_sessions")]
public class DraftSessionController : ControllerBase
{
    private readonly DraftSessionService _svc;

    public DraftSessionController(DraftSessionService svc) => _svc = svc;

    [Microsoft.AspNetCore.Authorization.AllowAnonymous]
    [HttpGet]
    public async Task<IActionResult> List()
    {
        var items = await _svc.GetAllAsync();
        return Ok(items);
    }

    [Microsoft.AspNetCore.Authorization.AllowAnonymous]
    [HttpPost]
    public async Task<IActionResult> Create([FromBody] DraftSessionDto dto)
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

    [Microsoft.AspNetCore.Authorization.AllowAnonymous]
    [HttpGet("{id:int}")]
    public async Task<IActionResult> Show(int id)
    {
        var entity = await _svc.GetByIdAsync(id);
        if (entity is null) return NotFound();
        return Ok(entity);
    }

    [Microsoft.AspNetCore.Authorization.AllowAnonymous]
    [HttpPut("{id:int}")]
    [HttpPatch("{id:int}")]
    public async Task<IActionResult> Update(int id, [FromBody] DraftSessionDto dto)
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

    [Microsoft.AspNetCore.Authorization.AllowAnonymous]
    [HttpDelete("{id:int}")]
    public async Task<IActionResult> Delete(int id)
    {
        var deleted = await _svc.DeleteAsync(id);
        if (!deleted) return NotFound();
        return NoContent();
    }

    [HttpPost("{id:int}/start")]
    public async System.Threading.Tasks.Task<IActionResult> Start(int id)
    {
        try
        {
            await _svc.StartAsync(id);
            return NoContent();
        }
        catch (KeyNotFoundException) { return NotFound(); }
    }

    [HttpPost("{id:int}/abandon")]
    public async System.Threading.Tasks.Task<IActionResult> Abandon(int id)
    {
        try
        {
            await _svc.AbandonAsync(id);
            return NoContent();
        }
        catch (KeyNotFoundException) { return NotFound(); }
    }

    [HttpPost("{id:int}/complete")]
    public async System.Threading.Tasks.Task<IActionResult> Complete(int id)
    {
        try
        {
            await _svc.CompleteAsync(id);
            return NoContent();
        }
        catch (KeyNotFoundException) { return NotFound(); }
    }

    [HttpGet("{id:int}/full")]
    public async System.Threading.Tasks.Task<IActionResult> IsFull(int id)
    {
        try
        {
            var result = await _svc.IsFullAsync(id);
            return Ok(result);
        }
        catch (KeyNotFoundException) { return NotFound(); }
    }

    [HttpPatch("{id:int}/transitions/waitingforplayers-to-drafting")]
    public async Task<IActionResult> TransitionWaitingForPlayersToDrafting(int id)
    {
        try { return Ok(await _svc.TransitionWaitingForPlayersToDraftingAsync(id)); }
        catch (InvalidOperationException ex) { return Conflict(new { error = ex.Message }); }
        catch (ArgumentException ex) { return UnprocessableEntity(new { error = ex.Message }); }
        catch (KeyNotFoundException) { return NotFound(); }
    }

    [HttpPatch("{id:int}/transitions/drafting-to-completed")]
    public async Task<IActionResult> TransitionDraftingToCompleted(int id)
    {
        try { return Ok(await _svc.TransitionDraftingToCompletedAsync(id)); }
        catch (InvalidOperationException ex) { return Conflict(new { error = ex.Message }); }
        catch (ArgumentException ex) { return UnprocessableEntity(new { error = ex.Message }); }
        catch (KeyNotFoundException) { return NotFound(); }
    }

    [Microsoft.AspNetCore.Authorization.Authorize(Roles = "Admin")]
    [HttpPatch("{id:int}/transitions/drafting-to-abandoned")]
    public async Task<IActionResult> TransitionDraftingToAbandoned(int id)
    {
        try { return Ok(await _svc.TransitionDraftingToAbandonedAsync(id)); }
        catch (InvalidOperationException ex) { return Conflict(new { error = ex.Message }); }
        catch (ArgumentException ex) { return UnprocessableEntity(new { error = ex.Message }); }
        catch (KeyNotFoundException) { return NotFound(); }
    }

    [Microsoft.AspNetCore.Authorization.Authorize(Roles = "Admin")]
    [HttpPatch("{id:int}/transitions/waitingforplayers-to-abandoned")]
    public async Task<IActionResult> TransitionWaitingForPlayersToAbandoned(int id)
    {
        try { return Ok(await _svc.TransitionWaitingForPlayersToAbandonedAsync(id)); }
        catch (InvalidOperationException ex) { return Conflict(new { error = ex.Message }); }
        catch (ArgumentException ex) { return UnprocessableEntity(new { error = ex.Message }); }
        catch (KeyNotFoundException) { return NotFound(); }
    }

    [HttpPatch("{id:int}/transitions/completed-to-drafting")]
    public async Task<IActionResult> TransitionCompletedToDrafting(int id)
    {
        try { return Ok(await _svc.TransitionCompletedToDraftingAsync(id)); }
        catch (InvalidOperationException ex) { return Conflict(new { error = ex.Message }); }
        catch (ArgumentException ex) { return UnprocessableEntity(new { error = ex.Message }); }
        catch (KeyNotFoundException) { return NotFound(); }
    }

    [HttpPatch("{id:int}/transitions/abandoned-to-drafting")]
    public async Task<IActionResult> TransitionAbandonedToDrafting(int id)
    {
        try { return Ok(await _svc.TransitionAbandonedToDraftingAsync(id)); }
        catch (InvalidOperationException ex) { return Conflict(new { error = ex.Message }); }
        catch (ArgumentException ex) { return UnprocessableEntity(new { error = ex.Message }); }
        catch (KeyNotFoundException) { return NotFound(); }
    }
}
