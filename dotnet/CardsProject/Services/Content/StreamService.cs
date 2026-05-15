using Microsoft.EntityFrameworkCore;
using System.ComponentModel.DataAnnotations;
using CardsProject.Controllers.Content;
using CardsProject.Domain.Content;
using CardsProject.Infrastructure;
using Stream = CardsProject.Domain.Content.Stream;

namespace CardsProject.Services.Content;

public class StreamService
{
    private readonly AppDbContext _db;

    public StreamService(AppDbContext db) => _db = db;

    private static void ValidateEntity(object entity)
    {
        var ctx = new ValidationContext(entity);
        Validator.ValidateObject(entity, ctx, validateAllProperties: true);
    }

    public async Task<List<Stream>> GetAllAsync()
        => await _db.Streams.AsNoTracking().ToListAsync();

    public async Task<Stream?> GetByIdAsync(int id)
        => await _db.Streams.FindAsync(id);

    public async Task<Stream> CreateAsync(StreamDto dto)
    {
        var entity = new Stream();
        if (dto.Title is not null) entity.Title = dto.Title;
        if (dto.StreamUrl is not null) entity.StreamUrl = dto.StreamUrl;
        if (dto.Platform is not null && Enum.TryParse<StreamPlatformType>(dto.Platform, out var platformVal)) entity.Platform = platformVal;
        if (dto.Status is not null && Enum.TryParse<StreamStatusType>(dto.Status, out var statusVal)) entity.Status = statusVal;
        if (dto.ViewerCountPeak is not null) entity.ViewerCountPeak = dto.ViewerCountPeak.Value;
        if (dto.ScheduledStart is not null) entity.ScheduledStart = dto.ScheduledStart.Value;
        if (dto.ActualStart is not null) entity.ActualStart = dto.ActualStart.Value;
        if (dto.EndedAt is not null) entity.EndedAt = dto.EndedAt.Value;
        if (dto.VodUrl is not null) entity.VodUrl = dto.VodUrl;
        if (dto.TournamentId is not null) entity.TournamentId = dto.TournamentId;
        if (dto.StreamerId is not null) entity.StreamerId = dto.StreamerId;
        Validate(entity);
        ValidateEntity(entity);
        _db.Streams.Add(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async Task<Stream?> UpdateAsync(int id, StreamDto dto)
    {
        var entity = await _db.Streams.FindAsync(id);
        if (entity is null) return null;
        if (dto.Title is not null) entity.Title = dto.Title;
        if (dto.StreamUrl is not null) entity.StreamUrl = dto.StreamUrl;
        if (dto.Platform is not null && Enum.TryParse<StreamPlatformType>(dto.Platform, out var platformVal)) entity.Platform = platformVal;
        if (dto.Status is not null && Enum.TryParse<StreamStatusType>(dto.Status, out var statusVal)) entity.Status = statusVal;
        if (dto.ViewerCountPeak is not null) entity.ViewerCountPeak = dto.ViewerCountPeak.Value;
        if (dto.ScheduledStart is not null) entity.ScheduledStart = dto.ScheduledStart.Value;
        if (dto.ActualStart is not null) entity.ActualStart = dto.ActualStart.Value;
        if (dto.EndedAt is not null) entity.EndedAt = dto.EndedAt.Value;
        if (dto.VodUrl is not null) entity.VodUrl = dto.VodUrl;
        if (dto.TournamentId is not null) entity.TournamentId = dto.TournamentId;
        if (dto.StreamerId is not null) entity.StreamerId = dto.StreamerId;
        Validate(entity);
        ValidateEntity(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async Task<bool> DeleteAsync(int id)
    {
        var entity = await _db.Streams.FindAsync(id);
        if (entity is null) return false;
        _db.Streams.Remove(entity);
        await _db.SaveChangesAsync();
        return true;
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
