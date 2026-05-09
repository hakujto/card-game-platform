using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using CardsProject.Infrastructure;
using CardsProject.Domain.Content;

namespace CardsProject.Controllers.Content;

[ApiController]
[Route("api/article_comments")]
public class ArticleCommentController : ControllerBase
{
    private readonly AppDbContext _db;

    public ArticleCommentController(AppDbContext db) => _db = db;

    [HttpGet]
    public async Task<IActionResult> List()
    {
        var items = await _db.ArticleComments.AsNoTracking().ToListAsync();
        return Ok(items);
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] ArticleCommentDto dto)
    {
        var entity = new ArticleComment();
        if (dto.Body is not null) entity.Body = dto.Body;
        if (dto.IsHidden is not null) entity.IsHidden = dto.IsHidden.Value;
        if (dto.CreatedAt is not null) entity.CreatedAt = dto.CreatedAt.Value;
        if (dto.ArticleId is not null) entity.ArticleId = dto.ArticleId;
        if (dto.AuthorId is not null) entity.AuthorId = dto.AuthorId;
        if (dto.ParentCommentId is not null) entity.ParentCommentId = dto.ParentCommentId;
        _db.ArticleComments.Add(entity);
        await _db.SaveChangesAsync();
        return CreatedAtAction(nameof(Show), new { id = entity.Id }, entity);
    }

    [HttpGet("{id:int}")]
    public async Task<IActionResult> Show(int id)
    {
        var entity = await _db.ArticleComments.FindAsync(id);
        if (entity is null) return NotFound();
        return Ok(entity);
    }

    [HttpPut("{id:int}")]
    [HttpPatch("{id:int}")]
    public async Task<IActionResult> Update(int id, [FromBody] ArticleCommentDto dto)
    {
        var entity = await _db.ArticleComments.FindAsync(id);
        if (entity is null) return NotFound();
        if (dto.Body is not null) entity.Body = dto.Body;
        if (dto.IsHidden is not null) entity.IsHidden = dto.IsHidden.Value;
        if (dto.CreatedAt is not null) entity.CreatedAt = dto.CreatedAt.Value;
        if (dto.ArticleId is not null) entity.ArticleId = dto.ArticleId;
        if (dto.AuthorId is not null) entity.AuthorId = dto.AuthorId;
        if (dto.ParentCommentId is not null) entity.ParentCommentId = dto.ParentCommentId;
        await _db.SaveChangesAsync();
        return Ok(entity);
    }

    [HttpDelete("{id:int}")]
    public async Task<IActionResult> Delete(int id)
    {
        var entity = await _db.ArticleComments.FindAsync(id);
        if (entity is null) return NotFound();
        _db.ArticleComments.Remove(entity);
        await _db.SaveChangesAsync();
        return NoContent();
    }
}
