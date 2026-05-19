using CardsProject.Domain.Tournaments;
using CardsProject.Domain.Players;
using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;

namespace CardsProject.Domain.Content;

public enum StreamStatusType
{
    Scheduled,
    Live,
    Ended
}

public enum StreamPlatformType
{
    Twitch,
    YouTube,
    KickStream,
    Platform
}

public enum StreamLanguageType
{
    EN,
    DE,
    FR,
    IT,
    ES,
    JP,
    PT
}

public class Stream : IValidatableObject
{
    public int Id { get; set; }

    public string Title { get; set; } = "";
    public string StreamUrl { get; set; } = "";
    public StreamStatusType Status { get; set; }
    public StreamPlatformType Platform { get; set; }
    public StreamLanguageType Language { get; set; }
    public bool IsOfficial { get; set; } = false;
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
        // TODO: implement go_live
    }

    public void End()
    {
        // TODO: implement end
    }

    public void UpdateViewerPeak(int count)
    {
        // TODO: implement update_viewer_peak
    }

    public int DurationMinutes()
    {
        // TODO: implement duration_minutes
        return default;
    }

    // ── Lifecycle state machine ──────────────────────────────────────
    private static readonly System.Collections.Generic.Dictionary<StreamStatusType, StreamStatusType[]> AllowedTransitions = new()
    {
        [StreamStatusType.Scheduled] = new[] { StreamStatusType.Live },
        [StreamStatusType.Live] = new[] { StreamStatusType.Ended }
    };

    public void AssertTransition(StreamStatusType to)
    {
        if (!AllowedTransitions.TryGetValue(Status, out var allowed) || !System.Array.Exists(allowed, s => s == to))
            throw new InvalidOperationException($"Transition {Status} -> {to} not allowed");
    }

    // ── Domain invariants (simple rules) ──────────────────────────────
    public IEnumerable<ValidationResult> Validate(ValidationContext validationContext)
    {
        if (!( ViewerCountPeak >= 0 ))
            yield return new ValidationResult("Peak viewer count must not be negative", new[] { nameof(Id) });
    }
}
