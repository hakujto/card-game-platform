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
    public DbSet<TournamentJudge> TournamentJudges { get; set; }
    public DbSet<TournamentRegistration> TournamentRegistrations { get; set; }
    public DbSet<TournamentRound> TournamentRounds { get; set; }
    public DbSet<Match> Matches { get; set; }
    public DbSet<Game> Games { get; set; }
    public DbSet<TournamentPrize> TournamentPrizes { get; set; }
    public DbSet<AwardedPrize> AwardedPrizes { get; set; }
    public DbSet<Product> Products { get; set; }
    public DbSet<Order> Orders { get; set; }
    public DbSet<OrderItem> OrderItems { get; set; }
    public DbSet<Coupon> Coupons { get; set; }
    public DbSet<Tradelisting> Tradelistings { get; set; }
    public DbSet<TradeBid> TradeBids { get; set; }
    public DbSet<TradeTransaction> TradeTransactions { get; set; }
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
        builder.Entity<Deck>().HasMany(e => e.Cards).WithMany().UsingEntity(j => j.ToTable("DeckCardsLink"));
        builder.Entity<Deck>().HasMany(e => e.SideboardCards).WithMany().UsingEntity(j => j.ToTable("DeckSideboardCardsLink"));
        builder.Entity<Deck>().HasMany(e => e.Tags).WithMany().UsingEntity(j => j.ToTable("DeckTagsLink"));
        builder.Entity<Player>().HasMany(e => e.Achievements).WithMany().UsingEntity(j => j.ToTable("PlayerAchievementsLink"));
        builder.Entity<Player>().HasMany(e => e.Friends).WithMany().UsingEntity(j => j.ToTable("PlayerFriends"));
        builder.Entity<CraftingRecipe>().HasMany(e => e.RequiredCards).WithMany().UsingEntity(j => j.ToTable("CraftingRecipeRequiredCards"));
        builder.Entity<Tournament>().HasMany(e => e.Judges).WithMany().UsingEntity(j => j.ToTable("TournamentJudgesLink"));
        builder.Entity<Article>().HasMany(e => e.Tags).WithMany().UsingEntity(j => j.ToTable("ArticleTagsLink"));
    }
}
