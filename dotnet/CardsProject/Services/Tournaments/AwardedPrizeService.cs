using CardsProject.Domain.Tournaments;
using CardsProject.Infrastructure;

namespace CardsProject.Services.Tournaments;

public class AwardedPrizeService
{
    private readonly AppDbContext _db;

    public AwardedPrizeService(AppDbContext db) => _db = db;

    public System.Threading.Tasks.Task<AwardedPrize> Create(AwardedPrize entity)
    {
        throw new NotImplementedException();
    }

    public System.Threading.Tasks.Task<AwardedPrize> Update(AwardedPrize entity)
    {
        throw new NotImplementedException();
    }
}
