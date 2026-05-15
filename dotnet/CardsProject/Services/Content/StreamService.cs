using CardsProject.Domain.Content;
using CardsProject.Infrastructure;
using Stream = CardsProject.Domain.Content.Stream;

namespace CardsProject.Services.Content;

public class StreamService
{
    private readonly AppDbContext _db;

    public StreamService(AppDbContext db) => _db = db;

    public async System.Threading.Tasks.Task<Stream> CreateAsync(Stream entity)
    {
        _db.Streams.Add(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async System.Threading.Tasks.Task<Stream> UpdateAsync(Stream entity)
    {
        _db.Streams.Update(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async System.Threading.Tasks.Task<bool> GoLiveAsync(int id)
    {
        var entity = await _db.Streams.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("Stream not found: " + id);
        entity.GoLive();
        await _db.SaveChangesAsync();
        return true;
    }
    public async System.Threading.Tasks.Task<bool> EndAsync(int id)
    {
        var entity = await _db.Streams.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("Stream not found: " + id);
        entity.End();
        await _db.SaveChangesAsync();
        return true;
    }
    public async System.Threading.Tasks.Task<bool> UpdateViewerPeakAsync(int id, int count)
    {
        var entity = await _db.Streams.FindAsync(id);
        if (entity is null) throw new KeyNotFoundException("Stream not found: " + id);
        entity.UpdateViewerPeak(count);
        await _db.SaveChangesAsync();
        return true;
    }
    public void Validate(Stream entity)
    {
        if (entity.ActualStart != null && !(entity.Status == StreamStatusType.Live)) throw new InvalidOperationException("actual_start_requires_live_or_ended");
    }
}
