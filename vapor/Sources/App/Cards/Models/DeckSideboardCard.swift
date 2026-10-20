import Vapor
import Fluent

final class DeckSideboardCard: Model, Content {
    static let schema = "deck_sideboard_cards"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "quantity")
    var quantity: Int

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
        deckID: UUID,
        cardID: UUID
    ) {
        self.id = id
        self.quantity = quantity
        self.$deck.id = deckID
        self.$card.id = cardID
    }

    struct DTO: Content {
        var id: UUID?
        var quantity: Int
        var deckId: UUID?
        var cardId: UUID?
        var createdAt: Date?
        var updatedAt: Date?
    }

    func toDTO() -> DTO {
        DTO(
            id: self.id,
            quantity: self.quantity,
            deckId: self.$deck.id,
            cardId: self.$card.id,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt
        )
    }
}

extension DeckSideboardCard {
    struct CreateRequest: Content {
        var quantity: Int = 1
        var deckId: UUID
        var cardId: UUID
    }

    struct UpdateRequest: Content {
        var quantity: Int?
        var deckId: UUID??
        var cardId: UUID??
    }
}