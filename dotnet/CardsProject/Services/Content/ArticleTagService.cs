using CardsProject.Domain.Content;
using CardsProject.Infrastructure;

namespace CardsProject.Services.Content;

public class ArticleTagService
{
    private readonly AppDbContext _db;

    public ArticleTagService(AppDbContext db) => _db = db;

    public async System.Threading.Tasks.Task<ArticleTag> CreateAsync(ArticleTag entity)
    {
        _db.ArticleTags.Add(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async System.Threading.Tasks.Task<ArticleTag> UpdateAsync(ArticleTag entity)
    {
        _db.ArticleTags.Update(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

}
