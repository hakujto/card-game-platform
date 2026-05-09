using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using CardsProject.Infrastructure;
using CardsProject.Domain.Content;

namespace CardsProject.Controllers.Content;

[ApiController]
[Route("api/article_tag_assignments")]
public class ArticleTagAssignmentController : ControllerBase
{
    private readonly AppDbContext _db;

    public ArticleTagAssignmentController(AppDbContext db) => _db = db;

    [HttpGet]
    public async Task<IActionResult> List()
    {
        var items = await _db.ArticleTagAssignments.AsNoTracking().ToListAsync();
        return Ok(items);
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] ArticleTagAssignmentDto dto)
    {
        var entity = new ArticleTagAssignment();
        if (dto.ArticleId is not null) entity.ArticleId = dto.ArticleId;
        if (dto.TagId is not null) entity.TagId = dto.TagId;
        _db.ArticleTagAssignments.Add(entity);
        await _db.SaveChangesAsync();
        return CreatedAtAction(nameof(Show), new { id = entity.Id }, entity);
    }

    [HttpGet("{id:int}")]
    public async Task<IActionResult> Show(int id)
    {
        var entity = await _db.ArticleTagAssignments.FindAsync(id);
        if (entity is null) return NotFound();
        return Ok(entity);
    }

    [HttpPut("{id:int}")]
    [HttpPatch("{id:int}")]
    public async Task<IActionResult> Update(int id, [FromBody] ArticleTagAssignmentDto dto)
    {
        var entity = await _db.ArticleTagAssignments.FindAsync(id);
        if (entity is null) return NotFound();
        if (dto.ArticleId is not null) entity.ArticleId = dto.ArticleId;
        if (dto.TagId is not null) entity.TagId = dto.TagId;
        await _db.SaveChangesAsync();
        return Ok(entity);
    }

    [HttpDelete("{id:int}")]
    public async Task<IActionResult> Delete(int id)
    {
        var entity = await _db.ArticleTagAssignments.FindAsync(id);
        if (entity is null) return NotFound();
        _db.ArticleTagAssignments.Remove(entity);
        await _db.SaveChangesAsync();
        return NoContent();
    }
}
