using CardsProject.Domain.Players;
using CardsProject.Domain.Cards;
using System.ComponentModel.DataAnnotations.Schema;

namespace CardsProject.Domain.Tournaments;

public enum TournamentRegistrationStatusType
{
    Registered,
    Waitlisted,
    Withdrawn,
    Disqualified
}

public class TournamentRegistration
{
    public int Id { get; set; }

    public TournamentRegistrationStatusType Status { get; set; }
    public int? Seed { get; set; } = null;
    public int? FinalStanding { get; set; } = null;
    public int PointsEarned { get; set; } = 0;
    public DateTime? RegisteredAt { get; set; } = null;

    public int? TournamentId { get; set; }
    [ForeignKey(nameof(TournamentId))]
    public Tournament? Tournament { get; set; }
    public int? PlayerId { get; set; }
    [ForeignKey(nameof(PlayerId))]
    public Player? Player { get; set; }
    public int? DeckId { get; set; }
    [ForeignKey(nameof(DeckId))]
    public Deck? Deck { get; set; }

    // Business operations

    public void Withdraw()
    {
        throw new NotImplementedException("withdraw not implemented");
    }

    public void Disqualify(string reason)
    {
        throw new NotImplementedException("disqualify not implemented");
    }

    public void PromoteFromWaitlist()
    {
        throw new NotImplementedException("promote_from_waitlist not implemented");
    }
}
