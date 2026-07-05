namespace CardsProject.Controllers.Marketplace;

public class OrderDto
{
    [System.Text.Json.Serialization.JsonIgnore(Condition = System.Text.Json.Serialization.JsonIgnoreCondition.WhenWritingDefault)]
    public string? Status { get; set; }
    public decimal? Total { get; set; }
    public decimal? DiscountApplied { get; set; }
    public string? Currency { get; set; }
    public string? PaymentMethod { get; set; }
    public string? ShippingAddress { get; set; }
    public string? TrackingNumber { get; set; }
    [System.Text.Json.Serialization.JsonIgnore(Condition = System.Text.Json.Serialization.JsonIgnoreCondition.WhenWritingDefault)]
    [System.Text.Json.Serialization.JsonPropertyName("createdAt")]
    public DateTime? CreatedAt { get; set; }
    [System.Text.Json.Serialization.JsonIgnore(Condition = System.Text.Json.Serialization.JsonIgnoreCondition.WhenWritingDefault)]
    [System.Text.Json.Serialization.JsonPropertyName("paidAt")]
    public DateTime? PaidAt { get; set; }
    [System.Text.Json.Serialization.JsonPropertyName("shippedAt")]
    public DateTime? ShippedAt { get; set; }
    public int? PlayerId { get; set; }
    public int? CouponId { get; set; }
}
