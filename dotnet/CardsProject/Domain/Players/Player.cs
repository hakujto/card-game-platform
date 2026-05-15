using CardsProject.Infrastructure;
using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;

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
    public DateTime? CreatedAt { get; set; } = null;
    public DateTime? LastActiveAt { get; set; } = null;

    public string? UserId { get; set; }
    [ForeignKey(nameof(UserId))]
    public ApplicationUser? User { get; set; }

    public ICollection<Achievement> Achievements { get; set; } = new List<Achievement>();
    public ICollection<Player> Friends { get; set; } = new List<Player>();

    // Business operations

    public bool Promote()
    {
        throw new NotImplementedException("promote not implemented");
    }

    public bool Demote()
    {
        throw new NotImplementedException("demote not implemented");
    }

    public void RecordWin()
    {
        throw new NotImplementedException("record_win not implemented");
    }

    public void RecordLoss()
    {
        throw new NotImplementedException("record_loss not implemented");
    }

    public decimal WinRate()
    {
        throw new NotImplementedException("win_rate not implemented");
    }

    public void Verify()
    {
        throw new NotImplementedException("verify not implemented");
    }

    public void UpdateRating(int delta)
    {
        throw new NotImplementedException("update_rating not implemented");
    }

    // ── Domain invariants (simple rules) ──────────────────────────────
    public IEnumerable<ValidationResult> Validate(ValidationContext validationContext)
    {
        if (!( Rating >= 0 && Rating <= 9999 ))
            yield return new ValidationResult("Rating must be between 0 and 9999", new[] { nameof(Id) });
        if (!( (Rating != null && PeakRating >= Rating) ))
            yield return new ValidationResult("Peak rating must be greater than or equal to current rating", new[] { nameof(Id) });
        if (!( DisplayName != null ))
            yield return new ValidationResult("Display name must not be empty", new[] { nameof(Id) });
    }
}
