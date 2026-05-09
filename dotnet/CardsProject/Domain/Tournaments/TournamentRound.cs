using System.ComponentModel.DataAnnotations.Schema;

namespace CardsProject.Domain.Tournaments;

public enum TournamentRoundStatusType
{
    Pending,
    Active,
    Completed
}

public class TournamentRound
{
    public int Id { get; set; }

    public int RoundNumber { get; set; } = 0;
    public TournamentRoundStatusType Status { get; set; }
    public DateTime? StartedAt { get; set; } = null;
    public DateTime? EndedAt { get; set; } = null;
    public int TimeLimitMinutes { get; set; } = 50;

    public int? TournamentId { get; set; }
    [ForeignKey(nameof(TournamentId))]
    public Tournament? Tournament { get; set; }
    public int? MatchesId { get; set; }
    [ForeignKey(nameof(MatchesId))]
    public Match? Matches { get; set; }
}
