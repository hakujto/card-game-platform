using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using CardsProject.Infrastructure;
using CardsProject.Domain.Marketplace;
using CardsProject.Services.Marketplace;

namespace CardsProject.Controllers.Marketplace;

[ApiController]
[Route("api/trade_disputes")]
[Microsoft.AspNetCore.Authorization.AllowAnonymous]
public class TradeDisputeController : ControllerBase
{
    private readonly AppDbContext _db;
    private readonly TradeDisputeService _svc;

    public TradeDisputeController(AppDbContext db, TradeDisputeService svc) { _db = db; _svc = svc; }

    [HttpGet]
    public async Task<IActionResult> List()
    {
        var items = await _db.TradeDisputes.AsNoTracking().ToListAsync();
        return Ok(items);
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] TradeDisputeDto dto)
    {
        var entity = new TradeDispute();
        if (dto.Reason is not null && Enum.TryParse<TradeDisputeReasonType>(dto.Reason, out var reasonVal)) entity.Reason = reasonVal;
        if (dto.Description is not null) entity.Description = dto.Description;
        if (dto.Status is not null && Enum.TryParse<TradeDisputeStatusType>(dto.Status, out var statusVal)) entity.Status = statusVal;
        if (dto.Resolution is not null) entity.Resolution = dto.Resolution;
        if (dto.OpenedAt is not null) entity.OpenedAt = dto.OpenedAt.Value;
        if (dto.ResolvedAt is not null) entity.ResolvedAt = dto.ResolvedAt.Value;
        if (dto.TransactionId is not null) entity.TransactionId = dto.TransactionId;
        if (dto.OpenedById is not null) entity.OpenedById = dto.OpenedById;
        if (dto.ResolvedById is not null) entity.ResolvedById = dto.ResolvedById;
        if (!TryValidateModel(entity)) return BadRequest(ModelState);
        try { _svc.Validate(entity); } catch (InvalidOperationException ex) { return BadRequest(new { error = ex.Message }); }
        _db.TradeDisputes.Add(entity);
        await _db.SaveChangesAsync();
        return CreatedAtAction(nameof(Show), new { id = entity.Id }, entity);
    }

    [HttpGet("{id:int}")]
    public async Task<IActionResult> Show(int id)
    {
        var entity = await _db.TradeDisputes.FindAsync(id);
        if (entity is null) return NotFound();
        return Ok(entity);
    }

    [HttpPut("{id:int}")]
    [HttpPatch("{id:int}")]
    public async Task<IActionResult> Update(int id, [FromBody] TradeDisputeDto dto)
    {
        var entity = await _db.TradeDisputes.FindAsync(id);
        if (entity is null) return NotFound();
        if (dto.Reason is not null && Enum.TryParse<TradeDisputeReasonType>(dto.Reason, out var reasonVal)) entity.Reason = reasonVal;
        if (dto.Description is not null) entity.Description = dto.Description;
        if (dto.Status is not null && Enum.TryParse<TradeDisputeStatusType>(dto.Status, out var statusVal)) entity.Status = statusVal;
        if (dto.Resolution is not null) entity.Resolution = dto.Resolution;
        if (dto.OpenedAt is not null) entity.OpenedAt = dto.OpenedAt.Value;
        if (dto.ResolvedAt is not null) entity.ResolvedAt = dto.ResolvedAt.Value;
        if (dto.TransactionId is not null) entity.TransactionId = dto.TransactionId;
        if (dto.OpenedById is not null) entity.OpenedById = dto.OpenedById;
        if (dto.ResolvedById is not null) entity.ResolvedById = dto.ResolvedById;
        if (!TryValidateModel(entity)) return BadRequest(ModelState);
        try { _svc.Validate(entity); } catch (InvalidOperationException ex) { return BadRequest(new { error = ex.Message }); }
        await _db.SaveChangesAsync();
        return Ok(entity);
    }

    [HttpDelete("{id:int}")]
    public async Task<IActionResult> Delete(int id)
    {
        var entity = await _db.TradeDisputes.FindAsync(id);
        if (entity is null) return NotFound();
        _db.TradeDisputes.Remove(entity);
        await _db.SaveChangesAsync();
        return NoContent();
    }

    [HttpPost("{id:int}/escalate")]
    public async System.Threading.Tasks.Task<IActionResult> Escalate(int id)
    {
        var entity = await _db.TradeDisputes.FindAsync(id);
        if (entity is null) return NotFound();
        entity.Escalate();
        await _db.SaveChangesAsync();
        return NoContent();
    }

    [HttpPost("{id:int}/resolve")]
    public async System.Threading.Tasks.Task<IActionResult> Resolve(int id, [FromBody] System.Collections.Generic.Dictionary<string, object> body)
    {
        var entity = await _db.TradeDisputes.FindAsync(id);
        if (entity is null) return NotFound();
        var resolutionText = (string)body["resolution_text"];
        entity.Resolve(resolutionText);
        await _db.SaveChangesAsync();
        return NoContent();
    }

    [HttpPost("{id:int}/review")]
    public async System.Threading.Tasks.Task<IActionResult> Review(int id)
    {
        var entity = await _db.TradeDisputes.FindAsync(id);
        if (entity is null) return NotFound();
        entity.Review();
        await _db.SaveChangesAsync();
        return NoContent();
    }
}
