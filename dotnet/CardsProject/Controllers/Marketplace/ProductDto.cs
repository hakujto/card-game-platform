namespace CardsProject.Controllers.Marketplace;

public class ProductDto
{
    public string? Name { get; set; }
    public string? ProductType { get; set; }
    public decimal? Price { get; set; }
    public int? Stock { get; set; }
    public bool? Active { get; set; }
    public int? DiscountPercent { get; set; }
    public string? Description { get; set; }
    public string? ImageUrl { get; set; }
    public bool? Featured { get; set; }
    public int? CardId { get; set; }
    public int? CardSetId { get; set; }
}
