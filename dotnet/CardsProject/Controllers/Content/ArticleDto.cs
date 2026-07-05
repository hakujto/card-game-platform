namespace CardsProject.Controllers.Content;

public class ArticleDto
{
    public string? Title { get; set; }
    public string? Slug { get; set; }
    public string? Body { get; set; }
    public string? Excerpt { get; set; }
    public string? CoverImageUrl { get; set; }
    [System.Text.Json.Serialization.JsonIgnore(Condition = System.Text.Json.Serialization.JsonIgnoreCondition.WhenWritingDefault)]
    public string? Status { get; set; }
    public string? ArticleType { get; set; }
    public string? Language { get; set; }
    [System.Text.Json.Serialization.JsonIgnore(Condition = System.Text.Json.Serialization.JsonIgnoreCondition.WhenWritingDefault)]
    public int? ViewCount { get; set; }
    [System.Text.Json.Serialization.JsonIgnore(Condition = System.Text.Json.Serialization.JsonIgnoreCondition.WhenWritingDefault)]
    public int? LikesCount { get; set; }
    public long? TotalViewsAlltime { get; set; }
    public bool? IsFeatured { get; set; }
    [System.Text.Json.Serialization.JsonPropertyName("publishedAt")]
    public DateTime? PublishedAt { get; set; }
    [System.Text.Json.Serialization.JsonIgnore(Condition = System.Text.Json.Serialization.JsonIgnoreCondition.WhenWritingDefault)]
    [System.Text.Json.Serialization.JsonPropertyName("createdAt")]
    public DateTime? CreatedAt { get; set; }
    [System.Text.Json.Serialization.JsonPropertyName("updatedAt")]
    public DateTime? UpdatedAt { get; set; }
    public int? AuthorId { get; set; }
    public int? FeaturedDeckId { get; set; }
}
