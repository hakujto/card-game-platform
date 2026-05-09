using CardsProject.Domain.Players;
using System.ComponentModel.DataAnnotations.Schema;

namespace CardsProject.Domain.Tournaments;

public enum TournamentJudgeRoleType
{
    HeadJudge,
    Judge,
    ScorekeeperJudge
}

public class TournamentJudge
{
    public int Id { get; set; }

    public TournamentJudgeRoleType Role { get; set; }

    public int? TournamentId { get; set; }
    [ForeignKey(nameof(TournamentId))]
    public Tournament? Tournament { get; set; }
    public int? PlayerId { get; set; }
    [ForeignKey(nameof(PlayerId))]
    public Player? Player { get; set; }
}
