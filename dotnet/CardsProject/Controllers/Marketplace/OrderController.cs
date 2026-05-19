using Microsoft.AspNetCore.Mvc;
using System.ComponentModel.DataAnnotations;
using CardsProject.Services.Marketplace;

namespace CardsProject.Controllers.Marketplace;

[ApiController]
[Route("api/orders")]
public class OrderController : ControllerBase
{
    private readonly OrderService _svc;

    public OrderController(OrderService svc) => _svc = svc;

    [Microsoft.AspNetCore.Authorization.AllowAnonymous]
    [HttpGet]
    public async Task<IActionResult> List()
    {
        var items = await _svc.GetAllAsync();
        return Ok(items);
    }

    [Microsoft.AspNetCore.Authorization.AllowAnonymous]
    [HttpPost]
    public async Task<IActionResult> Create([FromBody] OrderDto dto)
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
    public async Task<IActionResult> Update(int id, [FromBody] OrderDto dto)
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

    [HttpPost("{id:int}/pay")]
    public async System.Threading.Tasks.Task<IActionResult> Pay(int id, [FromBody] System.Collections.Generic.Dictionary<string, object> body)
    {
        try
        {
            var paymentRef = (string)body["payment_ref"];
            var result = await _svc.PayAsync(id, paymentRef);
            return Ok(result);
        }
        catch (KeyNotFoundException) { return NotFound(); }
    }

    [HttpPost("{id:int}/process-payment")]
    public async System.Threading.Tasks.Task<IActionResult> ProcessPayment(int id)
    {
        try
        {
            var result = await _svc.ProcessPaymentAsync(id);
            return Ok(result);
        }
        catch (KeyNotFoundException) { return NotFound(); }
    }

    [HttpGet("{id:int}/total")]
    public async System.Threading.Tasks.Task<IActionResult> CalculateTotal(int id)
    {
        try
        {
            var result = await _svc.CalculateTotalAsync(id);
            return Ok(result);
        }
        catch (KeyNotFoundException) { return NotFound(); }
    }

    [HttpPatch("{id:int}/discount")]
    public async System.Threading.Tasks.Task<IActionResult> ApplyDiscount(int id, [FromBody] System.Collections.Generic.Dictionary<string, object> body)
    {
        try
        {
            var percent = (int)body["percent"];
            var result = await _svc.ApplyDiscountAsync(id, percent);
            return Ok(result);
        }
        catch (KeyNotFoundException) { return NotFound(); }
    }

    [HttpPost("{id:int}/refund")]
    public async System.Threading.Tasks.Task<IActionResult> Refund(int id)
    {
        try
        {
            await _svc.RefundAsync(id);
            return NoContent();
        }
        catch (KeyNotFoundException) { return NotFound(); }
    }

    [HttpPatch("{id:int}/transitions/pending-to-paid")]
    public async Task<IActionResult> TransitionPendingToPaid(int id)
    {
        try { return Ok(await _svc.TransitionPendingToPaidAsync(id)); }
        catch (InvalidOperationException ex) { return Conflict(new { error = ex.Message }); }
        catch (ArgumentException ex) { return UnprocessableEntity(new { error = ex.Message }); }
        catch (KeyNotFoundException) { return NotFound(); }
    }

    [Microsoft.AspNetCore.Authorization.Authorize(Roles = "Admin")]
    [HttpPatch("{id:int}/transitions/paid-to-processing")]
    public async Task<IActionResult> TransitionPaidToProcessing(int id)
    {
        try { return Ok(await _svc.TransitionPaidToProcessingAsync(id)); }
        catch (InvalidOperationException ex) { return Conflict(new { error = ex.Message }); }
        catch (ArgumentException ex) { return UnprocessableEntity(new { error = ex.Message }); }
        catch (KeyNotFoundException) { return NotFound(); }
    }

    [Microsoft.AspNetCore.Authorization.Authorize(Roles = "Admin")]
    [HttpPatch("{id:int}/transitions/processing-to-shipped")]
    public async Task<IActionResult> TransitionProcessingToShipped(int id)
    {
        try { return Ok(await _svc.TransitionProcessingToShippedAsync(id)); }
        catch (InvalidOperationException ex) { return Conflict(new { error = ex.Message }); }
        catch (ArgumentException ex) { return UnprocessableEntity(new { error = ex.Message }); }
        catch (KeyNotFoundException) { return NotFound(); }
    }

    [Microsoft.AspNetCore.Authorization.Authorize(Roles = "Admin")]
    [HttpPatch("{id:int}/transitions/shipped-to-completed")]
    public async Task<IActionResult> TransitionShippedToCompleted(int id)
    {
        try { return Ok(await _svc.TransitionShippedToCompletedAsync(id)); }
        catch (InvalidOperationException ex) { return Conflict(new { error = ex.Message }); }
        catch (ArgumentException ex) { return UnprocessableEntity(new { error = ex.Message }); }
        catch (KeyNotFoundException) { return NotFound(); }
    }

    [HttpPatch("{id:int}/transitions/pending-to-cancelled")]
    public async Task<IActionResult> TransitionPendingToCancelled(int id)
    {
        try { return Ok(await _svc.TransitionPendingToCancelledAsync(id)); }
        catch (InvalidOperationException ex) { return Conflict(new { error = ex.Message }); }
        catch (ArgumentException ex) { return UnprocessableEntity(new { error = ex.Message }); }
        catch (KeyNotFoundException) { return NotFound(); }
    }

    [Microsoft.AspNetCore.Authorization.Authorize(Roles = "Admin")]
    [HttpPatch("{id:int}/transitions/paid-to-cancelled")]
    public async Task<IActionResult> TransitionPaidToCancelled(int id)
    {
        try { return Ok(await _svc.TransitionPaidToCancelledAsync(id)); }
        catch (InvalidOperationException ex) { return Conflict(new { error = ex.Message }); }
        catch (ArgumentException ex) { return UnprocessableEntity(new { error = ex.Message }); }
        catch (KeyNotFoundException) { return NotFound(); }
    }

    [Microsoft.AspNetCore.Authorization.Authorize(Roles = "Admin")]
    [HttpPatch("{id:int}/transitions/completed-to-refunded")]
    public async Task<IActionResult> TransitionCompletedToRefunded(int id)
    {
        try { return Ok(await _svc.TransitionCompletedToRefundedAsync(id)); }
        catch (InvalidOperationException ex) { return Conflict(new { error = ex.Message }); }
        catch (ArgumentException ex) { return UnprocessableEntity(new { error = ex.Message }); }
        catch (KeyNotFoundException) { return NotFound(); }
    }

    [HttpPatch("{id:int}/transitions/refunded-to-completed")]
    public async Task<IActionResult> TransitionRefundedToCompleted(int id)
    {
        try { return Ok(await _svc.TransitionRefundedToCompletedAsync(id)); }
        catch (InvalidOperationException ex) { return Conflict(new { error = ex.Message }); }
        catch (ArgumentException ex) { return UnprocessableEntity(new { error = ex.Message }); }
        catch (KeyNotFoundException) { return NotFound(); }
    }

    [HttpPatch("{id:int}/transitions/completed-to-cancelled")]
    public async Task<IActionResult> TransitionCompletedToCancelled(int id)
    {
        try { return Ok(await _svc.TransitionCompletedToCancelledAsync(id)); }
        catch (InvalidOperationException ex) { return Conflict(new { error = ex.Message }); }
        catch (ArgumentException ex) { return UnprocessableEntity(new { error = ex.Message }); }
        catch (KeyNotFoundException) { return NotFound(); }
    }
}
