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

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CardPriceHistoryDto dto)
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
    public async Task<IActionResult> Update(int id, [FromBody] CardPriceHistoryDto dto)
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

    [HttpGet("{id:int}/change")]
    public async System.Threading.Tasks.Task<IActionResult> PriceChangePercent(int id, [FromQuery] decimal previousAvg)
    {
        try
        {
            var result = await _svc.PriceChangePercentAsync(id, previousAvg);
            return Ok(result);
        }
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
        catch (KeyNotFoundException) { return NotFound(); }
    }
}
