namespace CardsProject.Domain.Tournaments;

public class TournamentAuditLog
{
    public int Id { get; set; }
    public int RecordId { get; set; }
    public string Field { get; set; } = string.Empty;
    public string? OldValue { get; set; }
    public string? NewValue { get; set; }
    public DateTime ChangedAt { get; set; } = DateTime.UtcNow;
}
