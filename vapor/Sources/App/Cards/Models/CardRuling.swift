import Vapor
import Fluent

final class CardRuling: Model, Content {
    static let schema = "card_rulings"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "ruling_text")
    var rulingText: String

    @Field(key: "published_at")
    var publishedAt: String

    @Field(key: "source")
    var source: String

    @Parent(key: "card_id")
    var card: Card

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    init() { }

    init(
        id: UUID? = nil,
        rulingText: String,
        publishedAt: String,
        source: String,
        cardID: UUID
    ) {
        self.id = id
        self.rulingText = rulingText
        self.publishedAt = publishedAt
        self.source = source
        self.$card.id = cardID
    }

    struct DTO: Content {
        var id: UUID?
        var rulingText: String
        var publishedAt: String
        var source: String
        var cardId: UUID?
        var createdAt: Date?
        var updatedAt: Date?
    }

    func toDTO() -> DTO {
        DTO(
            id: self.id,
            rulingText: self.rulingText,
            publishedAt: self.publishedAt,
            source: self.source,
            cardId: self.$card.id,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt
        )
    }
}

extension CardRuling {
    struct CreateRequest: Content {
        var rulingText: String
        var publishedAt: String
        var source: String
        var cardId: UUID
    }

    struct UpdateRequest: Content {
        var rulingText: String?
        var publishedAt: String?
        var source: String?
        var cardId: UUID??
    }
}