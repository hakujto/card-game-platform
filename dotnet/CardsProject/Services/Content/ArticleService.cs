using CardsProject.Domain.Content;
using CardsProject.Infrastructure;

namespace CardsProject.Services.Content;

public class ArticleService
{
    private readonly AppDbContext _db;

    public ArticleService(AppDbContext db) => _db = db;

    public System.Threading.Tasks.Task<Article> Create(Article entity)
    {
        throw new NotImplementedException();
    }

    public System.Threading.Tasks.Task<Article> Update(Article entity)
    {
        throw new NotImplementedException();
    }
}
