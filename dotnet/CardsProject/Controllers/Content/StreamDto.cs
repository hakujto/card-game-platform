namespace CardsProject.Controllers.Content;

public class StreamDto
{
    public string? Title { get; set; }
    public string? StreamUrl { get; set; }
    public string? Platform { get; set; }
    public string? Status { get; set; }
    public int? ViewerCountPeak { get; set; }
    public DateTime? ScheduledStart { get; set; }
    public DateTime? ActualStart { get; set; }
    public DateTime? EndedAt { get; set; }
    public string? VodUrl { get; set; }
    public int? TournamentId { get; set; }
    public int? StreamerId { get; set; }
}
