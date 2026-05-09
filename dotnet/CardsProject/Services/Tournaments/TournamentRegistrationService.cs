using CardsProject.Domain.Tournaments;
using CardsProject.Infrastructure;

namespace CardsProject.Services.Tournaments;

public class TournamentRegistrationService
{
    private readonly AppDbContext _db;

    public TournamentRegistrationService(AppDbContext db) => _db = db;

    public System.Threading.Tasks.Task<TournamentRegistration> Create(TournamentRegistration entity)
    {
        throw new NotImplementedException();
    }

    public System.Threading.Tasks.Task<TournamentRegistration> Update(TournamentRegistration entity)
    {
        throw new NotImplementedException();
    }
}
