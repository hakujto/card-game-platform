using Microsoft.AspNetCore.Mvc;
using System.ComponentModel.DataAnnotations;
using CardsProject.Services.Marketplace;

namespace CardsProject.Controllers.Marketplace;

[ApiController]
[Route("api/trade_transactions")]
[Microsoft.AspNetCore.Authorization.AllowAnonymous]
public class TradeTransactionController : ControllerBase
{
    private readonly TradeTransactionService _svc;

    public TradeTransactionController(TradeTransactionService svc) => _svc = svc;

    [HttpGet]
    public async Task<IActionResult> List()
    {
        var items = await _svc.GetAllAsync();
        return Ok(items);
    }

    [HttpGet("{id:int}")]
    public async Task<IActionResult> Show(int id)
    {
        var entity = await _svc.GetByIdAsync(id);
        if (entity is null) return NotFound();
        return Ok(entity);
    }

    [HttpPost("{id:int}/complete")]
    public async System.Threading.Tasks.Task<IActionResult> Complete(int id)
    {
        try
        {
            await _svc.CompleteAsync(id);
            return NoContent();
        }
        catch (ArgumentException ex) { return UnprocessableEntity(new { error = ex.Message }); }
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
        catch (ArgumentException ex) { return UnprocessableEntity(new { error = ex.Message }); }
        catch (KeyNotFoundException) { return NotFound(); }
    }

    [HttpPost("{id:int}/dispute")]
    public async System.Threading.Tasks.Task<IActionResult> OpenDispute(int id, [FromBody] System.Collections.Generic.Dictionary<string, object> body)
    {
        try
        {
            var reason = (string)body["reason"];
            await _svc.OpenDisputeAsync(id, reason);
            return NoContent();
        }
        catch (ArgumentException ex) { return UnprocessableEntity(new { error = ex.Message }); }
        catch (KeyNotFoundException) { return NotFound(); }
    }

    [HttpGet("{id:int}/seller-net")]
    public async System.Threading.Tasks.Task<IActionResult> SellerNet(int id)
    {
        try
        {
            var result = await _svc.SellerNetAsync(id);
            return Ok(result);
        }
        catch (ArgumentException ex) { return UnprocessableEntity(new { error = ex.Message }); }
        catch (KeyNotFoundException) { return NotFound(); }
    }
}
