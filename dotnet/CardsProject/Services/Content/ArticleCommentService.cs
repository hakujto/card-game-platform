using CardsProject.Domain.Content;
using CardsProject.Infrastructure;

namespace CardsProject.Services.Content;

public class ArticleCommentService
{
    private readonly AppDbContext _db;

    public ArticleCommentService(AppDbContext db) => _db = db;

    public async System.Threading.Tasks.Task<ArticleComment> CreateAsync(ArticleComment entity)
    {
        _db.ArticleComments.Add(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async System.Threading.Tasks.Task<ArticleComment> UpdateAsync(ArticleComment entity)
    {
        _db.ArticleComments.Update(entity);
        await _db.SaveChangesAsync();
        return entity;
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
}
