package cardsproject.domain.cards;

import jakarta.persistence.*;
import java.time.LocalDate;

@Entity
@Table(name = "card_sets")
public class CardSet {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String name = "";
    private String code = "";
    private LocalDate releaseDate;
    @Enumerated(EnumType.STRING)
    private CardSetSetTypeType setType;
    private Integer totalCards = 0;
    private String description;
    private String logoUrl;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getCode() { return code; }
    public void setCode(String code) { this.code = code; }
    public LocalDate getReleaseDate() { return releaseDate; }
    public void setReleaseDate(LocalDate releaseDate) { this.releaseDate = releaseDate; }
    public CardSetSetTypeType getSetType() { return setType; }
    public void setSetType(CardSetSetTypeType setType) { this.setType = setType; }
    public Integer getTotalCards() { return totalCards; }
    public void setTotalCards(Integer totalCards) { this.totalCards = totalCards; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public String getLogoUrl() { return logoUrl; }
    public void setLogoUrl(String logoUrl) { this.logoUrl = logoUrl; }
}
