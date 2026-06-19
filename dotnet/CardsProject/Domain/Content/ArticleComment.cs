using CardsProject.Domain.Players;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text.Json.Serialization;

namespace CardsProject.Domain.Content;

public class ArticleComment
{
    public int Id { get; set; }

    public string Body { get; set; } = "";
    public bool IsHidden { get; set; } = false;
    [JsonPropertyName("createdAt")]
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

    public ICollection<ArticleComment> Replies { get; set; } = new List<ArticleComment>();

    // Business operations

    public void Hide()
    {
        // TODO: implement hide
    }

    public void Unhide()
    {
        // TODO: implement unhide
    }

    public bool IsReply()
    {
        // TODO: implement is_reply
        return default;
    }
}
