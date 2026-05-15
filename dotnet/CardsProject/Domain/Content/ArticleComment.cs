using CardsProject.Domain.Players;
using System.ComponentModel.DataAnnotations.Schema;

namespace CardsProject.Domain.Content;

public class ArticleComment
{
    public int Id { get; set; }

    public string Body { get; set; } = "";
    public bool IsHidden { get; set; } = false;
    public DateTime? CreatedAt { get; set; } = null;

    public int? ArticleId { get; set; }
    [ForeignKey(nameof(ArticleId))]
    public Article? Article { get; set; }
    public int? AuthorId { get; set; }
    [ForeignKey(nameof(AuthorId))]
    public Player? Author { get; set; }
    public int? ParentCommentId { get; set; }
    [ForeignKey(nameof(ParentCommentId))]
    public ArticleComment? ParentComment { get; set; }

    // Business operations

    public void Hide()
    {
        throw new NotImplementedException("hide not implemented");
    }

    public void Unhide()
    {
        throw new NotImplementedException("unhide not implemented");
    }

    public bool IsReply()
    {
        throw new NotImplementedException("is_reply not implemented");
    }
}
