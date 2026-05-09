using CardsProject.Domain.Content;
using CardsProject.Infrastructure;

namespace CardsProject.Services.Content;

public class ArticleTagService
{
    private readonly AppDbContext _db;

    public ArticleTagService(AppDbContext db) => _db = db;

    public System.Threading.Tasks.Task<ArticleTag> Create(ArticleTag entity)
    {
        throw new NotImplementedException();
    }

    public System.Threading.Tasks.Task<ArticleTag> Update(ArticleTag entity)
    {
        throw new NotImplementedException();
    }
}
