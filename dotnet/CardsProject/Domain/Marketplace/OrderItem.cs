using System.ComponentModel.DataAnnotations.Schema;

namespace CardsProject.Domain.Marketplace;

public class OrderItem
{
    public int Id { get; set; }

    public int Quantity { get; set; } = 0;
    public decimal PriceAtPurchase { get; set; } = 0.00m;
    public bool Foil { get; set; } = false;

    public int? OrderId { get; set; }
    [ForeignKey(nameof(OrderId))]
    public Order? Order { get; set; }
    public int? ProductId { get; set; }
    [ForeignKey(nameof(ProductId))]
    public Product? Product { get; set; }
}
