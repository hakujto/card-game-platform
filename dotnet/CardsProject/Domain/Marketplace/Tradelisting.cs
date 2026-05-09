using CardsProject.Domain.Players;
using CardsProject.Domain.Cards;
using System.ComponentModel.DataAnnotations.Schema;

namespace CardsProject.Domain.Marketplace;

public enum TradelistingListingTypeType
{
    FixedPrice,
    Auction,
    TradeOffer
}

public enum TradelistingConditionType
{
    Mint,
    NearMint,
    Excellent,
    Good,
    Played
}

public enum TradelistingStatusType
{
    Active,
    Sold,
    Expired,
    Cancelled,
    Pending
}

public class Tradelisting
{
    public int Id { get; set; }

    public TradelistingListingTypeType ListingType { get; set; }
    public decimal? AskingPrice { get; set; } = null;
    public decimal? AuctionStartPrice { get; set; } = null;
    public decimal? AuctionCurrentBid { get; set; } = null;
    public DateTime? AuctionEndTime { get; set; } = null;
    public bool Foil { get; set; } = false;
    public TradelistingConditionType Condition { get; set; }
    public int Quantity { get; set; } = 1;
    public TradelistingStatusType Status { get; set; }
    public string? Description { get; set; }
    public DateTime? CreatedAt { get; set; } = null;
    public DateTime? ExpiresAt { get; set; } = null;

    public int? SellerId { get; set; }
    [ForeignKey(nameof(SellerId))]
    public Player? Seller { get; set; }
    public int? CardId { get; set; }
    [ForeignKey(nameof(CardId))]
    public Card? Card { get; set; }
    public int? BidsId { get; set; }
    [ForeignKey(nameof(BidsId))]
    public TradeBid? Bids { get; set; }
}
