using CardsProject.Domain.Players;
using CardsProject.Domain.Cards;
using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;

namespace CardsProject.Domain.Marketplace;

public enum TradeListingStatusType
{
    Active,
    Sold,
    Expired,
    Cancelled,
    Pending
}

public enum TradeListingListingTypeType
{
    FixedPrice,
    Auction,
    TradeOffer
}

public enum TradeListingConditionType
{
    Mint,
    NearMint,
    Excellent,
    Good,
    Played
}

public class TradeListing : IValidatableObject
{
    public int Id { get; set; }

    public TradeListingStatusType Status { get; set; }
    public TradeListingListingTypeType ListingType { get; set; }
    public decimal? AskingPrice { get; set; } = null;
    public decimal? AuctionStartPrice { get; set; } = null;
    public decimal? AuctionCurrentBid { get; set; } = null;
    public DateTime? AuctionEndTime { get; set; } = null;
    public bool Foil { get; set; } = false;
    public TradeListingConditionType Condition { get; set; }
    public int Quantity { get; set; } = 1;
    public string? Description { get; set; }
    public DateTime? CreatedAt { get; set; } = null;
    public DateTime? ExpiresAt { get; set; } = null;

    public int? SellerId { get; set; }
    [ForeignKey(nameof(SellerId))]
    public Player? Seller { get; set; }
    public int? CardId { get; set; }
    [ForeignKey(nameof(CardId))]
    public Card? Card { get; set; }

    // Business operations

    public void Close()
    {
        // TODO: implement close
    }

    public void Extend(int days)
    {
        // TODO: implement extend
    }

    public void Cancel()
    {
        // TODO: implement cancel
    }

    public bool IsExpired()
    {
        // TODO: implement is_expired
        return default;
    }

    public void FinalizeAuction()
    {
        // TODO: implement finalize_auction
    }

    // ── Domain invariants (simple rules) ──────────────────────────────
    public IEnumerable<ValidationResult> Validate(ValidationContext validationContext)
    {
        if (!( Quantity >= 1 && Quantity <= 9999 ))
            yield return new ValidationResult("Listing quantity must be between 1 and 9999", new[] { nameof(Id) });
    }
}
