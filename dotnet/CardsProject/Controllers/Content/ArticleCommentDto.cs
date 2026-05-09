namespace CardsProject.Controllers.Content;

public class ArticleCommentDto
{
    public string? Body { get; set; }
    public bool? IsHidden { get; set; }
    public DateTime? CreatedAt { get; set; }
    public int? ArticleId { get; set; }
    public int? AuthorId { get; set; }
    public int? ParentCommentId { get; set; }
}
