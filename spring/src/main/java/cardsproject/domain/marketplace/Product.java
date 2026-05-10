package cardsproject.domain.marketplace;

import jakarta.persistence.*;
import java.math.BigDecimal;

@Entity
@Table(name = "products")
public class Product {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String name = "";
    @Enumerated(EnumType.STRING)
    private ProductProductTypeType productType;
    private BigDecimal price = BigDecimal.ZERO;
    private Integer stock = 0;
    private Boolean active = true;
    private Integer discountPercent = 0;
    private String description;
    private String imageUrl;
    private Boolean featured = false;

    @Column(name = "card_id")
    private Long cardId;
    @Column(name = "card_set_id")
    private Long cardSetId;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public ProductProductTypeType getProductType() { return productType; }
    public void setProductType(ProductProductTypeType productType) { this.productType = productType; }
    public BigDecimal getPrice() { return price; }
    public void setPrice(BigDecimal price) { this.price = price; }
    public Integer getStock() { return stock; }
    public void setStock(Integer stock) { this.stock = stock; }
    public Boolean getActive() { return active; }
    public void setActive(Boolean active) { this.active = active; }
    public Integer getDiscountPercent() { return discountPercent; }
    public void setDiscountPercent(Integer discountPercent) { this.discountPercent = discountPercent; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public String getImageUrl() { return imageUrl; }
    public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }
    public Boolean getFeatured() { return featured; }
    public void setFeatured(Boolean featured) { this.featured = featured; }
    public Long getCardId() { return cardId; }
    public void setCardId(Long cardId) { this.cardId = cardId; }
    public Long getCardSetId() { return cardSetId; }
    public void setCardSetId(Long cardSetId) { this.cardSetId = cardSetId; }
}
