using CardsProject.Domain.Players;
using CardsProject.Domain.Cards;
using System.ComponentModel.DataAnnotations.Schema;

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

public class Article
{
    public int Id { get; set; }

    public string Title { get; set; } = "";
    public string Slug { get; set; } = "";
    public string Body { get; set; } = "";
    public string? Excerpt { get; set; }
    public string? CoverImageUrl { get; set; }
    public ArticleStatusType Status { get; set; }
    public ArticleArticleTypeType ArticleType { get; set; }
    public int ViewCount { get; set; } = 0;
    public DateTime? PublishedAt { get; set; } = null;
    public DateTime? CreatedAt { get; set; } = null;
    public DateTime? UpdatedAt { get; set; } = null;

    public int? AuthorId { get; set; }
    [ForeignKey(nameof(AuthorId))]
    public Player? Author { get; set; }
    public int? FeaturedDeckId { get; set; }
    [ForeignKey(nameof(FeaturedDeckId))]
    public Deck? FeaturedDeck { get; set; }
    public int? CommentsId { get; set; }
    [ForeignKey(nameof(CommentsId))]
    public ArticleComment? Comments { get; set; }

    public ICollection<ArticleTag> Tags { get; set; } = new List<ArticleTag>();
}
