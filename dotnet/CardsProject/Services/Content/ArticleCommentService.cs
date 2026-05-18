using Microsoft.EntityFrameworkCore;
using System.ComponentModel.DataAnnotations;
using CardsProject.Controllers.Content;
using CardsProject.Domain.Content;
using CardsProject.Infrastructure;

namespace CardsProject.Services.Content;

public class ArticleCommentService
{
    private readonly AppDbContext _db;

    public ArticleCommentService(AppDbContext db) => _db = db;

    private static void ValidateEntity(object entity)
    {
        var ctx = new ValidationContext(entity);
        Validator.ValidateObject(entity, ctx, validateAllProperties: true);
    }

    public async Task<List<ArticleComment>> GetAllAsync()
        => await _db.ArticleComments.AsNoTracking().ToListAsync();

    public async Task<ArticleComment?> GetByIdAsync(int id)
        => await _db.ArticleComments.FindAsync(id);

    public async Task<ArticleComment> CreateAsync(ArticleCommentDto dto)
    {
        var entity = new ArticleComment();
        if (dto.Body is not null) entity.Body = dto.Body;
        if (dto.IsHidden is not null) entity.IsHidden = dto.IsHidden.Value;
        if (dto.CreatedAt is not null) entity.CreatedAt = dto.CreatedAt.Value;
        if (dto.ArticleId is not null) entity.ArticleId = dto.ArticleId;
        if (dto.AuthorId is not null) entity.AuthorId = dto.AuthorId;
        if (dto.ParentCommentId is not null) entity.ParentCommentId = dto.ParentCommentId;
        ValidateEntity(entity);
        _db.ArticleComments.Add(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async Task<ArticleComment?> UpdateAsync(int id, ArticleCommentDto dto)
    {
        var entity = await _db.ArticleComments.FindAsync(id);
        if (entity is null) return null;
        if (dto.Body is not null) entity.Body = dto.Body;
        if (dto.IsHidden is not null) entity.IsHidden = dto.IsHidden.Value;
        if (dto.CreatedAt is not null) entity.CreatedAt = dto.CreatedAt.Value;
        if (dto.ArticleId is not null) entity.ArticleId = dto.ArticleId;
        if (dto.AuthorId is not null) entity.AuthorId = dto.AuthorId;
        if (dto.ParentCommentId is not null) entity.ParentCommentId = dto.ParentCommentId;
        ValidateEntity(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async Task<bool> DeleteAsync(int id)
    {
        var entity = await _db.ArticleComments.FindAsync(id);
        if (entity is null) return false;
        _db.ArticleComments.Remove(entity);
        await _db.SaveChangesAsync();
        return true;
    }

    public async System.Threading.Tasks.Task<bool> HideAsync(int id)
    {
        var entity = await _db.ArticleComments.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("ArticleComment not found: " + id);
        entity.Hide();
        await _db.SaveChangesAsync();
        return true;
    }
    public async System.Threading.Tasks.Task<bool> UnhideAsync(int id)
    {
        var entity = await _db.ArticleComments.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("ArticleComment not found: " + id);
        entity.Unhide();
        await _db.SaveChangesAsync();
        return true;
    }
    public async System.Threading.Tasks.Task<bool> IsReplyAsync(int id)
    {
        var entity = await _db.ArticleComments.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("ArticleComment not found: " + id);
        var result = entity.IsReply();
        await _db.SaveChangesAsync();
        return result;
    }
}
