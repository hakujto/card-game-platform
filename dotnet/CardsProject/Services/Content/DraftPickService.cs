using CardsProject.Domain.Content;
using CardsProject.Infrastructure;

namespace CardsProject.Services.Content;

public class DraftPickService
{
    private readonly AppDbContext _db;

    public DraftPickService(AppDbContext db) => _db = db;

    public System.Threading.Tasks.Task<DraftPick> Create(DraftPick entity)
    {
        throw new NotImplementedException();
    }

    public System.Threading.Tasks.Task<DraftPick> Update(DraftPick entity)
    {
        throw new NotImplementedException();
    }
}
