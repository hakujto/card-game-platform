using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using CardsProject.Infrastructure;
using CardsProject.Domain.Players;
using CardsProject.Services.Players;

namespace CardsProject.Controllers.Players;

[ApiController]
[Route("api/friendships")]
[Microsoft.AspNetCore.Authorization.AllowAnonymous]
public class FriendshipController : ControllerBase
{
    private readonly AppDbContext _db;
    public FriendshipController(AppDbContext db) => _db = db;

    [HttpGet]
    public async Task<IActionResult> List()
    {
        var items = await _db.Friendships.AsNoTracking().ToListAsync();
        return Ok(items);
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] FriendshipDto dto)
    {
        var entity = new Friendship();
        if (dto.Status is not null && Enum.TryParse<FriendshipStatusType>(dto.Status, out var statusVal)) entity.Status = statusVal;
        if (dto.CreatedAt is not null) entity.CreatedAt = dto.CreatedAt.Value;
        if (dto.RequesterId is not null) entity.RequesterId = dto.RequesterId;
        if (dto.ReceiverId is not null) entity.ReceiverId = dto.ReceiverId;
        if (!TryValidateModel(entity)) return BadRequest(ModelState);
        _db.Friendships.Add(entity);
        await _db.SaveChangesAsync();
        return CreatedAtAction(nameof(Show), new { id = entity.Id }, entity);
    }

    [HttpGet("{id:int}")]
    public async Task<IActionResult> Show(int id)
    {
        var entity = await _db.Friendships.FindAsync(id);
        if (entity is null) return NotFound();
        return Ok(entity);
    }

    [HttpPut("{id:int}")]
    [HttpPatch("{id:int}")]
    public async Task<IActionResult> Update(int id, [FromBody] FriendshipDto dto)
    {
        var entity = await _db.Friendships.FindAsync(id);
        if (entity is null) return NotFound();
        if (dto.Status is not null && Enum.TryParse<FriendshipStatusType>(dto.Status, out var statusVal)) entity.Status = statusVal;
        if (dto.CreatedAt is not null) entity.CreatedAt = dto.CreatedAt.Value;
        if (dto.RequesterId is not null) entity.RequesterId = dto.RequesterId;
        if (dto.ReceiverId is not null) entity.ReceiverId = dto.ReceiverId;
        if (!TryValidateModel(entity)) return BadRequest(ModelState);
        await _db.SaveChangesAsync();
        return Ok(entity);
    }

    [HttpDelete("{id:int}")]
    public async Task<IActionResult> Delete(int id)
    {
        var entity = await _db.Friendships.FindAsync(id);
        if (entity is null) return NotFound();
        _db.Friendships.Remove(entity);
        await _db.SaveChangesAsync();
        return NoContent();
    }

    [HttpPost("{id:int}/accept")]
    public async System.Threading.Tasks.Task<IActionResult> Accept(int id)
    {
        var entity = await _db.Friendships.FindAsync(id);
        if (entity is null) return NotFound();
        entity.Accept();
        await _db.SaveChangesAsync();
        return NoContent();
    }

    [HttpPost("{id:int}/decline")]
    public async System.Threading.Tasks.Task<IActionResult> Decline(int id)
    {
        var entity = await _db.Friendships.FindAsync(id);
        if (entity is null) return NotFound();
        entity.Decline();
        await _db.SaveChangesAsync();
        return NoContent();
    }

    [HttpPost("{id:int}/block")]
    public async System.Threading.Tasks.Task<IActionResult> Block(int id)
    {
        var entity = await _db.Friendships.FindAsync(id);
        if (entity is null) return NotFound();
        entity.Block();
        await _db.SaveChangesAsync();
        return NoContent();
    }
}
