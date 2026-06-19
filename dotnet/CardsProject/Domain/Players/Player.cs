using CardsProject.Infrastructure;
using CardsProject.Domain.Cards;
using CardsProject.Domain.Tournaments;
using CardsProject.Domain.Marketplace;
using CardsProject.Domain.Content;
using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;

namespace CardsProject.Domain.Players;

public enum PlayerRankType
{
    Bronze,
    Silver,
    Gold,
    Platinum,
    Diamond,
    Master,
    Grandmaster
}

public enum PlayerPreferredFormatType
{
    Standard,
    Extended,
    Legacy,
    Vintage,
    Commander,
    Draft
}

public class Player : IValidatableObject
{
    public int Id { get; set; }

    public string DisplayName { get; set; } = "";
    public PlayerRankType Rank { get; set; }
    public int Rating { get; set; } = 1000;
    public int PeakRating { get; set; } = 1000;
    public string? Bio { get; set; }
    public string? CountryCode { get; set; }
    public string? AvatarUrl { get; set; }
    public PlayerPreferredFormatType? PreferredFormat { get; set; }
    public bool IsVerified { get; set; } = false;
    [JsonPropertyName("createdAt")]
    public DateTime? CreatedAt { get; set; } = null;
    [JsonPropertyName("lastActiveAt")]
    public DateTime? LastActiveAt { get; set; } = null;

    public string? UserId { get; set; }
    [ForeignKey(nameof(UserId))]
    public ApplicationUser? User { get; set; }

    public ICollection<CardsProject.Domain.Cards.Deck> Decks { get; set; } = new List<CardsProject.Domain.Cards.Deck>();
    public ICollection<PlayerSeasonStats> SeasonStats { get; set; } = new List<PlayerSeasonStats>();
    public ICollection<PlayerCollection> Collection { get; set; } = new List<PlayerCollection>();
    public ICollection<Friendship> SentFriendRequests { get; set; } = new List<Friendship>();
    public ICollection<Friendship> ReceivedFriendRequests { get; set; } = new List<Friendship>();
    public ICollection<PlayerAchievement> AchievementRecords { get; set; } = new List<PlayerAchievement>();
    public ICollection<CardsProject.Domain.Tournaments.Tournament> OrganizedTournaments { get; set; } = new List<CardsProject.Domain.Tournaments.Tournament>();
    public ICollection<CardsProject.Domain.Tournaments.TournamentJudge> JudgeRoles { get; set; } = new List<CardsProject.Domain.Tournaments.TournamentJudge>();
    public ICollection<CardsProject.Domain.Tournaments.TournamentRegistration> TournamentRegistrations { get; set; } = new List<CardsProject.Domain.Tournaments.TournamentRegistration>();
    public ICollection<CardsProject.Domain.Tournaments.Match> MatchesAsPlayer1 { get; set; } = new List<CardsProject.Domain.Tournaments.Match>();
    public ICollection<CardsProject.Domain.Tournaments.Match> MatchesAsPlayer2 { get; set; } = new List<CardsProject.Domain.Tournaments.Match>();
    public ICollection<CardsProject.Domain.Tournaments.Game> WonGames { get; set; } = new List<CardsProject.Domain.Tournaments.Game>();
    public ICollection<CardsProject.Domain.Tournaments.AwardedPrize> AwardedPrizes { get; set; } = new List<CardsProject.Domain.Tournaments.AwardedPrize>();
    public ICollection<CardsProject.Domain.Marketplace.Order> Orders { get; set; } = new List<CardsProject.Domain.Marketplace.Order>();
    public ICollection<CardsProject.Domain.Marketplace.TradeListing> TradeListings { get; set; } = new List<CardsProject.Domain.Marketplace.TradeListing>();
    public ICollection<CardsProject.Domain.Marketplace.TradeBid> Bids { get; set; } = new List<CardsProject.Domain.Marketplace.TradeBid>();
    public ICollection<CardsProject.Domain.Marketplace.TradeTransaction> Purchases { get; set; } = new List<CardsProject.Domain.Marketplace.TradeTransaction>();
    public ICollection<CardsProject.Domain.Marketplace.TradeTransaction> Sales { get; set; } = new List<CardsProject.Domain.Marketplace.TradeTransaction>();
    public ICollection<CardsProject.Domain.Marketplace.TradeDispute> DisputesOpened { get; set; } = new List<CardsProject.Domain.Marketplace.TradeDispute>();
    public ICollection<CardsProject.Domain.Marketplace.TradeDispute> DisputesResolved { get; set; } = new List<CardsProject.Domain.Marketplace.TradeDispute>();
    public ICollection<CardsProject.Domain.Content.DraftParticipant> DraftSessions { get; set; } = new List<CardsProject.Domain.Content.DraftParticipant>();
    public ICollection<CardsProject.Domain.Content.Article> Articles { get; set; } = new List<CardsProject.Domain.Content.Article>();
    public ICollection<CardsProject.Domain.Content.ArticleComment> ArticleComments { get; set; } = new List<CardsProject.Domain.Content.ArticleComment>();
    public ICollection<CardsProject.Domain.Content.Stream> Streams { get; set; } = new List<CardsProject.Domain.Content.Stream>();

    // Business operations

    public bool Promote()
    {
        // TODO: implement promote
        return default;
    }

    public bool Demote()
    {
        // TODO: implement demote
        return default;
    }

    public void RecordWin()
    {
        // TODO: implement record_win
    }

    public void RecordLoss()
    {
        // TODO: implement record_loss
    }

    public decimal WinRate()
    {
        // TODO: implement win_rate
        return default;
    }

    public void Verify()
    {
        // TODO: implement verify
    }

    public void UpdateRating(int delta)
    {
        // TODO: implement update_rating
    }

    // ── Domain invariants (simple rules) ──────────────────────────────
    public IEnumerable<ValidationResult> Validate(ValidationContext validationContext)
    {
        if (!( Rating >= 0 && Rating <= 9999 ))
            yield return new ValidationResult("Rating must be between 0 and 9999", new[] { nameof(Id) });
        if (!( PeakRating >= Rating ))
            yield return new ValidationResult("Peak rating must be greater than or equal to current rating", new[] { nameof(Id) });
        if (!( true ))
            yield return new ValidationResult("Display name must not be empty", new[] { nameof(Id) });
    }

    // ── Lifecycle hooks (call from AppDbContext.SaveChangesAsync override) ───
    public void InitializeCollection()
    {
        // TODO: implement initialize_collection
    }
    public void UpdateRank()
    {
        // TODO: implement update_rank
    }
}
