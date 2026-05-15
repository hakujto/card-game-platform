namespace CardsProject.Controllers.Content;

public class ArticleDto
{
    public string? Title { get; set; }
    public string? Slug { get; set; }
    public string? Body { get; set; }
    public string? Excerpt { get; set; }
    public string? CoverImageUrl { get; set; }
    public string? Status { get; set; }
    public string? ArticleType { get; set; }
    public int? ViewCount { get; set; }
    public DateTime? PublishedAt { get; set; }
    public DateTime? CreatedAt { get; set; }
    public DateTime? UpdatedAt { get; set; }
    public int? AuthorId { get; set; }
    public int? FeaturedDeckId { get; set; }
}
