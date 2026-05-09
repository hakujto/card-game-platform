using CardsProject.Domain.Content;
using CardsProject.Infrastructure;

namespace CardsProject.Services.Content;

public class DraftParticipantService
{
    private readonly AppDbContext _db;

    public DraftParticipantService(AppDbContext db) => _db = db;

    public System.Threading.Tasks.Task<DraftParticipant> Create(DraftParticipant entity)
    {
        throw new NotImplementedException();
    }

    public System.Threading.Tasks.Task<DraftParticipant> Update(DraftParticipant entity)
    {
        throw new NotImplementedException();
    }
}
