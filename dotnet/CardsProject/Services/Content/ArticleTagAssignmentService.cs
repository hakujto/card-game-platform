using CardsProject.Domain.Content;
using CardsProject.Infrastructure;

namespace CardsProject.Services.Content;

public class ArticleTagAssignmentService
{
    private readonly AppDbContext _db;

    public ArticleTagAssignmentService(AppDbContext db) => _db = db;

    public async System.Threading.Tasks.Task<ArticleTagAssignment> CreateAsync(ArticleTagAssignment entity)
    {
        _db.ArticleTagAssignments.Add(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async System.Threading.Tasks.Task<ArticleTagAssignment> UpdateAsync(ArticleTagAssignment entity)
    {
        _db.ArticleTagAssignments.Update(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

}
