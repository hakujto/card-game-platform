using CardsProject.Domain.Players;
using CardsProject.Domain.Cards;
using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;

namespace CardsProject.Domain.Content;

public enum ArticleStatusType
{
    Draft,
    Published,
    Archived
}

public enum ArticleArticleTypeType
{
    Guide,
    Tierlist,
    Matchup,
    News,
    Spotlight,
    Decklist
}

public enum ArticleLanguageType
{
    EN,
    DE,
    FR,
    IT,
    ES,
    JP,
    PT
}

public class Article : IValidatableObject
{
    public int Id { get; set; }

    public string Title { get; set; } = "";
    public string Slug { get; set; } = "";
    public string Body { get; set; } = "";
    public string? Excerpt { get; set; }
    public string? CoverImageUrl { get; set; }
    public ArticleStatusType Status { get; set; }
    public ArticleArticleTypeType ArticleType { get; set; }
    public ArticleLanguageType Language { get; set; }
    public int ViewCount { get; set; } = 0;
    public int LikesCount { get; set; } = 0;
    public bool IsFeatured { get; set; } = false;
    [JsonPropertyName("publishedAt")]
    public DateTime? PublishedAt { get; set; } = null;
    [JsonPropertyName("createdAt")]
    public DateTime? CreatedAt { get; set; } = null;
    [JsonPropertyName("updatedAt")]
    public DateTime? UpdatedAt { get; set; } = null;

    public int? AuthorId { get; set; }
    [ForeignKey(nameof(AuthorId))]
    public Player? Author { get; set; }
    public int? FeaturedDeckId { get; set; }
    [ForeignKey(nameof(FeaturedDeckId))]
    public Deck? FeaturedDeck { get; set; }

    public ICollection<ArticleTagAssignment> TagAssignments { get; set; } = new List<ArticleTagAssignment>();
    public ICollection<ArticleComment> Comments { get; set; } = new List<ArticleComment>();

    // Business operations

    public void Publish()
    {
        // TODO: implement publish
    }

    public void Archive()
    {
        // TODO: implement archive
    }

    public void IncrementView()
    {
        // TODO: implement increment_view
    }

    public void Like()
    {
        // TODO: implement like
    }

    public void Unlike()
    {
        // TODO: implement unlike
    }

    public int ReadingTimeMinutes()
    {
        // TODO: implement reading_time_minutes
        return default;
    }

    // ── Lifecycle state machine ──────────────────────────────────────
    private static readonly System.Collections.Generic.Dictionary<ArticleStatusType, ArticleStatusType[]> AllowedTransitions = new()
    {
        [ArticleStatusType.Draft] = new[] { ArticleStatusType.Published },
        [ArticleStatusType.Published] = new[] { ArticleStatusType.Archived },
        [ArticleStatusType.Archived] = new[] { ArticleStatusType.Draft }
    };

    public void AssertTransition(ArticleStatusType to)
    {
        if (!AllowedTransitions.TryGetValue(Status, out var allowed) || !System.Array.Exists(allowed, s => s == to))
            throw new InvalidOperationException($"Transition {Status} -> {to} not allowed");
    }

    // ── Domain invariants (simple rules) ──────────────────────────────
    public IEnumerable<ValidationResult> Validate(ValidationContext validationContext)
    {
        if (!( ViewCount >= 0 ))
            yield return new ValidationResult("Article view count must not be negative", new[] { nameof(Id) });
        if (!( LikesCount >= 0 ))
            yield return new ValidationResult("Article likes count must not be negative", new[] { nameof(Id) });
    }

    // ── Lifecycle hooks (call from AppDbContext.SaveChangesAsync override) ───
    public void UpdateSearchIndex()
    {
        // TODO: implement update_search_index
    }
}
