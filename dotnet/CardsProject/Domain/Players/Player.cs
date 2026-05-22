using CardsProject.Infrastructure;
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

    public ICollection<Achievement> Achievements { get; set; } = new List<Achievement>();
    public ICollection<Player> Friends { get; set; } = new List<Player>();

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
    public void UpdateRank()
    {
        // TODO: implement update_rank
    }
}
