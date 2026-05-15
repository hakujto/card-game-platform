using Microsoft.EntityFrameworkCore;
using System.ComponentModel.DataAnnotations;
using CardsProject.Controllers.Content;
using CardsProject.Domain.Content;
using CardsProject.Infrastructure;

namespace CardsProject.Services.Content;

public class ArticleTagService
{
    private readonly AppDbContext _db;

    public ArticleTagService(AppDbContext db) => _db = db;

    private static void ValidateEntity(object entity)
    {
        var ctx = new ValidationContext(entity);
        Validator.ValidateObject(entity, ctx, validateAllProperties: true);
    }

    public async Task<List<ArticleTag>> GetAllAsync()
        => await _db.ArticleTags.AsNoTracking().ToListAsync();

    public async Task<ArticleTag?> GetByIdAsync(int id)
        => await _db.ArticleTags.FindAsync(id);

    public async Task<ArticleTag> CreateAsync(ArticleTagDto dto)
    {
        var entity = new ArticleTag();
        if (dto.Name is not null) entity.Name = dto.Name;
        if (dto.Slug is not null) entity.Slug = dto.Slug;
        ValidateEntity(entity);
        _db.ArticleTags.Add(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async Task<ArticleTag?> UpdateAsync(int id, ArticleTagDto dto)
    {
        var entity = await _db.ArticleTags.FindAsync(id);
        if (entity is null) return null;
        if (dto.Name is not null) entity.Name = dto.Name;
        if (dto.Slug is not null) entity.Slug = dto.Slug;
        ValidateEntity(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async Task<bool> DeleteAsync(int id)
    {
        var entity = await _db.ArticleTags.FindAsync(id);
        if (entity is null) return false;
        _db.ArticleTags.Remove(entity);
        await _db.SaveChangesAsync();
        return true;
    }

}
