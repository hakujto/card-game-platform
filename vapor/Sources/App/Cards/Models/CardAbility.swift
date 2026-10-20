import Vapor
import Fluent

enum CardAbilityAbilityType: String, Codable, CaseIterable {
    case keyword = "Keyword"
    case activated = "Activated"
    case triggered = "Triggered"
    case `static` = "Static"
}

enum CardAbilityTiming: String, Codable, CaseIterable {
    case `any` = "Any"
    case sorcery = "Sorcery"
    case instant = "Instant"
    case combat = "Combat"
}

final class CardAbility: Model, Content {
    static let schema = "card_abilitys"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "ability_type")
    var abilityType: CardAbilityAbilityType

    @OptionalField(key: "keyword")
    var keyword: String?

    @Field(key: "ability_text")
    var abilityText: String

    @OptionalField(key: "timing")
    var timing: CardAbilityTiming?

    @Parent(key: "card_id")
    var card: Card

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    init() { }

    init(
        id: UUID? = nil,
        abilityType: CardAbilityAbilityType = .keyword,
        keyword: String?,
        abilityText: String,
        timing: CardAbilityTiming?,
        cardID: UUID
    ) {
        self.id = id
        self.abilityType = abilityType
        self.keyword = keyword
        self.abilityText = abilityText
        self.timing = timing
        self.$card.id = cardID
    }

    struct DTO: Content {
        var id: UUID?
        var abilityType: CardAbilityAbilityType
        var keyword: String?
        var abilityText: String
        var timing: CardAbilityTiming?
        var cardId: UUID?
        var createdAt: Date?
        var updatedAt: Date?
    }

    func toDTO() -> DTO {
        DTO(
            id: self.id,
            abilityType: self.abilityType,
            keyword: self.keyword,
            abilityText: self.abilityText,
            timing: self.timing,
            cardId: self.$card.id,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt
        )
    }
}

extension CardAbility {
    struct CreateRequest: Content {
        var abilityType: CardAbilityAbilityType = .keyword
        var keyword: String?
        var abilityText: String
        var timing: CardAbilityTiming?
        var cardId: UUID
    }

    struct UpdateRequest: Content {
        var abilityType: CardAbilityAbilityType?
        var keyword: String??
        var abilityText: String?
        var timing: CardAbilityTiming??
        var cardId: UUID??
    }
}