using CardsProject.Domain.Content;
using CardsProject.Infrastructure;
using Stream = CardsProject.Domain.Content.Stream;

namespace CardsProject.Services.Content;

public class StreamService
{
    private readonly AppDbContext _db;

    public StreamService(AppDbContext db) => _db = db;

    public System.Threading.Tasks.Task<Stream> Create(Stream entity)
    {
        throw new NotImplementedException();
    }

    public System.Threading.Tasks.Task<Stream> Update(Stream entity)
    {
        throw new NotImplementedException();
    }
}
