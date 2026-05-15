using CardsProject.Domain.Tournaments;
using CardsProject.Domain.Players;
using System.ComponentModel.DataAnnotations.Schema;

namespace CardsProject.Domain.Content;

public enum StreamPlatformType
{
    Twitch,
    YouTube,
    KickStream,
    Platform
}

public enum StreamStatusType
{
    Scheduled,
    Live,
    Ended
}

public class Stream
{
    public int Id { get; set; }

    public string Title { get; set; } = "";
    public string StreamUrl { get; set; } = "";
    public StreamPlatformType Platform { get; set; }
    public StreamStatusType Status { get; set; }
    public int ViewerCountPeak { get; set; } = 0;
    public DateTime? ScheduledStart { get; set; } = null;
    public DateTime? ActualStart { get; set; } = null;
    public DateTime? EndedAt { get; set; } = null;
    public string? VodUrl { get; set; }

    public int? TournamentId { get; set; }
    [ForeignKey(nameof(TournamentId))]
    public Tournament? Tournament { get; set; }
    public int? StreamerId { get; set; }
    [ForeignKey(nameof(StreamerId))]
    public Player? Streamer { get; set; }

    // Business operations

    public void GoLive()
    {
        throw new NotImplementedException("go_live not implemented");
    }

    public void End()
    {
        throw new NotImplementedException("end not implemented");
    }

    public void UpdateViewerPeak(int count)
    {
        throw new NotImplementedException("update_viewer_peak not implemented");
    }

    public int DurationMinutes()
    {
        throw new NotImplementedException("duration_minutes not implemented");
    }
}
