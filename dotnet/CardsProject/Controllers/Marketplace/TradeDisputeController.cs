using Microsoft.AspNetCore.Mvc;
using System.ComponentModel.DataAnnotations;
using CardsProject.Services.Marketplace;

namespace CardsProject.Controllers.Marketplace;

[ApiController]
[Route("api/trade_disputes")]
public class TradeDisputeController : ControllerBase
{
    private readonly TradeDisputeService _svc;

    public TradeDisputeController(TradeDisputeService svc) => _svc = svc;

    [Microsoft.AspNetCore.Authorization.AllowAnonymous]
    [HttpGet]
    public async Task<IActionResult> List()
    {
        var items = await _svc.GetAllAsync();
        return Ok(items);
    }

    [Microsoft.AspNetCore.Authorization.AllowAnonymous]
    [HttpPost]
    public async Task<IActionResult> Create([FromBody] TradeDisputeDto dto)
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

    [Microsoft.AspNetCore.Authorization.AllowAnonymous]
    [HttpGet("{id:int}")]
    public async Task<IActionResult> Show(int id)
    {
        var entity = await _svc.GetByIdAsync(id);
        if (entity is null) return NotFound();
        return Ok(entity);
    }

    [HttpPost("{id:int}/escalate")]
    public async System.Threading.Tasks.Task<IActionResult> Escalate(int id)
    {
        try
        {
            await _svc.EscalateAsync(id);
            return NoContent();
        }
        catch (ArgumentException ex) { return UnprocessableEntity(new { error = ex.Message }); }
        catch (KeyNotFoundException) { return NotFound(); }
    }

    [Microsoft.AspNetCore.Authorization.Authorize(Roles = "admin,moderator")]
    [HttpPost("{id:int}/resolve")]
    public async System.Threading.Tasks.Task<IActionResult> Resolve(int id, [FromBody] System.Collections.Generic.Dictionary<string, object> body)
    {
        try
        {
            var resolutionText = (string)body["resolution_text"];
            await _svc.ResolveAsync(id, resolutionText);
            return NoContent();
        }
        catch (ArgumentException ex) { return UnprocessableEntity(new { error = ex.Message }); }
        catch (KeyNotFoundException) { return NotFound(); }
    }

    [HttpPost("{id:int}/close")]
    public async System.Threading.Tasks.Task<IActionResult> CloseResolved(int id)
    {
        try
        {
            await _svc.CloseResolvedAsync(id);
            return NoContent();
        }
        catch (ArgumentException ex) { return UnprocessableEntity(new { error = ex.Message }); }
        catch (KeyNotFoundException) { return NotFound(); }
    }

    [HttpPost("{id:int}/review")]
    public async System.Threading.Tasks.Task<IActionResult> Review(int id)
    {
        try
        {
            await _svc.ReviewAsync(id);
            return NoContent();
        }
        catch (ArgumentException ex) { return UnprocessableEntity(new { error = ex.Message }); }
        catch (KeyNotFoundException) { return NotFound(); }
    }

    [Microsoft.AspNetCore.Authorization.Authorize(Roles = "Admin,Moderator")]
    [HttpPatch("{id:int}/transitions/open-to-underreview")]
    public async Task<IActionResult> TransitionOpenToUnderReview(int id)
    {
        try { return Ok(await _svc.TransitionOpenToUnderReviewAsync(id)); }
        catch (InvalidOperationException ex) { return Conflict(new { error = ex.Message }); }
        catch (ArgumentException ex) { return UnprocessableEntity(new { error = ex.Message }); }
        catch (KeyNotFoundException) { return NotFound(); }
    }

    [Microsoft.AspNetCore.Authorization.Authorize(Roles = "Admin,Moderator")]
    [HttpPatch("{id:int}/transitions/underreview-to-resolved")]
    public async Task<IActionResult> TransitionUnderReviewToResolved(int id)
    {
        try { return Ok(await _svc.TransitionUnderReviewToResolvedAsync(id)); }
        catch (InvalidOperationException ex) { return Conflict(new { error = ex.Message }); }
        catch (ArgumentException ex) { return UnprocessableEntity(new { error = ex.Message }); }
        catch (KeyNotFoundException) { return NotFound(); }
    }

    [Microsoft.AspNetCore.Authorization.Authorize(Roles = "Admin")]
    [HttpPatch("{id:int}/transitions/underreview-to-escalated")]
    public async Task<IActionResult> TransitionUnderReviewToEscalated(int id)
    {
        try { return Ok(await _svc.TransitionUnderReviewToEscalatedAsync(id)); }
        catch (InvalidOperationException ex) { return Conflict(new { error = ex.Message }); }
        catch (ArgumentException ex) { return UnprocessableEntity(new { error = ex.Message }); }
        catch (KeyNotFoundException) { return NotFound(); }
    }

    [Microsoft.AspNetCore.Authorization.Authorize(Roles = "Admin")]
    [HttpPatch("{id:int}/transitions/escalated-to-resolved")]
    public async Task<IActionResult> TransitionEscalatedToResolved(int id)
    {
        try { return Ok(await _svc.TransitionEscalatedToResolvedAsync(id)); }
        catch (InvalidOperationException ex) { return Conflict(new { error = ex.Message }); }
        catch (ArgumentException ex) { return UnprocessableEntity(new { error = ex.Message }); }
        catch (KeyNotFoundException) { return NotFound(); }
    }

    [HttpPatch("{id:int}/transitions/resolved-to-open")]
    public async Task<IActionResult> TransitionResolvedToOpen(int id)
    {
        try { return Ok(await _svc.TransitionResolvedToOpenAsync(id)); }
        catch (InvalidOperationException ex) { return Conflict(new { error = ex.Message }); }
        catch (ArgumentException ex) { return UnprocessableEntity(new { error = ex.Message }); }
        catch (KeyNotFoundException) { return NotFound(); }
    }
}
