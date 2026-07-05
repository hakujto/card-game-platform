using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;

using CardsProject.Domain.Cards;
using CardsProject.Domain.Players;
using CardsProject.Domain.Tournaments;
using CardsProject.Domain.Marketplace;
using CardsProject.Domain.Content;
using Stream = CardsProject.Domain.Content.Stream;

namespace CardsProject.Infrastructure;

public class AppDbContext : IdentityDbContext<ApplicationUser>
{
    public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) {}

    public DbSet<Card> Cards { get; set; }
    public DbSet<CardAuditLog> CardsAuditLogs { get; set; }
    public DbSet<CardSet> CardSets { get; set; }
    public DbSet<CardRuling> CardRulings { get; set; }
    public DbSet<CardAbility> CardAbilities { get; set; }
    public DbSet<Deck> Decks { get; set; }
    public DbSet<DeckCard> DeckCards { get; set; }
    public DbSet<DeckSideboardCard> DeckSideboardCards { get; set; }
    public DbSet<DeckTag> DeckTags { get; set; }
    public DbSet<DeckTagAssignment> DeckTagAssignments { get; set; }
    public DbSet<Player> Players { get; set; }
    public DbSet<PlayerSeasonStats> PlayerSeasonStatses { get; set; }
    public DbSet<PlayerCollection> PlayerCollections { get; set; }
    public DbSet<Friendship> Friendships { get; set; }
    public DbSet<Achievement> Achievements { get; set; }
    public DbSet<PlayerAchievement> PlayerAchievements { get; set; }
    public DbSet<CraftingRecipe> CraftingRecipes { get; set; }
    public DbSet<CraftingIngredient> CraftingIngredients { get; set; }
    public DbSet<Season> Seasons { get; set; }
    public DbSet<Tournament> Tournaments { get; set; }
    public DbSet<TournamentAuditLog> TournamentsAuditLogs { get; set; }
    public DbSet<TournamentJudge> TournamentJudges { get; set; }
    public DbSet<TournamentRegistration> TournamentRegistrations { get; set; }
    public DbSet<TournamentRound> TournamentRounds { get; set; }
    public DbSet<Match> Matches { get; set; }
    public DbSet<Game> Games { get; set; }
    public DbSet<TournamentPrize> TournamentPrizes { get; set; }
    public DbSet<AwardedPrize> AwardedPrizes { get; set; }
    public DbSet<Product> Products { get; set; }
    public DbSet<Order> Orders { get; set; }
    public DbSet<OrderAuditLog> OrdersAuditLogs { get; set; }
    public DbSet<OrderItem> OrderItems { get; set; }
    public DbSet<Coupon> Coupons { get; set; }
    public DbSet<TradeListing> TradeListings { get; set; }
    public DbSet<TradeBid> TradeBids { get; set; }
    public DbSet<TradeTransaction> TradeTransactions { get; set; }
    public DbSet<TradeTransactionAuditLog> TradeTransactionsAuditLogs { get; set; }
    public DbSet<CardPriceHistory> CardPriceHistories { get; set; }
    public DbSet<TradeDispute> TradeDisputes { get; set; }
    public DbSet<DraftSession> DraftSessions { get; set; }
    public DbSet<DraftParticipant> DraftParticipants { get; set; }
    public DbSet<DraftPick> DraftPicks { get; set; }
    public DbSet<Article> Articles { get; set; }
    public DbSet<ArticleTag> ArticleTags { get; set; }
    public DbSet<ArticleTagAssignment> ArticleTagAssignments { get; set; }
    public DbSet<ArticleComment> ArticleComments { get; set; }
    public DbSet<Stream> Streams { get; set; }

    protected override void OnModelCreating(ModelBuilder builder)
    {
        base.OnModelCreating(builder);
        builder.Entity<Card>().HasOne(e => e.Set).WithMany(e => e.Cards).HasForeignKey(e => e.SetId).OnDelete(DeleteBehavior.Restrict);
        builder.Entity<CardRuling>().HasOne(e => e.Card).WithMany(e => e.Rulings).HasForeignKey(e => e.CardId).OnDelete(DeleteBehavior.Cascade);
        builder.Entity<CardAbility>().HasOne(e => e.Card).WithMany(e => e.Abilities).HasForeignKey(e => e.CardId).OnDelete(DeleteBehavior.Cascade);
        builder.Entity<Deck>().HasOne(e => e.Player).WithMany(e => e.Decks).HasForeignKey(e => e.PlayerId).OnDelete(DeleteBehavior.Cascade);
        builder.Entity<DeckCard>().HasOne(e => e.Deck).WithMany(e => e.DeckCards).HasForeignKey(e => e.DeckId).OnDelete(DeleteBehavior.Cascade);
        builder.Entity<DeckCard>().HasOne(e => e.Card).WithMany(e => e.DeckCards).HasForeignKey(e => e.CardId).OnDelete(DeleteBehavior.Restrict);
        builder.Entity<DeckSideboardCard>().HasOne(e => e.Deck).WithMany(e => e.SideboardCards).HasForeignKey(e => e.DeckId).OnDelete(DeleteBehavior.Cascade);
        builder.Entity<DeckSideboardCard>().HasOne(e => e.Card).WithMany(e => e.SideboardDecks).HasForeignKey(e => e.CardId).OnDelete(DeleteBehavior.Restrict);
        builder.Entity<DeckTagAssignment>().HasOne(e => e.Deck).WithMany(e => e.TagAssignments).HasForeignKey(e => e.DeckId).OnDelete(DeleteBehavior.Cascade);
        builder.Entity<DeckTagAssignment>().HasOne(e => e.Tag).WithMany(e => e.DeckAssignments).HasForeignKey(e => e.TagId).OnDelete(DeleteBehavior.Cascade);
        builder.Entity<Player>().HasOne(e => e.User).WithOne().HasForeignKey<Player>(e => e.UserId).OnDelete(DeleteBehavior.Cascade);
        builder.Entity<Player>().HasIndex(e => e.UserId).IsUnique();
        builder.Entity<PlayerSeasonStats>().HasOne(e => e.Player).WithMany(e => e.SeasonStats).HasForeignKey(e => e.PlayerId).OnDelete(DeleteBehavior.Cascade);
        builder.Entity<PlayerSeasonStats>().HasOne(e => e.Season).WithMany(e => e.PlayerStats).HasForeignKey(e => e.SeasonId).OnDelete(DeleteBehavior.Cascade);
        builder.Entity<PlayerCollection>().HasOne(e => e.Player).WithMany(e => e.Collection).HasForeignKey(e => e.PlayerId).OnDelete(DeleteBehavior.Cascade);
        builder.Entity<PlayerCollection>().HasOne(e => e.Card).WithMany(e => e.PlayerCollections).HasForeignKey(e => e.CardId).OnDelete(DeleteBehavior.Restrict);
        builder.Entity<Friendship>().HasOne(e => e.Requester).WithMany(e => e.SentFriendRequests).HasForeignKey(e => e.RequesterId).OnDelete(DeleteBehavior.Cascade);
        builder.Entity<Friendship>().HasOne(e => e.Receiver).WithMany(e => e.ReceivedFriendRequests).HasForeignKey(e => e.ReceiverId).OnDelete(DeleteBehavior.Cascade);
        builder.Entity<PlayerAchievement>().HasOne(e => e.Player).WithMany(e => e.AchievementRecords).HasForeignKey(e => e.PlayerId).OnDelete(DeleteBehavior.Cascade);
        builder.Entity<PlayerAchievement>().HasOne(e => e.Achievement).WithMany(e => e.PlayerRecords).HasForeignKey(e => e.AchievementId).OnDelete(DeleteBehavior.Restrict);
        builder.Entity<CraftingRecipe>().HasOne(e => e.ResultCard).WithMany(e => e.CraftingRecipes).HasForeignKey(e => e.ResultCardId).OnDelete(DeleteBehavior.Restrict);
        builder.Entity<CraftingIngredient>().HasOne(e => e.Recipe).WithMany(e => e.Ingredients).HasForeignKey(e => e.RecipeId).OnDelete(DeleteBehavior.Cascade);
        builder.Entity<CraftingIngredient>().HasOne(e => e.Card).WithMany(e => e.UsedInRecipes).HasForeignKey(e => e.CardId).OnDelete(DeleteBehavior.Restrict);
        builder.Entity<Tournament>().HasOne(e => e.Season).WithMany(e => e.Tournaments).HasForeignKey(e => e.SeasonId).OnDelete(DeleteBehavior.Restrict);
        builder.Entity<Tournament>().HasOne(e => e.Organizer).WithMany(e => e.OrganizedTournaments).HasForeignKey(e => e.OrganizerId).OnDelete(DeleteBehavior.Restrict);
        builder.Entity<TournamentJudge>().HasOne(e => e.Tournament).WithMany(e => e.JudgeAssignments).HasForeignKey(e => e.TournamentId).OnDelete(DeleteBehavior.Cascade);
        builder.Entity<TournamentJudge>().HasOne(e => e.Player).WithMany(e => e.JudgeRoles).HasForeignKey(e => e.PlayerId).OnDelete(DeleteBehavior.Restrict);
        builder.Entity<TournamentRegistration>().HasOne(e => e.Tournament).WithMany(e => e.Registrations).HasForeignKey(e => e.TournamentId).OnDelete(DeleteBehavior.Cascade);
        builder.Entity<TournamentRegistration>().HasOne(e => e.Player).WithMany(e => e.TournamentRegistrations).HasForeignKey(e => e.PlayerId).OnDelete(DeleteBehavior.Restrict);
        builder.Entity<TournamentRegistration>().HasOne(e => e.Deck).WithMany(e => e.TournamentRegistrations).HasForeignKey(e => e.DeckId).OnDelete(DeleteBehavior.Restrict);
        builder.Entity<TournamentRound>().HasOne(e => e.Tournament).WithMany(e => e.Rounds).HasForeignKey(e => e.TournamentId).OnDelete(DeleteBehavior.Cascade);
        builder.Entity<Match>().HasOne(e => e.Round).WithMany(e => e.Matches).HasForeignKey(e => e.RoundId).OnDelete(DeleteBehavior.Cascade);
        builder.Entity<Match>().HasOne(e => e.Player1).WithMany(e => e.MatchesAsPlayer1).HasForeignKey(e => e.Player1Id).OnDelete(DeleteBehavior.Restrict);
        builder.Entity<Match>().HasOne(e => e.Player2).WithMany(e => e.MatchesAsPlayer2).HasForeignKey(e => e.Player2Id).OnDelete(DeleteBehavior.SetNull);
        builder.Entity<Game>().HasOne(e => e.Match).WithMany(e => e.Games).HasForeignKey(e => e.MatchId).OnDelete(DeleteBehavior.Cascade);
        builder.Entity<Game>().HasOne(e => e.Winner).WithMany(e => e.WonGames).HasForeignKey(e => e.WinnerId).OnDelete(DeleteBehavior.SetNull);
        builder.Entity<TournamentPrize>().HasOne(e => e.Tournament).WithMany(e => e.Prizes).HasForeignKey(e => e.TournamentId).OnDelete(DeleteBehavior.Cascade);
        builder.Entity<AwardedPrize>().HasOne(e => e.Prize).WithMany(e => e.AwardedPrizes).HasForeignKey(e => e.PrizeId).OnDelete(DeleteBehavior.Restrict);
        builder.Entity<AwardedPrize>().HasOne(e => e.Player).WithMany(e => e.AwardedPrizes).HasForeignKey(e => e.PlayerId).OnDelete(DeleteBehavior.Restrict);
        builder.Entity<Product>().HasOne(e => e.Card).WithOne(e => e.ShopProduct).HasForeignKey<Product>(e => e.CardId).OnDelete(DeleteBehavior.SetNull);
        builder.Entity<Product>().HasIndex(e => e.CardId).IsUnique();
        builder.Entity<Product>().HasOne(e => e.CardSet).WithMany(e => e.ShopProducts).HasForeignKey(e => e.CardSetId).OnDelete(DeleteBehavior.SetNull);
        builder.Entity<Order>().HasOne(e => e.Player).WithMany(e => e.Orders).HasForeignKey(e => e.PlayerId).OnDelete(DeleteBehavior.Restrict);
        builder.Entity<Order>().HasOne(e => e.Coupon).WithMany(e => e.Orders).HasForeignKey(e => e.CouponId).OnDelete(DeleteBehavior.SetNull);
        builder.Entity<OrderItem>().HasOne(e => e.Order).WithMany(e => e.Items).HasForeignKey(e => e.OrderId).OnDelete(DeleteBehavior.Cascade);
        builder.Entity<OrderItem>().HasOne(e => e.Product).WithMany(e => e.OrderItems).HasForeignKey(e => e.ProductId).OnDelete(DeleteBehavior.Restrict);
        builder.Entity<TradeListing>().HasOne(e => e.Seller).WithMany(e => e.TradeListings).HasForeignKey(e => e.SellerId).OnDelete(DeleteBehavior.Restrict);
        builder.Entity<TradeListing>().HasOne(e => e.Card).WithMany(e => e.TradeListings).HasForeignKey(e => e.CardId).OnDelete(DeleteBehavior.Restrict);
        builder.Entity<TradeBid>().HasOne(e => e.Listing).WithMany(e => e.Bids).HasForeignKey(e => e.ListingId).OnDelete(DeleteBehavior.Cascade);
        builder.Entity<TradeBid>().HasOne(e => e.Bidder).WithMany(e => e.Bids).HasForeignKey(e => e.BidderId).OnDelete(DeleteBehavior.Restrict);
        builder.Entity<TradeTransaction>().HasOne(e => e.Listing).WithOne(e => e.Transaction).HasForeignKey<TradeTransaction>(e => e.ListingId).OnDelete(DeleteBehavior.Restrict);
        builder.Entity<TradeTransaction>().HasIndex(e => e.ListingId).IsUnique();
        builder.Entity<TradeTransaction>().HasOne(e => e.Buyer).WithMany(e => e.Purchases).HasForeignKey(e => e.BuyerId).OnDelete(DeleteBehavior.Restrict);
        builder.Entity<TradeTransaction>().HasOne(e => e.Seller).WithMany(e => e.Sales).HasForeignKey(e => e.SellerId).OnDelete(DeleteBehavior.Restrict);
        builder.Entity<CardPriceHistory>().HasOne(e => e.Card).WithMany(e => e.PriceHistory).HasForeignKey(e => e.CardId).OnDelete(DeleteBehavior.Cascade);
        builder.Entity<TradeDispute>().HasOne(e => e.Transaction).WithOne(e => e.Dispute).HasForeignKey<TradeDispute>(e => e.TransactionId).OnDelete(DeleteBehavior.Cascade);
        builder.Entity<TradeDispute>().HasIndex(e => e.TransactionId).IsUnique();
        builder.Entity<TradeDispute>().HasOne(e => e.OpenedBy).WithMany(e => e.DisputesOpened).HasForeignKey(e => e.OpenedById).OnDelete(DeleteBehavior.Restrict);
        builder.Entity<TradeDispute>().HasOne(e => e.ResolvedBy).WithMany(e => e.DisputesResolved).HasForeignKey(e => e.ResolvedById).OnDelete(DeleteBehavior.SetNull);
        builder.Entity<DraftSession>().HasOne(e => e.CardSet).WithMany(e => e.DraftSessions).HasForeignKey(e => e.CardSetId).OnDelete(DeleteBehavior.Restrict);
        builder.Entity<DraftParticipant>().HasOne(e => e.Session).WithMany(e => e.Participants).HasForeignKey(e => e.SessionId).OnDelete(DeleteBehavior.Cascade);
        builder.Entity<DraftParticipant>().HasOne(e => e.Player).WithMany(e => e.DraftSessions).HasForeignKey(e => e.PlayerId).OnDelete(DeleteBehavior.Restrict);
        builder.Entity<DraftPick>().HasOne(e => e.Participant).WithMany(e => e.Picks).HasForeignKey(e => e.ParticipantId).OnDelete(DeleteBehavior.Cascade);
        builder.Entity<DraftPick>().HasOne(e => e.Card).WithMany(e => e.DraftPicks).HasForeignKey(e => e.CardId).OnDelete(DeleteBehavior.Restrict);
        builder.Entity<Article>().HasOne(e => e.Author).WithMany(e => e.Articles).HasForeignKey(e => e.AuthorId).OnDelete(DeleteBehavior.Restrict);
        builder.Entity<Article>().HasOne(e => e.FeaturedDeck).WithMany(e => e.Articles).HasForeignKey(e => e.FeaturedDeckId).OnDelete(DeleteBehavior.SetNull);
        builder.Entity<ArticleTagAssignment>().HasOne(e => e.Article).WithMany(e => e.TagAssignments).HasForeignKey(e => e.ArticleId).OnDelete(DeleteBehavior.Cascade);
        builder.Entity<ArticleTagAssignment>().HasOne(e => e.Tag).WithMany(e => e.ArticleAssignments).HasForeignKey(e => e.TagId).OnDelete(DeleteBehavior.Cascade);
        builder.Entity<ArticleComment>().HasOne(e => e.Article).WithMany(e => e.Comments).HasForeignKey(e => e.ArticleId).OnDelete(DeleteBehavior.Cascade);
        builder.Entity<ArticleComment>().HasOne(e => e.Author).WithMany(e => e.ArticleComments).HasForeignKey(e => e.AuthorId).OnDelete(DeleteBehavior.Restrict);
        builder.Entity<ArticleComment>().HasOne(e => e.ParentComment).WithMany(e => e.Replies).HasForeignKey(e => e.ParentCommentId).OnDelete(DeleteBehavior.SetNull);
        builder.Entity<Stream>().HasOne(e => e.Tournament).WithMany(e => e.Streams).HasForeignKey(e => e.TournamentId).OnDelete(DeleteBehavior.SetNull);
        builder.Entity<Stream>().HasOne(e => e.Streamer).WithMany(e => e.Streams).HasForeignKey(e => e.StreamerId).OnDelete(DeleteBehavior.Restrict);
        builder.Entity<Card>().HasIndex(e => e.PublicId).IsUnique();
        builder.Entity<CardSet>().HasIndex(e => e.Code).IsUnique();
        builder.Entity<Player>().HasIndex(e => e.PublicId).IsUnique();
        builder.Entity<Player>().HasIndex(e => e.DisplayName).IsUnique();
        builder.Entity<Tournament>().HasIndex(e => e.PublicId).IsUnique();
        builder.Entity<Coupon>().HasIndex(e => e.Code).IsUnique();
        builder.Entity<TradeListing>().HasIndex(e => e.PublicId).IsUnique();
        builder.Entity<Article>().HasIndex(e => e.Slug).IsUnique();
        builder.Entity<ArticleTag>().HasIndex(e => e.Slug).IsUnique();
    }
}
