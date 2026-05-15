using Microsoft.EntityFrameworkCore;
using System.ComponentModel.DataAnnotations;
using CardsProject.Controllers.Content;
using CardsProject.Domain.Content;
using CardsProject.Infrastructure;

namespace CardsProject.Services.Content;

public class ArticleService
{
    private readonly AppDbContext _db;

    public ArticleService(AppDbContext db) => _db = db;

    private static void ValidateEntity(object entity)
    {
        var ctx = new ValidationContext(entity);
        Validator.ValidateObject(entity, ctx, validateAllProperties: true);
    }

    public async Task<List<Article>> GetAllAsync()
        => await _db.Articles.AsNoTracking().ToListAsync();

    public async Task<Article?> GetByIdAsync(int id)
        => await _db.Articles.FindAsync(id);

    public async Task<Article> CreateAsync(ArticleDto dto)
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
        Validate(entity);
        ValidateEntity(entity);
        _db.Articles.Add(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async Task<Article?> UpdateAsync(int id, ArticleDto dto)
    {
        var entity = await _db.Articles.FindAsync(id);
        if (entity is null) return null;
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
        Validate(entity);
        ValidateEntity(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async Task<bool> DeleteAsync(int id)
    {
        var entity = await _db.Articles.FindAsync(id);
        if (entity is null) return false;
        _db.Articles.Remove(entity);
        await _db.SaveChangesAsync();
        return true;
    }

    public async System.Threading.Tasks.Task<bool> PublishAsync(int id)
    {
        var entity = await _db.Articles.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("Article not found: " + id);
        entity.Publish();
        await _db.SaveChangesAsync();
        return true;
    }
    public async System.Threading.Tasks.Task<bool> ArchiveAsync(int id)
    {
        var entity = await _db.Articles.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("Article not found: " + id);
        entity.Archive();
        await _db.SaveChangesAsync();
        return true;
    }
    public async System.Threading.Tasks.Task<bool> IncrementViewAsync(int id)
    {
        var entity = await _db.Articles.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("Article not found: " + id);
        entity.IncrementView();
        await _db.SaveChangesAsync();
        return true;
    }
    public void Validate(Article entity)
    {
        if (entity.Status == ArticleStatusType.Published && entity.PublishedAt == null) throw new InvalidOperationException("Published article must have a published_at timestamp");
    }
}
