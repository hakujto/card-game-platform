using CardsProject.Domain.Content;
using CardsProject.Infrastructure;

namespace CardsProject.Services.Content;

public class ArticleTagAssignmentService
{
    private readonly AppDbContext _db;

    public ArticleTagAssignmentService(AppDbContext db) => _db = db;

    public System.Threading.Tasks.Task<ArticleTagAssignment> Create(ArticleTagAssignment entity)
    {
        throw new NotImplementedException();
    }

    public System.Threading.Tasks.Task<ArticleTagAssignment> Update(ArticleTagAssignment entity)
    {
        throw new NotImplementedException();
    }
}
