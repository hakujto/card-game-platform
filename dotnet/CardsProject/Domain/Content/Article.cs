using CardsProject.Domain.Players;
using CardsProject.Domain.Cards;
using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;

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
    public DateTime? PublishedAt { get; set; } = null;
    public DateTime? CreatedAt { get; set; } = null;
    public DateTime? UpdatedAt { get; set; } = null;

    public int? AuthorId { get; set; }
    [ForeignKey(nameof(AuthorId))]
    public Player? Author { get; set; }
    public int? FeaturedDeckId { get; set; }
    [ForeignKey(nameof(FeaturedDeckId))]
    public Deck? FeaturedDeck { get; set; }

    public ICollection<ArticleTag> Tags { get; set; } = new List<ArticleTag>();

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

    // ── Domain invariants (simple rules) ──────────────────────────────
    public IEnumerable<ValidationResult> Validate(ValidationContext validationContext)
    {
        if (!( ViewCount >= 0 ))
            yield return new ValidationResult("Article view count must not be negative", new[] { nameof(Id) });
        if (!( LikesCount >= 0 ))
            yield return new ValidationResult("Article likes count must not be negative", new[] { nameof(Id) });
    }
}
