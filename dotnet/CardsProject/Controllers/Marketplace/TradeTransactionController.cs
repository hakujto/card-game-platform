using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using CardsProject.Infrastructure;
using CardsProject.Domain.Marketplace;
using CardsProject.Services.Marketplace;

namespace CardsProject.Controllers.Marketplace;

[ApiController]
[Route("api/trade_transactions")]
[Microsoft.AspNetCore.Authorization.AllowAnonymous]
public class TradeTransactionController : ControllerBase
{
    private readonly AppDbContext _db;
    private readonly TradeTransactionService _svc;

    public TradeTransactionController(AppDbContext db, TradeTransactionService svc) { _db = db; _svc = svc; }

    [HttpGet]
    public async Task<IActionResult> List()
    {
        var items = await _db.TradeTransactions.AsNoTracking().ToListAsync();
        return Ok(items);
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] TradeTransactionDto dto)
    {
        var entity = new TradeTransaction();
        if (dto.FinalPrice is not null) entity.FinalPrice = dto.FinalPrice.Value;
        if (dto.PlatformFee is not null) entity.PlatformFee = dto.PlatformFee.Value;
        if (dto.Status is not null && Enum.TryParse<TradeTransactionStatusType>(dto.Status, out var statusVal)) entity.Status = statusVal;
        if (dto.CompletedAt is not null) entity.CompletedAt = dto.CompletedAt.Value;
        if (dto.ListingId is not null) entity.ListingId = dto.ListingId;
        if (dto.BuyerId is not null) entity.BuyerId = dto.BuyerId;
        if (dto.SellerId is not null) entity.SellerId = dto.SellerId;
        if (!TryValidateModel(entity)) return BadRequest(ModelState);
        try { _svc.Validate(entity); } catch (InvalidOperationException ex) { return BadRequest(new { error = ex.Message }); }
        _db.TradeTransactions.Add(entity);
        await _db.SaveChangesAsync();
        return CreatedAtAction(nameof(Show), new { id = entity.Id }, entity);
    }

    [HttpGet("{id:int}")]
    public async Task<IActionResult> Show(int id)
    {
        var entity = await _db.TradeTransactions.FindAsync(id);
        if (entity is null) return NotFound();
        return Ok(entity);
    }

    [HttpPut("{id:int}")]
    [HttpPatch("{id:int}")]
    public async Task<IActionResult> Update(int id, [FromBody] TradeTransactionDto dto)
    {
        var entity = await _db.TradeTransactions.FindAsync(id);
        if (entity is null) return NotFound();
        if (dto.FinalPrice is not null) entity.FinalPrice = dto.FinalPrice.Value;
        if (dto.PlatformFee is not null) entity.PlatformFee = dto.PlatformFee.Value;
        if (dto.Status is not null && Enum.TryParse<TradeTransactionStatusType>(dto.Status, out var statusVal)) entity.Status = statusVal;
        if (dto.CompletedAt is not null) entity.CompletedAt = dto.CompletedAt.Value;
        if (dto.ListingId is not null) entity.ListingId = dto.ListingId;
        if (dto.BuyerId is not null) entity.BuyerId = dto.BuyerId;
        if (dto.SellerId is not null) entity.SellerId = dto.SellerId;
        if (!TryValidateModel(entity)) return BadRequest(ModelState);
        try { _svc.Validate(entity); } catch (InvalidOperationException ex) { return BadRequest(new { error = ex.Message }); }
        await _db.SaveChangesAsync();
        return Ok(entity);
    }

    [HttpDelete("{id:int}")]
    public async Task<IActionResult> Delete(int id)
    {
        var entity = await _db.TradeTransactions.FindAsync(id);
        if (entity is null) return NotFound();
        _db.TradeTransactions.Remove(entity);
        await _db.SaveChangesAsync();
        return NoContent();
    }

    [HttpPost("{id:int}/complete")]
    public async System.Threading.Tasks.Task<IActionResult> Complete(int id)
    {
        var entity = await _db.TradeTransactions.FindAsync(id);
        if (entity is null) return NotFound();
        entity.Complete();
        await _db.SaveChangesAsync();
        return NoContent();
    }

    [HttpPost("{id:int}/refund")]
    public async System.Threading.Tasks.Task<IActionResult> Refund(int id)
    {
        var entity = await _db.TradeTransactions.FindAsync(id);
        if (entity is null) return NotFound();
        entity.Refund();
        await _db.SaveChangesAsync();
        return NoContent();
    }

    [HttpPost("{id:int}/dispute")]
    public async System.Threading.Tasks.Task<IActionResult> OpenDispute(int id, [FromBody] System.Collections.Generic.Dictionary<string, object> body)
    {
        var entity = await _db.TradeTransactions.FindAsync(id);
        if (entity is null) return NotFound();
        var reason = (string)body["reason"];
        entity.OpenDispute(reason);
        await _db.SaveChangesAsync();
        return NoContent();
    }
}
