using Microsoft.AspNetCore.Mvc;
using System.ComponentModel.DataAnnotations;
using CardsProject.Services.Marketplace;

namespace CardsProject.Controllers.Marketplace;

[ApiController]
[Route("api/trade_listings")]
public class TradeListingController : ControllerBase
{
    private readonly TradeListingService _svc;

    public TradeListingController(TradeListingService svc) => _svc = svc;

    [Microsoft.AspNetCore.Authorization.AllowAnonymous]
    [HttpGet]
    public async Task<IActionResult> List()
    {
        var items = await _svc.GetAllAsync();
        return Ok(items);
    }

    [Microsoft.AspNetCore.Authorization.AllowAnonymous]
    [HttpPost]
    public async Task<IActionResult> Create([FromBody] TradeListingDto dto)
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
    public async Task<IActionResult> Update(int id, [FromBody] TradeListingDto dto)
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

    [HttpPost("{id:int}/close")]
    public async System.Threading.Tasks.Task<IActionResult> Close(int id)
    {
        try
        {
            await _svc.CloseAsync(id);
            return NoContent();
        }
        catch (KeyNotFoundException) { return NotFound(); }
    }

    [HttpPatch("{id:int}/extend")]
    public async System.Threading.Tasks.Task<IActionResult> Extend(int id, [FromBody] System.Collections.Generic.Dictionary<string, object> body)
    {
        try
        {
            var days = (int)body["days"];
            await _svc.ExtendAsync(id, days);
            return NoContent();
        }
        catch (KeyNotFoundException) { return NotFound(); }
    }

    [HttpDelete("{id:int}/cancel")]
    public async System.Threading.Tasks.Task<IActionResult> Cancel(int id)
    {
        try
        {
            await _svc.CancelAsync(id);
            return NoContent();
        }
        catch (KeyNotFoundException) { return NotFound(); }
    }

    [HttpGet("{id:int}/expired")]
    public async System.Threading.Tasks.Task<IActionResult> IsExpired(int id)
    {
        try
        {
            var result = await _svc.IsExpiredAsync(id);
            return Ok(result);
        }
        catch (KeyNotFoundException) { return NotFound(); }
    }

    [HttpPost("{id:int}/finalize")]
    public async System.Threading.Tasks.Task<IActionResult> FinalizeAuction(int id)
    {
        try
        {
            await _svc.FinalizeAuctionAsync(id);
            return NoContent();
        }
        catch (KeyNotFoundException) { return NotFound(); }
    }

    [Microsoft.AspNetCore.Authorization.Authorize(Roles = "Seller")]
    [HttpPatch("{id:int}/transitions/pending-to-active")]
    public async Task<IActionResult> TransitionPendingToActive(int id)
    {
        try { return Ok(await _svc.TransitionPendingToActiveAsync(id)); }
        catch (InvalidOperationException ex) { return Conflict(new { error = ex.Message }); }
        catch (ArgumentException ex) { return UnprocessableEntity(new { error = ex.Message }); }
        catch (KeyNotFoundException) { return NotFound(); }
    }

    [HttpPatch("{id:int}/transitions/active-to-sold")]
    public async Task<IActionResult> TransitionActiveToSold(int id)
    {
        try { return Ok(await _svc.TransitionActiveToSoldAsync(id)); }
        catch (InvalidOperationException ex) { return Conflict(new { error = ex.Message }); }
        catch (ArgumentException ex) { return UnprocessableEntity(new { error = ex.Message }); }
        catch (KeyNotFoundException) { return NotFound(); }
    }

    [HttpPatch("{id:int}/transitions/active-to-expired")]
    public async Task<IActionResult> TransitionActiveToExpired(int id)
    {
        try { return Ok(await _svc.TransitionActiveToExpiredAsync(id)); }
        catch (InvalidOperationException ex) { return Conflict(new { error = ex.Message }); }
        catch (ArgumentException ex) { return UnprocessableEntity(new { error = ex.Message }); }
        catch (KeyNotFoundException) { return NotFound(); }
    }

    [Microsoft.AspNetCore.Authorization.Authorize(Roles = "Seller")]
    [HttpPatch("{id:int}/transitions/active-to-cancelled")]
    public async Task<IActionResult> TransitionActiveToCancelled(int id)
    {
        try { return Ok(await _svc.TransitionActiveToCancelledAsync(id)); }
        catch (InvalidOperationException ex) { return Conflict(new { error = ex.Message }); }
        catch (ArgumentException ex) { return UnprocessableEntity(new { error = ex.Message }); }
        catch (KeyNotFoundException) { return NotFound(); }
    }

    [HttpPatch("{id:int}/transitions/sold-to-active")]
    public async Task<IActionResult> TransitionSoldToActive(int id)
    {
        try { return Ok(await _svc.TransitionSoldToActiveAsync(id)); }
        catch (InvalidOperationException ex) { return Conflict(new { error = ex.Message }); }
        catch (ArgumentException ex) { return UnprocessableEntity(new { error = ex.Message }); }
        catch (KeyNotFoundException) { return NotFound(); }
    }

    [HttpPatch("{id:int}/transitions/expired-to-active")]
    public async Task<IActionResult> TransitionExpiredToActive(int id)
    {
        try { return Ok(await _svc.TransitionExpiredToActiveAsync(id)); }
        catch (InvalidOperationException ex) { return Conflict(new { error = ex.Message }); }
        catch (ArgumentException ex) { return UnprocessableEntity(new { error = ex.Message }); }
        catch (KeyNotFoundException) { return NotFound(); }
    }
}
