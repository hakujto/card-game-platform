using CardsProject.Domain.Tournaments;
using CardsProject.Infrastructure;

namespace CardsProject.Services.Tournaments;

public class AwardedPrizeService
{
    private readonly AppDbContext _db;

    public AwardedPrizeService(AppDbContext db) => _db = db;

    public async System.Threading.Tasks.Task<AwardedPrize> CreateAsync(AwardedPrize entity)
    {
        _db.AwardedPrizes.Add(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async System.Threading.Tasks.Task<AwardedPrize> UpdateAsync(AwardedPrize entity)
    {
        _db.AwardedPrizes.Update(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public void Validate(AwardedPrize entity)
    {
        if (entity.Claimed == true && entity.ClaimedAt == null) throw new InvalidOperationException("Claimed prize must have a claimed_at timestamp");
    }
}
