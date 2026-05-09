using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using CardsProject.Infrastructure;
using CardsProject.Domain.Content;

namespace CardsProject.Controllers.Content;

[ApiController]
[Route("api/articles")]
public class ArticleController : ControllerBase
{
    private readonly AppDbContext _db;

    public ArticleController(AppDbContext db) => _db = db;

    [HttpGet]
    public async Task<IActionResult> List()
    {
        var items = await _db.Articles.AsNoTracking().ToListAsync();
        return Ok(items);
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] ArticleDto dto)
    {
        var entity = new Article();
        if (dto.Title is not null) entity.Title = dto.Title;
        if (dto.Slug is not null) entity.Slug = dto.Slug;
        if (dto.Body is not null) entity.Body = dto.Body;
        if (dto.Excerpt is not null) entity.Excerpt = dto.Excerpt;
        if (dto.CoverImageUrl is not null) entity.CoverImageUrl = dto.CoverImageUrl;
        if (dto.Status is not null && Enum.TryParse<ArticleStatusType>(dto.Status, out var statusVal)) entity.Status = statusVal;
        if (dto.ArticleType is not null && Enum.TryParse<ArticleArticleTypeType>(dto.ArticleType, out var articleTypeVal)) entity.ArticleType = articleTypeVal;
        if (dto.ViewCount is not null) entity.ViewCount = dto.ViewCount.Value;
        if (dto.PublishedAt is not null) entity.PublishedAt = dto.PublishedAt.Value;
        if (dto.CreatedAt is not null) entity.CreatedAt = dto.CreatedAt.Value;
        if (dto.UpdatedAt is not null) entity.UpdatedAt = dto.UpdatedAt.Value;
        if (dto.AuthorId is not null) entity.AuthorId = dto.AuthorId;
        if (dto.FeaturedDeckId is not null) entity.FeaturedDeckId = dto.FeaturedDeckId;
        if (dto.CommentsId is not null) entity.CommentsId = dto.CommentsId;
        _db.Articles.Add(entity);
        await _db.SaveChangesAsync();
        return CreatedAtAction(nameof(Show), new { id = entity.Id }, entity);
    }

    [HttpGet("{id:int}")]
    public async Task<IActionResult> Show(int id)
    {
        var entity = await _db.Articles.FindAsync(id);
        if (entity is null) return NotFound();
        return Ok(entity);
    }

    [HttpPut("{id:int}")]
    [HttpPatch("{id:int}")]
    public async Task<IActionResult> Update(int id, [FromBody] ArticleDto dto)
    {
        var entity = await _db.Articles.FindAsync(id);
        if (entity is null) return NotFound();
        if (dto.Title is not null) entity.Title = dto.Title;
        if (dto.Slug is not null) entity.Slug = dto.Slug;
        if (dto.Body is not null) entity.Body = dto.Body;
        if (dto.Excerpt is not null) entity.Excerpt = dto.Excerpt;
        if (dto.CoverImageUrl is not null) entity.CoverImageUrl = dto.CoverImageUrl;
        if (dto.Status is not null && Enum.TryParse<ArticleStatusType>(dto.Status, out var statusVal)) entity.Status = statusVal;
        if (dto.ArticleType is not null && Enum.TryParse<ArticleArticleTypeType>(dto.ArticleType, out var articleTypeVal)) entity.ArticleType = articleTypeVal;
        if (dto.ViewCount is not null) entity.ViewCount = dto.ViewCount.Value;
        if (dto.PublishedAt is not null) entity.PublishedAt = dto.PublishedAt.Value;
        if (dto.CreatedAt is not null) entity.CreatedAt = dto.CreatedAt.Value;
        if (dto.UpdatedAt is not null) entity.UpdatedAt = dto.UpdatedAt.Value;
        if (dto.AuthorId is not null) entity.AuthorId = dto.AuthorId;
        if (dto.FeaturedDeckId is not null) entity.FeaturedDeckId = dto.FeaturedDeckId;
        if (dto.CommentsId is not null) entity.CommentsId = dto.CommentsId;
        await _db.SaveChangesAsync();
        return Ok(entity);
    }

    [HttpDelete("{id:int}")]
    public async Task<IActionResult> Delete(int id)
    {
        var entity = await _db.Articles.FindAsync(id);
        if (entity is null) return NotFound();
        _db.Articles.Remove(entity);
        await _db.SaveChangesAsync();
        return NoContent();
    }
}
