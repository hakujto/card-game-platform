using CardsProject.Domain.Players;
using System.ComponentModel.DataAnnotations.Schema;

namespace CardsProject.Domain.Tournaments;

public class AwardedPrize
{
    public int Id { get; set; }

    public int FinalPlacement { get; set; } = 0;
    public DateTime? AwardedAt { get; set; } = null;
    public bool Claimed { get; set; } = false;
    public DateTime? ClaimedAt { get; set; } = null;

    public int? PrizeId { get; set; }
    [ForeignKey(nameof(PrizeId))]
    public TournamentPrize? Prize { get; set; }
    public int? PlayerId { get; set; }
    [ForeignKey(nameof(PlayerId))]
    public Player? Player { get; set; }
}
