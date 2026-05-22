using Microsoft.AspNetCore.Mvc;
using System.ComponentModel.DataAnnotations;
using CardsProject.Services.Marketplace;

namespace CardsProject.Controllers.Marketplace;

[ApiController]
[Route("api/card_price_histories")]
[Microsoft.AspNetCore.Authorization.AllowAnonymous]
public class CardPriceHistoryController : ControllerBase
{
    private readonly CardPriceHistoryService _svc;

    public CardPriceHistoryController(CardPriceHistoryService svc) => _svc = svc;

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

    [HttpGet("{id:int}/change")]
    public async System.Threading.Tasks.Task<IActionResult> PriceChangePercent(int id, [FromQuery] decimal previousAvg)
    {
        try
        {
            var result = await _svc.PriceChangePercentAsync(id, previousAvg);
            return Ok(result);
        }
        catch (ArgumentException ex) { return UnprocessableEntity(new { error = ex.Message }); }
        catch (KeyNotFoundException) { return NotFound(); }
    }

    [HttpGet("{id:int}/spike")]
    public async System.Threading.Tasks.Task<IActionResult> IsPriceSpike(int id, [FromQuery] int thresholdPercent)
    {
        try
        {
            var result = await _svc.IsPriceSpikeAsync(id, thresholdPercent);
            return Ok(result);
        }
        catch (ArgumentException ex) { return UnprocessableEntity(new { error = ex.Message }); }
        catch (KeyNotFoundException) { return NotFound(); }
    }
}
