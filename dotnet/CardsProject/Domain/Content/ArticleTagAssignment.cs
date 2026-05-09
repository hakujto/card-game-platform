using System.ComponentModel.DataAnnotations.Schema;

namespace CardsProject.Domain.Content;

public class ArticleTagAssignment
{
    public int Id { get; set; }


    public int? ArticleId { get; set; }
    [ForeignKey(nameof(ArticleId))]
    public Article? Article { get; set; }
    public int? TagId { get; set; }
    [ForeignKey(nameof(TagId))]
    public ArticleTag? Tag { get; set; }
}
