using CardsProject.Domain.Content;
using CardsProject.Infrastructure;

namespace CardsProject.Services.Content;

public class DraftSessionService
{
    private readonly AppDbContext _db;

    public DraftSessionService(AppDbContext db) => _db = db;

    public System.Threading.Tasks.Task<DraftSession> Create(DraftSession entity)
    {
        throw new NotImplementedException();
    }

    public System.Threading.Tasks.Task<DraftSession> Update(DraftSession entity)
    {
        throw new NotImplementedException();
    }
}
