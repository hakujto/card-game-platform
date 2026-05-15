using CardsProject.Domain.Content;
using CardsProject.Infrastructure;

namespace CardsProject.Services.Content;

public class ArticleService
{
    private readonly AppDbContext _db;

    public ArticleService(AppDbContext db) => _db = db;

    public async System.Threading.Tasks.Task<Article> CreateAsync(Article entity)
    {
        _db.Articles.Add(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async System.Threading.Tasks.Task<Article> UpdateAsync(Article entity)
    {
        _db.Articles.Update(entity);
        await _db.SaveChangesAsync();
        return entity;
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
