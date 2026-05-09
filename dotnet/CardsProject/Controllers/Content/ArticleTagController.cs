using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using CardsProject.Infrastructure;
using CardsProject.Domain.Content;

namespace CardsProject.Controllers.Content;

[ApiController]
[Route("api/article_tags")]
public class ArticleTagController : ControllerBase
{
    private readonly AppDbContext _db;

    public ArticleTagController(AppDbContext db) => _db = db;

    [HttpGet]
    public async Task<IActionResult> List()
    {
        var items = await _db.ArticleTags.AsNoTracking().ToListAsync();
        return Ok(items);
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] ArticleTagDto dto)
    {
        var entity = new ArticleTag();
        if (dto.Name is not null) entity.Name = dto.Name;
        if (dto.Slug is not null) entity.Slug = dto.Slug;
        _db.ArticleTags.Add(entity);
        await _db.SaveChangesAsync();
        return CreatedAtAction(nameof(Show), new { id = entity.Id }, entity);
    }

    [HttpGet("{id:int}")]
    public async Task<IActionResult> Show(int id)
    {
        var entity = await _db.ArticleTags.FindAsync(id);
        if (entity is null) return NotFound();
        return Ok(entity);
    }

    [HttpPut("{id:int}")]
    [HttpPatch("{id:int}")]
    public async Task<IActionResult> Update(int id, [FromBody] ArticleTagDto dto)
    {
        var entity = await _db.ArticleTags.FindAsync(id);
        if (entity is null) return NotFound();
        if (dto.Name is not null) entity.Name = dto.Name;
        if (dto.Slug is not null) entity.Slug = dto.Slug;
        await _db.SaveChangesAsync();
        return Ok(entity);
    }

    [HttpDelete("{id:int}")]
    public async Task<IActionResult> Delete(int id)
    {
        var entity = await _db.ArticleTags.FindAsync(id);
        if (entity is null) return NotFound();
        _db.ArticleTags.Remove(entity);
        await _db.SaveChangesAsync();
        return NoContent();
    }
}
