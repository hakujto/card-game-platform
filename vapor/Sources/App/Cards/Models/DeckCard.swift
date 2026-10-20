import Vapor
import Fluent

final class DeckCard: Model, Content {
    static let schema = "deck_cards"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "quantity")
    var quantity: Int

    @Field(key: "is_commander")
    var isCommander: Bool

    @Parent(key: "deck_id")
    var deck: Deck

    @Parent(key: "card_id")
    var card: Card

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    init() { }

    init(
        id: UUID? = nil,
        quantity: Int = 1,
        isCommander: Bool = false,
        deckID: UUID,
        cardID: UUID
    ) {
        self.id = id
        self.quantity = quantity
        self.isCommander = isCommander
        self.$deck.id = deckID
        self.$card.id = cardID
    }

    struct DTO: Content {
        var id: UUID?
        var quantity: Int
        var isCommander: Bool
        var deckId: UUID?
        var cardId: UUID?
        var createdAt: Date?
        var updatedAt: Date?
    }

    func toDTO() -> DTO {
        DTO(
            id: self.id,
            quantity: self.quantity,
            isCommander: self.isCommander,
            deckId: self.$deck.id,
            cardId: self.$card.id,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt
        )
    }
}

extension DeckCard {
    struct CreateRequest: Content {
        var quantity: Int = 1
        var isCommander: Bool = false
        var deckId: UUID
        var cardId: UUID
    }

    struct UpdateRequest: Content {
        var quantity: Int?
        var isCommander: Bool?
        var deckId: UUID??
        var cardId: UUID??
    }
}