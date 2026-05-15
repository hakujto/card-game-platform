using Microsoft.EntityFrameworkCore;
using System.ComponentModel.DataAnnotations;
using CardsProject.Controllers.Content;
using CardsProject.Domain.Content;
using CardsProject.Infrastructure;

namespace CardsProject.Services.Content;

public class ArticleTagAssignmentService
{
    private readonly AppDbContext _db;

    public ArticleTagAssignmentService(AppDbContext db) => _db = db;

    private static void ValidateEntity(object entity)
    {
        var ctx = new ValidationContext(entity);
        Validator.ValidateObject(entity, ctx, validateAllProperties: true);
    }

    public async Task<List<ArticleTagAssignment>> GetAllAsync()
        => await _db.ArticleTagAssignments.AsNoTracking().ToListAsync();

    public async Task<ArticleTagAssignment?> GetByIdAsync(int id)
        => await _db.ArticleTagAssignments.FindAsync(id);

    public async Task<ArticleTagAssignment> CreateAsync(ArticleTagAssignmentDto dto)
    {
        var entity = new ArticleTagAssignment();
        if (dto.ArticleId is not null) entity.ArticleId = dto.ArticleId;
        if (dto.TagId is not null) entity.TagId = dto.TagId;
        ValidateEntity(entity);
        _db.ArticleTagAssignments.Add(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async Task<ArticleTagAssignment?> UpdateAsync(int id, ArticleTagAssignmentDto dto)
    {
        var entity = await _db.ArticleTagAssignments.FindAsync(id);
        if (entity is null) return null;
        if (dto.ArticleId is not null) entity.ArticleId = dto.ArticleId;
        if (dto.TagId is not null) entity.TagId = dto.TagId;
        ValidateEntity(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async Task<bool> DeleteAsync(int id)
    {
        var entity = await _db.ArticleTagAssignments.FindAsync(id);
        if (entity is null) return false;
        _db.ArticleTagAssignments.Remove(entity);
        await _db.SaveChangesAsync();
        return true;
    }

}
