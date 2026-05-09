using CardsProject.Domain.Content;
using CardsProject.Infrastructure;

namespace CardsProject.Services.Content;

public class ArticleCommentService
{
    private readonly AppDbContext _db;

    public ArticleCommentService(AppDbContext db) => _db = db;

    public System.Threading.Tasks.Task<ArticleComment> Create(ArticleComment entity)
    {
        throw new NotImplementedException();
    }

    public System.Threading.Tasks.Task<ArticleComment> Update(ArticleComment entity)
    {
        throw new NotImplementedException();
    }
}
