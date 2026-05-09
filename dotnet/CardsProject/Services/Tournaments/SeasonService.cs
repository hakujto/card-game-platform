using CardsProject.Domain.Tournaments;
using CardsProject.Infrastructure;

namespace CardsProject.Services.Tournaments;

public class SeasonService
{
    private readonly AppDbContext _db;

    public SeasonService(AppDbContext db) => _db = db;

    public System.Threading.Tasks.Task<Season> Create(Season entity)
    {
        throw new NotImplementedException();
    }

    public System.Threading.Tasks.Task<Season> Update(Season entity)
    {
        throw new NotImplementedException();
    }
}
